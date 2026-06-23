package com.adso.cheng.controllers;

import com.adso.cheng.dao.OnlineOrderDAO;
import com.adso.cheng.models.OnlineOrder;
import com.adso.cheng.models.User;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet("/api/notifications")
public class OrderNotificationServlet extends HttpServlet {

    private final OnlineOrderDAO orderDAO = new OnlineOrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 3 && user.getRoleId() != 4)) {
            out.print("{\"error\": \"Unauthorized\", \"unreadCount\": 0}");
            return;
        }

        try {
            List<OnlineOrder> unreadOrders = orderDAO.getUnreadOrdersByRole(user.getRoleId());
            
            // Serializar manualmente con hora en Colombia (UTC-5)
            ZoneId bogota = ZoneId.of("America/Bogota");
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
            JsonArray ordersArray = new JsonArray();
            Gson gson = new Gson();
            
            for (OnlineOrder o : unreadOrders) {
                JsonObject obj = new JsonObject();
                obj.addProperty("id", o.getId());
                obj.addProperty("customerName", o.getCustomerName());
                obj.addProperty("totalAmount", o.getTotalAmount());
                obj.addProperty("status", o.getStatus());
                String horaFormateada = o.getCreatedAt() != null
                    ? o.getCreatedAt().toInstant().atZone(bogota).format(formatter)
                    : "";
                obj.addProperty("createdAtFormatted", horaFormateada);
                ordersArray.add(obj);
            }
            
            out.print("{\"unreadCount\": " + unreadOrders.size() + ", \"orders\": " + ordersArray.toString() + "}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\": \"Internal Server Error\", \"unreadCount\": 0}");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 3 && user.getRoleId() != 4)) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String action = request.getParameter("action");
        if ("markAllRead".equals(action)) {
            orderDAO.markAllAsRead(user.getRoleId());
            response.setStatus(HttpServletResponse.SC_OK);
        } else if ("updateStatus".equals(action)) {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            String status = request.getParameter("status");
            orderDAO.updateStatus(orderId, status);
            response.setStatus(HttpServletResponse.SC_OK);
        } else if ("markRead".equals(action)) {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            orderDAO.markAsRead(orderId, user.getRoleId());
            response.setStatus(HttpServletResponse.SC_OK);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}
