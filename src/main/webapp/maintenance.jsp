<%@ page import="com.adso.cheng.models.User" %>
<%@ page import="com.adso.cheng.models.Product" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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
    <link rel="stylesheet" href="resources/theme.css?v=6">
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
        
        /* --- LEGIBILIDAD EXTREMA --- */
        .text-secondary, .text-muted { 
            color: rgba(255, 255, 255, 0.9) !important; 
            font-weight: 600;
        }
        body.light-mode .text-secondary, body.light-mode .text-muted { 
            color: rgba(0, 0, 0, 0.8) !important; 
            font-weight: 700;
        }

        /* Custom Nav Pills / Tabs */
        .nav-tabs-custom .nav-link {
            color: var(--text-color) !important;
            border: 2px solid rgba(255, 255, 255, 0.15) !important;
            background: transparent !important;
            transition: all 0.3s ease;
        }
        body.light-mode .nav-tabs-custom .nav-link {
            border-color: rgba(0, 0, 0, 0.15) !important;
        }
        .nav-tabs-custom .nav-link.active {
            background-color: var(--accent-orange) !important;
            color: #121417 !important;
            border-color: var(--accent-orange) !important;
            box-shadow: 0 4px 15px var(--accent-glow);
        }

        /* Tablas: Forzar contraste sobreescribiendo Bootstrap */
        .table { 
            --bs-table-bg: transparent;
            --bs-table-color: var(--text-color);
            color: var(--text-color) !important; 
        }
        .table th { 
            font-weight: 800 !important; 
            letter-spacing: 1px; 
            font-size: 0.9rem; 
            border-bottom: 3px solid var(--card-border) !important; 
            color: rgba(255, 255, 255, 0.9) !important;
        }
        body.light-mode .table th {
            color: rgba(0, 0, 0, 0.8) !important;
        }
        .table td { 
            font-weight: 700 !important; 
            font-size: 1.05rem !important; 
            border-bottom: 1px solid var(--card-border) !important; 
            vertical-align: middle; 
            color: #ffffff !important; 
        }
        body.light-mode .table td {
            color: #121417 !important;
        }
        .table tbody tr:hover td { 
            background-color: rgba(255, 255, 255, 0.1) !important; 
        }
        body.light-mode .table tbody tr:hover td { 
            background-color: rgba(0, 0, 0, 0.05) !important; 
        }

        /* Inputs y Selects dentro de la tabla */
        .table .form-select, .table .form-control {
            background-color: rgba(255, 255, 255, 0.08) !important;
            border: 1px solid rgba(255, 255, 255, 0.2) !important;
            color: #ffffff !important;
        }
        body.light-mode .table .form-select, body.light-mode .table .form-control {
            background-color: #ffffff !important;
            border: 1px solid rgba(0, 0, 0, 0.2) !important;
            color: #121417 !important;
        }
    </style>
</head>
<body>
<script src="resources/theme.js?v=2"></script>

<%@ include file="navbar.jsp" %>

