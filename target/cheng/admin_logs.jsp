<%@ page import="com.adso.cheng.models.User" %>
<%@ page import="com.adso.cheng.utils.DbConnection" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRoleId() != 1) { // Only Admin
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Registros Administrativos - Asama Moto Parts</title>
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
            border-left: 5px solid var(--accent-orange);
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
            border: 1px solid rgba(255,255,255,0.05);
            margin-bottom: 25px;
        }
        
        .card { background: var(--metallic-gunmetal); border-radius: 15px; border: 1px solid rgba(255,255,255,0.05); color: #fff; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        .card-header { background: transparent !important; border-bottom: 1px solid rgba(255,255,255,0.1); font-weight: 600; padding: 15px 20px; }
        
        .table-dark { background-color: transparent !important; }
        .table { color: #ccc; }
        .table th, .table td { border-color: rgba(255,255,255,0.1); }
    </style>
    <link rel="stylesheet" href="resources/theme.css">
</head>
<body>
<script src="resources/theme.js"></script>

<%@ include file="navbar.jsp" %>

<div class="container mt-4">
    <div class="row mb-4">
        <div class="col-md-4">
            <div class="dashboard-stats">
                <h6 class="text-secondary text-uppercase mb-2"><i class="bi bi-graph-up-arrow text-danger"></i> Ventas de Hoy</h6>
                <%
                    double todaySales = 0;
                    try (Connection conn = DbConnection.getConnection();
                         Statement stmt = conn.createStatement();
                         ResultSet rs = stmt.executeQuery("SELECT SUM(total_price) FROM sales WHERE DATE(sale_date) = CURRENT_DATE")) {
                        if(rs.next()) todaySales = rs.getDouble(1);
                    } catch(Exception e) {}
                %>
                <h2 class="mb-0 text-white fw-bold">$<%= String.format("%.2f", todaySales) %></h2>
            </div>
        </div>
    </div>

    <div class="card shadow-sm">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="mb-0 text-danger"><i class="bi bi-clock-history"></i> Control de Asistencia (Entrada / Salida)</h5>
            <button class="btn btn-sm btn-secondary" style="border-radius:20px;" onclick="window.print()"><i class="bi bi-printer"></i> Imprimir Reporte</button>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-borderless table-hover m-0">
                    <thead style="border-bottom: 1px solid rgba(255,255,255,0.1);">
                        <tr>
                            <th class="text-secondary">Fecha</th>
                            <th class="text-secondary">Empleado</th>
                            <th class="text-secondary">Rol</th>
                            <th class="text-secondary">Hora Entrada</th>
                            <th class="text-secondary">Hora Salida</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            String sql = "SELECT t.date, u.full_name, r.name as role_name, t.entry_time, t.exit_time " +
                                         "FROM time_tracking t " +
                                         "JOIN users u ON t.user_id = u.id " +
                                         "JOIN roles r ON u.role_id = r.id " +
                                         "ORDER BY t.date DESC, t.entry_time DESC LIMIT 100";
                            try (Connection conn = DbConnection.getConnection();
                                 Statement stmt = conn.createStatement();
                                 ResultSet rs = stmt.executeQuery(sql)) {
                                while(rs.next()) {
                        %>
                        <tr>
                            <td><%= rs.getDate("date") %></td>
                            <td><strong class="text-white"><%= rs.getString("full_name") %></strong></td>
                            <td><span class="badge bg-secondary"><%= rs.getString("role_name") %></span></td>
                            <td class="text-success"><%= rs.getTime("entry_time") %></td>
                            <td class="text-danger"><%= rs.getTimestamp("exit_time") != null ? rs.getTime("exit_time") : "Sin marcar" %></td>
                        </tr>
                        <%      }
                            } catch (Exception e) { e.printStackTrace(); }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

</body>
</html>
