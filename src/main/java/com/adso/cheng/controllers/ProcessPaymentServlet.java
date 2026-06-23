package com.adso.cheng.controllers;

import com.adso.cheng.models.User;
import com.adso.cheng.utils.DbConnection;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;
import com.mercadopago.MercadoPagoConfig;
import com.mercadopago.client.payment.PaymentClient;
import com.mercadopago.client.payment.PaymentCreateRequest;
import com.mercadopago.client.payment.PaymentPayerRequest;
import com.mercadopago.resources.payment.Payment;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.List;
import java.util.Map;

@WebServlet("/api/process_payment")
public class ProcessPaymentServlet extends HttpServlet {

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
            // Leer el cuerpo de la petición (JSON enviado por el frontend Payment Brick)
            StringBuilder sb = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }

            Gson gson = new Gson();
            JsonObject payload = gson.fromJson(sb.toString(), JsonObject.class);

            // Obtener datos del carrito
            String cartDataStr = payload.get("cartData").getAsString();
            List<Map<String, Object>> cart = gson.fromJson(cartDataStr, new TypeToken<List<Map<String, Object>>>(){}.getType());

            if (cart == null || cart.isEmpty()) {
                sendError(response, "Carrito vacío");
                return;
            }

            // Datos del pago (Brick)
            JsonObject formData = payload.getAsJsonObject("formData");
            String token = formData.get("token").getAsString();
            String paymentMethodId = formData.get("payment_method_id").getAsString();
            String issuerId = formData.has("issuer_id") && !formData.get("issuer_id").isJsonNull() ? formData.get("issuer_id").getAsString() : null;
            int installments = formData.get("installments").getAsInt();
            double transactionAmount = formData.get("transaction_amount").getAsDouble();
            JsonObject payerObj = formData.getAsJsonObject("payer");
            String email = payerObj.get("email").getAsString();
            
            // Extracción segura del identification
            JsonObject identificationObj = payerObj.getAsJsonObject("identification");
            String docType = identificationObj != null && identificationObj.has("type") && !identificationObj.get("type").isJsonNull() ? identificationObj.get("type").getAsString() : null;
            String docNumber = identificationObj != null && identificationObj.has("number") && !identificationObj.get("number").isJsonNull() ? identificationObj.get("number").getAsString() : null;

            // Guardar orden como PENDIENTE
            int orderId = savePendingOrderToDb(user.getId(), cartDataStr, cart);

            // Construir el payer info
            PaymentPayerRequest.PaymentPayerRequestBuilder payerBuilder = PaymentPayerRequest.builder()
                    .email(email);

            if (docType != null && !docType.isEmpty() && docNumber != null && !docNumber.isEmpty()) {
                payerBuilder.identification(com.mercadopago.client.common.IdentificationRequest.builder()
                        .type(docType)
                        .number(docNumber)
                        .build());
            }

            // Crear el pago con Mercado Pago
            PaymentCreateRequest.PaymentCreateRequestBuilder paymentBuilder = PaymentCreateRequest.builder()
                    .transactionAmount(BigDecimal.valueOf(transactionAmount))
                    .token(token)
                    .description("Compra en Asama Motors Parts")
                    .installments(installments)
                    .paymentMethodId(paymentMethodId)
                    .payer(payerBuilder.build())
                    .externalReference(String.valueOf(orderId));

            if (issuerId != null && !issuerId.isEmpty()) {
                paymentBuilder.issuerId(issuerId);
            }

            PaymentClient client = new PaymentClient();
            Payment payment = client.create(paymentBuilder.build());

            PrintWriter out = response.getWriter();
            if ("approved".equals(payment.getStatus())) {
                out.print("{\"success\": true, \"status\": \"approved\", \"orderId\": " + orderId + "}");
            } else {
                out.print("{\"success\": false, \"status\": \"" + payment.getStatus() + "\"}");
            }

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

            // Hora actual en Colombia (UTC-5)
            Timestamp nowColombia = Timestamp.from(
                ZonedDateTime.now(ZoneId.of("America/Bogota")).toInstant()
            );

            String orderSql = "INSERT INTO online_orders (customer_id, total_amount, shipping_cost, items_json, status, created_at) VALUES (?, ?, ?, ?, 'PENDIENTE', ?)";
            try (PreparedStatement orderStmt = conn.prepareStatement(orderSql, PreparedStatement.RETURN_GENERATED_KEYS)) {
                orderStmt.setInt(1, customerId);
                orderStmt.setDouble(2, total);
                orderStmt.setDouble(3, 0.0);
                orderStmt.setString(4, cartDataStr);
                orderStmt.setTimestamp(5, nowColombia);
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
