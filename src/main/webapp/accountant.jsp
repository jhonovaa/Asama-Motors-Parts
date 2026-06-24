<%@ page import="com.adso.cheng.models.User" %>
<%@ page import="com.adso.cheng.utils.DbConnection" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 2)) { // Solo Admin y Contador
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="accountant.title" /></title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        .dashboard-stats {
            background: var(--card-bg);
            border-left: 5px solid var(--accent-orange);
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
            border: 1px solid var(--card-border);
            margin-bottom: 25px;
            height: 100%;
        }

        /* Diseño de Tabla estilo Tarjetas Verticales (Pricing Table) */
        .pricing-designed-table {
            border-collapse: separate !important;
            border-spacing: 8px 0 !important;
            width: 100%;
            margin-top: 15px;
        }
        .pricing-designed-table th {
            border: none !important;
            padding: 18px 10px !important;
            text-align: center;
            background-color: var(--accent-orange) !important;
            color: #121417 !important;
            font-weight: 800 !important;
            font-size: 0.85rem !important;
            letter-spacing: 1px;
            text-transform: uppercase;
            border-top-left-radius: 16px !important;
            border-top-right-radius: 16px !important;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            position: sticky;
            top: 0;
            z-index: 10;
        }
        .pricing-designed-table td {
            border: none !important;
            padding: 16px 12px !important;
            text-align: center;
            font-weight: 700 !important;
            font-size: 1rem !important;
            color: var(--text-color) !important;
            background-color: rgba(255, 255, 255, 0.05) !important;
            transition: background-color 0.2s, color 0.2s;
            vertical-align: middle;
        }
        .pricing-designed-table tr:nth-child(even) td {
            background-color: rgba(255, 255, 255, 0.02) !important;
        }
        
        /* Efecto Hover individual por columna en celdas body */
        .pricing-designed-table tbody tr:hover td {
            background-color: rgba(255, 255, 255, 0.08) !important;
        }
        .pricing-designed-table tr:nth-child(even):hover td {
            background-color: rgba(255, 255, 255, 0.05) !important;
        }

        /* Light Mode overrides */
        body.light-mode .pricing-designed-table td {
            background-color: rgba(0, 0, 0, 0.03) !important;
            color: #121417 !important;
        }
        body.light-mode .pricing-designed-table tr:nth-child(even) td {
            background-color: rgba(0, 0, 0, 0.01) !important;
        }
        body.light-mode .pricing-designed-table tbody tr:hover td {
            background-color: rgba(0, 0, 0, 0.06) !important;
        }
        body.light-mode .pricing-designed-table tr:nth-child(even):hover td {
            background-color: rgba(0, 0, 0, 0.04) !important;
        }

        /* Redondear la última fila de cada columna */
        .pricing-designed-table tr:last-child td {
            border-bottom-left-radius: 16px !important;
            border-bottom-right-radius: 16px !important;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
        }

        /* Los colores de encabezados se manejan dinámicamente con var(--accent-orange) */
    </style>
    <link rel="stylesheet" href="resources/theme.css?v=6">
</head>
<body>
<script src="resources/theme.js?v=2"></script>

<%@ include file="navbar.jsp" %>

<div class="container pb-5 mt-4">
    
    <%
        double totalPresencial = 0;
        double totalVirtual = 0;
        double totalGeneral = 0;
        int productosVendidos = 0;

        try (Connection conn = DbConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            // Stats
            ResultSet rs = stmt.executeQuery("SELECT SUM(total_price) FROM sales WHERE customer_id IS NULL");
            if(rs.next()) totalPresencial = rs.getDouble(1);

            rs = stmt.executeQuery("SELECT SUM(total_price) FROM sales WHERE customer_id IS NOT NULL");
            if(rs.next()) totalVirtual = rs.getDouble(1);
            
            rs = stmt.executeQuery("SELECT SUM(quantity) FROM sales");
            if(rs.next()) productosVendidos = rs.getInt(1);

            totalGeneral = totalPresencial + totalVirtual;
        } catch(Exception e) {}
    %>

    <div class="row g-4 mb-4">
        <div class="col-md-3">
            <div class="dashboard-stats">
                <h6 class="text-secondary text-uppercase mb-2"><i class="bi bi-wallet2 text-danger"></i> <fmt:message key="accountant.total_revenue" /></h6>
                <h3 class="mb-0 fw-bold" style="color: var(--text-color);">$<%= String.format("%.2f", totalGeneral) %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="dashboard-stats" style="border-left-color: #ff9800;">
                <h6 class="text-secondary text-uppercase mb-2"><i class="bi bi-shop text-warning"></i> <fmt:message key="accountant.physical_sales" /></h6>
                <h3 class="mb-0 fw-bold" style="color: var(--text-color);">$<%= String.format("%.2f", totalPresencial) %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="dashboard-stats" style="border-left-color: #4caf50;">
                <h6 class="text-secondary text-uppercase mb-2"><i class="bi bi-globe text-success"></i> <fmt:message key="accountant.virtual_sales" /></h6>
                <h3 class="mb-0 fw-bold" style="color: var(--text-color);">$<%= String.format("%.2f", totalVirtual) %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="dashboard-stats" style="border-left-color: #03a9f4;">
                <h6 class="text-secondary text-uppercase mb-2"><i class="bi bi-box-seam text-info"></i> <fmt:message key="accountant.units_sold" /></h6>
                <h3 class="mb-0 fw-bold" style="color: var(--text-color);"><%= productosVendidos %></h3>
            </div>
        </div>
    </div>

    <!-- Notificaciones de Devoluciones y Garantías -->
    <div class="card-custom shadow-sm mb-4 border-danger border-2">
        <div class="card-header d-flex justify-content-between align-items-center bg-danger bg-opacity-10">
            <h5 class="mb-0 text-danger"><i class="bi bi-bell-fill"></i> <fmt:message key="accountant.notifications" /></h5>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive" style="max-height: 300px;">
                <table class="pricing-designed-table cols-4">
                    <thead>
                        <tr>
                            <th class="text-uppercase pb-3 pt-3"><fmt:message key="accountant.approval_date" /></th>
                            <th class="text-uppercase pb-3 pt-3"><fmt:message key="accountant.claim_id" /></th>
                            <th class="text-uppercase pb-3 pt-3"><fmt:message key="accountant.status" /></th>
                            <th class="text-uppercase pb-3 pt-3"><fmt:message key="accountant.report_pdf" /></th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try (Connection conn = DbConnection.getConnection();
                                 Statement stmt = conn.createStatement();
                                 ResultSet rs = stmt.executeQuery(
                                    "SELECT id, request_id, pdf_path, is_read, created_at FROM accountant_reports ORDER BY created_at DESC"
                                 )) {
                                boolean hasReports = false;
                                while(rs.next()) {
                                    hasReports = true;
                                    boolean isRead = rs.getBoolean("is_read");
                          %>
                        <tr>
                            <td><%= rs.getTimestamp("created_at").toString().substring(0, 16) %></td>
                            <td><span class="badge bg-secondary bg-opacity-25 text-light border border-secondary border-opacity-50 py-2 px-3 fw-bold fs-6">#<%= rs.getInt("request_id") %></span></td>
                            <td>
                                <% if(!isRead) { %>
                                    <span class="badge bg-danger bg-opacity-25 text-danger border border-danger border-opacity-50 py-2 px-3 fw-bold fs-6 rounded-pill"><fmt:message key="accountant.new" /></span>
                                <% } else { %>
                                    <span class="badge bg-light bg-opacity-10 text-secondary border border-secondary border-opacity-20 py-2 px-3 fw-bold fs-6 rounded-pill"><fmt:message key="accountant.reviewed" /></span>
                                <% } %>
                            </td>
                            <td>
                                <a href="<%= rs.getString("pdf_path") %>" target="_blank" class="btn btn-sm btn-outline-danger rounded-pill px-3 py-2 fw-bold" onclick="this.parentElement.previousElementSibling.innerHTML='<span class=\'badge bg-light bg-opacity-10 text-secondary border border-secondary border-opacity-20 py-2 px-3 fw-bold fs-6 rounded-pill\'><fmt:message key="accountant.reviewed" /></span>';">
                                    <i class="bi bi-file-earmark-pdf-fill me-1"></i><fmt:message key="accountant.view_pdf" />
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                                if(!hasReports) {
                        %>
                        <tr><td colspan="4" class="text-center text-muted py-4"><fmt:message key="accountant.no_reports" /></td></tr>
                        <%
                                }
                            } catch(Exception e) {}
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Presencial Table -->
    <div class="card-custom shadow-sm mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="mb-0 text-warning"><i class="bi bi-shop"></i> <fmt:message key="accountant.physical_history" /></h5>
            <button class="btn btn-sm btn-secondary" style="border-radius:20px;" onclick="window.print()"><i class="bi bi-printer"></i> <fmt:message key="accountant.print" /></button>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive" style="max-height: 400px;">
                <table class="pricing-designed-table cols-5">
                    <thead>
                        <tr>
                            <th class="text-uppercase pb-3 pt-3"><fmt:message key="accountant.date" /></th>
                            <th class="text-uppercase pb-3 pt-3"><fmt:message key="accountant.product" /></th>
                            <th class="text-uppercase pb-3 pt-3"><fmt:message key="accountant.cashier" /></th>
                            <th class="text-uppercase pb-3 pt-3"><fmt:message key="accountant.qty" /></th>
                            <th class="text-uppercase pb-3 pt-3"><fmt:message key="accountant.total" /></th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try (Connection conn = DbConnection.getConnection();
                                 Statement stmt = conn.createStatement();
                                 ResultSet rs = stmt.executeQuery(
                                    "SELECT s.sale_date, p.name as product_name, c.full_name as cashier_name, s.quantity, s.total_price " +
                                    "FROM sales s " +
                                    "JOIN products p ON s.product_id = p.id " +
                                    "JOIN users c ON s.cashier_id = c.id " +
                                    "WHERE s.customer_id IS NULL " +
                                    "ORDER BY s.sale_date DESC"
                                 )) {
                                while(rs.next()) {
                        %>
                        <tr>
                            <td><%= rs.getTimestamp("sale_date").toString().substring(0, 16) %></td>
                            <td><%= rs.getString("product_name") %></td>
                            <td><span class="badge bg-secondary bg-opacity-25 text-light border border-secondary border-opacity-50 py-2 px-3 fw-bold fs-6"><%= rs.getString("cashier_name") %></span></td>
                            <td><%= rs.getInt("quantity") %></td>
                            <td class="fw-bolder text-accent fs-5">$<%= String.format("%.2f", rs.getDouble("total_price")) %></td>
                        </tr>
                        <%
                                }
                            } catch(Exception e) {}
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Virtual Table -->
    <div class="card-custom shadow-sm mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="mb-0 text-success"><i class="bi bi-globe"></i> <fmt:message key="accountant.online_history" /></h5>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive" style="max-height: 400px;">
                <table class="pricing-designed-table cols-5">
                    <thead>
                        <tr>
                            <th class="text-uppercase pb-3 pt-3"><fmt:message key="accountant.date" /></th>
                            <th class="text-uppercase pb-3 pt-3"><fmt:message key="accountant.product" /></th>
                            <th class="text-uppercase pb-3 pt-3"><fmt:message key="accountant.customer" /></th>
                            <th class="text-uppercase pb-3 pt-3"><fmt:message key="accountant.qty" /></th>
                            <th class="text-uppercase pb-3 pt-3"><fmt:message key="accountant.total" /></th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try (Connection conn = DbConnection.getConnection();
                                 Statement stmt = conn.createStatement();
                                 ResultSet rs = stmt.executeQuery(
                                    "SELECT s.sale_date, p.name as product_name, cu.full_name as customer_name, s.quantity, s.total_price " +
                                    "FROM sales s " +
                                    "JOIN products p ON s.product_id = p.id " +
                                    "JOIN users cu ON s.customer_id = cu.id " +
                                    "WHERE s.customer_id IS NOT NULL " +
                                    "ORDER BY s.sale_date DESC"
                                 )) {
                                while(rs.next()) {
                        %>
                        <tr>
                            <td><%= rs.getTimestamp("sale_date").toString().substring(0, 16) %></td>
                            <td><%= rs.getString("product_name") %></td>
                            <td><span class="badge bg-primary bg-opacity-25 text-primary border border-primary border-opacity-50 py-2 px-3 fw-bold fs-6"><%= rs.getString("customer_name") %></span></td>
                            <td><%= rs.getInt("quantity") %></td>
                            <td class="fw-bolder text-accent fs-5">$<%= String.format("%.2f", rs.getDouble("total_price")) %></td>
                        </tr>
                        <%
                                }
                            } catch(Exception e) {}
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</div>

</body>
</html>
