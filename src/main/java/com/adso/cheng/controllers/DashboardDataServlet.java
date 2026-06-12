package com.adso.cheng.controllers;

import com.adso.cheng.models.User;
import com.adso.cheng.utils.DbConnection;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/dashboardData")
public class DashboardDataServlet extends HttpServlet {
    private Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        // Security Check: Only Admin (1)
        if (user == null || user.getRoleId() != 1) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String action = request.getParameter("action");
        if ("topCashier".equals(action)) {
            out.print(gson.toJson(getTopCashier()));
        } else if ("graphData".equals(action)) {
            out.print(gson.toJson(getGraphData()));
        } else if ("cashierHistory".equals(action)) {
            out.print(gson.toJson(getCashierHistory()));
        } else if ("onlineHistory".equals(action)) {
            out.print(gson.toJson(getOnlineHistory()));
        } else if ("dailySummary".equals(action)) {
            out.print(gson.toJson(getDailySummary()));
        } else if ("dailySalesDetails".equals(action)) {
            String date = request.getParameter("date");
            out.print(gson.toJson(getDailySalesDetails(date)));
        } else {
            out.print("{\"error\": \"Invalid action\"}");
        }
        out.flush();
    }
    
    private Map<String, Object> getTopCashier() {
        Map<String, Object> result = new HashMap<>();
        String sql = "SELECT u.full_name, COUNT(s.id) as total_sales, SUM(s.quantity) as total_products, SUM(s.total_price) as total_revenue " +
                     "FROM sales s " +
                     "JOIN users u ON s.cashier_id = u.id " +
                     "WHERE s.sale_date >= CURRENT_DATE - INTERVAL '30 days' " +
                     "GROUP BY u.id " +
                     "ORDER BY total_sales DESC LIMIT 1";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                result.put("name", rs.getString("full_name"));
                result.put("total_sales", rs.getInt("total_sales"));
                result.put("total_products", rs.getInt("total_products"));
                result.put("total_revenue", rs.getDouble("total_revenue"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    private Map<String, Object> getGraphData() {
        Map<String, Object> result = new HashMap<>();
        List<String> labels = new ArrayList<>();
        List<Integer> entered = new ArrayList<>();
        List<Integer> sold = new ArrayList<>();
        
        String sql = "WITH dates AS ( " +
                     "  SELECT generate_series(CURRENT_DATE - INTERVAL '29 days', CURRENT_DATE, '1 day'::interval)::date as d " +
                     "), " +
                     "sales_daily AS ( " +
                     "  SELECT DATE(sale_date) as d, SUM(quantity) as qty FROM sales GROUP BY DATE(sale_date) " +
                     "), " +
                     "entered_daily AS ( " +
                     "  SELECT DATE(created_at) as d, SUM(quantity_added) as qty FROM inventory_logs GROUP BY DATE(created_at) " +
                     ") " +
                     "SELECT dates.d, COALESCE(e.qty, 0) as entered_qty, COALESCE(s.qty, 0) as sold_qty " +
                     "FROM dates " +
                     "LEFT JOIN entered_daily e ON dates.d = e.d " +
                     "LEFT JOIN sales_daily s ON dates.d = s.d " +
                     "ORDER BY dates.d";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                labels.add(rs.getDate("d").toString());
                entered.add(rs.getInt("entered_qty"));
                sold.add(rs.getInt("sold_qty"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        result.put("labels", labels);
        result.put("entered", entered);
        result.put("sold", sold);
        return result;
    }
    
    private List<Map<String, Object>> getCashierHistory() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT u.full_name, DATE(s.sale_date) as sale_date, COUNT(s.id) as sales_count, SUM(s.total_price) as revenue " +
                     "FROM sales s " +
                     "JOIN users u ON s.cashier_id = u.id " +
                     "WHERE s.sale_date >= CURRENT_DATE - INTERVAL '30 days' " +
                     "GROUP BY u.id, DATE(s.sale_date) " +
                     "ORDER BY sale_date DESC, revenue DESC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("cashier", rs.getString("full_name"));
                row.put("date", rs.getDate("sale_date").toString());
                row.put("sales_count", rs.getInt("sales_count"));
                row.put("revenue", rs.getDouble("revenue"));
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    private List<Map<String, Object>> getOnlineHistory() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT DATE(s.sale_date) as sale_date, COUNT(s.id) as sales_count, SUM(s.total_price) as revenue " +
                     "FROM sales s " +
                     "WHERE s.sale_date >= CURRENT_DATE - INTERVAL '30 days' AND (s.sale_type = 'ONLINE' OR s.cashier_id IS NULL) " +
                     "GROUP BY DATE(s.sale_date) " +
                     "ORDER BY sale_date DESC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("date", rs.getDate("sale_date").toString());
                row.put("sales_count", rs.getInt("sales_count"));
                row.put("revenue", rs.getDouble("revenue"));
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private List<Map<String, Object>> getDailySummary() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT DATE(s.sale_date) as sale_date, " +
                     "SUM(CASE WHEN s.sale_type = 'ONLINE' OR s.cashier_id IS NULL THEN 1 ELSE 0 END) as online_count, " +
                     "SUM(CASE WHEN s.sale_type = 'ONLINE' OR s.cashier_id IS NULL THEN s.total_price ELSE 0 END) as online_revenue, " +
                     "SUM(CASE WHEN s.sale_type != 'ONLINE' AND s.cashier_id IS NOT NULL THEN 1 ELSE 0 END) as cashier_count, " +
                     "SUM(CASE WHEN s.sale_type != 'ONLINE' AND s.cashier_id IS NOT NULL THEN s.total_price ELSE 0 END) as cashier_revenue, " +
                     "SUM(s.total_price) as total_revenue " +
                     "FROM sales s " +
                     "WHERE s.sale_date >= CURRENT_DATE - INTERVAL '30 days' " +
                     "GROUP BY DATE(s.sale_date) " +
                     "ORDER BY sale_date DESC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("date", rs.getDate("sale_date").toString());
                row.put("online_count", rs.getInt("online_count"));
                row.put("online_revenue", rs.getDouble("online_revenue"));
                row.put("cashier_count", rs.getInt("cashier_count"));
                row.put("cashier_revenue", rs.getDouble("cashier_revenue"));
                row.put("total_revenue", rs.getDouble("total_revenue"));
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private List<Map<String, Object>> getDailySalesDetails(String dateStr) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (dateStr == null || dateStr.trim().isEmpty()) return list;
        String sql = "SELECT s.sale_date, s.sale_type, u.full_name as cashier_name, p.name as product_name, s.quantity, s.total_price " +
                     "FROM sales s " +
                     "JOIN products p ON s.product_id = p.id " +
                     "LEFT JOIN users u ON s.cashier_id = u.id " +
                     "WHERE DATE(s.sale_date) = ?::date " +
                     "ORDER BY s.sale_date ASC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, dateStr);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("sale_date", rs.getTimestamp("sale_date").toString());
                    row.put("sale_type", rs.getString("sale_type"));
                    row.put("cashier_name", rs.getString("cashier_name"));
                    row.put("product_name", rs.getString("product_name"));
                    row.put("quantity", rs.getInt("quantity"));
                    row.put("total_price", rs.getDouble("total_price"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
