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
import com.adso.cheng.utils.EmailUtil;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect("profile.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("verifyEmailOtp".equals(action)) {
            String inputOtp = request.getParameter("otp");
            String sessionOtp = (String) session.getAttribute("profileOtp");
            User pendingProfile = (User) session.getAttribute("pendingProfileUpdate");

            if (sessionOtp != null && sessionOtp.equals(inputOtp) && pendingProfile != null) {
                // Apply changes
                boolean success = userDAO.updateUser(pendingProfile);
                if (success) {
                    // Update current session user
                    currentUser.setFullName(pendingProfile.getFullName());
                    currentUser.setDocumentId(pendingProfile.getDocumentId());
                    currentUser.setEmail(pendingProfile.getEmail());
                    
                    session.removeAttribute("profileOtp");
                    session.removeAttribute("pendingProfileUpdate");
                    
                    response.sendRedirect("profile.jsp?msg=Perfil+y+correo+actualizados+con+exito");
                } else {
                    response.sendRedirect("profile.jsp?msg=Error+al+guardar+en+base+de+datos");
                }
            } else {
                request.setAttribute("error", "Código de seguridad incorrecto.");
                request.getRequestDispatcher("verify_email.jsp").forward(request, response);
            }
            return;
        } 
        
        if ("cancelUpdate".equals(action)) {
            session.removeAttribute("profileOtp");
            session.removeAttribute("pendingProfileUpdate");
            response.sendRedirect("profile.jsp");
            return;
        }

        // Direct Form Submission (Profile Update)
        String fullName = request.getParameter("fullName");
        String documentId = request.getParameter("documentId");
        String newEmail = request.getParameter("email");

        if (fullName == null || documentId == null || newEmail == null) {
            response.sendRedirect("profile.jsp?msg=Datos+invalidos");
            return;
        }

        if (!currentUser.getEmail().equals(newEmail)) {
            // Email changed - require OTP
            User pendingProfile = new User();
            pendingProfile.setId(currentUser.getId());
            pendingProfile.setFullName(fullName);
            pendingProfile.setDocumentId(documentId);
            pendingProfile.setEmail(newEmail);
            
            session.setAttribute("pendingProfileUpdate", pendingProfile);
            
            SecureRandom random = new SecureRandom();
            int otp = 100000 + random.nextInt(900000);
            session.setAttribute("profileOtp", String.valueOf(otp));
            
            try {
                EmailUtil.sendOtpEmail(newEmail, String.valueOf(otp));
                System.out.println("OTP de cambio de correo enviado a: " + newEmail);
            } catch (Exception e) {
                e.printStackTrace();
            }
            
            response.sendRedirect("verify_email.jsp");
        } else {
            // Email not changed - direct update
            currentUser.setFullName(fullName);
            currentUser.setDocumentId(documentId);
            
            boolean success = userDAO.updateUser(currentUser);
            if (success) {
                response.sendRedirect("profile.jsp?msg=Perfil+actualizado+exitosamente");
            } else {
                response.sendRedirect("profile.jsp?msg=Error+al+actualizar+el+perfil");
            }
        }
    }
}
