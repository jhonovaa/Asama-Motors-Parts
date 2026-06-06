package com.adso.cheng.controllers;

import com.adso.cheng.utils.DbConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/time-tracking")
public class TimeTrackingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("list".equals(action)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            StringBuilder json = new StringBuilder("[");
            String sql = "SELECT u.full_name, t.entry_time, t.exit_time FROM time_tracking t JOIN users u ON t.user_id = u.id WHERE t.date = CURRENT_DATE ORDER BY t.entry_time DESC";
            
            try (Connection conn = DbConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql);
                 ResultSet rs = stmt.executeQuery()) {
                
                boolean first = true;
                while (rs.next()) {
                    if (!first) json.append(",");
                    
                    String name = rs.getString("full_name");
                    String entry = rs.getTimestamp("entry_time") != null ? rs.getTimestamp("entry_time").toString() : "";
                    String exit = rs.getTimestamp("exit_time") != null ? rs.getTimestamp("exit_time").toString() : "";
                    
                    json.append("{")
                        .append("\"name\":\"").append(name.replace("\"", "\\\"")).append("\",")
                        .append("\"entry\":\"").append(entry).append("\",")
                        .append("\"exit\":\"").append(exit).append("\"")
                        .append("}");
                    first = false;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            json.append("]");
            
            PrintWriter out = response.getWriter();
            out.print(json.toString());
            return;
        } else if ("history_dates".equals(action)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            StringBuilder json = new StringBuilder("[");
            String sql = "SELECT DISTINCT date FROM time_tracking ORDER BY date DESC";
            
            try (Connection conn = DbConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql);
                 ResultSet rs = stmt.executeQuery()) {
                
                boolean first = true;
                while (rs.next()) {
                    if (!first) json.append(",");
                    json.append("\"").append(rs.getDate("date").toString()).append("\"");
                    first = false;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            json.append("]");
            
            PrintWriter out = response.getWriter();
            out.print(json.toString());
            return;
        } else if ("history_by_date".equals(action)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            String targetDate = request.getParameter("date");
            
            StringBuilder json = new StringBuilder("[");
            String sql = "SELECT u.full_name, t.entry_time, t.exit_time FROM time_tracking t JOIN users u ON t.user_id = u.id WHERE t.date = ?::DATE AND t.exit_time IS NOT NULL ORDER BY t.entry_time ASC";
            
            try (Connection conn = DbConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, targetDate);
                try (ResultSet rs = stmt.executeQuery()) {
                    boolean first = true;
                    while (rs.next()) {
                        if (!first) json.append(",");
                        
                        String name = rs.getString("full_name");
                        String entry = rs.getTimestamp("entry_time") != null ? rs.getTimestamp("entry_time").toString() : "";
                        String exit = rs.getTimestamp("exit_time") != null ? rs.getTimestamp("exit_time").toString() : "";
                        
                        json.append("{")
                            .append("\"name\":\"").append(name.replace("\"", "\\\"")).append("\",")
                            .append("\"entry\":\"").append(entry).append("\",")
                            .append("\"exit\":\"").append(exit).append("\"")
                            .append("}");
                        first = false;
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            json.append("]");
            
            PrintWriter out = response.getWriter();
            out.print(json.toString());
            return;
        }

        request.getRequestDispatcher("time_tracking.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String barcode = request.getParameter("barcode");
        if (barcode == null || barcode.trim().isEmpty()) {
            out.print("{\"error\": \"Código inválido\"}");
            return;
        }

        try (Connection conn = DbConnection.getConnection()) {
            // Find user by barcode
            String userSql = "SELECT id, full_name FROM users WHERE barcode = ?";
            int userId = -1;
            String userName = "";
            try (PreparedStatement uStmt = conn.prepareStatement(userSql)) {
                uStmt.setString(1, barcode);
                try (ResultSet rs = uStmt.executeQuery()) {
                    if (rs.next()) {
                        userId = rs.getInt("id");
                        userName = rs.getString("full_name");
                    } else {
                        out.print("{\"error\": \"Empleado no encontrado\"}");
                        return;
                    }
                }
            }

            // Check if there is an open shift today
            String checkSql = "SELECT id, exit_time FROM time_tracking WHERE user_id = ? AND date = CURRENT_DATE ORDER BY id DESC LIMIT 1";
            int trackingId = -1;
            boolean hasExit = false;
            try (PreparedStatement cStmt = conn.prepareStatement(checkSql)) {
                cStmt.setInt(1, userId);
                try (ResultSet rs = cStmt.executeQuery()) {
                    if (rs.next()) {
                        trackingId = rs.getInt("id");
                        hasExit = rs.getTimestamp("exit_time") != null;
                    }
                }
            }

            if (trackingId == -1 || hasExit) {
                // Register Entry
                String inSql = "INSERT INTO time_tracking (user_id, entry_time) VALUES (?, CURRENT_TIMESTAMP)";
                try (PreparedStatement inStmt = conn.prepareStatement(inSql)) {
                    inStmt.setInt(1, userId);
                    inStmt.executeUpdate();
                    out.print("{\"success\": true, \"type\": \"Entrada\", \"name\": \"" + userName + "\"}");
                }
            } else {
                // Register Exit
                String outSql = "UPDATE time_tracking SET exit_time = CURRENT_TIMESTAMP WHERE id = ?";
                try (PreparedStatement outStmt = conn.prepareStatement(outSql)) {
                    outStmt.setInt(1, trackingId);
                    outStmt.executeUpdate();
                    out.print("{\"success\": true, \"type\": \"Salida\", \"name\": \"" + userName + "\"}");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\": \"Error en el servidor\"}");
        }
    }
}
