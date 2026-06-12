package com.adso.cheng.controllers;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.adso.cheng.models.User;

@WebServlet("/verifyOtp")
public class OtpServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String sessionOtp = (String) session.getAttribute("otp");
        String inputOtp = request.getParameter("otp");
        User pendingUser = (User) session.getAttribute("pendingUser");

        if (pendingUser == null || sessionOtp == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        if (sessionOtp.equals(inputOtp)) {
            // OTP verified — grant access
            session.removeAttribute("otp");
            session.removeAttribute("pendingUser");
            session.setAttribute("user", pendingUser);
            
            // Set user as online
            try (java.sql.Connection conn = com.adso.cheng.utils.DbConnection.getConnection();
                 java.sql.PreparedStatement stmt = conn.prepareStatement("UPDATE users SET is_online = TRUE WHERE id = ?")) {
                stmt.setInt(1, pendingUser.getId());
                stmt.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
            }

            response.sendRedirect("dashboard.jsp");
        } else {
            request.setAttribute("error", "Código OTP incorrecto. Intenta de nuevo.");
            request.setAttribute("otpCode", sessionOtp); // Show again for simulation
            request.getRequestDispatcher("otp.jsp").forward(request, response);
        }
    }
}
