<%@ page import="com.adso.cheng.models.User" %>
<%@ page import="com.adso.cheng.utils.DbConnection" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
    <title>Contabilidad - Asama Moto Parts</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --bg-color: #0f1013;
            --text-color: #f1f2f6;
            --nav-bg: rgba(15, 16, 19, 0.85);
            --metallic-gunmetal: #1a1d24;
            --card-bg: #2a2e35;
            --accent-orange: #FF6B35;
        }
        body { font-family: 'Inter', sans-serif; background-color: var(--bg-color); color: var(--text-color); }
        .navbar-custom { background-color: var(--nav-bg); backdrop-filter: blur(20px); border-bottom: 1px solid rgba(255,255,255,0.08); }
        .navbar-brand { color: #E5E4E2 !important; font-weight: 700; }
        
        .dashboard-stats {
            background: var(--metallic-gunmetal);
            border-left: 5px solid var(--accent-red);
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
            border: 1px solid rgba(255,255,255,0.05);
            margin-bottom: 25px;
            height: 100%;
        }
        
        .card { background: var(--metallic-gunmetal); border-radius: 15px; border: 1px solid rgba(255,255,255,0.05); color: #fff; box-shadow: 0 10px 30px rgba(0,0,0,0.5); margin-bottom: 30px;}
        .card-header { background: transparent !important; border-bottom: 1px solid rgba(255,255,255,0.1); font-weight: 600; padding: 15px 20px; }
        
        .table-dark { background-color: transparent !important; }
        .table { color: #ccc; }
        .table th, .table td { border-color: rgba(255,255,255,0.1); }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-dark navbar-custom mb-4">
    <div class="container-fluid">
        <a class="navbar-brand" href="dashboard.jsp">Módulo de Contabilidad</a>
        <div>
            <a class="btn btn-outline-danger btn-sm me-2" href="dashboard.jsp" style="border-radius:20px;">Volver al Panel</a>
            <a class="btn btn-outline-secondary btn-sm" href="logout" style="border-radius:20px;">Cerrar Sesión</a>
        </div>
    </div>
</nav>

<div class="container pb-5">
    
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
                <h6 class="text-secondary text-uppercase mb-2"><i class="bi bi-wallet2 text-danger"></i> Ingresos Totales</h6>
                <h3 class="mb-0 text-white fw-bold">$<%= String.format("%.2f", totalGeneral) %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="dashboard-stats" style="border-left-color: #ff9800;">
                <h6 class="text-secondary text-uppercase mb-2"><i class="bi bi-shop text-warning"></i> Físico (Caja)</h6>
                <h3 class="mb-0 text-white fw-bold">$<%= String.format("%.2f", totalPresencial) %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="dashboard-stats" style="border-left-color: #4caf50;">
                <h6 class="text-secondary text-uppercase mb-2"><i class="bi bi-globe text-success"></i> Virtual (Online)</h6>
                <h3 class="mb-0 text-white fw-bold">$<%= String.format("%.2f", totalVirtual) %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="dashboard-stats" style="border-left-color: #03a9f4;">
                <h6 class="text-secondary text-uppercase mb-2"><i class="bi bi-box-seam text-info"></i> Unidades Vendidas</h6>
                <h3 class="mb-0 text-white fw-bold"><%= productosVendidos %></h3>
            </div>
        </div>
    </div>

    <!-- Presencial Table -->
    <div class="card shadow-sm">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="mb-0 text-warning"><i class="bi bi-shop"></i> Historial de Ventas Físicas (Cajero)</h5>
            <button class="btn btn-sm btn-secondary" style="border-radius:20px;" onclick="window.print()"><i class="bi bi-printer"></i> Imprimir</button>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive" style="max-height: 400px;">
                <table class="table table-borderless table-hover m-0 table-sm">
                    <thead style="border-bottom: 1px solid rgba(255,255,255,0.1); position: sticky; top: 0; background: var(--metallic-gunmetal);">
                        <tr>
                            <th class="text-secondary">Fecha</th>
                            <th class="text-secondary">Producto</th>
                            <th class="text-secondary">Cajero Responsable</th>
                            <th class="text-secondary text-center">Cant.</th>
                            <th class="text-secondary text-end">Total</th>
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
                            <td class="text-white"><%= rs.getString("product_name") %></td>
                            <td><span class="badge bg-secondary"><%= rs.getString("cashier_name") %></span></td>
                            <td class="text-center"><%= rs.getInt("quantity") %></td>
                            <td class="text-end fw-bold text-white">$<%= String.format("%.2f", rs.getDouble("total_price")) %></td>
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
    <div class="card shadow-sm">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="mb-0 text-success"><i class="bi bi-globe"></i> Historial de Ventas Online (E-commerce)</h5>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive" style="max-height: 400px;">
                <table class="table table-borderless table-hover m-0 table-sm">
                    <thead style="border-bottom: 1px solid rgba(255,255,255,0.1); position: sticky; top: 0; background: var(--metallic-gunmetal);">
                        <tr>
                            <th class="text-secondary">Fecha</th>
                            <th class="text-secondary">Producto</th>
                            <th class="text-secondary">Cliente</th>
                            <th class="text-secondary text-center">Cant.</th>
                            <th class="text-secondary text-end">Total</th>
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
                            <td class="text-white"><%= rs.getString("product_name") %></td>
                            <td><span class="badge bg-primary"><%= rs.getString("customer_name") %></span></td>
                            <td class="text-center"><%= rs.getInt("quantity") %></td>
                            <td class="text-end fw-bold text-white">$<%= String.format("%.2f", rs.getDouble("total_price")) %></td>
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
