package com.adso.cheng.controllers;

import com.adso.cheng.models.User;
import com.adso.cheng.utils.DbConnection;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.mercadopago.MercadoPagoConfig;
import com.mercadopago.client.preference.PreferenceBackUrlsRequest;
import com.mercadopago.client.preference.PreferenceClient;
import com.mercadopago.client.preference.PreferenceItemRequest;
import com.mercadopago.client.preference.PreferenceRequest;
import com.mercadopago.resources.preference.Preference;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private static final String MP_ACCESS_TOKEN = "TEST-8022765023928233-061712-28261b5fc7fae494536814a4f08052d7-3481175118";

    @Override
    public void init() throws ServletException {
        super.init();
        MercadoPagoConfig.setAccessToken(MP_ACCESS_TOKEN);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || user.getRoleId() != 5) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            String cartData = request.getParameter("cartData");
            if (cartData == null || cartData.isEmpty()) {
                sendError(response, "Carrito vacío");
                return;
            }

            Gson gson = new Gson();
            List<Map<String, Object>> cart = gson.fromJson(cartData, new TypeToken<List<Map<String, Object>>>(){}.getType());

            if (cart == null || cart.isEmpty()) {
                sendError(response, "Carrito vacío");
                return;
            }

            // Save order to DB as PENDIENTE
            int orderId = savePendingOrderToDb(user.getId(), cartData, cart);

            // Create Mercado Pago Preference
            List<PreferenceItemRequest> items = new ArrayList<>();
            for (Map<String, Object> item : cart) {
                String name = (String) item.get("name");
                double price = (Double) item.get("price");
                int qty = ((Double) item.get("qty")).intValue();

                PreferenceItemRequest itemRequest = PreferenceItemRequest.builder()
                        .title(name)
                        .quantity(qty)
                        .unitPrice(BigDecimal.valueOf(price))
                        .currencyId("COP")
                        .build();
                items.add(itemRequest);
            }
            // Construir back URLs para redirección después del pago
            String baseUrl = "http://localhost:8080" + request.getContextPath();

            PreferenceBackUrlsRequest backUrls = PreferenceBackUrlsRequest.builder()
                    .success(baseUrl + "/PaymentSuccessServlet")
                    .failure(baseUrl + "/pago-fallido.jsp")
                    .pending(baseUrl + "/pago-fallido.jsp")
                    .build();

            PreferenceRequest preferenceRequest = PreferenceRequest.builder()
                    .items(items)
                    .backUrls(backUrls)
                    .externalReference(String.valueOf(orderId))
                    .build();

            PreferenceClient client = new PreferenceClient();
            Preference preference = client.create(preferenceRequest);

            // Respond success with init_point and orderId
            PrintWriter out = response.getWriter();
            out.print("{\"success\": true, \"init_point\": \"" + preference.getSandboxInitPoint() + "\", \"orderId\": " + orderId + "}");

        } catch (com.mercadopago.exceptions.MPApiException apiEx) {
            apiEx.printStackTrace();
            sendError(response, "API Error: " + apiEx.getApiResponse().getContent());
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, e.getMessage());
        }
    }

    private int savePendingOrderToDb(int customerId, String cartDataStr, List<Map<String, Object>> cart) throws Exception {
        int orderId = -1;
        try (Connection conn = DbConnection.getConnection()) {
            double total = 0;
            for (Map<String, Object> item : cart) {
                double price = (Double) item.get("price");
                int qty = ((Double) item.get("qty")).intValue();
                total += price * qty;
            }

            String orderSql = "INSERT INTO online_orders (customer_id, total_amount, shipping_cost, items_json, status) VALUES (?, ?, ?, ?, 'PENDIENTE')";
            try (PreparedStatement orderStmt = conn.prepareStatement(orderSql, PreparedStatement.RETURN_GENERATED_KEYS)) {
                orderStmt.setInt(1, customerId);
                orderStmt.setDouble(2, total);
                orderStmt.setDouble(3, 0.0);
                orderStmt.setString(4, cartDataStr);
                orderStmt.executeUpdate();

                ResultSet rs = orderStmt.getGeneratedKeys();
                if (rs.next()) {
                    orderId = rs.getInt(1);
                }
            }
        }
        return orderId;
    }

    private void sendError(HttpServletResponse response, String errorMsg) throws IOException {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        out.print("{\"success\": false, \"error\": " + new Gson().toJson(errorMsg) + "}");
    }
}
