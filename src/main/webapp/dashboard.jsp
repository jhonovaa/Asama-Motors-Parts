<%@ page import="com.adso.cheng.models.User" %>
<%@ page import="com.adso.cheng.utils.DbConnection" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel de Control - Asama Moto Parts</title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="resources/theme.css?v=6">
    <style>
        /* --- LEGIBILIDAD EXTREMA --- */
        .text-secondary, .text-muted { 
            color: rgba(255, 255, 255, 0.85) !important; 
            font-weight: 500;
        }
        body.light-mode .text-secondary, body.light-mode .text-muted { 
            color: rgba(0, 0, 0, 0.75) !important; 
            font-weight: 600;
        }

        /* Formularios */
        .form-label {
            font-weight: 600 !important;
            color: var(--text-color) !important;
        }
        .form-control {
            background-color: rgba(255, 255, 255, 0.05) !important;
            color: #ffffff !important;
            border: 1px solid rgba(255, 255, 255, 0.15) !important;
            font-weight: 500;
        }
        .form-control::placeholder {
            color: rgba(255, 255, 255, 0.4) !important;
        }
        .form-control:focus {
            background-color: rgba(255, 255, 255, 0.08) !important;
            border-color: var(--accent-orange) !important;
            box-shadow: 0 0 0 0.25rem var(--accent-glow) !important;
        }
        body.light-mode .form-control {
            background-color: #ffffff !important;
            color: #212529 !important;
            border-color: rgba(0, 0, 0, 0.15) !important;
        }
        body.light-mode .form-control::placeholder {
            color: rgba(0, 0, 0, 0.5) !important;
        }

        /* Tablas */
        .table { color: var(--text-color) !important; }
        .table th { font-weight: 700 !important; letter-spacing: 0.5px; font-size: 0.85rem; }
        .table td { font-weight: 500 !important; font-size: 0.95rem; }
    </style>
</head>
<body>
<script src="resources/theme.js"></script>

<%@ include file="navbar.jsp" %>