<div class="container py-4 mt-2">
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <div>
            <h3 class="fw-bold mb-1"><i class="bi bi-wrench-adjustable-circle me-2" style="color:var(--accent-orange)"></i><fmt:message key="maintenance.header" /></h3>
            <p class="text-secondary mb-0"><fmt:message key="maintenance.subtitle" /></p>
        </div>
        <% if(user.getRoleId() == 1) { %>
        <div class="d-flex gap-2">
            <button class="btn btn-accent rounded-pill px-3" data-bs-toggle="modal" data-bs-target="#registerJobModal">
                <i class="bi bi-plus-circle me-1"></i> <fmt:message key="maintenance.create_job_title" />
            </button>
            <button class="btn btn-moto-outline rounded-pill px-3" data-bs-toggle="modal" data-bs-target="#registerMotoModal">
                <i class="bi bi-bicycle me-1"></i> <fmt:message key="maintenance.register_moto_title" />
            </button>
        </div>
        <% } %>
    </div>

    <!-- Tabs -->
    <ul class="nav nav-pills nav-tabs-custom mb-4 gap-2" role="tablist">
        <li class="nav-item"><a class="nav-link active px-4 py-2 rounded-pill fw-bold border border-2" data-bs-toggle="tab" href="#tabJobs"><fmt:message key="maintenance.tab_jobs" /></a></li>
        <% if(user.getRoleId() == 1) { %>
        <li class="nav-item"><a class="nav-link px-4 py-2 rounded-pill fw-bold border border-2" data-bs-toggle="tab" href="#tabNewMoto"><fmt:message key="maintenance.registered_motos_title" /></a></li>
        <% } %>
    </ul>

    <div class="tab-content">
        <!-- TAB 1: Orders List -->
        <div class="tab-pane fade show active" id="tabJobs">
            <div class="section-card">
                <h5 class="section-title"><i class="bi bi-clipboard-check me-2"></i><fmt:message key="maintenance.jobs_title" /></h5>
                <div class="table-responsive">
                    <table class="table align-middle table-borderless table-hover m-0">
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
                                <td class="fw-bold text-white"><%= job.get("plate") %></td>
                                <td><%= job.get("motoBrand") %> <%= job.get("motoModel") %></td>
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
                                        <input type="hidden" name="cost" value="<%= job.get("cost") %>">
                                        <button type="submit" class="btn btn-accent btn-sm" style="font-size:0.7rem;padding:5px 10px;" title="Actualizar Estado">OK</button>
                                        <button type="button" class="btn btn-outline-info btn-sm ms-1" style="font-size:0.7rem;padding:5px 8px;" onclick="openRequestPartModal(<%= job.get("id") %>)" title="Pedir Repuesto"><i class="bi bi-tools"></i></button>
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
        <!-- TAB 2: Registered Motorcycles -->
        <div class="tab-pane fade" id="tabNewMoto">
            <div class="section-card">
                <h5 class="section-title"><i class="bi bi-list-ul me-2"></i><fmt:message key="maintenance.registered_motos_title" /></h5>
                <div class="table-responsive">
                    <table class="table align-middle table-borderless table-hover m-0">
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
                                <td class="fw-bold text-white"><%= m.get("plate") %></td>
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
        <% } %>
    </div>
</div>

