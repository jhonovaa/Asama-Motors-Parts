package com.adso.cheng.controllers;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;

import com.adso.cheng.dao.ProductDAO;
import com.adso.cheng.models.Product;
import com.adso.cheng.models.User;
import com.adso.cheng.utils.DbConnection;
import com.google.gson.Gson;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/cashier")
public class CashierServlet extends HttpServlet {
    private ProductDAO productDAO = new ProductDAO();
    private com.adso.cheng.dao.MaintenanceDAO maintenanceDAO = new com.adso.cheng.dao.MaintenanceDAO();
    private Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 4)) {
            response.sendRedirect("login");
            return;
        }

        request.setAttribute("completedJobs", maintenanceDAO.getCompletedUnpaidJobs());
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

                com.adso.cheng.utils.AuditLogger.logAction(user.getId(), "VENTAS", "Venta Procesada en Tienda", "Vendió cantidad: " + qty + " del producto ID: " + productId + " por un total de $" + total);
                
                out.print("{\"success\": true, \"invoiceId\": " + invoiceId + "}");
            } catch (Exception e) {
                e.printStackTrace();
                out.print("{\"error\": \"Error processing payment\"}");
            }
        } else if ("payCart".equals(action)) {
            String cartData = request.getParameter("cartData");
            String customerEmail = request.getParameter("customerEmail");
            
            try {
                java.util.List<java.util.Map<String, Object>> cart = gson.fromJson(cartData, new com.google.gson.reflect.TypeToken<java.util.List<java.util.Map<String, Object>>>() {}.getType());
                double total = 0.0;
                
                com.adso.cheng.dao.UserDAO userDAO = new com.adso.cheng.dao.UserDAO();
                User customer = null;
                boolean isRegistered = false;
                int customerId = -1;
                String customerName = "Consumidor Final";
                String customerDoc = "222222222222";
                
                if (customerEmail != null && !customerEmail.trim().isEmpty()) {
                    customer = userDAO.getUserByEmail(customerEmail.trim());
                    if (customer != null) {
                        isRegistered = true;
                        customerId = customer.getId();
                        customerName = customer.getFullName();
                        customerDoc = customer.getDocumentId();
                    } else {
                        customerName = customerEmail.trim(); // Just for the email greeting
                    }
                }
                
                try (Connection conn = DbConnection.getConnection()) {
                    conn.setAutoCommit(false);
                    String sql = "INSERT INTO sales (customer_id, cashier_id, product_id, quantity, total_price) VALUES (?, ?, ?, ?, ?)";
                    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                        for (java.util.Map<String, Object> item : cart) {
                            int productId = ((Double) item.get("id")).intValue();
                            int qty = ((Double) item.get("qty")).intValue();
                            double price = (Double) item.get("price");
                            double subtotal = price * qty;
                            total += subtotal;
                            
                            if (customerId != -1) {
                                stmt.setInt(1, customerId);
                            } else {
                                stmt.setNull(1, java.sql.Types.INTEGER);
                            }
                            stmt.setInt(2, user.getId());
                            stmt.setInt(3, productId);
                            stmt.setInt(4, qty);
                            stmt.setDouble(5, subtotal);
                            stmt.addBatch();
                            
                            try (PreparedStatement stockStmt = conn.prepareStatement("UPDATE products SET stock = stock - ? WHERE id = ?")) {
                                stockStmt.setInt(1, qty);
                                stockStmt.setInt(2, productId);
                                stockStmt.executeUpdate();
                            }
                        }
                        stmt.executeBatch();
                    }
                    conn.commit();
                }
                
                int invoiceId = com.adso.cheng.utils.DianInvoiceGenerator.generateInvoice(
                    customerId,
                    customerDoc,
                    customerName,
                    customerEmail != null && !customerEmail.trim().isEmpty() ? customerEmail.trim() : "no-reply@asama.com",
                    cart,
                    0.0,
                    -1
                );
                
                if (customerEmail != null && !customerEmail.trim().isEmpty()) {
                    try {
                        com.adso.cheng.utils.EmailUtil.sendPurchaseInvoiceEmail(
                            customerEmail.trim(), 
                            customerName, 
                            cart, 
                            total, 
                            isRegistered, 
                            false, 
                            "https://asamamotors.lat/"
                        );
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                
                com.adso.cheng.utils.AuditLogger.logAction(user.getId(), "VENTAS", "Venta POS Multiple", "Vendió carrito con total $" + total);
                
                out.print("{\"success\": true, \"invoiceId\": " + invoiceId + ", \"isRegistered\": " + isRegistered + ", \"hasEmail\": " + (customerEmail != null && !customerEmail.trim().isEmpty()) + "}");
                
            } catch (Exception e) {
                e.printStackTrace();
                out.print("{\"error\": \"Error processing cart payment\"}");
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
                
                // 3. Podio de Dias del Mes
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
        } else if ("payMaintenance".equals(action)) {
            int jobId = Integer.parseInt(request.getParameter("jobId"));
            int customerId = Integer.parseInt(request.getParameter("customerId"));
            String customerDocument = request.getParameter("customerDocument");
            String customerName = request.getParameter("customerName");
            String customerEmail = request.getParameter("customerEmail");
            double totalCost = Double.parseDouble(request.getParameter("cost"));
            String description = request.getParameter("description");
            String plate = request.getParameter("plate");
            
            java.util.List<java.util.Map<String, Object>> parts = maintenanceDAO.getJobParts(jobId);
            java.util.List<java.util.Map<String, Object>> cart = new java.util.ArrayList<>();
            
            double partsTotal = 0;
            for(java.util.Map<String, Object> p : parts) {
                java.util.Map<String, Object> item = new java.util.HashMap<>();
                item.put("id", (double)(Integer)p.get("productId"));
                item.put("name", "Repuesto: " + p.get("name") + " (" + p.get("reason") + ")");
                int qty = (Integer)p.get("quantity");
                item.put("qty", (double)qty);
                double laborPerItem = ((Double)p.get("laborCost")) / qty;
                double priceWithLabor = ((Double)p.get("price")) + laborPerItem;
                item.put("price", priceWithLabor);
                cart.add(item);
                partsTotal += priceWithLabor * qty;
            }
            
            if (totalCost - partsTotal > 0.01) {
                java.util.Map<String, Object> serviceItem = new java.util.HashMap<>();
                serviceItem.put("id", 0.0);
                serviceItem.put("name", "Servicio Taller: " + description + " (Moto " + plate + ")");
                serviceItem.put("qty", 1.0);
                serviceItem.put("price", totalCost - partsTotal);
                cart.add(serviceItem);
            }
            
            int invoiceId = -1;
            try {
                invoiceId = com.adso.cheng.utils.DianInvoiceGenerator.generateInvoice(
                    customerId, customerDocument != null ? customerDocument : "222222222222", customerName, customerEmail != null ? customerEmail : "no-reply@asama.com", cart, 0.0, -1
                );
                maintenanceDAO.markJobAsPaid(jobId);
                com.adso.cheng.utils.AuditLogger.logAction(user.getId(), "CAJA", "Cobro Taller", "Cobró orden de taller ID: " + jobId + " por $" + totalCost);
                out.print("{\"success\": true, \"invoiceId\": " + invoiceId + "}");
            } catch (Exception e) {
                e.printStackTrace();
                out.print("{\"error\": \"Error generando factura\"}");
            }
        }
    }
}