<div class="container pb-5 mb-5" style="margin-top: 100px;">
    <div class="row mb-4">
        <div class="col-12">
            <div class="welcome-card p-4 p-md-5 d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-4">
                <div>
                    <h2 class="fw-bold mb-2">Bienvenido, <span class="text-accent"><%= user.getFullName() %></span></h2>
                    <p class="text-secondary mb-0 fs-5">Selecciona el modulo al que deseas acceder segun tus permisos.</p>
                </div>
                <div class="text-md-end">
                    <span class="badge role-badge px-4 py-2 fs-6 fw-bold">
                        <i class="bi bi-shield-check me-2"></i>
                        <% if(user.getRoleId() == 1) out.print("Administrador");
                           else if(user.getRoleId() == 2) out.print("Contador");
                           else if(user.getRoleId() == 3) out.print("Bodeguero");
                           else if(user.getRoleId() == 4) out.print("Cajero");
                           else if(user.getRoleId() == 5) out.print("Cliente");
                           else if(user.getRoleId() == 6) out.print("Mecanico"); %>
                    </span>
                    <p class="text-secondary small mt-2 mb-0 fw-bold"><i class="bi bi-person-vcard me-1"></i> ID: <%= user.getDocumentId() %></p>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4">
        
        <% if(user.getRoleId() == 2) { // Contador %>
            <div class="col-md-6 mx-auto">
                <div class="action-card text-center p-5 h-100 d-flex flex-column justify-content-center align-items-center">
                    <div class="brand-icon-wrapper mb-4">
                        <i class="bi bi-graph-up-arrow fs-1 text-accent"></i>
                    </div>
                    <h4 class="fw-bold mb-3">Modulo de Contabilidad</h4>
                    <p class="text-secondary mb-4 fs-6">Revisa las ventas, transacciones registradas y genera reportes financieros.</p>
                    <a href="accountant.jsp" class="btn btn-accent px-5 py-2 rounded-pill fw-bold">Ver Reportes Financieros</a>
                </div>
            </div>

        <% } else if(user.getRoleId() == 5) { // Cliente %>
            <div class="col-lg-4 col-md-5">
                <div class="action-card p-4 h-100">
                    <h5 class="text-accent fw-bold border-bottom border-secondary pb-3 mb-4">
                        <i class="bi bi-person-circle me-2"></i>Editar Perfil
                    </h5>
                    <% if(request.getParameter("msg") != null) { %>
                        <div class="alert alert-success py-2 small rounded-3 bg-opacity-10 border-success text-success fw-bold">
                            <i class="bi bi-check-circle me-1"></i><%= request.getParameter("msg") %>
                        </div>
                    <% } %>
                    <form action="profile" method="POST">
                        <div class="mb-3">
                            <label class="form-label small">Nombre Completo</label>
                            <div class="input-group">
                                <span class="input-group-text bg-transparent border-end-0 border-secondary"><i class="bi bi-person text-secondary"></i></span>
                                <input type="text" name="fullName" class="form-control border-start-0 ps-0" value="<%= user.getFullName() %>" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small">Cedula</label>
                            <div class="input-group">
                                <span class="input-group-text bg-transparent border-end-0 border-secondary"><i class="bi bi-card-text text-secondary"></i></span>
                                <input type="text" name="documentId" class="form-control border-start-0 ps-0" value="<%= user.getDocumentId() %>" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small">Correo Electronico</label>
                            <div class="input-group">
                                <span class="input-group-text bg-transparent border-end-0 border-secondary"><i class="bi bi-envelope text-secondary"></i></span>
                                <input type="email" name="email" class="form-control border-start-0 ps-0" value="<%= user.getEmail() %>" required>
                            </div>
                        </div>
                        <div class="mb-4">
                            <label class="form-label small">Nueva Contrasena</label>
                            <div class="input-group">
                                <span class="input-group-text bg-transparent border-end-0 border-secondary"><i class="bi bi-lock text-secondary"></i></span>
                                <input type="password" name="password" class="form-control border-start-0 ps-0" placeholder="Dejar en blanco para omitir">
                            </div>
                        </div>
                        <button type="submit" class="btn btn-accent w-100 rounded-pill py-2 fw-bold">Guardar Cambios</button>
                    </form>
                </div>
            </div>
            
            <div class="col-lg-8 col-md-7">
                <div class="action-card p-4 h-100 d-flex flex-column">
                    <div class="d-flex justify-content-between align-items-center border-bottom border-secondary pb-3 mb-4">
                        <h5 class="text-accent fw-bold mb-0"><i class="bi bi-bag-check me-2"></i>Historial de Compras</h5>
                        <a href="catalog.jsp" class="btn btn-sm btn-moto-outline rounded-pill px-3 fw-bold">Ir a Tienda</a>
                    </div>
                    <div class="table-responsive flex-grow-1" style="max-height: 400px; overflow-y: auto;">
                        <table class="table table-hover align-middle table-borderless">
                            <thead class="sticky-top" style="background: var(--card-bg);">
                                <tr>
                                    <th class="text-secondary small text-uppercase">Fecha</th>
                                    <th class="text-secondary small text-uppercase">Repuesto</th>
                                    <th class="text-secondary small text-uppercase text-center">Cant.</th>
                                    <th class="text-secondary small text-uppercase text-end">Total</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                try (Connection conn = DbConnection.getConnection();
                                     PreparedStatement stmt = conn.prepareStatement(
                                         "SELECT s.sale_date, p.name, s.quantity, s.total_price " +
                                         "FROM sales s JOIN products p ON s.product_id = p.id " +
                                         "WHERE s.customer_id = ? ORDER BY s.sale_date DESC")) {
                                    stmt.setInt(1, user.getId());
                                    ResultSet rs = stmt.executeQuery();
                                    boolean hasPurchases = false;
                                    while(rs.next()) {
                                        hasPurchases = true;
                                %>
                                <tr>
                                    <td class="text-muted small"><%= rs.getTimestamp("sale_date").toString().substring(0, 16) %></td>
                                    <td class="fw-bold"><%= rs.getString("name") %></td>
                                    <td class="text-center"><span class="badge bg-secondary bg-opacity-25 text-light px-2"><%= rs.getInt("quantity") %></span></td>
                                    <td class="fw-bold text-end text-accent">$<%= String.format("%.2f", rs.getDouble("total_price")) %></td>
                                </tr>
                                <%
                                    }
                                    if(!hasPurchases) {
                                        out.print("<tr><td colspan='4' class='text-center text-secondary py-5 fw-bold'><i class='bi bi-inbox fs-1 d-block mb-2'></i>No has realizado compras aun.</td></tr>");
                                    }
                                } catch(Exception e) { e.printStackTrace(); }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="action-card p-4 text-center h-100 d-flex flex-column justify-content-center transition-all">
                    <i class="bi bi-search fs-1 text-accent mb-3"></i>
                    <h5 class="fw-bold">Buscar Repuesto</h5>
                    <p class="text-secondary small mb-4">Escanea codigos de barras con tu camara para buscar piezas rapidamente.</p>
                    <a href="search_product.jsp" class="btn btn-moto rounded-pill px-4 mx-auto mt-auto fw-bold">Abrir Escaner</a>
                </div>
            </div>
            <div class="col-md-6">
                <div class="action-card p-4 text-center h-100 d-flex flex-column justify-content-center transition-all">
                    <i class="bi bi-camera-viewfinder fs-1 text-accent mb-3"></i>
                    <h5 class="fw-bold">Escaner Visual IA</h5>
                    <p class="text-secondary small mb-4">Toma una foto del repuesto y deja que nuestra Inteligencia Artificial lo identifique.</p>
                    <a href="visual_scanner.jsp" class="btn btn-moto-outline rounded-pill px-4 mx-auto mt-auto fw-bold">Identificar Pieza</a>
                </div>
            </div>

        <% } else if(user.getRoleId() == 6) { // Mecanico %>
            <div class="col-md-6">
                <div class="action-card p-5 text-center h-100 d-flex flex-column justify-content-center transition-all">
                    <i class="bi bi-wrench-adjustable fs-1 text-accent mb-3"></i>
                    <h4 class="fw-bold mb-3">Taller de Mantenimiento</h4>
                    <p class="text-secondary mb-4 fs-6">Gestiona las ordenes de trabajo asignadas a ti y actualiza su estado.</p>
                    <a href="maintenance" class="btn btn-accent rounded-pill px-5 py-2 mt-auto mx-auto fw-bold">Ingresar al Taller</a>
                </div>
            </div>
            <div class="col-md-6">
                <div class="action-card p-5 text-center h-100 d-flex flex-column justify-content-center transition-all">
                    <i class="bi bi-upc-scan fs-1 text-accent mb-3"></i>
                    <h4 class="fw-bold mb-3">Buscar Repuesto</h4>
                    <p class="text-secondary mb-4 fs-6">Verifica disponibilidad de inventario escaneando codigos de barras.</p>
                    <a href="search_product.jsp" class="btn btn-moto-outline rounded-pill px-5 py-2 mt-auto mx-auto fw-bold">Abrir Escaner</a>
                </div>
            </div>

        <% } else { // Admin (1), Bodeguero (3), Cajero (4) %>

            <% if(user.getRoleId() == 1) { %>
            <div class="col-12 mb-5">
                <div class="d-flex align-items-center mb-4">
                    <i class="bi bi-bar-chart-line-fill fs-3 text-accent me-3"></i>
                    <h4 class="fw-bold mb-0">Estadisticas de Sistema <span class="badge bg-secondary bg-opacity-25 text-light ms-2 fs-6 fw-normal">Ultimos 30 dias</span></h4>
                </div>
                
                <div class="row g-4">
                    <div class="col-xl-4 col-lg-5">
                        <div class="action-card p-4 h-100 d-flex flex-column text-center position-relative overflow-hidden">
                            <div class="position-absolute top-0 start-50 translate-middle-x w-100 h-100 bg-gradient-to-b from-accent to-transparent opacity-10 pointer-events-none" style="background: linear-gradient(180deg, var(--accent-glow) 0%, transparent 100%);"></div>
                            
                            <h6 class="text-secondary text-uppercase fw-bold letter-spacing-1 mb-4 z-1">Rendimiento en Ventas</h6>
                            <i class="bi bi-trophy-fill text-warning fs-1 mb-2 z-1" style="filter: drop-shadow(0 0 10px rgba(255,193,7,0.5));"></i>
                            
                            <h3 id="topCashierName" class="fw-bolder mb-1 z-1">Cargando...</h3>
                            <p class="text-accent small mb-4 z-1 fw-bold">Mejor Cajero del Mes</p>
                            
                            <div class="mt-auto bg-dark bg-opacity-25 p-3 rounded-3 z-1 border border-secondary border-opacity-25">
                                <h4 id="topCashierRevenue" class="text-success fw-bold mb-1">$0.00</h4>
                                <p class="text-secondary small mb-0 fw-bold"><i class="bi bi-box-seam me-1"></i><span id="topCashierSales">0</span> articulos vendidos</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-xl-8 col-lg-7">
                        <div class="action-card p-4 h-100">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <h6 class="text-secondary text-uppercase fw-bold letter-spacing-1 mb-0">Flujo de Inventario vs Ventas</h6>
                                <button class="btn btn-sm btn-outline-secondary border-0"><i class="bi bi-three-dots"></i></button>
                            </div>
                            <div class="chart-container position-relative" style="height: 250px; width: 100%;">
                                <canvas id="salesChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
            
            <div class="col-12 mt-2">
                <h5 class="fw-bold mb-3 d-flex align-items-center">
                    <i class="bi bi-shop me-2 text-accent fs-4"></i>Operaciones de Tienda
                </h5>
                <hr class="border-secondary mt-0 mb-4 opacity-25">
            </div>

            <div class="row g-4 mb-4">
                <% if(user.getRoleId() == 1 || user.getRoleId() == 3) { %>
                <div class="col-md-4">
                    <div class="action-card p-4 text-center h-100 transition-all">
                        <i class="bi bi-box-seam fs-1 text-accent mb-3 d-block"></i>
                        <h5 class="fw-bold mb-2">Inventario</h5>
                        <p class="text-secondary small mb-4 fw-medium">Administra el stock y catalogo de repuestos.</p>
                        <a href="inventory" class="btn btn-moto-outline rounded-pill w-100 mt-auto fw-bold">Gestionar</a>
                    </div>
                </div>
                <% } %>
                
                <% if(user.getRoleId() == 1 || user.getRoleId() == 4) { %>
                <div class="col-md-4">
                    <div class="action-card p-4 text-center h-100 transition-all">
                        <i class="bi bi-cart-check fs-1 text-accent mb-3 d-block"></i>
                        <h5 class="fw-bold mb-2">Punto de Venta</h5>
                        <p class="text-secondary small mb-4 fw-medium">Caja registradora con soporte de escaner.</p>
                        <a href="cashier" class="btn btn-accent rounded-pill w-100 mt-auto text-dark fw-bold">Abrir Caja</a>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="action-card p-4 text-center h-100 transition-all">
                        <i class="bi bi-upc-scan fs-1 text-accent mb-3 d-block"></i>
                        <h5 class="fw-bold mb-2">Consultar Repuesto</h5>
                        <p class="text-secondary small mb-4 fw-medium">Escanea o busca articulos rapidamente.</p>
                        <a href="search_product.jsp" class="btn btn-moto-outline rounded-pill w-100 mt-auto fw-bold">Consultar</a>
                    </div>
                </div>
                <% } %>
            </div>

            <% if(user.getRoleId() == 1) { %>
            <div class="col-12 mt-5">
                <h5 class="fw-bold mb-3 d-flex align-items-center">
                    <i class="bi bi-gear-wide-connected me-2 text-accent fs-4"></i>Administracion General
                </h5>
                <hr class="border-secondary mt-0 mb-4 opacity-25">
            </div>

            <div class="row g-4 mb-4">
                <div class="col-md-3 col-sm-6">
                    <div class="action-card p-4 text-center h-100 transition-all">
                        <i class="bi bi-wrench-adjustable fs-2 text-accent mb-3 d-block"></i>
                        <h6 class="fw-bold mb-2">Taller</h6>
                        <p class="text-secondary small mb-4 fw-medium" style="font-size: 0.8rem;">Control de ordenes de trabajo.</p>
                        <a href="maintenance" class="btn btn-sm btn-moto w-100 rounded-pill fw-bold">Ingresar</a>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6">
                    <div class="action-card p-4 text-center h-100 transition-all">
                        <i class="bi bi-people fs-2 text-accent mb-3 d-block"></i>
                        <h6 class="fw-bold mb-2">Personal</h6>
                        <p class="text-secondary small mb-4 fw-medium" style="font-size: 0.8rem;">Usuarios y carnets QR.</p>
                        <a href="employees" class="btn btn-sm btn-moto-outline w-100 rounded-pill fw-bold">Gestionar</a>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6">
                    <div class="action-card p-4 text-center h-100 transition-all">
                        <i class="bi bi-clock-history fs-2 text-accent mb-3 d-block"></i>
                        <h6 class="fw-bold mb-2">Asistencia</h6>
                        <p class="text-secondary small mb-4 fw-medium" style="font-size: 0.8rem;">Terminal de fichaje de empleados.</p>
                        <a href="time_tracking.jsp" class="btn btn-sm btn-moto-outline w-100 rounded-pill fw-bold">Terminal</a>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6">
                    <div class="action-card p-4 text-center h-100 transition-all">
                        <i class="bi bi-journal-richtext fs-2 text-accent mb-3 d-block"></i>
                        <h6 class="fw-bold mb-2">Historiales</h6>
                        <p class="text-secondary small mb-4 fw-medium" style="font-size: 0.8rem;">Auditoria de ventas y sistema.</p>
                        <a href="sales_history.jsp" class="btn btn-sm btn-moto w-100 rounded-pill fw-bold">Revisar</a>
                    </div>
                </div>
            </div>
            <% } %>
        <% } %>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<% if(user.getRoleId() == 1) { %>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
document.addEventListener("DOMContentLoaded", function() {
    fetch('dashboardData?action=topCashier')
        .then(res => res.json())
        .then(data => {
            if(data.name) {
                document.getElementById('topCashierName').textContent = data.name;
                document.getElementById('topCashierRevenue').textContent = '$' + data.total_revenue.toLocaleString('es-CO', {minimumFractionDigits: 2});
                document.getElementById('topCashierSales').textContent = data.total_products;
            } else {
                document.getElementById('topCashierName').textContent = 'Sin Datos';
            }
        }).catch(err => {
            document.getElementById('topCashierName').textContent = 'Error';
        });

    fetch('dashboardData?action=graphData')
        .then(res => res.json())
        .then(data => {
            const ctx = document.getElementById('salesChart').getContext('2d');
            const isLight = document.body.classList.contains('light-mode');
            
            const accentColor = getComputedStyle(document.documentElement).getPropertyValue('--accent-orange').trim() || '#00E5FF';
            const accentGlow = getComputedStyle(document.documentElement).getPropertyValue('--accent-glow').trim() || 'rgba(0, 229, 255, 0.4)';
            const secondaryColor = isLight ? '#6c757d' : '#E2E8F0';
            const secondaryBg = isLight ? 'rgba(108, 117, 125, 0.1)' : 'rgba(226, 232, 240, 0.1)';
            const gridColor = isLight ? 'rgba(0,0,0,0.05)' : 'rgba(255,255,255,0.05)';
            const textColor = isLight ? '#495057' : '#adb5bd';
            
            Chart.defaults.color = textColor;
            Chart.defaults.font.family = "'Inter', sans-serif";
            
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: data.labels,
                    datasets: [
                        {
                            label: 'Repuestos Ingresados',
                            data: data.entered,
                            borderColor: secondaryColor,
                            backgroundColor: secondaryBg,
                            borderWidth: 2,
                            pointBackgroundColor: secondaryColor,
                            pointBorderColor: isLight ? '#fff' : '#121417',
                            pointHoverRadius: 6,
                            tension: 0.4,
                            fill: true
                        },
                        {
                            label: 'Repuestos Vendidos',
                            data: data.sold,
                            borderColor: accentColor,
                            backgroundColor: accentGlow,
                            borderWidth: 3,
                            pointBackgroundColor: accentColor,
                            pointBorderColor: isLight ? '#fff' : '#121417',
                            pointHoverRadius: 6,
                            tension: 0.4,
                            fill: true
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: {
                        mode: 'index',
                        intersect: false,
                    },
                    scales: {
                        y: { 
                            beginAtZero: true, 
                            grid: { color: gridColor, drawBorder: false },
                            border: { dash: [5, 5] }
                        },
                        x: { 
                            grid: { display: false },
                            border: { display: false }
                        }
                    },
                    plugins: {
                        legend: { 
                            position: 'top',
                            align: 'end',
                            labels: { usePointStyle: true, boxWidth: 8, padding: 20 }
                        },
                        tooltip: {
                            backgroundColor: isLight ? 'rgba(255,255,255,0.9)' : 'rgba(30,32,36,0.9)',
                            titleColor: isLight ? '#000' : '#fff',
                            bodyColor: isLight ? '#333' : '#ddd',
                            borderColor: gridColor,
                            borderWidth: 1,
                            padding: 12,
                            boxPadding: 6
                        }
                    }
                }
            });
        });
});
</script>
<% } %>
</body>
</html>