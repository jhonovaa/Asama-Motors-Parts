package com.adso.cheng.controllers;

import com.adso.cheng.dao.MotorcycleDAO;
import com.adso.cheng.models.Motorcycle;
import com.adso.cheng.models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/motorcycle")
public class MotorcycleServlet extends HttpServlet {

    private MotorcycleDAO motorcycleDAO = new MotorcycleDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || user.getRoleId() != 5) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("add".equals(action)) {
            Motorcycle m = new Motorcycle();
            m.setCustomerId(user.getId());
            m.setPlate(request.getParameter("plate"));
            m.setBrand(request.getParameter("brand"));
            m.setModel(request.getParameter("model"));
            String yearStr = request.getParameter("year");
            m.setYear(yearStr != null && !yearStr.isEmpty() ? Integer.parseInt(yearStr) : 0);

            if (motorcycleDAO.addMotorcycle(m)) {
                response.sendRedirect("dashboard.jsp?msgMoto=Moto registrada correctamente");
            } else {
                response.sendRedirect("dashboard.jsp?errorMoto=No se pudo registrar (quizas la placa ya existe)");
            }
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            motorcycleDAO.deleteMotorcycle(id, user.getId());
            response.sendRedirect("dashboard.jsp?msgMoto=Moto eliminada correctamente");
        }
    }
}
