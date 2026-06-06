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
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<link rel="stylesheet" href="resources/theme.css?v=6">
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
