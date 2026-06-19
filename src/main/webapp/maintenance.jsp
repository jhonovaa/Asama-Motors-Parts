<%@ page import="com.adso.cheng.models.User" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 6)) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    List<Map<String, Object>> jobs = (List<Map<String, Object>>) request.getAttribute("jobs");
    List<Map<String, Object>> motorcycles = (List<Map<String, Object>>) request.getAttribute("motorcycles");
    List<Map<String, Object>> mechanics = (List<Map<String, Object>>) request.getAttribute("mechanics");
    List<Map<String, Object>> customers = (List<Map<String, Object>>) request.getAttribute("customers");
    if(jobs == null) jobs = new ArrayList<>();
    if(motorcycles == null) motorcycles = new ArrayList<>();
    if(mechanics == null) mechanics = new ArrayList<>();
    if(customers == null) customers = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="maintenance.title" /></title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        .section-card {
            background: var(--card-bg);
            border-radius: 16px;
            padding: 30px;
            border: 1px solid var(--card-border);
            margin-bottom: 24px;
        }
        .section-title { color: var(--accent-orange); font-weight: 700; margin-bottom: 20px; }
        .badge-pending { background: rgba(255,193,7,0.15); color: #ffc107; border: 1px solid rgba(255,193,7,0.3); }
        .badge-progress { background: rgba(52,152,219,0.15); color: #3498db; border: 1px solid rgba(52,152,219,0.3); }
        .badge-done { background: rgba(46,204,113,0.15); color: #2ecc71; border: 1px solid rgba(46,204,113,0.3); }
        .status-badge { padding: 5px 14px; border-radius: 20px; font-size: 0.78rem; font-weight: 600; }
    </style>
    <link rel="stylesheet" href="resources/theme.css?v=6">
</head>
<body>
<script src="resources/theme.js?v=2"></script>

<%@ include file="navbar.jsp" %>

<div class="container py-4 mt-2">
    <h3 class="fw-bold mb-1"><i class="bi bi-wrench-adjustable-circle me-2" style="color:var(--accent-orange)"></i><fmt:message key="maintenance.header" /></h3>
    <p class="text-secondary mb-4"><fmt:message key="maintenance.subtitle" /></p>

    <!-- Tabs -->
    <ul class="nav nav-tabs mb-4" role="tablist">
        <li class="nav-item"><a class="nav-link active" data-bs-toggle="tab" href="#tabJobs"><fmt:message key="maintenance.tab_jobs" /></a></li>
        <% if(user.getRoleId() == 1) { %>
        <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#tabNewMoto"><fmt:message key="maintenance.tab_register_moto" /></a></li>
        <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#tabNewJob"><fmt:message key="maintenance.tab_new_job" /></a></li>
        <% } %>
    </ul>

    <div class="tab-content">
        <!-- TAB 1: Orders List -->
        <div class="tab-pane fade show active" id="tabJobs">
            <div class="section-card">
                <h5 class="section-title"><i class="bi bi-clipboard-check me-2"></i><fmt:message key="maintenance.jobs_title" /></h5>
                <div class="table-responsive">
                    <table class="table table-sm">
                        <thead>
                            <tr>
                                <th class="text-secondary">#</th>
                                <th class="text-secondary"><fmt:message key="maintenance.plate" /></th>
                                <th class="text-secondary"><fmt:message key="maintenance.moto" /></th>
                                <th class="text-secondary"><fmt:message key="maintenance.customer" /></th>
                                <th class="text-secondary"><fmt:message key="maintenance.mechanic" /></th>
                                <th class="text-secondary"><fmt:message key="maintenance.description" /></th>
                                <th class="text-secondary"><fmt:message key="maintenance.status" /></th>
                                <th class="text-secondary"><fmt:message key="maintenance.cost" /></th>
                                <% if(user.getRoleId() == 1 || user.getRoleId() == 6) { %>
                                <th class="text-secondary"><fmt:message key="maintenance.action" /></th>
                                <% } %>
                            </tr>
                        </thead>
                        <tbody>
                            <% if(jobs.isEmpty()) { %>
                                <tr><td colspan="9" class="text-center text-muted py-4"><fmt:message key="maintenance.no_jobs" /></td></tr>
                            <% } else {
                                for(Map<String, Object> job : jobs) {
                                    String status = (String) job.get("status");
                                    String badgeClass = "badge-pending";
                                    if("EN_PROCESO".equals(status)) badgeClass = "badge-progress";
                                    else if("COMPLETADO".equals(status)) badgeClass = "badge-done";
                            %>
                            <tr>
                                <td><%= job.get("id") %></td>
                                <td class="fw-bold"><%= job.get("plate") %></td>
                                <td><%= job.get("brand") %> <%= job.get("model") %></td>
                                <td><%= job.get("customerName") %></td>
                                <td><%= job.get("mechanicName") != null ? job.get("mechanicName") : "<fmt:message key='maintenance.unassigned' />" %></td>
                                <td class="small"><%= job.get("description") %></td>
                                <td>
                                    <span class="status-badge <%= badgeClass %>">
                                        <% if("PENDIENTE".equals(status)) { %><fmt:message key="maintenance.status_pending" /><% }
                                           else if("EN_PROCESO".equals(status)) { %><fmt:message key="maintenance.status_progress" /><% }
                                           else if("COMPLETADO".equals(status)) { %><fmt:message key="maintenance.status_completed" /><% }
                                           else { %><%= status %><% } %>
                                    </span>
                                </td>
                                <td class="fw-bold">$<%= String.format("%.2f", ((Number)job.get("cost")).doubleValue()) %></td>
                                <% if(user.getRoleId() == 1 || user.getRoleId() == 6) { %>
                                <td>
                                    <% if(!"COMPLETADO".equals(status)) { %>
                                    <form action="maintenance" method="POST" class="d-flex gap-1 align-items-center">
                                        <input type="hidden" name="action" value="updateStatus">
                                        <input type="hidden" name="jobId" value="<%= job.get("id") %>">
                                        <select name="status" class="form-select form-select-sm" style="width:130px;font-size:0.75rem;">
                                            <option value="PENDIENTE" <%= "PENDIENTE".equals(status)?"selected":"" %>><fmt:message key="maintenance.status_pending" /></option>
                                            <option value="EN_PROCESO" <%= "EN_PROCESO".equals(status)?"selected":"" %>><fmt:message key="maintenance.status_progress" /></option>
                                            <option value="COMPLETADO"><fmt:message key="maintenance.status_completed" /></option>
                                        </select>
                                        <input type="number" name="cost" step="0.01" min="0" placeholder="$" class="form-control form-control-sm" style="width:80px;font-size:0.75rem;" value="<%= String.format("%.2f", ((Number)job.get("cost")).doubleValue()) %>">
                                        <button type="submit" class="btn btn-moto btn-sm" style="font-size:0.7rem;padding:5px 10px;"><fmt:message key="maintenance.ok_btn" /></button>
                                    </form>
                                    <% } else { %>
                                    <span class="text-muted small"><fmt:message key="maintenance.finished" /></span>
                                    <% } %>
                                </td>
                                <% } %>
                            </tr>
                            <% } } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <% if(user.getRoleId() == 1) { %>
        <!-- TAB 2: Register Motorcycle -->
        <div class="tab-pane fade" id="tabNewMoto">
            <div class="row g-4">
                <div class="col-md-5">
                    <div class="section-card">
                        <h5 class="section-title"><i class="bi bi-bicycle me-2"></i><fmt:message key="maintenance.register_moto_title" /></h5>
                        <form action="maintenance" method="POST">
                            <input type="hidden" name="action" value="addMotorcycle">
                            <div class="mb-3">
                                <label class="form-label small text-secondary"><fmt:message key="maintenance.customer" /></label>
                                <select name="customerId" class="form-select" required>
                                    <option value=""><fmt:message key="maintenance.select_option" /></option>
                                    <% for(Map<String, Object> c : customers) { %>
                                    <option value="<%= c.get("id") %>"><%= c.get("full_name") %> (<%= c.get("email") %>)</option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label small text-secondary"><fmt:message key="maintenance.plate_label" /></label>
                                <input type="text" name="plate" class="form-control" placeholder="<fmt:message key='maintenance.plate_placeholder'/>" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label small text-secondary"><fmt:message key="maintenance.brand_label" /></label>
                                <input type="text" name="brand" class="form-control" placeholder="<fmt:message key='maintenance.brand_placeholder'/>" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label small text-secondary"><fmt:message key="maintenance.model_label" /></label>
                                <input type="text" name="model" class="form-control" placeholder="<fmt:message key='maintenance.model_placeholder'/>" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label small text-secondary"><fmt:message key="maintenance.year_label" /></label>
                                <input type="number" name="year" class="form-control" placeholder="2024" min="1980" max="2030" required>
                            </div>
                            <button type="submit" class="btn btn-moto w-100"><fmt:message key="maintenance.register_moto_btn" /></button>
                        </form>
                    </div>
                </div>
                <div class="col-md-7">
                    <div class="section-card">
                        <h5 class="section-title"><i class="bi bi-list-ul me-2"></i><fmt:message key="maintenance.registered_motos_title" /></h5>
                        <div class="table-responsive">
                            <table class="table table-sm">
                                <thead>
                                    <tr>
                                        <th class="text-secondary"><fmt:message key="maintenance.plate_label" /></th>
                                        <th class="text-secondary"><fmt:message key="maintenance.brand_label" /></th>
                                        <th class="text-secondary"><fmt:message key="maintenance.model_label" /></th>
                                        <th class="text-secondary"><fmt:message key="maintenance.year_label" /></th>
                                        <th class="text-secondary"><fmt:message key="maintenance.owner" /></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if(motorcycles.isEmpty()) { %>
                                        <tr><td colspan="5" class="text-center text-muted py-3"><fmt:message key="maintenance.no_motos" /></td></tr>
                                    <% } else {
                                        for(Map<String, Object> m : motorcycles) { %>
                                    <tr>
                                        <td class="fw-bold"><%= m.get("plate") %></td>
                                        <td><%= m.get("brand") %></td>
                                        <td><%= m.get("model") %></td>
                                        <td><%= m.get("year") %></td>
                                        <td><%= m.get("customerName") != null ? m.get("customerName") : "-" %></td>
                                    </tr>
                                    <% } } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- TAB 3: New Job -->
        <div class="tab-pane fade" id="tabNewJob">
            <div class="section-card" style="max-width:550px;">
                <h5 class="section-title"><i class="bi bi-plus-circle me-2"></i><fmt:message key="maintenance.create_job_title" /></h5>
                <form action="maintenance" method="POST">
                    <input type="hidden" name="action" value="addJob">
                    <div class="mb-3">
                        <label class="form-label small text-secondary"><fmt:message key="maintenance.moto_plate_label" /></label>
                        <select name="motorcycleId" class="form-select" required>
                            <option value=""><fmt:message key="maintenance.select_option" /></option>
                            <% for(Map<String, Object> m : motorcycles) { %>
                            <option value="<%= m.get("id") %>"><%= m.get("plate") %> - <%= m.get("brand") %> <%= m.get("model") %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small text-secondary"><fmt:message key="maintenance.assigned_mechanic_label" /></label>
                        <select name="mechanicId" class="form-select" required>
                            <option value=""><fmt:message key="maintenance.select_option" /></option>
                            <% for(Map<String, Object> mech : mechanics) { %>
                            <option value="<%= mech.get("id") %>"><%= mech.get("full_name") %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small text-secondary"><fmt:message key="maintenance.job_desc_label" /></label>
                        <textarea name="description" class="form-control" rows="4" placeholder="<fmt:message key='maintenance.job_desc_placeholder'/>" required></textarea>
                    </div>
                    <button type="submit" class="btn btn-moto w-100"><fmt:message key="maintenance.create_job_btn" /></button>
                </form>
            </div>
        </div>
        <% } %>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
