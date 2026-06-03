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
import com.google.gson.Gson;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/faceData")
public class FaceDataServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();
        
        List<Map<String, String>> employees = new ArrayList<>();
        String sql = "SELECT id, full_name, photo_path, barcode FROM users WHERE role_id != 5 AND photo_path IS NOT NULL";
        
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, String> emp = new HashMap<>();
                emp.put("id", String.valueOf(rs.getInt("id")));
                emp.put("name", rs.getString("full_name"));
                emp.put("photoUrl", rs.getString("photo_path"));
                emp.put("barcode", rs.getString("barcode"));
                employees.add(emp);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            out.print("{\"error\":\"Database error\"}");
            return;
        }
        
        out.print(gson.toJson(employees));
    }
}
