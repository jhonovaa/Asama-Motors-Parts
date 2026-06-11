package com.adso.cheng.controllers;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.adso.cheng.models.User;
import com.adso.cheng.utils.DbConnection;
import com.adso.cheng.utils.HashUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

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

        String fullName = request.getParameter("fullName");
        String documentId = request.getParameter("documentId");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        int roleId = Integer.parseInt(request.getParameter("roleId"));            
        
        String hashedPassword = HashUtil.sha256(password);
        
        // Auto-generate barcode based on Role prefix and Document ID
        String rolePrefix = "EMP";
        if(roleId == 1) rolePrefix = "ADM";
        else if(roleId == 2) rolePrefix = "CON";
        else if(roleId == 3) rolePrefix = "BOD";
        else if(roleId == 4) rolePrefix = "CAJ";
        else if(roleId == 6) rolePrefix = "MEC";

        String barcode = "ASAMA-" + rolePrefix + "-" + documentId;

        String sql = "INSERT INTO users (full_name, document_id, email, password, role_id, barcode, photo_path) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, fullName);
            stmt.setString(2, documentId);
            stmt.setString(3, email);
            stmt.setString(4, hashedPassword); 
            stmt.setInt(5, roleId);
            stmt.setString(6, barcode);
            
            // Temporary null for photo_path, will update after getting ID
            stmt.setString(7, null);
            
            stmt.executeUpdate();
            
            ResultSet rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                int newUserId = rs.getInt(1);
                
                // Handle file upload
                Part filePart = request.getPart("photo");
                if (filePart != null && filePart.getSize() > 0) {
                    String uploadPath = request.getServletContext().getRealPath("") + File.separator + "resources" + File.separator + "fotos" + File.separator + "empleados";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) uploadDir.mkdirs();

                    String fileName = newUserId + ".jpg"; // Save as user_id.jpg
                    filePart.write(uploadPath + File.separator + fileName);
                    
                    String photoPath = "resources/fotos/empleados/" + fileName;
                    
                    // Update user with photo path
                    try (PreparedStatement updateStmt = conn.prepareStatement("UPDATE users SET photo_path = ? WHERE id = ?")) {
                        updateStmt.setString(1, photoPath);
                        updateStmt.setInt(2, newUserId);
                        updateStmt.executeUpdate();
                    }
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("employees");
    }
    
}
