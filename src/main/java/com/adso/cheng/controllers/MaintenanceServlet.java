package com.adso.cheng.controllers;

import com.adso.cheng.dao.MaintenanceDAO;
import com.adso.cheng.dao.ProductDAO;
import com.adso.cheng.models.Product;
import com.adso.cheng.models.User;
import com.adso.cheng.utils.AuditLogger;
import com.adso.cheng.utils.DbConnection;
import com.google.gson.Gson;
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
    private ProductDAO productDAO = new ProductDAO();
    private Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // Security Check: Only Admin (1), Mecánico (6), or Cajero (4)
        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 6 && user.getRoleId() != 4)) {
            response.sendRedirect("login");
            return;
        }

        String action = request.getParameter("action");
        if ("getJobParts".equals(action)) {
            int jobId = Integer.parseInt(request.getParameter("jobId"));
            List<Map<String, Object>> parts = maintenanceDAO.getJobParts(jobId);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(gson.toJson(parts));
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

        // Fetch all products for the mechanics' catalog
        List<Product> inventory = productDAO.getAllProducts();
        request.setAttribute("inventory", inventory);

        request.getRequestDispatcher("maintenance.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 6 && user.getRoleId() != 4)) {
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
            
            // Add moto and get ID
            int motoId = maintenanceDAO.addMotorcycle(customerId, plate, brand, model, year);
            AuditLogger.logAction(user.getId(), "MANTENIMIENTO", "Moto Registrada", "Registró moto placa: " + plate + " para el cliente ID: " + customerId);
            
            // Auto-assign to mechanic
            String mechanicIdStr = request.getParameter("mechanicId");
            if (mechanicIdStr != null && !mechanicIdStr.isEmpty() && motoId > 0) {
                int mechanicId = Integer.parseInt(mechanicIdStr);
                maintenanceDAO.addJob(motoId, mechanicId, "Ingreso Automático de Taller");
                AuditLogger.logAction(user.getId(), "MANTENIMIENTO", "Orden Creada", "Asignó orden automáticamente al mecánico ID: " + mechanicId + " para la moto ID: " + motoId);
            }

        } else if ("addJob".equals(action)) {
            int motorcycleId = Integer.parseInt(request.getParameter("motorcycleId"));
            int mechanicId = Integer.parseInt(request.getParameter("mechanicId"));
            String description = request.getParameter("description");
            maintenanceDAO.addJob(motorcycleId, mechanicId, description);
            AuditLogger.logAction(user.getId(), "MANTENIMIENTO", "Orden Creada", "Asignó orden al mecánico ID: " + mechanicId + " para la moto ID: " + motorcycleId);

        } else if ("updateStatus".equals(action)) {
            int jobId = Integer.parseInt(request.getParameter("jobId"));
            String status = request.getParameter("status");
            double cost = Double.parseDouble(request.getParameter("cost"));
            maintenanceDAO.updateJobStatus(jobId, status, cost);
            AuditLogger.logAction(user.getId(), "MANTENIMIENTO", "Orden Actualizada", "Cambió estado a: " + status + " en orden ID: " + jobId + " con costo: $" + cost);
            
            if ("COMPLETADO".equalsIgnoreCase(status)) {
                try {
                    Map<String, Object> job = maintenanceDAO.getJobById(jobId);
                    if (job != null && job.get("customerEmail") != null) {
                        List<Map<String, Object>> parts = maintenanceDAO.getJobParts(jobId);
                        com.adso.cheng.utils.EmailUtil.sendMaintenanceFinishedEmail((String)job.get("customerEmail"), job, parts);
                        System.out.println("Correo de taller terminado enviado exitosamente a: " + job.get("customerEmail"));
                    }
                } catch (Exception e) {
                    System.err.println("Error enviando correo de taller terminado: " + e.getMessage());
                    e.printStackTrace();
                }
            }
            
        } else if ("requestPart".equals(action)) {
            int jobId = Integer.parseInt(request.getParameter("jobId"));
            int productId = Integer.parseInt(request.getParameter("productId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            String reason = request.getParameter("reason");
            double laborCost = Double.parseDouble(request.getParameter("laborCost"));
            double productPrice = Double.parseDouble(request.getParameter("productPrice"));
            
            maintenanceDAO.addJobPart(jobId, productId, quantity, reason, laborCost, productPrice);
            AuditLogger.logAction(user.getId(), "MANTENIMIENTO", "Repuesto Solicitado", "Solicitó " + quantity + " unid. producto ID: " + productId + " para orden ID: " + jobId);
        }

        // Force relative redirect to avoid Tomcat HTTP/HTTPS proxy issues
        response.setStatus(HttpServletResponse.SC_MOVED_TEMPORARILY);
        response.setHeader("Location", "maintenance");
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
