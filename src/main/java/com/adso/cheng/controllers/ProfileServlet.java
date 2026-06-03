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
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String fullName = request.getParameter("fullName");
        String documentId = request.getParameter("documentId");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        String sql = "UPDATE users SET full_name = ?, document_id = ?, email = ?";
        boolean updatePass = password != null && !password.trim().isEmpty();
        if (updatePass) {
            sql += ", password = ?";
        }
        sql += " WHERE id = ?";

        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, fullName);
            stmt.setString(2, documentId);
            stmt.setString(3, email);
            int idx = 4;
            if (updatePass) {
                stmt.setString(idx++, password);
            }
            stmt.setInt(idx, user.getId());
            stmt.executeUpdate();

            // Update session
            user.setFullName(fullName);
            user.setDocumentId(documentId);
            user.setEmail(email);
            if (updatePass) user.setPassword(password);
            
            response.sendRedirect("dashboard.jsp?msg=Perfil+actualizado");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("dashboard.jsp?error=Error+al+actualizar");
        }
    }
}
