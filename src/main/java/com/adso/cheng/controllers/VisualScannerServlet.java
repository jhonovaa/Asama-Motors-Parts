package com.adso.cheng.controllers;

import com.adso.cheng.dao.ProductDAO;
import com.adso.cheng.models.Product;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/visualSearch")
public class VisualScannerServlet extends HttpServlet {
    private ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();

        String keyword = request.getParameter("keyword");
        String brand = request.getParameter("brand");

        List<Product> allProducts = productDAO.getAllProducts();
        List<Map<String, Object>> results = new ArrayList<>();

        for (Product p : allProducts) {
            boolean matches = true;

            // Filter by keyword (searches in name, description, brand)
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = keyword.toLowerCase().trim();
                String name = p.getName() != null ? p.getName().toLowerCase() : "";
                String desc = p.getDescription() != null ? p.getDescription().toLowerCase() : "";
                String br = p.getBrand() != null ? p.getBrand().toLowerCase() : "";
                
                // Split keywords and check if ALL match
                String[] keywords = kw.split("[,\\s]+");
                boolean allMatch = true;
                boolean hasValidKeywords = false;
                for (String k : keywords) {
                    if (k.length() <= 2) continue; // ignore short words like 'de', 'el'
                    hasValidKeywords = true;
                    if (!(name.contains(k) || desc.contains(k) || br.contains(k))) {
                        allMatch = false;
                        break;
                    }
                }
                if (hasValidKeywords && !allMatch) {
                    matches = false;
                }
            }

            // Filter by brand
            if (brand != null && !brand.trim().isEmpty()) {
                String productBrand = p.getBrand() != null ? p.getBrand().toLowerCase() : "";
                if (!productBrand.contains(brand.toLowerCase().trim())) {
                    matches = false;
                }
            }

            if (matches) {
                Map<String, Object> item = new HashMap<>();
                item.put("id", p.getId());
                item.put("name", p.getName());
                item.put("description", p.getDescription());
                item.put("brand", p.getBrand());
                item.put("price", p.getPrice());
                item.put("stock", p.getStock());
                item.put("barcode", p.getBarcode());
                item.put("imageUrl", p.getImageUrl());
                results.add(item);
            }
        }

        out.print(gson.toJson(results));
    }
}
