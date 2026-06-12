package com.adso.cheng.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            com.adso.cheng.models.User user = (com.adso.cheng.models.User) session.getAttribute("user");
            if (user != null) {
                try (java.sql.Connection conn = com.adso.cheng.utils.DbConnection.getConnection();
                     java.sql.PreparedStatement stmt = conn.prepareStatement("UPDATE users SET is_online = FALSE WHERE id = ?")) {
                    stmt.setInt(1, user.getId());
                    stmt.executeUpdate();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            session.invalidate();
        }
        
        String msg = request.getParameter("msg");
        String redirectUrl = "login.jsp";
        if (msg != null && !msg.trim().isEmpty()) {
            redirectUrl += "?msg=" + java.net.URLEncoder.encode(msg, "UTF-8");
        }
        
        response.sendRedirect(redirectUrl);
    }
}
