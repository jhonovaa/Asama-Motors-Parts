package com.adso.cheng.controllers;

import com.adso.cheng.models.User;
import com.adso.cheng.utils.DbConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.ResultSet;
import java.util.UUID;

@WebServlet("/postSaleRequest")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
    maxFileSize = 1024 * 1024 * 5,       // 5 MB
    maxRequestSize = 1024 * 1024 * 10    // 10 MB
)
public class PostSaleRequestServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null || user.getRoleId() != 5) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            int saleId = Integer.parseInt(request.getParameter("sale_id"));
            String requestType = request.getParameter("request_type");
            String damage = request.getParameter("damage");
            String description = request.getParameter("description");
            
            // Validate request type
            if (!"GARANTIA".equals(requestType) && !"DEVOLUCION".equals(requestType)) {
                throw new IllegalArgumentException("Tipo de solicitud inválido.");
            }

            Part filePart = request.getPart("image");
            String imagePath = null;
            
            if (filePart != null && filePart.getSize() > 0) {
                // Determine folder based on request type
                String folderName = "GARANTIA".equals(requestType) ? "garantias" : "devoluciones";
                
                String baseWebapp = com.adso.cheng.utils.UploadUtil.getSourceWebappPath(request);
                String baseUploadPath = baseWebapp + File.separator + "resources" + File.separator + "fotos" + File.separator + folderName;
                File uploadDir = new File(baseUploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();

                // Generate a unique filename
                String fileName = UUID.randomUUID().toString() + getExtension(filePart);
                filePart.write(baseUploadPath + File.separator + fileName);
                
                // Also write to deployed directory for immediate UI access
                String deployUploadPath = request.getServletContext().getRealPath("/resources/fotos/" + folderName);
                if (deployUploadPath != null) {
                    File deployDir = new File(deployUploadPath);
                    if (!deployDir.exists()) deployDir.mkdirs();
                    java.nio.file.Files.copy(
                        new java.io.File(baseUploadPath + File.separator + fileName).toPath(),
                        new java.io.File(deployUploadPath + File.separator + fileName).toPath(),
                        java.nio.file.StandardCopyOption.REPLACE_EXISTING
                    );
                }
                
                imagePath = "resources/fotos/" + folderName + "/" + fileName;
            }

            // Insert into DB
            String sql = "INSERT INTO post_sale_requests (sale_id, request_type, damage, description, image_path) VALUES (?, ?, ?, ?, ?)";
            try (Connection conn = DbConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, saleId);
                stmt.setString(2, requestType);
                stmt.setString(3, damage);
                stmt.setString(4, description);
                stmt.setString(5, imagePath);
                stmt.executeUpdate();
            }

            response.sendRedirect("dashboard.jsp?msg=Solicitud enviada correctamente. El administrador la revisara pronto.");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("dashboard.jsp?msg=Error al enviar la solicitud: " + e.getMessage());
        }
    }
    
    private String getExtension(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        for (String token : contentDisp.split(";")) {
            if (token.trim().startsWith("filename")) {
                String filename = token.substring(token.indexOf("=") + 2, token.length() - 1);
                int lastIndex = filename.lastIndexOf(".");
                if (lastIndex == -1) return ".jpg";
                return filename.substring(lastIndex);
            }
        }
        return ".jpg";
    }
}
