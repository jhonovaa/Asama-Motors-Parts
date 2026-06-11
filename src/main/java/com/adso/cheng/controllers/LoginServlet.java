package com.adso.cheng.controllers;

import java.io.IOException;
import java.security.SecureRandom;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.adso.cheng.dao.UserDAO;
import com.adso.cheng.models.User;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        User user = userDAO.authenticate(email, password);

        if (user != null) {
            // Validar acceso exclusivo desde la App Android
            String userAgent = request.getHeader("User-Agent");
            if (userAgent != null && userAgent.contains("ChengAndroidApp")) {
                int role = user.getRoleId();
                if (role != 1 && role != 5) {
                    request.setAttribute("error", "Acceso denegado: Esta aplicación es exclusiva para Administradores y Clientes");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                    return;
                }
            }

            HttpSession session = request.getSession();
            session.setAttribute("pendingUser", user);
            
            // Generate 6-digit OTP
            SecureRandom random = new SecureRandom();
            int otp = 100000 + random.nextInt(900000);
            session.setAttribute("otp", String.valueOf(otp));
            // Send email
            try {
                com.adso.cheng.utils.EmailUtil.sendOtpEmail(user.getEmail(), String.valueOf(otp));
            } catch (Exception e) {
                e.printStackTrace();
                // Don't block login, just warn (useful for local testing or when Gmail blocks standard passwords)
                session.setAttribute("emailWarning", "Google bloqueó el inicio de sesión. Revisa la consola (System.out) para ver el OTP.");
            }
            
            // Redirect to OTP verification page
            response.sendRedirect("otp.jsp");
        } else {
            request.setAttribute("error", "Credenciales incorrectas");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