<% if(user.getRoleId() == 1) { %>
<!-- Modal Crear Trabajo -->
<div class="modal fade" id="registerJobModal" tabindex="-1" aria-labelledby="registerJobModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-secondary">
      <div class="modal-header border-secondary">
        <h5 class="modal-title text-accent fw-bold" id="registerJobModalLabel">
            <i class="bi bi-plus-circle me-2"></i><fmt:message key="maintenance.create_job_title" />
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter: var(--close-btn-filter);"></button>
      </div>
      <form action="maintenance" method="POST">
          <div class="modal-body p-4">
              <input type="hidden" name="action" value="addJob">
              <div class="mb-3">
                  <label class="form-label text-secondary small fw-semibold"><fmt:message key="maintenance.moto_plate_label" /></label>
                  <select name="motorcycleId" class="form-select" required>
                      <option value=""><fmt:message key="maintenance.select_option" /></option>
                      <% for(Map<String, Object> m : motorcycles) { %>
                      <option value="<%= m.get("id") %>"><%= m.get("plate") %> - <%= m.get("brand") %> <%= m.get("model") %></option>
                      <% } %>
                  </select>
              </div>
              <div class="mb-3">
                  <label class="form-label text-secondary small fw-semibold"><fmt:message key="maintenance.assigned_mechanic_label" /></label>
                  <select name="mechanicId" class="form-select" required>
                      <option value=""><fmt:message key="maintenance.select_option" /></option>
                      <% for(Map<String, Object> mech : mechanics) { %>
                      <option value="<%= mech.get("id") %>"><%= mech.get("fullName") %></option>
                      <% } %>
                  </select>
              </div>
              <div class="mb-3">
                  <label class="form-label text-secondary small fw-semibold"><fmt:message key="maintenance.job_desc_label" /></label>
                  <textarea name="description" class="form-control" rows="4" placeholder="<fmt:message key='maintenance.job_desc_placeholder'/>" required></textarea>
              </div>
          </div>
          <div class="modal-footer border-secondary">
            <button type="button" class="btn btn-outline-secondary rounded-pill" data-bs-dismiss="modal"><fmt:message key="employees.cancel" /></button>
            <button type="submit" class="btn btn-accent rounded-pill fw-bold"><fmt:message key="maintenance.create_job_btn" /></button>
          </div>
      </form>
    </div>
  </div>
</div>

<!-- Modal Registrar Motocicleta -->
<div class="modal fade" id="registerMotoModal" tabindex="-1" aria-labelledby="registerMotoModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-secondary">
      <div class="modal-header border-secondary">
        <h5 class="modal-title text-accent fw-bold" id="registerMotoModalLabel">
            <i class="bi bi-bicycle me-2"></i><fmt:message key="maintenance.register_moto_title" />
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter: var(--close-btn-filter);"></button>
      </div>
      <form action="maintenance" method="POST">
          <div class="modal-body p-4">
              <input type="hidden" name="action" value="addMotorcycle">
              <div class="mb-3">
                  <label class="form-label text-secondary small fw-semibold"><fmt:message key="maintenance.customer" /></label>
                  <select name="customerId" class="form-select" required>
                      <option value=""><fmt:message key="maintenance.select_option" /></option>
                      <% for(Map<String, Object> c : customers) { %>
                      <option value="<%= c.get("id") %>"><%= c.get("fullName") %> (<%= c.get("email") %>)</option>
                      <% } %>
                  </select>
              </div>
              <div class="mb-3">
                  <label class="form-label text-secondary small fw-semibold"><fmt:message key="maintenance.plate_label" /></label>
                  <input type="text" name="plate" class="form-control" placeholder="<fmt:message key='maintenance.plate_placeholder'/>" required>
              </div>
              <div class="mb-3">
                  <label class="form-label text-secondary small fw-semibold"><fmt:message key="maintenance.brand_label" /></label>
                  <input type="text" name="brand" class="form-control" placeholder="<fmt:message key='maintenance.brand_placeholder'/>" required>
              </div>
              <div class="mb-3">
                  <label class="form-label text-secondary small fw-semibold"><fmt:message key="maintenance.model_label" /></label>
                  <input type="text" name="model" class="form-control" placeholder="<fmt:message key='maintenance.model_placeholder'/>" required>
              </div>
              <div class="mb-3">
                  <label class="form-label text-secondary small fw-semibold"><fmt:message key="maintenance.year_label" /></label>
                  <input type="number" name="year" class="form-control" placeholder="2024" min="1980" max="2030" required>
              </div>
          </div>
          <div class="modal-footer border-secondary">
            <button type="button" class="btn btn-outline-secondary rounded-pill" data-bs-dismiss="modal"><fmt:message key="employees.cancel" /></button>
            <button type="submit" class="btn btn-accent rounded-pill fw-bold"><fmt:message key="maintenance.register_moto_btn" /></button>
          </div>
      </form>
    </div>
  </div>
</div>
<% } %>

