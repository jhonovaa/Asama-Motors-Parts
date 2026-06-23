<%@ page import="com.adso.cheng.models.User" %>
<%@ page import="com.adso.cheng.models.Product" %>
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
    List<Product> inventory = (List<Product>) request.getAttribute("inventory");
    if(jobs == null) jobs = new ArrayList<>();
    if(motorcycles == null) motorcycles = new ArrayList<>();
    if(mechanics == null) mechanics = new ArrayList<>();
    if(customers == null) customers = new ArrayList<>();
    if(inventory == null) inventory = new ArrayList<>();
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
        .status-badge { padding: 5px 14px; border-radius: 20px; font-size: 0.78rem; font-weight: 600; text-transform: uppercase; }
        .part-card { transition: all 0.2s; cursor: pointer; border: 1px solid var(--card-border); border-radius: 10px; }
        .part-card:hover { transform: translateY(-3px); box-shadow: 0 4px 15px rgba(0,0,0,0.1); border-color: var(--accent-orange); }
        .part-card img { width: 100%; height: 120px; object-fit: contain; border-radius: 10px 10px 0 0; background: #fff; padding: 10px; }
    </style>
    <link rel="stylesheet" href="resources/theme.css?v=6">
</head>
<body>
<script src="resources/theme.js?v=2"></script>

<%@ include file="navbar.jsp" %>

<div class="container py-4 mt-2">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h3 class="fw-bold mb-1"><i class="bi bi-wrench-adjustable-circle me-2" style="color:var(--accent-orange)"></i><fmt:message key="maintenance.header" /></h3>
            <p class="text-secondary mb-0"><fmt:message key="maintenance.subtitle" /></p>
        </div>
        <% if(user.getRoleId() == 1) { %>
        <button class="btn btn-moto" data-bs-toggle="modal" data-bs-target="#newJobModal">
            <i class="bi bi-plus-circle me-2"></i>Nueva Orden
        </button>
        <% } %>
    </div>

    <!-- Tabs -->
    <ul class="nav nav-tabs mb-4" role="tablist">
        <li class="nav-item"><a class="nav-link active" data-bs-toggle="tab" href="#tabJobs"><fmt:message key="maintenance.tab_jobs" /></a></li>
        <% if(user.getRoleId() == 1) { %>
        <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#tabNewMoto"><fmt:message key="maintenance.tab_register_moto" /></a></li>
        <% } %>
    </ul>

    <div class="tab-content">
        <!-- TAB 1: Orders List -->
        <div class="tab-pane fade show active" id="tabJobs">
            <div class="section-card">
                <h5 class="section-title"><i class="bi bi-clipboard-check me-2"></i><fmt:message key="maintenance.jobs_title" /></h5>
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead>
                            <tr>
                                <th class="text-secondary">#</th>
                                <th class="text-secondary"><fmt:message key="maintenance.plate" /></th>
                                <th class="text-secondary"><fmt:message key="maintenance.moto" /></th>
                                <% if(user.getRoleId() == 1) { %>
                                <th class="text-secondary"><fmt:message key="maintenance.customer" /></th>
                                <th class="text-secondary"><fmt:message key="maintenance.mechanic" /></th>
                                <% } %>
                                <th class="text-secondary"><fmt:message key="maintenance.description" /></th>
                                <th class="text-secondary"><fmt:message key="maintenance.status" /></th>
                                <th class="text-secondary text-end">Total</th>
                                <th class="text-secondary text-end">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if(jobs.isEmpty()) { %>
                                <tr><td colspan="9" class="text-center text-muted py-4"><fmt:message key="maintenance.no_jobs" /></td></tr>
                            <% } else {
                                for(Map<String, Object> job : jobs) {
                                    String status = (String) job.get("status");
                                    boolean isPaid = (Boolean) job.get("isPaid");
                                    String badgeClass = "badge-pending";
                                    if("EN_PROCESO".equals(status)) badgeClass = "badge-progress";
                                    else if("COMPLETADO".equals(status)) badgeClass = "badge-done";
                            %>
                            <tr>
                                <td><%= job.get("id") %></td>
                                <td><span class="badge bg-secondary"><%= job.get("plate") %></span></td>
                                <td><%= job.get("motoBrand") %> <%= job.get("motoModel") %></td>
                                <% if(user.getRoleId() == 1) { %>
                                <td><%= job.get("customerName") %></td>
                                <td><%= job.get("mechanicName") != null ? job.get("mechanicName") : "<span class='text-danger'>Sin Asignar</span>" %></td>
                                <% } %>
                                <td class="small text-truncate" style="max-width: 150px;" title="<%= job.get("description") %>"><%= job.get("description") %></td>
                                <td>
                                    <div class="d-flex flex-column gap-1">
                                        <span class="status-badge <%= badgeClass %> w-100 text-center"><%= status.replace("_", " ") %></span>
                                        <% if(isPaid) { %><span class="badge bg-success w-100"><i class="bi bi-check-circle me-1"></i>Pagado</span><% } %>
                                    </div>
                                </td>
                                <td class="fw-bold text-end">$<%= String.format("%,.2f", ((Number)job.get("cost")).doubleValue()) %></td>
                                <td>
                                    <div class="d-flex justify-content-end gap-2">
                                        <button class="btn btn-outline-secondary btn-sm" onclick="viewJobDetails(<%= job.get("id") %>, '<%= job.get("plate") %>', '<%= job.get("motoBrand") %>', '<%= job.get("motoModel") %>', '<%= job.get("customerName") %>', `<%= job.get("description") %>`, <%= job.get("cost") %>)" title="Ver Detalles">
                                            <i class="bi bi-eye"></i>
                                        </button>

                                        <% if(user.getRoleId() == 6 && !"COMPLETADO".equals(status)) { %>
                                            <button class="btn btn-primary btn-sm" onclick="openCatalog(<%= job.get("id") %>)" title="Pedir Repuesto">
                                                <i class="bi bi-tools"></i> Repuesto
                                            </button>
                                        <% } %>
                                        
                                        <% if(user.getRoleId() == 1 || user.getRoleId() == 6) { %>
                                            <% if(!"COMPLETADO".equals(status)) { %>
                                                <button class="btn btn-outline-dark btn-sm" onclick="openEditModal(<%= job.get("id") %>, '<%= status %>', <%= ((Number)job.get("cost")).doubleValue() %>)" title="Editar Estado">
                                                    <i class="bi bi-pencil"></i>
                                                </button>
                                            <% } %>
                                        <% } %>
                                    </div>
                                </td>
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
                        <h5 class="section-title"><i class="bi bi-bicycle me-2"></i>Registrar Moto Nueva</h5>
                        <form action="maintenance" method="POST">
                            <input type="hidden" name="action" value="addMotorcycle">
                            <div class="mb-3">
                                <label class="form-label small text-secondary">Propietario / Cliente</label>
                                <select name="customerId" class="form-select" required>
                                    <option value="">Seleccione Cliente...</option>
                                    <% for(Map<String, Object> c : customers) { %>
                                    <option value="<%= c.get("id") %>"><%= c.get("full_name") %> (<%= c.get("email") %>)</option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label small text-secondary">Placa</label>
                                <input type="text" name="plate" class="form-control text-uppercase" placeholder="AAA-123" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label small text-secondary">Marca</label>
                                <input type="text" name="brand" class="form-control" placeholder="Ej: Yamaha, Suzuki..." required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label small text-secondary">Modelo / Referencia</label>
                                <input type="text" name="model" class="form-control" placeholder="Ej: FZ-150, GN-125" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label small text-secondary">Año</label>
                                <input type="number" name="year" class="form-control" placeholder="2024" min="1980" max="2030" required>
                            </div>
                            <button type="submit" class="btn btn-moto w-100">Registrar Motocicleta</button>
                        </form>
                    </div>
                </div>
                <div class="col-md-7">
                    <div class="section-card">
                        <h5 class="section-title"><i class="bi bi-list-ul me-2"></i>Directorio de Motos</h5>
                        <div class="table-responsive">
                            <table class="table table-sm align-middle">
                                <thead>
                                    <tr>
                                        <th class="text-secondary">Placa</th>
                                        <th class="text-secondary">Marca</th>
                                        <th class="text-secondary">Modelo</th>
                                        <th class="text-secondary">Año</th>
                                        <th class="text-secondary">Propietario</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if(motorcycles.isEmpty()) { %>
                                        <tr><td colspan="5" class="text-center text-muted py-3">No hay motos registradas.</td></tr>
                                    <% } else {
                                        for(Map<String, Object> m : motorcycles) { %>
                                    <tr>
                                        <td class="fw-bold"><span class="badge bg-secondary"><%= m.get("plate") %></span></td>
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
        <% } %>
    </div>
</div>

<!-- Modal: New Job (Administrators Only) -->
<div class="modal fade" id="newJobModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title section-title mb-0"><i class="bi bi-plus-circle me-2"></i>Crear Orden de Trabajo</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form action="maintenance" method="POST">
                    <input type="hidden" name="action" value="addJob">
                    <div class="mb-3">
                        <label class="form-label small text-secondary">Motocicleta a Ingresar</label>
                        <select name="motorcycleId" class="form-select" required>
                            <option value="">Buscar placa o modelo...</option>
                            <% for(Map<String, Object> m : motorcycles) { %>
                            <option value="<%= m.get("id") %>"><%= m.get("plate") %> - <%= m.get("brand") %> <%= m.get("model") %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small text-secondary">Mecánico Asignado</label>
                        <select name="mechanicId" class="form-select" required>
                            <option value="">Seleccione el mecánico a cargo...</option>
                            <% for(Map<String, Object> mech : mechanics) { %>
                            <option value="<%= mech.get("id") %>"><%= mech.get("fullName") %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small text-secondary">Falla / Razón de Ingreso</label>
                        <textarea name="description" class="form-control" rows="4" placeholder="Describa el problema detalladamente..." required></textarea>
                    </div>
                    <button type="submit" class="btn btn-moto w-100">Crear Orden</button>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Job Details (The Eye Button) -->
<div class="modal fade" id="jobDetailsModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold" style="color:var(--accent-orange)"><i class="bi bi-eye me-2"></i>Detalles de la Orden</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="row mb-4">
                    <div class="col-md-6">
                        <h6 class="fw-bold text-secondary text-uppercase" style="font-size:0.8rem">Información de Motocicleta</h6>
                        <p class="mb-1"><span class="text-muted small">Placa:</span> <span class="fw-bold badge bg-secondary" id="detPlate"></span></p>
                        <p class="mb-1"><span class="text-muted small">Moto:</span> <span class="fw-bold" id="detMoto"></span></p>
                        <p class="mb-0"><span class="text-muted small">Dueño:</span> <span class="fw-bold" id="detCustomer"></span></p>
                    </div>
                    <div class="col-md-6">
                        <h6 class="fw-bold text-secondary text-uppercase" style="font-size:0.8rem">Descripción del Problema</h6>
                        <p class="small bg-light p-2 rounded border" id="detDescription"></p>
                    </div>
                </div>

                <h6 class="fw-bold text-secondary text-uppercase" style="font-size:0.8rem">Repuestos y Mano de Obra Aplicados</h6>
                <div class="table-responsive border rounded">
                    <table class="table table-sm mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Repuesto / Trabajo</th>
                                <th>Cantidad</th>
                                <th>Costo Base</th>
                                <th>Mano Obra</th>
                                <th class="text-end">Subtotal</th>
                            </tr>
                        </thead>
                        <tbody id="detPartsList">
                            <!-- Populated by JS -->
                        </tbody>
                        <tfoot>
                            <tr>
                                <th colspan="4" class="text-end">Monto Total de la Orden:</th>
                                <th class="text-end" style="color:var(--accent-orange)" id="detTotalCost"></th>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </div>
            <div class="modal-footer border-0">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Catalog for Mechanics -->
<div class="modal fade" id="catalogModal" tabindex="-1">
    <div class="modal-dialog modal-xl modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header border-0 pb-0 align-items-center">
                <h5 class="modal-title fw-bold" style="color:var(--accent-orange)"><i class="bi bi-box-seam me-2"></i>Catálogo de Repuestos</h5>
                <div class="ms-auto me-3" style="width:300px;">
                    <input type="text" id="catalogSearch" class="form-control" placeholder="Buscar pieza, marca o código..." onkeyup="filterCatalog()">
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 bg-light">
                <div class="row g-3" id="catalogGrid">
                    <% for(Product p : inventory) { %>
                    <div class="col-6 col-md-4 col-lg-3 catalog-item" data-name="<%= p.getName().toLowerCase() %> <%= p.getBrand() != null ? p.getBrand().toLowerCase() : "" %>">
                        <div class="card part-card h-100" onclick="openRequestPartModal(<%= p.getId() %>, '<%= p.getName().replace("'", "\\'") %>', <%= p.getPrice() %>, <%= p.getStock() %>)">
                            <% if(p.getImageUrl() != null && !p.getImageUrl().isEmpty()) { %>
                                <img src="<%= p.getImageUrl() %>" alt="<%= p.getName() %>">
                            <% } else { %>
                                <div class="bg-white d-flex align-items-center justify-content-center" style="height:120px;border-radius:10px 10px 0 0;">
                                    <i class="bi bi-image text-muted" style="font-size:3rem;"></i>
                                </div>
                            <% } %>
                            <div class="card-body p-3 text-center">
                                <h6 class="fw-bold mb-1" style="font-size:0.9rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;"><%= p.getName() %></h6>
                                <p class="small text-muted mb-2"><%= p.getBrand() != null ? p.getBrand() : "Genérico" %></p>
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="fw-bold text-success">$<%= String.format("%,.0f", p.getPrice()) %></span>
                                    <span class="badge <%= p.getStock() > 0 ? "bg-primary" : "bg-danger" %>">Stock: <%= p.getStock() %></span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Request Part Details -->
<div class="modal fade" id="requestPartModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title section-title mb-0"><i class="bi bi-tools me-2"></i>Añadir a la Orden</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="alert alert-info py-2 mb-3">
                    <i class="bi bi-info-circle me-2"></i>Instalando en moto: <strong id="reqMotoLabel"></strong>
                </div>
                
                <h6 class="fw-bold text-primary mb-3" id="reqPartName"></h6>
                
                <form action="maintenance" method="POST" id="requestPartForm">
                    <input type="hidden" name="action" value="requestPart">
                    <input type="hidden" name="jobId" id="reqJobId">
                    <input type="hidden" name="productId" id="reqProductId">
                    <input type="hidden" name="productPrice" id="reqProductPrice">
                    
                    <div class="mb-3">
                        <label class="form-label small text-secondary fw-bold">Cantidad requerida</label>
                        <input type="number" name="quantity" class="form-control" id="reqQuantity" value="1" min="1" required>
                        <div class="form-text text-danger" id="reqStockWarning" style="display:none;">¡Alerta! Has superado el stock disponible.</div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small text-secondary fw-bold">Motivo / Descripción de la instalación</label>
                        <textarea name="reason" class="form-control" rows="2" placeholder="Ej: Cambio por desgaste, se rompió la pieza original..." required></textarea>
                    </div>
                    <div class="mb-4">
                        <label class="form-label small text-secondary fw-bold">Costo de Mano de Obra ($)</label>
                        <input type="number" name="laborCost" class="form-control form-control-lg fw-bold text-success" step="0.01" min="0" value="0" placeholder="0.00" required>
                    </div>
                    <div class="d-flex justify-content-end gap-2">
                        <button type="button" class="btn btn-light" data-bs-toggle="modal" data-bs-target="#catalogModal">Volver al Catálogo</button>
                        <button type="submit" class="btn btn-primary px-4"><i class="bi bi-check2-circle me-2"></i>Registrar Repuesto</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Edit Status -->
<div class="modal fade" id="editStatusModal" tabindex="-1">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="modal-header border-0 pb-0">
                <h6 class="modal-title fw-bold" style="color:var(--accent-orange)"><i class="bi bi-pencil-square me-2"></i>Editar Estado</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-3">
                <form action="maintenance" method="POST">
                    <input type="hidden" name="action" value="updateStatus">
                    <input type="hidden" name="jobId" id="editJobId">
                    <div class="mb-3">
                        <label class="form-label small text-secondary">Estado Actual</label>
                        <select name="status" id="editStatusSelect" class="form-select form-select-sm">
                            <option value="PENDIENTE">Pendiente</option>
                            <option value="EN_PROCESO">En Proceso</option>
                            <option value="COMPLETADO">Terminado</option>
                        </select>
                    </div>
                    <div class="mb-4">
                        <label class="form-label small text-secondary">Subtotal Costo / MO ($)</label>
                        <input type="number" name="cost" id="editCostInput" step="0.01" min="0" class="form-control form-control-sm">
                    </div>
                    <button type="submit" class="btn btn-moto btn-sm w-100">Guardar Cambios</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    let currentJobId = null;
    let currentJobMoto = "";

    function filterCatalog() {
        let input = document.getElementById('catalogSearch').value.toLowerCase();
        let items = document.getElementsByClassName('catalog-item');
        for(let i=0; i<items.length; i++){
            let name = items[i].getAttribute('data-name');
            if(name.indexOf(input) > -1) {
                items[i].style.display = "";
            } else {
                items[i].style.display = "none";
            }
        }
    }

    function viewJobDetails(id, plate, brand, model, customer, desc, cost) {
        document.getElementById('detPlate').innerText = plate;
        document.getElementById('detMoto').innerText = brand + ' ' + model;
        document.getElementById('detCustomer').innerText = customer;
        document.getElementById('detDescription').innerText = desc;
        document.getElementById('detTotalCost').innerText = '$' + cost.toLocaleString('en-US', {minimumFractionDigits: 2});
        
        document.getElementById('detPartsList').innerHTML = '<tr><td colspan="5" class="text-center"><div class="spinner-border text-primary spinner-border-sm"></div> Cargando...</td></tr>';
        
        let modal = new bootstrap.Modal(document.getElementById('jobDetailsModal'));
        modal.show();

        // Fetch parts via AJAX
        fetch('<%= request.getContextPath() %>/maintenance?action=getJobParts&jobId=' + id)
            .then(res => {
                if(!res.ok) throw new Error("Status " + res.status);
                return res.json();
            })
            .then(data => {
                let html = '';
                if(data.length === 0) {
                    html = '<tr><td colspan="5" class="text-center text-muted">No se han registrado repuestos para esta orden.</td></tr>';
                } else {
                    data.forEach(p => {
                        let sub = (p.price * p.quantity) + p.laborCost;
                        html += `<tr>
                            <td>
                                <strong>${p.name}</strong><br>
                                <span class="text-muted small">Motivo: ${p.reason}</span>
                            </td>
                            <td>${p.quantity}</td>
                            <td>$${p.price.toLocaleString()}</td>
                            <td>$${p.laborCost.toLocaleString()}</td>
                            <td class="text-end fw-bold">$${sub.toLocaleString()}</td>
                        </tr>`;
                    });
                }
                document.getElementById('detPartsList').innerHTML = html;
            })
            .catch(err => {
                document.getElementById('detPartsList').innerHTML = '<tr><td colspan="5" class="text-danger text-center">Error al cargar repuestos: ' + err.message + '</td></tr>';
            });
    }

    function openCatalog(jobId) {
        currentJobId = jobId;
        // Find row to extract moto name
        let btn = event.currentTarget;
        currentJobMoto = btn.closest('tr').cells[2].innerText;
        
        let modal = new bootstrap.Modal(document.getElementById('catalogModal'));
        modal.show();
    }

    function openEditModal(id, status, cost) {
        document.getElementById('editJobId').value = id;
        document.getElementById('editStatusSelect').value = status;
        document.getElementById('editCostInput').value = cost;
        let modal = new bootstrap.Modal(document.getElementById('editStatusModal'));
        modal.show();
    }

    let selectedPartStock = 0;
    function openRequestPartModal(productId, productName, productPrice, productStock) {
        // Hide catalog, show request form
        let catModal = bootstrap.Modal.getInstance(document.getElementById('catalogModal'));
        if(catModal) catModal.hide();
        
        document.getElementById('reqJobId').value = currentJobId;
        document.getElementById('reqProductId').value = productId;
        document.getElementById('reqProductPrice').value = productPrice;
        document.getElementById('reqPartName').innerText = productName + " ($" + productPrice.toLocaleString() + ")";
        document.getElementById('reqMotoLabel').innerText = currentJobMoto;
        
        selectedPartStock = productStock;
        document.getElementById('reqQuantity').max = productStock;
        document.getElementById('reqQuantity').value = 1;
        document.getElementById('reqStockWarning').style.display = 'none';
        
        let reqModal = new bootstrap.Modal(document.getElementById('requestPartModal'));
        reqModal.show();
    }

    // Input validation for stock
    document.getElementById('reqQuantity').addEventListener('input', function(e) {
        let val = parseInt(this.value);
        if(val > selectedPartStock) {
            document.getElementById('reqStockWarning').style.display = 'block';
            this.classList.add('is-invalid');
        } else {
            document.getElementById('reqStockWarning').style.display = 'none';
            this.classList.remove('is-invalid');
        }
    });

    document.getElementById('requestPartForm').addEventListener('submit', function(e) {
        let val = parseInt(document.getElementById('reqQuantity').value);
        if(val > selectedPartStock) {
            e.preventDefault();
            alert("No hay suficiente stock en bodega para esta cantidad.");
        }
    });
</script>
</body>
</html>
