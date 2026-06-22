package com.adso.cheng.controllers;

import com.adso.cheng.dao.ProductDAO;
import com.adso.cheng.models.Product;
import com.adso.cheng.models.User;
import com.adso.cheng.utils.AuditLogger;
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

@WebServlet("/cashier")
public class CashierServlet extends HttpServlet {
    private ProductDAO productDAO = new ProductDAO();
    private Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 4)) {
            response.sendRedirect("login");
            return;
        }

        request.getRequestDispatcher("cashier.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 4)) {
            out.print("{\"error\": \"Unauthorized\"}");
            return;
        }

        String action = request.getParameter("action");
        if ("scan".equals(action)) {
            String barcode = request.getParameter("barcode");
            Product p = productDAO.getProductByBarcode(barcode);
            if (p != null) {
                out.print(gson.toJson(p));
            } else {
                out.print("{\"error\": \"Product not found\"}");
            }
        } else if ("pay".equals(action)) {
            // Processing payment and generating invoice
            int productId = Integer.parseInt(request.getParameter("productId"));
            int qty = Integer.parseInt(request.getParameter("quantity"));
            double total = Double.parseDouble(request.getParameter("total"));

            String sql = "INSERT INTO sales (cashier_id, product_id, quantity, total_price) VALUES (?, ?, ?, ?)";
            try (Connection conn = DbConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, user.getId());
                stmt.setInt(2, productId);
                stmt.setInt(3, qty);
                stmt.setDouble(4, total);
                stmt.executeUpdate();
                
                // Generar Factura
                Product p = productDAO.getProductByBarcode(request.getParameter("barcode"));
                java.util.List<java.util.Map<String, Object>> cart = new java.util.ArrayList<>();
                java.util.Map<String, Object> item = new java.util.HashMap<>();
                item.put("id", (double)productId); // gson expects double usually for numbers
                item.put("name", p != null ? p.getName() : "Producto");
                item.put("qty", (double)qty);
                item.put("price", total / qty);
                cart.add(item);
                
                // For cashier sales, no customer is logged in yet (anonymous/cash sale)
                int invoiceId = com.adso.cheng.utils.DianInvoiceGenerator.generateInvoice(
                    -1, // No customer ID
                    "222222222222",
                    "Consumidor Final",
                    "no-reply@asama.com",
                    cart,
                    0.0, // no shipping for in-store
                    -1 // no online order id
                );

                com.adso.cheng.utils.AuditLogger.logAction(user.getId(), "VENTAS", "Venta Procesada en Tienda", "Vendi√≥ cantidad: " + qty + " del producto ID: " + productId + " por un total de $" + total);
                
                out.print("{\"success\": true, \"invoiceId\": " + invoiceId + "}");
            } catch (Exception e) {
                e.printStackTrace();
                out.print("{\"error\": \"Error processing payment\"}");
            }
        } else if ("report".equals(action)) {
            try (Connection conn = DbConnection.getConnection()) {
                
                int todayTxs = 0;
                double todayTotal = 0.0;
                int monthTxs = 0;
                double monthTotal = 0.0;
                
                // 1. Hoy
                String sqlToday = "SELECT COUNT(id) as transactions, COALESCE(SUM(total_price), 0) as total FROM sales WHERE cashier_id = ? AND CAST(sale_date AS DATE) = CURRENT_DATE";
                try (PreparedStatement stmt = conn.prepareStatement(sqlToday)) {
                    stmt.setInt(1, user.getId());
                    try (java.sql.ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) {
                            todayTxs = rs.getInt("transactions");
                            todayTotal = rs.getDouble("total");
                        }
                    }
                }
                
                // 2. Mes
                String sqlMonth = "SELECT COUNT(id) as transactions, COALESCE(SUM(total_price), 0) as total FROM sales WHERE cashier_id = ? AND EXTRACT(MONTH FROM sale_date) = EXTRACT(MONTH FROM CURRENT_DATE) AND EXTRACT(YEAR FROM sale_date) = EXTRACT(YEAR FROM CURRENT_DATE)";
                try (PreparedStatement stmt = conn.prepareStatement(sqlMonth)) {
                    stmt.setInt(1, user.getId());
                    try (java.sql.ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) {
                            monthTxs = rs.getInt("transactions");
                            monthTotal = rs.getDouble("total");
                        }
                    }
                }
                
                // 3. Podio de DÌas del Mes
                String sqlTop = "SELECT CAST(sale_date AS DATE) as day_date, COALESCE(SUM(total_price), 0) as total FROM sales WHERE cashier_id = ? AND EXTRACT(MONTH FROM sale_date) = EXTRACT(MONTH FROM CURRENT_DATE) AND EXTRACT(YEAR FROM sale_date) = EXTRACT(YEAR FROM CURRENT_DATE) GROUP BY CAST(sale_date AS DATE) ORDER BY total DESC LIMIT 3";
                            
                java.util.List<java.util.Map<String, Object>> topDays = new java.util.ArrayList<>();
                try (PreparedStatement stmt = conn.prepareStatement(sqlTop)) {
                    stmt.setInt(1, user.getId());
                    try (java.sql.ResultSet rs = stmt.executeQuery()) {
                        while (rs.next()) {
                            java.util.Map<String, Object> dayMap = new java.util.HashMap<>();
                            dayMap.put("date", rs.getDate("day_date").toString());
                            dayMap.put("total", rs.getDouble("total"));
                            topDays.add(dayMap);
                        }
                    }
                }
                
                com.google.gson.Gson gson = new com.google.gson.Gson();
                java.util.Map<String, Object> responseMap = new java.util.HashMap<>();
                responseMap.put("todayTxs", todayTxs);
                responseMap.put("todayTotal", todayTotal);
                responseMap.put("monthTxs", monthTxs);
                responseMap.put("monthTotal", monthTotal);
                responseMap.put("topDays", topDays);
                
                out.print(gson.toJson(responseMap));

            } catch (Exception e) {
                e.printStackTrace();
                out.print("{\"error\": \"Error al generar el reporte\"}");
            }
        }
    }
}
