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
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="resources/theme.css?v=6">
    <style>
        /* --- LEGIBILIDAD MEJORADA --- */
        .text-secondary, .text-muted { color: rgba(255, 255, 255, 0.75) !important; }
        body.light-mode .text-secondary, body.light-mode .text-muted { color: rgba(0, 0, 0, 0.65) !important; }

        .table { color: var(--text-color) !important; }
        .table th { font-weight: 700; letter-spacing: 0.5px; font-size: 0.85rem; border-bottom: 2px solid var(--card-border); }
        .table td { font-weight: 500; font-size: 0.95rem; border-bottom: 1px solid var(--card-border); vertical-align: middle; }
        .table tbody tr:hover { background: rgba(255, 255, 255, 0.05); }
        body.light-mode .table tbody tr:hover { background: rgba(0, 0, 0, 0.03); }
    </style>
</head>
<body>
<script src="resources/theme.js"></script>

<%@ include file="navbar.jsp" %>

<div class="container-fluid px-4 pb-5 mb-5" style="margin-top: 100px;">
    
    <div class="d-flex align-items-center mb-4">
        <h2 class="fw-bold mb-0 text-accent"><i class="bi bi-journal-text me-2"></i>Historial de Ventas</h2>
        <span class="badge bg-secondary bg-opacity-25 text-light ms-3 px-3 py-2 rounded-pill fs-6 fw-normal border border-secondary border-opacity-25">Ultimos 30 dias</span>
    </div>
    
    <div class="row g-4 align-items-stretch">
        <div class="col-lg-6">
            <div class="action-card h-100 d-flex flex-column p-4">
                <div class="border-bottom border-secondary pb-3 mb-3">
                    <h5 class="fw-bold mb-0 text-accent"><i class="bi bi-person-badge me-2"></i>Ventas por Cajero</h5>
                </div>
                <div class="table-responsive flex-grow-1 pe-2" style="max-height: 50vh; overflow-y: auto;">
                    <table class="table table-borderless align-middle mb-0">
                        <thead class="sticky-top" style="background: var(--card-bg);">
                            <tr>
                                <th class="text-secondary text-uppercase pb-2">Fecha</th>
                                <th class="text-secondary text-uppercase pb-2">Cajero</th>
                                <th class="text-secondary text-uppercase pb-2 text-center">Transacciones</th>
                                <th class="text-secondary text-uppercase pb-2 text-end">Ingresos</th>
                            </tr>
                        </thead>
                        <tbody id="cashierHistoryTable">
                            <tr><td colspan="4" class="text-center text-secondary py-5"><div class="spinner-border spinner-border-sm me-2"></div>Cargando datos...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
        <div class="col-lg-6">
            <div class="action-card h-100 d-flex flex-column p-4">
                <div class="border-bottom border-secondary pb-3 mb-3">
                    <h5 class="fw-bold mb-0 text-accent"><i class="bi bi-globe me-2"></i>Ventas Online</h5>
                </div>
                <div class="table-responsive flex-grow-1 pe-2" style="max-height: 50vh; overflow-y: auto;">
                    <table class="table table-borderless align-middle mb-0">
                        <thead class="sticky-top" style="background: var(--card-bg);">
                            <tr>
                                <th class="text-secondary text-uppercase pb-2">Fecha</th>
                                <th class="text-secondary text-uppercase pb-2 text-center">Transacciones</th>
                                <th class="text-secondary text-uppercase pb-2 text-end">Ingresos</th>
                            </tr>
                        </thead>
                        <tbody id="onlineHistoryTable">
                            <tr><td colspan="3" class="text-center text-secondary py-5"><div class="spinner-border spinner-border-sm me-2"></div>Cargando datos...</td></tr>
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
                tbody.innerHTML = '<tr><td colspan="4" class="text-center text-secondary py-5"><i class="bi bi-inbox fs-1 d-block mb-3"></i>No hay registros recientes.</td></tr>';
            } else {
                data.forEach(row => {
                    tbody.innerHTML += 
                        '<tr>' +
                            '<td class="text-muted small">' + row.date + '</td>' +
                            '<td class="fw-bold">' + row.cashier + '</td>' +
                            '<td class="text-center"><span class="badge bg-secondary bg-opacity-25 text-light px-2">' + row.sales_count + '</span></td>' +
                            '<td class="text-end fw-bold text-accent fs-6">$' + row.revenue.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) + '</td>' +
                        '</tr>';
                });
            }
        }).catch(err => {
            document.getElementById('cashierHistoryTable').innerHTML = '<tr><td colspan="4" class="text-center text-danger py-4">Error al cargar los datos.</td></tr>';
        });

    // Fetch Online History
    fetch('dashboardData?action=onlineHistory')
        .then(res => res.json())
        .then(data => {
            const tbody = document.getElementById('onlineHistoryTable');
            tbody.innerHTML = '';
            
            if(data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="3" class="text-center text-secondary py-5"><i class="bi bi-inbox fs-1 d-block mb-3"></i>No hay registros recientes.</td></tr>';
            } else {
                data.forEach(row => {
                    tbody.innerHTML += 
                        '<tr>' +
                            '<td class="text-muted small">' + row.date + '</td>' +
                            '<td class="text-center"><span class="badge bg-secondary bg-opacity-25 text-light px-2">' + row.sales_count + '</span></td>' +
                            '<td class="text-end fw-bold text-accent fs-6">$' + row.revenue.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) + '</td>' +
                        '</tr>';
                });
            }
        }).catch(err => {
            document.getElementById('onlineHistoryTable').innerHTML = '<tr><td colspan="3" class="text-center text-danger py-4">Error al cargar los datos.</td></tr>';
        });
});
</script>
</body>
</html>