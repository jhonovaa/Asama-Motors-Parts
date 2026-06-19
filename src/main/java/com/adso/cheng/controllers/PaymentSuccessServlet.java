package com.adso.cheng.controllers;

import com.adso.cheng.utils.DbConnection;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;
import java.util.Map;

@WebServlet("/PaymentSuccessServlet")
public class PaymentSuccessServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String status = request.getParameter("status");
        String externalReference = request.getParameter("external_reference");

        if ("approved".equals(status) && externalReference != null && !externalReference.isEmpty()) {
            try {
                int orderId = Integer.parseInt(externalReference);
                completeOrder(orderId);
                // Redirigir a la vista de éxito
                response.sendRedirect("pago-exitoso.jsp?orderId=" + orderId);
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("pago-fallido.jsp?error=procesamiento");
            }
        } else {
            response.sendRedirect("pago-fallido.jsp?error=no_aprobado");
        }
    }

    private void completeOrder(int orderId) throws Exception {
        try (Connection conn = DbConnection.getConnection()) {
            conn.setAutoCommit(false);

            // Verificar estado actual
            String checkSql = "SELECT customer_id, items_json, status FROM online_orders WHERE id = ?";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setInt(1, orderId);
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next()) {
                    String currentStatus = rs.getString("status");
                    if ("COMPLETADO".equals(currentStatus)) {
                        // Ya fue procesado (quizás por un webhook o recarga de página), no hacer nada
                        return;
                    }

                    int customerId = rs.getInt("customer_id");
                    String itemsJson = rs.getString("items_json");

                    // Marcar como completado
                    String updateSql = "UPDATE online_orders SET status = 'COMPLETADO' WHERE id = ?";
                    try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                        updateStmt.setInt(1, orderId);
                        updateStmt.executeUpdate();
                    }

                    // Reducir stock y registrar en ventas
                    Gson gson = new Gson();
                    List<Map<String, Object>> cart = gson.fromJson(itemsJson, new TypeToken<List<Map<String, Object>>>(){}.getType());

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
                }
            }
            conn.commit();
        }
    }
}
