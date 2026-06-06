<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRoleId() != 1) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Historial de Ventas - Asama Moto Parts</title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <link rel="stylesheet" href="resources/theme.css?v=6">
</head>
<body>
<script src="resources/theme.js"></script>

<%@ include file="navbar.jsp" %>

<div class="container py-5 mt-3">
    <h2 class="fw-bold mb-4">Historial de Ventas (Últimos 30 días)</h2>
    
    <div class="row g-4">
        <div class="col-lg-6">
            <div class="card-custom">
                <h5 class="text-danger mb-4"><i class="bi bi-person-badge"></i> Ventas por Cajero</h5>
                <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
                    <table class="table table-sm table-hover align-middle">
                        <thead>
                            <tr>
                                <th>Fecha</th>
                                <th>Cajero</th>
                                <th>Ventas Realizadas</th>
                                <th>Ingresos</th>
                            </tr>
                        </thead>
                        <tbody id="cashierHistoryTable">
                            <tr><td colspan="4" class="text-center">Cargando...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
        <div class="col-lg-6">
            <div class="card-custom">
                <h5 class="text-danger mb-4"><i class="bi bi-globe"></i> Ventas Online</h5>
                <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
                    <table class="table table-sm table-hover align-middle">
                        <thead>
                            <tr>
                                <th>Fecha</th>
                                <th>Ventas Realizadas</th>
                                <th>Ingresos</th>
                            </tr>
                        </thead>
                        <tbody id="onlineHistoryTable">
                            <tr><td colspan="3" class="text-center">Cargando...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.addEventListener("DOMContentLoaded", function() {
    // Fetch Cashier History
    fetch('dashboardData?action=cashierHistory')
        .then(res => res.json())
        .then(data => {
            const tbody = document.getElementById('cashierHistoryTable');
            tbody.innerHTML = '';
            if(data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="4" class="text-center text-muted">No hay registros.</td></tr>';
            } else {
                data.forEach(row => {
                    tbody.innerHTML += 
                        '<tr>' +
                            '<td>' + row.date + '</td>' +
                            '<td>' + row.cashier + '</td>' +
                            '<td>' + row.sales_count + '</td>' +
                            '<td class="fw-bold">$' + row.revenue.toFixed(2) + '</td>' +
                        '</tr>';
                });
            }
        });

    // Fetch Online History
    fetch('dashboardData?action=onlineHistory')
        .then(res => res.json())
        .then(data => {
            const tbody = document.getElementById('onlineHistoryTable');
            tbody.innerHTML = '';
            if(data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="3" class="text-center text-muted">No hay registros.</td></tr>';
            } else {
                data.forEach(row => {
                    tbody.innerHTML += 
                        '<tr>' +
                            '<td>' + row.date + '</td>' +
                            '<td>' + row.sales_count + '</td>' +
                            '<td class="fw-bold">$' + row.revenue.toFixed(2) + '</td>' +
                        '</tr>';
                });
            }
        });
});
</script>
</body>
</html>
