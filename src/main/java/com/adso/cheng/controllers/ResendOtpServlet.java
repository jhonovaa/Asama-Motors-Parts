package com.adso.cheng.controllers;

import java.io.IOException;
import java.security.SecureRandom;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.adso.cheng.models.User;
import com.adso.cheng.utils.EmailUtil;

@WebServlet("/resendOtp")
public class ResendOtpServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        User pendingUser = (User) session.getAttribute("pendingUser");
        
        if (pendingUser == null) {
            response.getWriter().write("{\"success\": false, \"message\": \"Sesión expirada\"}");
            return;
        }
        
        // Generate new 6-digit OTP
        SecureRandom random = new SecureRandom();
        int otp = 100000 + random.nextInt(900000);
        session.setAttribute("otp", String.valueOf(otp));
        
        try {
            EmailUtil.sendOtpEmail(pendingUser.getEmail(), String.valueOf(otp));
            response.getWriter().write("{\"success\": true}");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"Fallo al enviar correo\"}");
        }
    }
}
