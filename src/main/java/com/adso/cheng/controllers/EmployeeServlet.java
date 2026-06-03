package com.adso.cheng.controllers;

import com.adso.cheng.utils.DbConnection;
import com.adso.cheng.utils.HashUtil;
import com.adso.cheng.models.User;
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
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/employees")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
    maxFileSize = 1024 * 1024 * 5,       // 5 MB
    maxRequestSize = 1024 * 1024 * 10    // 10 MB
)
public class EmployeeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null || user.getRoleId() != 1) { // Only Admin
            response.sendRedirect("login.jsp");
            return;
        }

        List<User> employees = new ArrayList<>();
        String sql = "SELECT u.*, r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.role_id != 5 ORDER BY u.id DESC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                User e = new User();
                e.setId(rs.getInt("id"));
                e.setFullName(rs.getString("full_name"));
                e.setDocumentId(rs.getString("document_id"));
                e.setEmail(rs.getString("email"));
                e.setRoleId(rs.getInt("role_id"));
                e.setBarcode(rs.getString("barcode"));
                try { e.setPhotoPath(rs.getString("photo_path")); } catch(Exception ignored) {}
                employees.add(e);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("employees", employees);
        request.getRequestDispatcher("employees.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || user.getRoleId() != 1) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "add";

        try (Connection conn = DbConnection.getConnection()) {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                try (PreparedStatement stmt = conn.prepareStatement("DELETE FROM users WHERE id = ?")) {
                    stmt.setInt(1, id);
                    stmt.executeUpdate();
                }
            } else if ("edit".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String fullName = request.getParameter("fullName");
                String documentId = request.getParameter("documentId");
                String email = request.getParameter("email");
                int roleId = Integer.parseInt(request.getParameter("roleId"));
                
                String barcode = documentId;
                
                String sql = "UPDATE users SET full_name=?, document_id=?, email=?, role_id=?, barcode=? WHERE id=?";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setString(1, fullName);
                    stmt.setString(2, documentId);
                    stmt.setString(3, email);
                    stmt.setInt(4, roleId);
                    stmt.setString(5, barcode);
                    stmt.setInt(6, id);
                    stmt.executeUpdate();
                }
                
                // Handle file upload for edit
                Part filePart = request.getPart("photo");
                if (filePart != null && filePart.getSize() > 0) {
                    savePhotoAndPath(filePart, id, conn, request);
                }
            } else { // add
                String fullName = request.getParameter("fullName");
                String documentId = request.getParameter("documentId");
                String email = request.getParameter("email");
                String password = request.getParameter("password");
                int roleId = Integer.parseInt(request.getParameter("roleId"));
                
                String hashedPassword = HashUtil.sha256(password);
                
                String barcode = documentId;

                String sql = "INSERT INTO users (full_name, document_id, email, password, role_id, barcode, photo_path) VALUES (?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                    stmt.setString(1, fullName);
                    stmt.setString(2, documentId);
                    stmt.setString(3, email);
                    stmt.setString(4, hashedPassword); 
                    stmt.setInt(5, roleId);
                    stmt.setString(6, barcode);
                    stmt.setString(7, null);
                    
                    stmt.executeUpdate();
                    
                    ResultSet rs = stmt.getGeneratedKeys();
                    if (rs.next()) {
                        int newUserId = rs.getInt(1);
                        Part filePart = request.getPart("photo");
                        if (filePart != null && filePart.getSize() > 0) {
                            savePhotoAndPath(filePart, newUserId, conn, request);
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("employees?msg=Error al procesar la solicitud");
            return;
        }

        String successMsg = "Empleado guardado correctamente";
        if ("delete".equals(action)) successMsg = "Empleado eliminado correctamente";
        else if ("edit".equals(action)) successMsg = "Empleado actualizado correctamente";
        
        response.sendRedirect("employees?msg=" + java.net.URLEncoder.encode(successMsg, "UTF-8"));
    }

    private void savePhotoAndPath(Part filePart, int userId, Connection conn, HttpServletRequest request) throws Exception {
        String baseUploadPath = "c:\\Users\\salaz\\Desktop\\asama\\src\\main\\webapp\\resources\\fotos\\empleados";
        File uploadDir = new File(baseUploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        String fileName = userId + ".jpg";
        filePart.write(baseUploadPath + File.separator + fileName);
        
        // Also write to deployed directory for immediate UI access
        String deployUploadPath = request.getServletContext().getRealPath("/resources/fotos/empleados");
        if (deployUploadPath != null) {
            File deployDir = new File(deployUploadPath);
            if (!deployDir.exists()) deployDir.mkdirs();
            java.nio.file.Files.copy(
                new java.io.File(baseUploadPath + File.separator + fileName).toPath(),
                new java.io.File(deployUploadPath + File.separator + fileName).toPath(),
                java.nio.file.StandardCopyOption.REPLACE_EXISTING
            );
        }

        String photoPath = "resources/fotos/empleados/" + fileName;
        
        try (PreparedStatement updateStmt = conn.prepareStatement("UPDATE users SET photo_path = ? WHERE id = ?")) {
            updateStmt.setString(1, photoPath);
            updateStmt.setInt(2, userId);
            updateStmt.executeUpdate();
        }
    }
}
