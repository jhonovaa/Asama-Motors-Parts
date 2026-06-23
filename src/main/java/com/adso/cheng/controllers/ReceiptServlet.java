package com.adso.cheng.controllers;

import com.adso.cheng.models.User;
import com.adso.cheng.utils.DbConnection;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

@WebServlet("/api/receipt")
public class ReceiptServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            return;
        }

        String orderIdParam = request.getParameter("orderId");
        if (orderIdParam == null || orderIdParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing orderId");
            return;
        }

        int orderId = Integer.parseInt(orderIdParam);
        String customerName = "";
        double totalAmount = 0.0;
        String itemsJson = "";
        Date createdAt = null;

        try (Connection conn = DbConnection.getConnection()) {
            boolean isAdminOrCashier = user.getRoleId() == 1 || user.getRoleId() == 4;
            String sql = "SELECT o.total_amount, o.items_json, o.created_at, u.full_name " +
                         "FROM online_orders o JOIN users u ON o.customer_id = u.id " +
                         "WHERE o.id = ?";
            if (!isAdminOrCashier) {
                sql += " AND o.customer_id = ?";
            }
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, orderId);
                if (!isAdminOrCashier) {
                    stmt.setInt(2, user.getId());
                }
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    totalAmount = rs.getDouble("total_amount");
                    itemsJson = rs.getString("items_json");
                    createdAt = rs.getTimestamp("created_at");
                    customerName = rs.getString("full_name");
                } else {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found or access denied");
                    return;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
            return;
        }

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\"Recibo_AsamaMotors_" + orderId + ".pdf\"");

        try {
            Document document = new Document();
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();

            // Header
            Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 20, BaseColor.BLACK);
            Paragraph title = new Paragraph("Asama Motors Parts", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            document.add(title);
            
            document.add(new Paragraph("\n"));

            // Info
            Font boldFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12);
            Font normalFont = FontFactory.getFont(FontFactory.HELVETICA, 12);
            
            document.add(new Paragraph("Recibo de Compra", boldFont));
            document.add(new Paragraph("Número de Orden: " + orderId, normalFont));
            document.add(new Paragraph("Cliente: " + customerName, normalFont));
            
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
            document.add(new Paragraph("Fecha: " + sdf.format(createdAt != null ? createdAt : new Date()), normalFont));
            
            document.add(new Paragraph("\n"));

            // Table
            PdfPTable table = new PdfPTable(4);
            table.setWidthPercentage(100);
            table.setWidths(new float[]{4f, 1f, 2f, 2f});
            
            table.addCell(new PdfPCell(new Phrase("Producto", boldFont)));
            table.addCell(new PdfPCell(new Phrase("Cant.", boldFont)));
            table.addCell(new PdfPCell(new Phrase("Precio Unit.", boldFont)));
            table.addCell(new PdfPCell(new Phrase("Subtotal", boldFont)));

            Gson gson = new Gson();
            List<Map<String, Object>> cart = gson.fromJson(itemsJson, new TypeToken<List<Map<String, Object>>>(){}.getType());
            
            for (Map<String, Object> item : cart) {
                String name = (String) item.get("name");
                int qty = ((Double) item.get("qty")).intValue();
                double price = (Double) item.get("price");
                double subtotal = price * qty;
                
                table.addCell(new Phrase(name, normalFont));
                table.addCell(new Phrase(String.valueOf(qty), normalFont));
                table.addCell(new Phrase(String.format("$%.2f", price), normalFont));
                table.addCell(new Phrase(String.format("$%.2f", subtotal), normalFont));
            }
            
            document.add(table);
            document.add(new Paragraph("\n"));
            
            Paragraph totalP = new Paragraph(String.format("Total Pagado: $%.2f", totalAmount), boldFont);
            totalP.setAlignment(Element.ALIGN_RIGHT);
            document.add(totalP);
            
            document.add(new Paragraph("\n"));
            Paragraph footer = new Paragraph("¡Gracias por su compra en Asama Motors Parts!", FontFactory.getFont(FontFactory.HELVETICA_OBLIQUE, 10));
            footer.setAlignment(Element.ALIGN_CENTER);
            document.add(footer);

            document.close();
        } catch (DocumentException e) {
            e.printStackTrace();
            throw new ServletException("Error generating PDF", e);
        }
    }
}
