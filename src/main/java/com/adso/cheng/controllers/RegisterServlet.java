package com.adso.cheng.controllers;

import com.adso.cheng.dao.UserDAO;
import com.adso.cheng.models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = new User();
        user.setFullName(request.getParameter("fullName"));
        user.setDocumentId(request.getParameter("documentId"));
        user.setEmail(request.getParameter("email"));
        user.setPassword(request.getParameter("password"));

        boolean success = userDAO.registerCustomer(user);

        if (success) {
            response.sendRedirect("login.jsp?success=1");
        } else {
            request.setAttribute("error", "No se pudo registrar la cuenta. Verifique sus datos.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}