<!-- Modal Pedir Repuesto -->
<div class="modal fade" id="requestPartModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-secondary">
      <div class="modal-header border-secondary">
        <h5 class="modal-title text-accent fw-bold">
            <i class="bi bi-tools me-2"></i>Pedir Repuesto
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter: var(--close-btn-filter);"></button>
      </div>
      <form action="maintenance" method="POST">
          <div class="modal-body p-4">
              <input type="hidden" name="action" value="requestPart">
              <input type="hidden" name="jobId" id="partJobId" value="">
              
              <div class="mb-3">
                  <label class="form-label text-secondary small fw-semibold">Repuesto del Catálogo</label>
                  <div class="dropdown w-100">
                      <button class="btn form-select text-start d-flex justify-content-between align-items-center w-100" type="button" data-bs-toggle="dropdown" aria-expanded="false" id="selectedProductBtn" style="background-color: rgba(255, 255, 255, 0.08); border: 1px solid rgba(255, 255, 255, 0.2); color: #fff;">
                          <span>Seleccionar...</span>
                      </button>
                      <div class="dropdown-menu w-100 p-0 shadow" style="max-height: 350px; overflow-y: auto; background-color: var(--card-bg); border: 1px solid var(--card-border);">
                          <div class="p-2 position-sticky top-0 z-1" style="background-color: var(--card-bg); border-bottom: 1px solid rgba(255,255,255,0.1);">
                              <input type="text" class="form-control form-control-sm" id="catalogSearch" placeholder="Buscar por nombre..." onkeyup="filterCatalog()" style="background-color: rgba(255, 255, 255, 0.1); color: white; border: none;">
                          </div>
                          <div id="catalogItems">
                              <% 
                              List<Product> inventory = (List<Product>) request.getAttribute("inventory");
                              if (inventory != null) {
                                  for(Product p : inventory) { 
                                      String img = p.getImageUrl() != null && !p.getImageUrl().isEmpty() ? p.getImageUrl() : "resources/placeholder.png";
                              %>
                              <a class="dropdown-item d-flex align-items-center py-2 catalog-item" href="javascript:void(0)" onclick="selectCatalogProduct(<%= p.getId() %>, '<%= p.getPrice() %>', '<%= p.getName().replace("'", "\\'") %>')" style="border-bottom: 1px solid rgba(255,255,255,0.05);">
                                  <img src="<%= img %>" style="width:40px;height:40px;object-fit:cover;border-radius:6px;" class="me-3">
                                  <div>
                                      <div class="fw-bold text-white catalog-item-name" style="white-space: normal; line-height: 1.2;"><%= p.getName() %></div>
                                      <div class="small" style="color: var(--accent-orange);">Stock: <%= p.getStock() %> | $<%= String.format("%.2f", p.getPrice()) %></div>
                                  </div>
                              </a>
                              <% } } %>
                          </div>
                      </div>
                  </div>
                  <input type="hidden" name="productId" id="partProductHidden" required>
                  <input type="hidden" name="productPrice" id="partProductPrice" value="0">
              </div>
              <div class="row">
                  <div class="col-md-6 mb-3">
                      <label class="form-label text-secondary small fw-semibold">Cantidad</label>
                      <input type="number" name="quantity" class="form-control" value="1" min="1" required>
                  </div>
                  <div class="col-md-6 mb-3">
                      <label class="form-label text-secondary small fw-semibold">Costo Mano de Obra ($)</label>
                      <input type="number" name="laborCost" step="0.01" min="0" class="form-control" value="0" required>
                  </div>
              </div>
              <div class="mb-3">
                  <label class="form-label text-secondary small fw-semibold">Motivo / Descripción</label>
                  <input type="text" name="reason" class="form-control" placeholder="Ej: Cambio de balatas" required>
              </div>
          </div>
          <div class="modal-footer border-secondary">
            <button type="button" class="btn btn-outline-secondary rounded-pill" data-bs-dismiss="modal">Cancelar</button>
            <button type="submit" class="btn btn-accent rounded-pill fw-bold">Pedir Repuesto</button>
          </div>
      </form>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function openRequestPartModal(jobId) {
        document.getElementById('partJobId').value = jobId;
        new bootstrap.Modal(document.getElementById('requestPartModal')).show();
    }
    
    function selectCatalogProduct(id, price, name) {
        document.getElementById('partProductHidden').value = id;
        document.getElementById('partProductPrice').value = price;
        document.getElementById('selectedProductBtn').querySelector('span').innerText = name;
    }

    function filterCatalog() {
        var input = document.getElementById("catalogSearch").value.toLowerCase();
        var items = document.querySelectorAll(".catalog-item");
        items.forEach(function(item) {
            var name = item.querySelector(".catalog-item-name").innerText.toLowerCase();
            if (name.includes(input)) {
                item.classList.remove("d-none");
            } else {
                item.classList.add("d-none");
            }
        });
    }
</script>
</body>
</html>
