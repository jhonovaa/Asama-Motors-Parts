<%@ page import="com.adso.cheng.models.User" %>
<%@ page import="com.adso.cheng.utils.DbConnection" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
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
    <title><fmt:message key="admin_logs.title" /></title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<link rel="stylesheet" href="resources/theme.css?v=6">
</head>
<body>
<script src="resources/theme.js"></script>

<%@ include file="navbar.jsp" %>

<div class="container mt-4 pb-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold"><i class="bi bi-journal-check text-accent me-2"></i><fmt:message key="admin_logs.header" /></h2>
        <button class="btn btn-outline-secondary rounded-pill" onclick="window.print()"><i class="bi bi-printer me-1"></i> <fmt:message key="admin_logs.print_report" /></button>
    </div>

    <!-- Stats & Active Personnel -->
    <div class="row mb-4">
        <div class="col-md-4 mb-3 mb-md-0">
            <div class="dashboard-stats h-100 p-4">
                <h6 class="text-secondary text-uppercase mb-2"><i class="bi bi-graph-up-arrow text-danger"></i> <fmt:message key="admin_logs.today_sales" /></h6>
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
        <div class="col-md-8">
            <div class="card-custom h-100 p-4 border border-accent border-opacity-50">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h6 class="text-secondary text-uppercase mb-0"><i class="bi bi-person-workspace text-accent"></i> <fmt:message key="admin_logs.active_personnel" /></h6>
                    <button class="btn btn-sm btn-outline-secondary rounded-circle" onclick="location.reload()" title="<fmt:message key='admin_logs.refresh' />">
                        <i class="bi bi-arrow-clockwise"></i>
                    </button>
                </div>
                <div class="d-flex flex-wrap gap-3">
                <%
                    boolean hasActive = false;
                    String activeSql = "SELECT u.full_name, r.name as role_name " +
                                       "FROM users u " +
                                       "JOIN roles r ON u.role_id = r.id " +
                                       "WHERE u.is_online = TRUE ORDER BY u.full_name ASC";
                    try (Connection conn = DbConnection.getConnection();
                         Statement stmt = conn.createStatement();
                         ResultSet rs = stmt.executeQuery(activeSql)) {
                        while(rs.next()) {
                            hasActive = true;
                %>
                    <div class="d-flex align-items-center bg-secondary bg-opacity-10 px-3 py-2 rounded-pill">
                        <div class="position-relative me-2">
                            <i class="bi bi-person-circle fs-4 text-secondary"></i>
                            <span class="position-absolute bottom-0 end-0 p-1 bg-success border border-light rounded-circle" style="width: 10px; height: 10px;"></span>
                        </div>
                        <div>
                            <p class="mb-0 fw-bold lh-1 text-white" style="font-size: 0.9rem;"><%= rs.getString("full_name") %></p>
                            <small class="text-success fw-bold lh-1" style="font-size: 0.75rem;"><%= rs.getString("role_name") %> - <fmt:message key="admin_logs.online" /></small>
                        </div>
                    </div>
                <%
                        }
                    } catch (Exception e) {}
                    if (!hasActive) {
                %>
                    <p class="text-muted small mb-0 w-100 text-center py-2"><fmt:message key="admin_logs.no_active" /></p>
                <% } %>
                </div>
            </div>
        </div>
    </div>

    <!-- Tabs for Tables -->
    <ul class="nav nav-tabs custom-tabs mb-4" id="logsTab" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active fw-bold" id="audit-tab" data-bs-toggle="tab" data-bs-target="#audit" type="button" role="tab"><fmt:message key="admin_logs.tab_audit" /></button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link fw-bold" id="attendance-tab" data-bs-toggle="tab" data-bs-target="#attendance" type="button" role="tab"><fmt:message key="admin_logs.tab_attendance" /></button>
        </li>
    </ul>

    <div class="tab-content" id="logsTabContent">
        <!-- Audit Logs Tab -->
        <div class="tab-pane fade show active" id="audit" role="tabpanel">
            <div class="card shadow-sm border-0">
                <div class="card-body p-0">
                    <div class="table-responsive" style="max-height: 500px;">
                        <table class="table table-hover m-0 align-middle">
                            <thead style="position: sticky; top: 0; background: var(--card-bg); border-bottom: 1px solid rgba(255,255,255,0.1); z-index: 1;">
                                <tr>
                                    <th class="text-secondary small text-uppercase"><fmt:message key="admin_logs.date_time" /></th>
                                    <th class="text-secondary small text-uppercase"><fmt:message key="admin_logs.employee" /></th>
                                    <th class="text-secondary small text-uppercase"><fmt:message key="admin_logs.module" /></th>
                                    <th class="text-secondary small text-uppercase"><fmt:message key="admin_logs.action" /></th>
                                    <th class="text-secondary small text-uppercase"><fmt:message key="admin_logs.operation_detail" /></th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    String auditSql = "SELECT a.created_at, u.full_name, r.name as role_name, a.module, a.action, a.details " +
                                                      "FROM audit_logs a " +
                                                      "JOIN users u ON a.user_id = u.id " +
                                                      "JOIN roles r ON u.role_id = r.id " +
                                                      "ORDER BY a.created_at DESC LIMIT 200";
                                    try (Connection conn = DbConnection.getConnection();
                                         Statement stmt = conn.createStatement();
                                         ResultSet rs = stmt.executeQuery(auditSql)) {
                                        boolean hasLogs = false;
                                        while(rs.next()) {
                                            hasLogs = true;
                                            String module = rs.getString("module");
                                            String badgeColor = "bg-secondary";
                                            if("VENTAS".equals(module)) badgeColor = "bg-success";
                                            else if("INVENTARIO".equals(module)) badgeColor = "bg-primary";
                                            else if("PERSONAL".equals(module)) badgeColor = "bg-warning text-dark";
                                            else if("MANTENIMIENTO".equals(module)) badgeColor = "bg-info text-dark";
                                            else if("GARANTIAS".equals(module)) badgeColor = "bg-danger";
                                %>
                                <tr>
                                    <td class="text-muted small"><%= rs.getTimestamp("created_at").toString().substring(0, 16) %></td>
                                    <td>
                                        <strong class="text-white"><%= rs.getString("full_name") %></strong><br>
                                        <small class="text-secondary" style="font-size: 0.75rem;"><%= rs.getString("role_name") %></small>
                                    </td>
                                    <td><span class="badge <%= badgeColor %> bg-opacity-25 border border-secondary px-2"><%= module %></span></td>
                                    <td class="fw-medium text-accent"><%= rs.getString("action") %></td>
                                    <td class="small text-white opacity-75"><%= rs.getString("details") %></td>
                                </tr>
                                <%      }
                                        if(!hasLogs) {
                                            out.print("<tr><td colspan='5' class='text-center py-4 text-muted'><fmt:message key='admin_logs.no_logs' /></td></tr>");
                                        }
                                    } catch (Exception e) { e.printStackTrace(); }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Attendance Tab -->
        <div class="tab-pane fade" id="attendance" role="tabpanel">
            <div class="card shadow-sm border-0">
                <div class="card-body p-0">
                    <div class="table-responsive" style="max-height: 500px;">
                        <table class="table table-borderless table-hover m-0">
                            <thead style="position: sticky; top: 0; background: var(--card-bg); border-bottom: 1px solid rgba(255,255,255,0.1); z-index: 1;">
                                <tr>
                                    <th class="text-secondary small text-uppercase"><fmt:message key="admin_logs.date" /></th>
                                    <th class="text-secondary small text-uppercase"><fmt:message key="admin_logs.employee" /></th>
                                    <th class="text-secondary small text-uppercase"><fmt:message key="admin_logs.role" /></th>
                                    <th class="text-secondary small text-uppercase"><fmt:message key="admin_logs.entry_time" /></th>
                                    <th class="text-secondary small text-uppercase"><fmt:message key="admin_logs.exit_time" /></th>
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
                                    <td class="text-success fw-medium"><i class="bi bi-box-arrow-in-right me-1"></i><%= rs.getTime("entry_time") %></td>
                                    <td class="text-danger fw-medium">
                                        <% if (rs.getTimestamp("exit_time") != null) { %>
                                            <i class="bi bi-box-arrow-right me-1"></i><%= rs.getTime("exit_time") %>
                                        <% } else { %>
                                            <span class="badge bg-warning text-dark"><i class="bi bi-circle-fill me-1" style="font-size:0.5rem;"></i><fmt:message key="admin_logs.active" /></span>
                                        <% } %>
                                    </td>
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
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
