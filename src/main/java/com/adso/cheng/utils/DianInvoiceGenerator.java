package com.adso.cheng.utils;

import com.google.gson.Gson;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class DianInvoiceGenerator {

    public static int generateInvoice(int customerId, String customerDocument, String customerName, String customerEmail, List<Map<String, Object>> cartItems, double shipping, int orderId) throws Exception {
        int invoiceId = -1;
        try (Connection conn = DbConnection.getConnection()) {
            
            // 1. Calculate totals
            double subtotal = 0;
            for (Map<String, Object> item : cartItems) {
                double price = (Double) item.get("price");
                int qty = ((Double) item.get("qty")).intValue();
                subtotal += (price * qty);
            }
            subtotal += shipping;
            
            // DIAN Simulation: Subtotal is the base amount without VAT. VAT is 19%
            // So if total is 1000, subtotal = 1000 / 1.19 = 840.33, tax = 159.67
            double totalAmount = subtotal;
            double baseSubtotal = totalAmount / 1.19;
            double taxAmount = totalAmount - baseSubtotal;
            
            // 2. Generate Invoice Number (Sequential Simulation)
            String invoiceNumber = "SETT-" + (1000 + (int)(Math.random() * 9000));
            
            // 3. Generate Simulated CUFE
            String rawCufe = invoiceNumber + customerDocument + totalAmount + UUID.randomUUID().toString();
            String cufe = generateSha384(rawCufe);
            
            // 4. Serialize items
            Gson gson = new Gson();
            String itemsJson = gson.toJson(cartItems);
            
            // 5. Insert into dian_invoices
            String sql = "INSERT INTO dian_invoices (invoice_number, cufe, customer_document, customer_name, customer_email, subtotal, tax_amount, total_amount, order_id, items_json) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
                stmt.setString(1, invoiceNumber);
                stmt.setString(2, cufe);
                stmt.setString(3, customerDocument != null ? customerDocument : "222222222222"); // Consumidor final
                stmt.setString(4, customerName != null ? customerName : "Consumidor Final");
                stmt.setString(5, customerEmail != null ? customerEmail : "no-reply@asama.com");
                stmt.setDouble(6, baseSubtotal);
                stmt.setDouble(7, taxAmount);
                stmt.setDouble(8, totalAmount);
                if (orderId > 0) {
                    stmt.setInt(9, orderId);
                } else {
                    stmt.setNull(9, java.sql.Types.INTEGER);
                }
                stmt.setString(10, itemsJson);
                
                stmt.executeUpdate();
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    invoiceId = rs.getInt(1);
                }
            }
        }
        return invoiceId;
    }
    
    private static String generateSha384(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-384");
            byte[] messageDigest = md.digest(input.getBytes());
            StringBuilder hexString = new StringBuilder();
            for (byte b : messageDigest) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            return UUID.randomUUID().toString().replace("-", "");
        }
    }
}
