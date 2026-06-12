package com.adso.cheng.controllers;

import com.adso.cheng.models.User;
import com.adso.cheng.utils.AuditLogger;
import com.adso.cheng.utils.DbConnection;
import com.adso.cheng.utils.UploadUtil;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.itextpdf.text.Document;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.UUID;

@WebServlet("/adminRequests")
public class AdminRequestsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || user.getRoleId() != 1) { // Solo admin
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        if ("list".equals(action)) {
            JsonArray array = new JsonArray();
            try (Connection conn = DbConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(
                     "SELECT r.*, p.name as product_name, u.full_name as customer_name, s.total_price " +
                     "FROM post_sale_requests r " +
                     "JOIN sales s ON r.sale_id = s.id " +
                     "JOIN products p ON s.product_id = p.id " +
                     "JOIN users u ON s.customer_id = u.id " +
                     "ORDER BY r.created_at DESC"
                 );
                 ResultSet rs = stmt.executeQuery()) {
                
                while (rs.next()) {
                    JsonObject obj = new JsonObject();
                    obj.addProperty("id", rs.getInt("id"));
                    obj.addProperty("created_at", rs.getTimestamp("created_at").toString().substring(0, 16));
                    obj.addProperty("customer_name", rs.getString("customer_name"));
                    obj.addProperty("product_name", rs.getString("product_name"));
                    obj.addProperty("request_type", rs.getString("request_type"));
                    obj.addProperty("status", rs.getString("status"));
                    obj.addProperty("damage", rs.getString("damage"));
                    obj.addProperty("description", rs.getString("description"));
                    obj.addProperty("image_path", rs.getString("image_path"));
                    obj.addProperty("admin_reply", rs.getString("admin_reply"));
                    obj.addProperty("total_price", rs.getDouble("total_price"));
                    array.add(obj);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            out.print(new Gson().toJson(array));
            out.flush();
        } else {
            request.getRequestDispatcher("admin_requests.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || user.getRoleId() != 1) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            int reqId = Integer.parseInt(request.getParameter("request_id"));
            String status = request.getParameter("status");
            String adminReply = request.getParameter("admin_reply");

            try (Connection conn = DbConnection.getConnection()) {
                // Update request
                try (PreparedStatement updateStmt = conn.prepareStatement("UPDATE post_sale_requests SET status = ?, admin_reply = ? WHERE id = ?")) {
                    updateStmt.setString(1, status);
                    updateStmt.setString(2, adminReply);
                    updateStmt.setInt(3, reqId);
                    updateStmt.executeUpdate();
                }

                // If approved, generate PDF report
                if ("APROBADA".equals(status)) {
                    // Get request info for PDF
                    String productName = "";
                    String reqType = "";
                    double price = 0.0;
                    String customer = "";
                    try (PreparedStatement infoStmt = conn.prepareStatement(
                            "SELECT p.name, r.request_type, s.total_price, u.full_name " +
                            "FROM post_sale_requests r " +
                            "JOIN sales s ON r.sale_id = s.id " +
                            "JOIN products p ON s.product_id = p.id " +
                            "JOIN users u ON s.customer_id = u.id " +
                            "WHERE r.id = ?")) {
                        infoStmt.setInt(1, reqId);
                        try (ResultSet rs = infoStmt.executeQuery()) {
                            if (rs.next()) {
                                productName = rs.getString("name");
                                reqType = rs.getString("request_type");
                                price = rs.getDouble("total_price");
                                customer = rs.getString("full_name");
                            }
                        }
                    }

                    String pdfPath = generatePdfReport(request, reqId, productName, reqType, price, customer);
                    
                    // Insert into accountant_reports
                    try (PreparedStatement insertStmt = conn.prepareStatement(
                            "INSERT INTO accountant_reports (request_id, pdf_path) VALUES (?, ?)")) {
                        insertStmt.setInt(1, reqId);
                        insertStmt.setString(2, pdfPath);
                        insertStmt.executeUpdate();
                    }
                }
            }
            
            AuditLogger.logAction(user.getId(), "GARANTIAS", "Resolución de Solicitud", "Cambió la solicitud ID: " + reqId + " a estado: " + status);

            response.sendRedirect("adminRequests?msg=Resolucion%20guardada%20correctamente.");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminRequests?msg=Error:%20" + e.getMessage());
        }
    }

    private String generatePdfReport(HttpServletRequest request, int reqId, String productName, String reqType, double price, String customer) throws Exception {
        String baseWebapp = UploadUtil.getSourceWebappPath(request);
        String reportDir = baseWebapp + File.separator + "resources" + File.separator + "reportes";
        File dir = new File(reportDir);
        if (!dir.exists()) dir.mkdirs();

        String fileName = "Reporte_" + reqType + "_" + reqId + "_" + UUID.randomUUID().toString().substring(0, 5) + ".pdf";
        String fullPath = reportDir + File.separator + fileName;

        Document document = new Document();
        PdfWriter.getInstance(document, new FileOutputStream(fullPath));
        document.open();

        Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18);
        Font boldFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12);
        Font normalFont = FontFactory.getFont(FontFactory.HELVETICA, 12);

        Paragraph title = new Paragraph("Reporte de " + reqType + " Aprobada", titleFont);
        title.setAlignment(Element.ALIGN_CENTER);
        title.setSpacingAfter(20);
        document.add(title);

        document.add(new Paragraph("ID Solicitud: " + reqId, normalFont));
        document.add(new Paragraph("Cliente: " + customer, normalFont));
        document.add(new Paragraph("Producto Devuelto/Reclamado: " + productName, normalFont));
        document.add(new Paragraph("Valor del Producto: $" + String.format("%.2f", price), boldFont));
        
        Paragraph footer = new Paragraph("\nEste documento es autogenerado por el sistema Asama Moto Parts para fines contables.", normalFont);
        footer.setSpacingBefore(30);
        document.add(footer);

        document.close();

        return "resources/reportes/" + fileName;
    }
}
