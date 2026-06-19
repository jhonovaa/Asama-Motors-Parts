<%@ page import="com.adso.cheng.models.User" %>
<%@ page import="com.adso.cheng.dao.OnlineOrderDAO" %>
<%@ page import="com.adso.cheng.models.OnlineOrder" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 4)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    OnlineOrderDAO dao = new OnlineOrderDAO();
    List<OnlineOrder> orders = dao.getAllOrders();
    
    // Marcar todos como leídos ahora que el usuario los está viendo
    dao.markAllAsRead(user.getRoleId());
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title><fmt:message key="orders.title" /></title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="resources/theme.css?v=6">
    <style>
        .order-card {
            background: var(--card-bg);
            border-radius: 12px;
            border: 1px solid var(--card-border);
            transition: 0.3s;
        }
        .order-card:hover { border-color: var(--accent-orange); }
        .order-card.order-new {
            border-color: var(--accent-orange);
            box-shadow: 0 0 18px rgba(255,107,53,0.25);
        }
        .text-secondary { color: rgba(255,255,255,0.7) !important; }
        body.light-mode .text-secondary { color: rgba(0,0,0,0.6) !important; }
        .badge-completado { background-color: #28a745; color: #fff; }
        .badge-pendiente  { background-color: #ffc107; color: #000; }
        .badge-preparacion{ background-color: #0dcaf0; color: #000; }
        .badge-enviado    { background-color: #0d6efd; color: #fff; }
        .badge-entregado  { background-color: #198754; color: #fff; }
        .item-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 6px 0;
            border-bottom: 1px solid var(--card-border);
            font-size: 0.9rem;
        }
        .item-row:last-child { border-bottom: none; }
        .mp-badge {
            background: linear-gradient(135deg, #009ee3, #0065b3);
            color: #fff;
            font-size: 0.7rem;
            font-weight: 700;
            padding: 2px 8px;
            border-radius: 20px;
            letter-spacing: 0.5px;
        }
    </style>
</head>
<body>
<script src="resources/theme.js?v=2"></script>
<%@ include file="navbar.jsp" %>

<div class="container pb-5" style="margin-top: 100px;">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold m-0"><i class="bi bi-box2-heart me-2 text-accent"></i><fmt:message key="orders.header" /></h2>
        <span class="text-secondary small"><%= orders.size() %> pedidos en total</span>
    </div>

    <div class="row g-4">
        <% if (orders.isEmpty()) { %>
            <div class="col-12 text-center py-5">
                <i class="bi bi-inbox fs-1 text-secondary mb-3 d-block"></i>
                <h4 class="fw-bold"><fmt:message key="orders.empty" /></h4>
            </div>
        <% } else { %>
            <% for(OnlineOrder o : orders) { %>
                <%
                    boolean isNew = (user.getRoleId() == 1 && !o.isReadAdmin()) ||
                                   (user.getRoleId() == 4 && !o.isReadCashier());
                    String statusBadgeClass = "badge-pendiente";
                    String oStatus = o.getStatus() != null ? o.getStatus() : "PENDIENTE";
                    
                    if("COMPLETADO".equals(oStatus))    statusBadgeClass = "badge-completado";
                    else if("EN_PREPARACION".equals(oStatus)) statusBadgeClass = "badge-preparacion";
                    else if("ENVIADO".equals(oStatus))  statusBadgeClass = "badge-enviado";
                    else if("ENTREGADO".equals(oStatus)) statusBadgeClass = "badge-entregado";
                    
                    String formattedDate = "N/A";
                    if (o.getCreatedAt() != null) {
                        try {
                            formattedDate = o.getCreatedAt().toInstant().atZone(java.time.ZoneId.of("America/Bogota")).format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
                        } catch (Exception e) {
                            formattedDate = o.getCreatedAt().toString();
                        }
                    }
                    
                    String itemsJsonSafe = o.getItemsJson();
                    if (itemsJsonSafe == null || itemsJsonSafe.trim().isEmpty()) {
                        itemsJsonSafe = "[]";
                    }
                %>
                <div class="col-12">
                    <div class="order-card p-4 <%= isNew ? "order-new" : "" %>">
                        
                        <!-- Header del pedido -->
                        <div class="d-flex flex-column flex-md-row justify-content-between mb-3 border-bottom border-secondary pb-3">
                            <div>
                                <div class="d-flex align-items-center gap-2 mb-1">
                                    <h5 class="fw-bold m-0">Pedido #<%= o.getId() %></h5>
                                    <span class="badge <%= statusBadgeClass %>"><%= oStatus %></span>
                                    <% if("COMPLETADO".equals(oStatus)) { %>
                                        <span class="mp-badge"><i class="bi bi-credit-card me-1"></i>Mercado Pago</span>
                                    <% } %>
                                    <% if(isNew) { %>
                                        <span class="badge bg-danger">NUEVO</span>
                                    <% } %>
                                </div>
                                <p class="mb-1 text-secondary small">
                                    <i class="bi bi-clock me-1"></i> <%= formattedDate %>
                                </p>
                                <p class="mb-0 text-accent fw-bold"><i class="bi bi-person me-1"></i><%= o.getCustomerName() != null ? o.getCustomerName() : "Cliente Desconocido" %></p>
                            </div>
                            <div class="text-md-end mt-3 mt-md-0">
                                <h4 class="fw-bolder mb-1 text-accent">$<%= String.format("%,.2f", o.getTotalAmount()) %></h4>
                                <p class="mb-2 text-secondary small">Envío: $<%= String.format("%.2f", o.getShippingCost()) %></p>
                                <!-- Cambiar estado -->
                                <div class="btn-group mb-2">
                                    <button type="button" class="btn btn-sm btn-outline-secondary dropdown-toggle" data-bs-toggle="dropdown">
                                        Cambiar estado
                                    </button>
                                    <ul class="dropdown-menu shadow">
                                        <li><a class="dropdown-item fw-bold text-warning" href="#" onclick="updateStatus(<%= o.getId() %>, 'PENDIENTE')">PENDIENTE</a></li>
                                        <li><a class="dropdown-item fw-bold text-info" href="#" onclick="updateStatus(<%= o.getId() %>, 'EN_PREPARACION')">EN_PREPARACION</a></li>
                                        <li><a class="dropdown-item fw-bold text-primary" href="#" onclick="updateStatus(<%= o.getId() %>, 'ENVIADO')">ENVIADO</a></li>
                                        <li><a class="dropdown-item fw-bold text-success" href="#" onclick="updateStatus(<%= o.getId() %>, 'ENTREGADO')">ENTREGADO</a></li>
                                    </ul>
                                </div>
                                <% if ("COMPLETADO".equals(oStatus) || "ENVIADO".equals(oStatus) || "ENTREGADO".equals(oStatus) || "EN_PREPARACION".equals(oStatus)) { %>
                                <br>
                                <a href="api/receipt?orderId=<%= o.getId() %>" class="btn btn-sm btn-outline-danger" target="_blank">
                                    <i class="bi bi-file-earmark-pdf-fill me-1"></i>Recibo PDF
                                </a>
                                <% } %>
                            </div>
                        </div>
                        
                        <!-- Artículos del pedido -->
                        <div>
                            <p class="fw-bold mb-2"><i class="bi bi-bag me-2 text-accent"></i>Artículos del pedido:</p>
                            <div id="items-list-<%= o.getId() %>"></div>
                            <script>
                                (function(){
                                    let items = <%= itemsJsonSafe %>;
                                    let container = document.getElementById('items-list-<%= o.getId() %>');
                                    if(Array.isArray(items)) {
                                        items.forEach(function(i) {
                                            let row = document.createElement('div');
                                            row.className = 'item-row';
                                            row.innerHTML =
                                                "<span><span class='badge bg-secondary me-2'>" + i.qty + "x</span>" + i.name + "</span>" +
                                                "<span class='fw-bold'>$" + (i.price * i.qty).toLocaleString('es-CO', {minimumFractionDigits:2}) + "</span>";
                                            container.appendChild(row);
                                        });
                                    } else {
                                        container.innerHTML = "<div class='text-secondary small'>No hay artículos</div>";
                                    }
                                })();
                            </script>
                        </div>
                    </div>
                </div>
            <% } %>
        <% } %>
    </div>
</div>

<script>
function updateStatus(orderId, status) {
    fetch('api/notifications', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=updateStatus&orderId=' + orderId + '&status=' + status
    }).then(r => {
        if(r.ok) location.reload();
    });
}
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

