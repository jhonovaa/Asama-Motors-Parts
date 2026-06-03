package com.adso.cheng.controllers;

import com.adso.cheng.dao.ProductDAO;
import com.adso.cheng.models.Product;
import com.adso.cheng.models.User;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/productSearch")
public class ProductSearchServlet extends HttpServlet {
    private ProductDAO productDAO = new ProductDAO();
    private Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        // Security Check: Customer (5), Cashier (4), Admin (1), Bodeguero (3)
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            return;
        }

        String barcode = request.getParameter("barcode");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (barcode == null || barcode.trim().isEmpty()) {
            out.print("{\"error\": \"Barcode is required\"}");
            return;
        }

        Product product = productDAO.getProductByBarcode(barcode.trim());
        
        if (product != null) {
            out.print(gson.toJson(product));
        } else {
            out.print("{\"error\": \"Product not found\"}");
        }
        out.flush();
    }
}
