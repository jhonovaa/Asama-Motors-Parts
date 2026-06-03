package com.adso.cheng.controllers;

import com.adso.cheng.dao.MaintenanceDAO;
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
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/maintenance")
public class MaintenanceServlet extends HttpServlet {
    private MaintenanceDAO maintenanceDAO = new MaintenanceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // Security Check: Only Admin (1) or Mecánico (6)
        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 6)) {
            response.sendRedirect("login");
            return;
        }

        // Fetch jobs based on role
        List<Map<String, Object>> jobs;
        if (user.getRoleId() == 6) {
            jobs = maintenanceDAO.getJobsByMechanic(user.getId());
        } else {
            jobs = maintenanceDAO.getAllJobs();
        }
        request.setAttribute("jobs", jobs);

        // Fetch all motorcycles
        List<Map<String, Object>> motorcycles = maintenanceDAO.getAllMotorcycles();
        request.setAttribute("motorcycles", motorcycles);

        // Fetch mechanics (role_id = 6)
        List<Map<String, Object>> mechanics = getUsersByRole(6);
        request.setAttribute("mechanics", mechanics);

        // Fetch customers (role_id = 5)
        List<Map<String, Object>> customers = getUsersByRole(5);
        request.setAttribute("customers", customers);

        request.getRequestDispatcher("maintenance.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 6)) {
            response.sendRedirect("login");
            return;
        }

        String action = request.getParameter("action");

        if ("addMotorcycle".equals(action)) {
            int customerId = Integer.parseInt(request.getParameter("customerId"));
            String plate = request.getParameter("plate");
            String brand = request.getParameter("brand");
            String model = request.getParameter("model");
            int year = Integer.parseInt(request.getParameter("year"));
            maintenanceDAO.addMotorcycle(customerId, plate, brand, model, year);

        } else if ("addJob".equals(action)) {
            int motorcycleId = Integer.parseInt(request.getParameter("motorcycleId"));
            int mechanicId = Integer.parseInt(request.getParameter("mechanicId"));
            String description = request.getParameter("description");
            maintenanceDAO.addJob(motorcycleId, mechanicId, description);

        } else if ("updateStatus".equals(action)) {
            int jobId = Integer.parseInt(request.getParameter("jobId"));
            String status = request.getParameter("status");
            double cost = Double.parseDouble(request.getParameter("cost"));
            maintenanceDAO.updateJobStatus(jobId, status, cost);
        }

        response.sendRedirect("maintenance");
    }

    private List<Map<String, Object>> getUsersByRole(int roleId) {
        List<Map<String, Object>> users = new ArrayList<>();
        String sql = "SELECT id, full_name, email FROM users WHERE role_id = ? ORDER BY full_name";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, roleId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> u = new HashMap<>();
                    u.put("id", rs.getInt("id"));
                    u.put("fullName", rs.getString("full_name"));
                    u.put("email", rs.getString("email"));
                    users.add(u);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }
}
