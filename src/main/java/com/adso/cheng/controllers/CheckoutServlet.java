package com.adso.cheng.controllers;

import com.adso.cheng.models.User;
import com.adso.cheng.utils.DbConnection;
import com.adso.cheng.utils.DianInvoiceGenerator;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
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
import java.util.List;
import java.util.Map;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (user == null || user.getRoleId() != 5) {
            out.print("{\"success\": false, \"error\": \"Unauthorized\"}");
            return;
        }

        String cartData = request.getParameter("cartData");
        if (cartData == null || cartData.isEmpty() || cartData.equals("[]")) {
            out.print("{\"success\": false, \"error\": \"El carrito está vacío\"}");
            return;
        }

        try {
            Gson gson = new Gson();
            List<Map<String, Object>> cart = gson.fromJson(cartData, new TypeToken<List<Map<String, Object>>>() {}.getType());

            // Calc subtotal
            double total = 0;
            for (Map<String, Object> item : cart) {
                double price = (Double) item.get("price");
                int qty = ((Double) item.get("qty")).intValue();
                total += price * qty;
            }

            int totalItems = cart.stream().mapToInt(i -> ((Double) i.get("qty")).intValue()).sum();
            double estWeight = (totalItems * 1.2) + 0.5;
            double shipping = 5.00 + (estWeight * 1.50);
            if (total >= 500) shipping = 0;
            if (total == 0) shipping = 0;
            double totalPay = total + shipping;

            // Save order as COMPLETADO first to get orderId
            int orderId = saveCompletedOrder(user.getId(), cartData, totalPay, shipping);

            // Generate DIAN Invoice
            int invoiceId = DianInvoiceGenerator.generateInvoice(
                    user.getId(),
                    user.getDocumentId() != null ? user.getDocumentId() : "222222222222",
                    user.getFullName(),
                    user.getEmail(),
                    cart,
                    shipping,
                    orderId
            );

            // Process Sales and Deduct Stock
            processSales(user.getId(), cart);

            // Return success and invoice ID to frontend
            out.print("{\"success\": true, \"invoiceId\": " + invoiceId + ", \"orderId\": " + orderId + "}");

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"error\": \"Error interno al procesar el pago simulado\"}");
        }
    }

    private int saveCompletedOrder(int customerId, String cartDataStr, double total, double shippingCost) throws Exception {
        int orderId = -1;
        try (Connection conn = DbConnection.getConnection()) {
            String orderSql = "INSERT INTO online_orders (customer_id, total_amount, shipping_cost, items_json, status, is_read_admin, is_read_cashier, is_read_storekeeper) VALUES (?, ?, ?, ?, 'COMPLETADO', FALSE, FALSE, FALSE)";
            try (PreparedStatement orderStmt = conn.prepareStatement(orderSql, PreparedStatement.RETURN_GENERATED_KEYS)) {
                orderStmt.setInt(1, customerId);
                orderStmt.setDouble(2, total);
                orderStmt.setDouble(3, shippingCost);
                orderStmt.setString(4, cartDataStr);
                orderStmt.executeUpdate();

                ResultSet rs = orderStmt.getGeneratedKeys();
                if (rs.next()) {
                    orderId = rs.getInt(1);
                }
            }
        }
        return orderId;
    }

    private void processSales(int customerId, List<Map<String, Object>> cart) throws Exception {
        try (Connection conn = DbConnection.getConnection()) {
            conn.setAutoCommit(false);
            String salesSql = "INSERT INTO sales (customer_id, cashier_id, product_id, quantity, total_price) VALUES (?, NULL, ?, ?, ?)";
            try (PreparedStatement salesStmt = conn.prepareStatement(salesSql)) {
                for (Map<String, Object> item : cart) {
                    int productId = ((Double) item.get("id")).intValue();
                    int qty = ((Double) item.get("qty")).intValue();
                    double price = (Double) item.get("price");
                    double subtotal = price * qty;

                    salesStmt.setInt(1, customerId);
                    salesStmt.setInt(2, productId);
                    salesStmt.setInt(3, qty);
                    salesStmt.setDouble(4, subtotal);
                    salesStmt.addBatch();

                    try (PreparedStatement stockStmt = conn.prepareStatement("UPDATE products SET stock = stock - ? WHERE id = ?")) {
                        stockStmt.setInt(1, qty);
                        stockStmt.setInt(2, productId);
                        stockStmt.executeUpdate();
                    }
                }
                salesStmt.executeBatch();
            }
            conn.commit();
        }
    }
}
