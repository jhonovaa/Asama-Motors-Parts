package com.adso.cheng.controllers;

import com.adso.cheng.dao.UserDAO;
import com.adso.cheng.models.User;
import com.adso.cheng.utils.EmailUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.UUID;

@WebServlet("/password-reset")
public class PasswordResetServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String token = request.getParameter("token");
        
        if (token != null && !token.isEmpty()) {
            User user = userDAO.getUserByResetToken(token);
            if (user != null) {
                // Token is valid
                request.setAttribute("token", token);
                request.getRequestDispatcher("reset_password.jsp").forward(request, response);
                return;
            } else {
                request.setAttribute("error", "El enlace de recuperación es inválido o ha expirado.");
                request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
                return;
            }
        }
        
        // No token provided, show forgot password page
        request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("requestReset".equals(action)) {
            String email = request.getParameter("email");
            User user = userDAO.getUserByEmail(email);

            if (user != null) {
                String token = UUID.randomUUID().toString();
                // Expira en 15 minutos
                Timestamp expiry = new Timestamp(System.currentTimeMillis() + (15 * 60 * 1000));
                
                if (userDAO.savePasswordResetToken(email, token, expiry)) {
                    try {
                        String appUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
                        String resetLink = appUrl + "/password-reset?token=" + token;
                        EmailUtil.sendPasswordResetEmail(email, resetLink);
                        
                        String encodedMsg = java.net.URLEncoder.encode("Se han enviado las instrucciones de recuperación a tu correo electrónico.", "UTF-8");
                        response.sendRedirect("login.jsp?msg=" + encodedMsg);
                        return;
                    } catch (Exception e) {
                        e.printStackTrace();
                        request.setAttribute("error", "Ocurrió un error al enviar el correo. Intenta de nuevo.");
                    }
                } else {
                    request.setAttribute("error", "Error interno al generar el enlace de recuperación.");
                }
            } else {
                // Por seguridad, siempre decimos que se envió para no revelar qué correos existen
                String encodedMsg = java.net.URLEncoder.encode("Si el correo existe en nuestro sistema, recibirás las instrucciones en breve.", "UTF-8");
                response.sendRedirect("login.jsp?msg=" + encodedMsg);
                return;
            }
            request.getRequestDispatcher("forgot_password.jsp").forward(request, response);

        } else if ("performReset".equals(action)) {
            String token = request.getParameter("token");
            String newPassword = request.getParameter("new_password");
            String confirmPassword = request.getParameter("confirm_password");

            if (newPassword == null || !newPassword.equals(confirmPassword)) {
                request.setAttribute("error", "Las contraseñas no coinciden.");
                request.setAttribute("token", token);
                request.getRequestDispatcher("reset_password.jsp").forward(request, response);
                return;
            }

            User user = userDAO.getUserByResetToken(token);
            if (user != null) {
                if (userDAO.updatePasswordAndClearToken(user.getId(), newPassword)) {
                    String encodedMsg = java.net.URLEncoder.encode("Tu contraseña ha sido actualizada con éxito. Ya puedes iniciar sesión.", "UTF-8");
                    response.sendRedirect("login.jsp?msg=" + encodedMsg);
                } else {
                    request.setAttribute("error", "Ocurrió un error al actualizar la contraseña.");
                    request.setAttribute("token", token);
                    request.getRequestDispatcher("reset_password.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("error", "El enlace de recuperación es inválido o ha expirado.");
                request.getRequestDispatcher("forgot_password.jsp").forward(request, response);
            }
        }
    }
}
