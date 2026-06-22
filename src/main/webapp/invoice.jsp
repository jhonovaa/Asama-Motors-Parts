<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.adso.cheng.utils.DbConnection" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="com.google.gson.reflect.TypeToken" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    String idParam = request.getParameter("id");
    String orderIdParam = request.getParameter("orderId");
    if ((idParam == null || idParam.isEmpty()) && (orderIdParam == null || orderIdParam.isEmpty())) {
        response.sendRedirect("index.jsp");
        return;
    }

    String invoiceNumber = "";
    String cufe = "";
    String issueDate = "";
    String customerDocument = "";
    String customerName = "";
    String customerEmail = "";
    double subtotal = 0;
    double taxAmount = 0;
    double totalAmount = 0;
    String itemsJson = "[]";

    try (Connection conn = DbConnection.getConnection()) {
        PreparedStatement stmt;
        if (idParam != null && !idParam.isEmpty()) {
            stmt = conn.prepareStatement("SELECT * FROM dian_invoices WHERE id = ?");
            stmt.setInt(1, Integer.parseInt(idParam));
        } else {
            stmt = conn.prepareStatement("SELECT * FROM dian_invoices WHERE order_id = ?");
            stmt.setInt(1, Integer.parseInt(orderIdParam));
        }
        
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            invoiceNumber = rs.getString("invoice_number");
            cufe = rs.getString("cufe");
            issueDate = rs.getTimestamp("issue_date").toString();
            customerDocument = rs.getString("customer_document");
            customerName = rs.getString("customer_name");
            customerEmail = rs.getString("customer_email");
            subtotal = rs.getDouble("subtotal");
            taxAmount = rs.getDouble("tax_amount");
            totalAmount = rs.getDouble("total_amount");
            itemsJson = rs.getString("items_json");
        } else {
            response.sendError(404, "Factura no encontrada");
            return;
        }
        stmt.close();
    } catch (Exception e) {
        response.sendError(500, "Error en base de datos");
        return;
    }

    NumberFormat format = NumberFormat.getCurrencyInstance(new Locale("en", "US"));
    Gson gson = new Gson();
    List<Map<String, Object>> cart = gson.fromJson(itemsJson, new TypeToken<List<Map<String, Object>>>(){}.getType());
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Factura Electrónica <%= invoiceNumber %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body { background-color: #f4f6f9; font-family: 'Inter', sans-serif; }
        .invoice-box { max-width: 800px; margin: 40px auto; padding: 40px; background: #fff; border-radius: 12px; box-shadow: 0 10px 30px rgba(0,0,0,0.05); }
        .invoice-header { border-bottom: 2px solid #0052ff; padding-bottom: 20px; margin-bottom: 20px; }
        .logo-text { font-size: 24px; font-weight: 800; color: #0052ff; letter-spacing: -1px; }
        .cufe-box { background: #f8f9fa; padding: 10px; border-radius: 6px; font-size: 11px; word-break: break-all; border: 1px solid #dee2e6; margin-top: 20px; }
        .qr-code { width: 120px; height: 120px; }
        .dian-badge { display: inline-block; background-color: #f0f4ff; color: #0052ff; padding: 5px 15px; border-radius: 50px; font-weight: 600; font-size: 12px; border: 1px solid #cce0ff; }
        @media print { body { background: #fff; } .invoice-box { box-shadow: none; margin: 0; padding: 0; } .no-print { display: none !important; } }
    </style>
    <!-- Librería para generar el QR -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
</head>
<body>

<div class="container">
    <div class="d-flex justify-content-end mb-3 mt-4 no-print invoice-box pb-0" style="background: none; box-shadow: none; margin-bottom: -20px;">
        <button class="btn btn-outline-primary me-2" onclick="window.close()"><i class="bi bi-x-circle me-1"></i> Cerrar</button>
        <button class="btn btn-primary" onclick="window.print()"><i class="bi bi-printer me-1"></i> Imprimir / Guardar PDF</button>
    </div>

    <div class="invoice-box">
        <div class="invoice-header d-flex justify-content-between align-items-center">
            <div>
                <div class="logo-text">ASAMA MOTORS PARTS</div>
                <div class="text-secondary small mt-1">NIT: 901.234.567-8</div>
                <div class="text-secondary small">Régimen Común - Responsable de IVA</div>
                <div class="text-secondary small">Dirección: Calle 123 #45-67, Bogotá, Colombia</div>
            </div>
            <div class="text-end">
                <div class="dian-badge mb-2"><i class="bi bi-check-circle-fill me-1"></i>Documento Oficial DIAN</div>
                <h4 class="fw-bold mb-0 text-dark">Factura de Venta Electrónica</h4>
                <div class="fs-5 text-primary fw-bold"><%= invoiceNumber %></div>
                <div class="text-secondary small">Fecha de Emisión: <%= issueDate %></div>
            </div>
        </div>

        <div class="row mb-4">
            <div class="col-sm-6">
                <h6 class="fw-bold text-uppercase text-muted" style="font-size: 12px;">Datos del Adquirente</h6>
                <div><strong>Nombre:</strong> <%= customerName %></div>
                <div><strong>Documento (NIT/CC):</strong> <%= customerDocument %></div>
                <div><strong>Email:</strong> <%= customerEmail %></div>
            </div>
            <div class="col-sm-6 text-end">
                <h6 class="fw-bold text-uppercase text-muted" style="font-size: 12px;">Resolución DIAN</h6>
                <div class="small">Autorización Num: 18762039485720 del 2026/01/01</div>
                <div class="small">Rango Autorizado: SETT-1000 hasta SETT-9999</div>
            </div>
        </div>

        <div class="table-responsive">
            <table class="table table-bordered table-striped">
                <thead class="table-light text-center">
                    <tr>
                        <th style="width: 10%">Cant</th>
                        <th style="width: 50%">Descripción</th>
                        <th style="width: 20%">Valor Unitario</th>
                        <th style="width: 20%">Total</th>
                    </tr>
                </thead>
                <tbody>
                    <% for(Map<String, Object> item : cart) { %>
                    <tr>
                        <td class="text-center"><%= ((Double)item.get("qty")).intValue() %></td>
                        <td><%= item.get("name") %></td>
                        <td class="text-end"><%= format.format((Double)item.get("price")) %></td>
                        <td class="text-end"><%= format.format((Double)item.get("price") * ((Double)item.get("qty")).intValue()) %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <div class="row mt-4">
            <div class="col-md-7">
                <div class="d-flex mt-3">
                    <div id="qrcode" class="qr-code me-3"></div>
                    <div>
                        <div class="fw-bold small">Firma Digital (CUFE):</div>
                        <div class="cufe-box"><%= cufe %></div>
                    </div>
                </div>
            </div>
            <div class="col-md-5">
                <table class="table table-borderless table-sm text-end">
                    <tr>
                        <td>Subtotal (Sin IVA):</td>
                        <td class="fw-medium"><%= format.format(subtotal) %></td>
                    </tr>
                    <tr>
                        <td>IVA (19%):</td>
                        <td class="fw-medium"><%= format.format(taxAmount) %></td>
                    </tr>
                    <tr class="border-top border-2 border-primary">
                        <td class="fw-bold fs-5 pt-2">Total a Pagar:</td>
                        <td class="fw-bold fs-5 text-primary pt-2"><%= format.format(totalAmount) %></td>
                    </tr>
                </table>
            </div>
        </div>

        <div class="text-center mt-5 pt-3 border-top text-secondary small">
            Este documento simula una factura electrónica de venta conforme a los lineamientos de la DIAN para el proyecto Asama Motors Parts. No tiene validez fiscal real.
        </div>
    </div>
</div>

<script>
    window.onload = function() {
        // Generar QR que contiene URL a esta misma factura
        new QRCode(document.getElementById("qrcode"), {
            text: window.location.href,
            width: 120,
            height: 120,
            colorDark : "#000000",
            colorLight : "#ffffff",
            correctLevel : QRCode.CorrectLevel.L
        });
    }
</script>
</body>
</html>
