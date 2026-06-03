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
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --bg-color: #0a0a0a;
            --text-color: #f0f0f0;
            --nav-bg: rgba(10, 10, 10, 0.9);
            --accent-orange: #FF6B35;
            --accent-dark: #2D3436;
            --card-bg: #1a1a1a;
            --card-border: rgba(255,255,255,0.06);
        }
        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg-color);
            color: var(--text-color);
        }
        .navbar {
            background-color: var(--nav-bg);
            backdrop-filter: blur(20px);
            border-bottom: 1px solid var(--card-border);
        }
        .navbar-brand { color: #fff !important; font-weight: 800; font-size: 1.2rem; }
        .navbar-brand span { color: var(--accent-orange); }
        .welcome-card {
            background: linear-gradient(145deg, #141414 0%, #1a1a1a 100%);
            border-radius: 20px;
            padding: 40px;
            text-align: center;
            border: 1px solid var(--card-border);
            margin-top: 40px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.5);
        }
        .action-card {
            background: var(--card-bg);
            border-radius: 15px;
            padding: 25px;
            height: 100%;
            border: 1px solid var(--card-border);
            transition: all 0.3s ease;
        }
        .action-card:hover { transform: translateY(-5px); border-color: var(--accent-orange); box-shadow: 0 8px 25px rgba(255,107,53,0.15); }
        .action-card .card-icon { color: var(--accent-orange); }
        .btn-moto {
            background-color: var(--accent-orange);
            color: #fff;
            border-radius: 30px;
            padding: 10px 20px;
            font-weight: 600;
            border: none;
            transition: 0.3s;
        }
        .btn-moto:hover { background-color: #E55A2B; color: white; }
        .btn-moto-outline {
            background-color: transparent;
            color: var(--accent-orange);
            border: 1px solid var(--accent-orange);
            border-radius: 30px;
            padding: 10px 20px;
            font-weight: 600;
            transition: 0.3s;
        }
        .btn-moto-outline:hover { background-color: var(--accent-orange); color: white; }
        .form-control {
            background: var(--accent-dark);
            border: 1px solid rgba(255,255,255,0.1);
            color: #fff;
            border-radius: 10px;
        }
        .form-control:focus {
            background: var(--accent-dark);
            color: #fff;
            border-color: var(--accent-orange);
            box-shadow: none;
        }
        .table { color: #ccc; }
        .table th, .table td { border-color: rgba(255,255,255,0.08); }
        .role-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            background: rgba(255,107,53,0.15);
            color: var(--accent-orange);
            border: 1px solid rgba(255,107,53,0.3);
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="dashboard.jsp"><i class="bi bi-gear-wide-connected me-2"></i>Asama<span>MotoParts</span></a>
        <div class="d-flex align-items-center gap-3">
            <span class="role-badge">
                <% if(user.getRoleId()==1) out.print("Admin");
                   else if(user.getRoleId()==2) out.print("Contador");
                   else if(user.getRoleId()==3) out.print("Bodeguero");
                   else if(user.getRoleId()==4) out.print("Cajero");
                   else if(user.getRoleId()==5) out.print("Cliente");
                   else if(user.getRoleId()==6) out.print("Mecánico"); %>
            </span>
            <a class="btn btn-moto-outline btn-sm" href="logout">Cerrar Sesión</a>
        </div>
    </div>
</nav>

<div class="container pb-5">
    <div class="row justify-content-center">
        <div class="col-md-11">
            <div class="welcome-card">
                <h2 class="fw-bold">Bienvenido, <span style="color:var(--accent-orange)"><%= user.getFullName() %></span></h2>
                <hr style="border-color: rgba(255,255,255,0.08);">
                <p class="text-secondary mb-5">Selecciona el módulo al que deseas acceder según tus permisos.</p>
                
                <div class="row g-4 text-start">
                    <% if(user.getRoleId() == 2) { // Contador %>
                        <div class="col-md-6 mx-auto">
                            <div class="action-card text-center">
                                <i class="bi bi-graph-up-arrow fs-1 card-icon mb-3"></i>
                                <h5>Módulo de Contabilidad</h5>
                                <p class="text-secondary small">Revisa las ventas y transacciones registradas.</p>
                                <a href="accountant.jsp" class="btn btn-moto w-100">Ver Reportes</a>
                            </div>
                        </div>

                    <% } else if(user.getRoleId() == 5) { // Cliente %>
                        <div class="col-md-5">
                            <div class="action-card">
                                <h5 style="color:var(--accent-orange)" class="mb-4"><i class="bi bi-person-circle"></i> Editar Perfil</h5>
                                <% if(request.getParameter("msg") != null) { %>
                                    <div class="alert alert-success py-2 small"><%= request.getParameter("msg") %></div>
                                <% } %>
                                <form action="profile" method="POST">
                                    <div class="mb-3">
                                        <label class="form-label small text-secondary">Nombre Completo</label>
                                        <input type="text" name="fullName" class="form-control" value="<%= user.getFullName() %>" required>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label small text-secondary">Cédula</label>
                                        <input type="text" name="documentId" class="form-control" value="<%= user.getDocumentId() %>" required>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label small text-secondary">Email</label>
                                        <input type="email" name="email" class="form-control" value="<%= user.getEmail() %>" required>
                                    </div>
                                    <div class="mb-4">
                                        <label class="form-label small text-secondary">Nueva Contraseña</label>
                                        <input type="password" name="password" class="form-control" placeholder="Dejar en blanco para no cambiar">
                                    </div>
                                    <button type="submit" class="btn btn-moto w-100">Guardar Cambios</button>
                                </form>
                            </div>
                        </div>
                        <div class="col-md-7">
                            <div class="action-card" style="max-height: 550px; overflow-y: auto;">
                                <div class="d-flex justify-content-between align-items-center mb-4">
                                    <h5 style="color:var(--accent-orange)" class="mb-0"><i class="bi bi-bag-check"></i> Historial de Compras</h5>
                                    <a href="index.jsp" class="btn btn-sm btn-moto-outline">Ir a Tienda</a>
                                </div>
                                <div class="table-responsive">
                                    <table class="table table-sm table-borderless">
                                        <thead style="border-bottom: 1px solid rgba(255,255,255,0.1);">
                                            <tr>
                                                <th class="text-secondary">Fecha</th>
                                                <th class="text-secondary">Repuesto</th>
                                                <th class="text-secondary">Cant.</th>
                                                <th class="text-secondary">Total</th>
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
                                                <td><%= rs.getTimestamp("sale_date").toString().substring(0, 16) %></td>
                                                <td><%= rs.getString("name") %></td>
                                                <td><%= rs.getInt("quantity") %></td>
                                                <td class="text-white fw-bold">$<%= String.format("%.2f", rs.getDouble("total_price")) %></td>
                                            </tr>
                                            <%
                                                }
                                                if(!hasPurchases) {
                                                    out.print("<tr><td colspan='4' class='text-center text-muted py-4'>No has realizado compras.</td></tr>");
                                                }
                                            } catch(Exception e) { e.printStackTrace(); }
                                            %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <!-- Buscar Producto for Cliente -->
                        <div class="col-md-4 mt-4">
                            <div class="action-card text-center">
                                <i class="bi bi-search fs-1 card-icon mb-3"></i>
                                <h5 class="text-white">Buscar Repuesto</h5>
                                <p class="text-secondary small">Escanea códigos de barras con la cámara.</p>
                                <a href="search_product.jsp" class="btn btn-moto w-100">Escanear</a>
                            </div>
                        </div>

                    <% } else if(user.getRoleId() == 6) { // Mecánico %>
                        <div class="col-md-6">
                            <div class="action-card text-center">
                                <i class="bi bi-wrench-adjustable-circle fs-1 card-icon mb-3"></i>
                                <h5 class="text-white">Taller de Mantenimiento</h5>
                                <p class="text-secondary small">Gestiona las órdenes de trabajo asignadas a ti.</p>
                                <a href="maintenance" class="btn btn-moto w-100">Ir al Taller</a>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="action-card text-center">
                                <i class="bi bi-search fs-1 card-icon mb-3"></i>
                                <h5 class="text-white">Buscar Repuesto</h5>
                                <p class="text-secondary small">Escanea códigos de barras con la cámara.</p>
                                <a href="search_product.jsp" class="btn btn-moto-outline w-100">Escanear</a>
                            </div>
                        </div>

                    <% } else { // Admin (1), Bodeguero (3), Cajero (4) %>
                        <% if(user.getRoleId() == 1 || user.getRoleId() == 3) { %>
                        <div class="col-md-4">
                            <div class="action-card text-center">
                                <i class="bi bi-box-seam fs-1 card-icon mb-3"></i>
                                <h5 class="text-white">Inventario de Repuestos</h5>
                                <p class="text-secondary small">Administra repuestos de motos y genera códigos de barra.</p>
                                <a href="inventory" class="btn btn-moto-outline w-100">Acceder</a>
                            </div>
                        </div>
                        <% } %>
                        
                        <% if(user.getRoleId() == 1 || user.getRoleId() == 4) { %>
                        <div class="col-md-4">
                            <div class="action-card text-center">
                                <i class="bi bi-cart-check fs-1 card-icon mb-3"></i>
                                <h5 class="text-white">Punto de Venta</h5>
                                <p class="text-secondary small">Caja registradora con soporte de escáner físico.</p>
                                <a href="cashier" class="btn btn-moto-outline w-100">Acceder</a>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="action-card text-center">
                                <i class="bi bi-search fs-1 card-icon mb-3"></i>
                                <h5 class="text-white">Buscar Repuesto</h5>
                                <p class="text-secondary small">Escanea códigos de barras con la cámara.</p>
                                <a href="search_product.jsp" class="btn btn-moto w-100">Escanear</a>
                            </div>
                        </div>
                        <% } %>

                        <% if(user.getRoleId() == 1) { %>
                        <div class="col-md-4 mt-4">
                            <div class="action-card text-center">
                                <i class="bi bi-wrench-adjustable-circle fs-1 card-icon mb-3"></i>
                                <h5 class="text-white">Taller de Mantenimiento</h5>
                                <p class="text-secondary small">Gestiona órdenes de trabajo y reparaciones de motos.</p>
                                <a href="maintenance" class="btn btn-moto w-100">Ir al Taller</a>
                            </div>
                        </div>
                        <div class="col-md-4 mt-4">
                            <div class="action-card text-center">
                                <i class="bi bi-people fs-1 card-icon mb-3"></i>
                                <h5 class="text-white">Personal</h5>
                                <p class="text-secondary small">Crea trabajadores y genera carnets.</p>
                                <a href="employees" class="btn btn-moto-outline w-100">Acceder</a>
                            </div>
                        </div>
                        <div class="col-md-4 mt-4">
                            <div class="action-card text-center">
                                <i class="bi bi-clock fs-1 card-icon mb-3"></i>
                                <h5 class="text-white">Terminal de Asistencia</h5>
                                <p class="text-secondary small">Abrir pantalla completa del escáner de carnets.</p>
                                <a href="time_tracking.jsp" class="btn btn-moto-outline w-100">Abrir Terminal</a>
                            </div>
                        </div>
                        <div class="col-md-4 mt-4">
                            <div class="action-card text-center">
                                <i class="bi bi-journal-text fs-1 card-icon mb-3"></i>
                                <h5 class="text-white">Registros e Historiales</h5>
                                <p class="text-secondary small">Ventas de cajeros, ventas online y accesos.</p>
                                <a href="sales_history.jsp" class="btn btn-moto w-100">Ver Historiales</a>
                            </div>
                        </div>
                        
                        <!-- Dashboard Analytics for Admin -->
                        <div class="col-12 mt-5">
                            <h4 class="fw-bold mb-4"><i class="bi bi-speedometer2 me-2" style="color:var(--accent-orange)"></i>Estadísticas (Últimos 30 días)</h4>
                            <div class="row g-4">
                                <div class="col-md-4">
                                    <div class="action-card text-center">
                                        <h5 style="color:var(--accent-orange)" class="mb-3"><i class="bi bi-trophy"></i> Cajero Estrella</h5>
                                        <h3 id="topCashierName" class="text-white fw-bold mb-1">-</h3>
                                        <p class="text-secondary small mb-2">Más ventas realizadas</p>
                                        <h5 id="topCashierRevenue" class="text-white mb-0">$0.00</h5>
                                        <p class="text-muted small"><span id="topCashierSales">0</span> productos</p>
                                    </div>
                                </div>
                                <div class="col-md-8">
                                    <div class="action-card">
                                        <h6 class="text-white mb-3">Flujo de Repuestos (Entrados vs Vendidos)</h6>
                                        <canvas id="salesChart" height="100"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
        </div>
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
                document.getElementById('topCashierRevenue').textContent = '$' + data.total_revenue.toFixed(2);
                document.getElementById('topCashierSales').textContent = data.total_products;
            }
        });

    fetch('dashboardData?action=graphData')
        .then(res => res.json())
        .then(data => {
            const ctx = document.getElementById('salesChart').getContext('2d');
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: data.labels,
                    datasets: [
                        {
                            label: 'Repuestos Entrados',
                            data: data.entered,
                            borderColor: '#FF6B35',
                            backgroundColor: 'rgba(255, 107, 53, 0.1)',
                            borderWidth: 2,
                            tension: 0.3,
                            fill: true
                        },
                        {
                            label: 'Repuestos Vendidos',
                            data: data.sold,
                            borderColor: '#3498db',
                            backgroundColor: 'rgba(52, 152, 219, 0.1)',
                            borderWidth: 2,
                            tension: 0.3,
                            fill: true
                        }
                    ]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: { beginAtZero: true, grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#ccc' } },
                        x: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#ccc' } }
                    },
                    plugins: {
                        legend: { labels: { color: '#fff' } }
                    }
                }
            });
        });
});
</script>
<% } %>
</body>
</html>
