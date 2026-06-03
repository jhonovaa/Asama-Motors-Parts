package com.adso.cheng.controllers;

import com.adso.cheng.models.User;
import com.adso.cheng.utils.DbConnection;
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
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import java.util.List;
import java.util.Map;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null || user.getRoleId() != 5) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            return;
        }

        String cartData = request.getParameter("cartData");
        if (cartData == null || cartData.isEmpty()) {
            response.sendRedirect("index.jsp");
            return;
        }

        Gson gson = new Gson();
        List<Map<String, Object>> cart = gson.fromJson(cartData, new TypeToken<List<Map<String, Object>>>(){}.getType());

        try (Connection conn = DbConnection.getConnection()) {
            conn.setAutoCommit(false); // Transaction

            String sql = "INSERT INTO sales (customer_id, cashier_id, product_id, quantity, total_price) VALUES (?, NULL, ?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                for (Map<String, Object> item : cart) {
                    int productId = ((Double) item.get("id")).intValue();
                    int qty = ((Double) item.get("qty")).intValue();
                    double price = ((Double) item.get("price"));
                    double subtotal = price * qty;

                    stmt.setInt(1, user.getId());
                    stmt.setInt(2, productId);
                    stmt.setInt(3, qty);
                    stmt.setDouble(4, subtotal);
                    stmt.addBatch();
                    
                    // Reduce stock
                    try(PreparedStatement stockStmt = conn.prepareStatement("UPDATE products SET stock = stock - ? WHERE id = ?")) {
                        stockStmt.setInt(1, qty);
                        stockStmt.setInt(2, productId);
                        stockStmt.executeUpdate();
                    }
                }
                stmt.executeBatch();
            }
            
            conn.commit();
            
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"success\": true}");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Payment processing failed");
        }
    }
}
