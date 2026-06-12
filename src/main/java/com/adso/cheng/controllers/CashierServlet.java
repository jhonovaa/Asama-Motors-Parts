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
            // Very simplified payment processing logic
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
                
                AuditLogger.logAction(user.getId(), "VENTAS", "Venta Procesada en Tienda", "Vendió cantidad: " + qty + " del producto ID: " + productId + " por un total de $" + total);
                
                out.print("{\"success\": true}");
            } catch (Exception e) {
                e.printStackTrace();
                out.print("{\"error\": \"Payment failed\"}");
            }
        }
    }
}
