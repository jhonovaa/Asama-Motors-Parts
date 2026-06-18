package com.adso.cheng.controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.adso.cheng.models.User;
import com.adso.cheng.utils.DbConnection;

@WebServlet("/add-expense")
public class ExpenseServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 2)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String expenseType = request.getParameter("expense_type");
        String description = request.getParameter("description");
        String amountStr = request.getParameter("amount");

        if (expenseType == null || description == null || amountStr == null || expenseType.isEmpty() || description.isEmpty() || amountStr.isEmpty()) {
            response.sendRedirect("accountant.jsp?error=Faltan campos por llenar");
            return;
        }

        try {
            double amount = Double.parseDouble(amountStr);

            try (Connection conn = DbConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(
                     "INSERT INTO expenses (user_id, expense_type, description, amount) VALUES (?, ?, ?, ?)")) {
                
                stmt.setInt(1, user.getId());
                stmt.setString(2, expenseType);
                stmt.setString(3, description);
                stmt.setDouble(4, amount);
                
                stmt.executeUpdate();
                
            }
            
            response.sendRedirect("accountant.jsp?success=Egreso registrado correctamente");
        } catch (NumberFormatException e) {
            response.sendRedirect("accountant.jsp?error=Monto inválido");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("accountant.jsp?error=Error al registrar egreso");
        }
    }
}
