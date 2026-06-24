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
    
    // Auto-mark all as read when opening this page
    OnlineOrderDAO dao = new OnlineOrderDAO();
    dao.markAllAsRead(user.getRoleId());
    
    List<OnlineOrder> orders = dao.getAllOrders();
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
        .text-secondary { color: rgba(255,255,255,0.7) !important; }
        body.light-mode .text-secondary { color: rgba(0,0,0,0.6) !important; }
        .badge-pending { background-color: #ffc107; color: #000; }
        .badge-preparing { background-color: #0dcaf0; color: #000; }
        .badge-shipped { background-color: #0d6efd; }
        .badge-delivered { background-color: #198754; }

        /* Estado del Pedido */
        .order-status-btn {
            color: #ffffff !important;
            border-color: rgba(255, 255, 255, 0.4) !important;
        }
        body.light-mode .order-status-btn {
            color: #000000 !important;
            border-color: #000000 !important;
        }
        
        /* Artículos de Pedidos */
        .order-card .list-group-item {
            color: #ffffff !important;
        }
        body.light-mode .order-card .list-group-item {
            color: #000000 !important;
            border-color: rgba(0, 0, 0, 0.12) !important;
        }
    </style>
</head>
<body>
<script src="resources/theme.js"></script>
<%@ include file="navbar.jsp" %>

<div class="container pb-5" style="margin-top: 100px;">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold m-0"><i class="bi bi-box2-heart me-2 text-accent"></i><fmt:message key="orders.header" /></h2>
    </div>

    <div class="row g-4">
        <% if (orders.isEmpty()) { %>
            <div class="col-12 text-center py-5">
                <i class="bi bi-inbox fs-1 text-secondary mb-3 d-block"></i>
                <h4 class="fw-bold"><fmt:message key="orders.empty" /></h4>
            </div>
        <% } else { %>
            <% for(OnlineOrder o : orders) { %>
                <div class="col-12">
                    <div class="order-card p-4">
                        <div class="d-flex flex-column flex-md-row justify-content-between mb-3 border-bottom border-secondary pb-3">
                            <div>
                                <h5 class="fw-bold mb-1"><fmt:message key="orders.order_label" /> #<%= o.getId() %> <span class="text-secondary fs-6 fw-normal ms-2"><%= o.getCreatedAt().toString().substring(0, 16) %></span></h5>
                                <p class="mb-0 text-accent fw-bold"><i class="bi bi-person me-1"></i> <%= o.getCustomerName() %></p>
                            </div>
                            <div class="text-md-end mt-3 mt-md-0">
                                <h4 class="fw-bolder mb-1">$<%= String.format("%.2f", o.getTotalAmount()) %></h4>
                                <p class="mb-0 text-secondary small"><fmt:message key="orders.shipping_label" />: $<%= String.format("%.2f", o.getShippingCost()) %></p>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <span class="fw-bold me-2"><fmt:message key="orders.status_label" />:</span>
                            <div class="btn-group">
                                  <button type="button" class="btn btn-sm btn-outline-light dropdown-toggle order-status-btn" data-bs-toggle="dropdown" aria-expanded="false">
                                      <% String oStatus = o.getStatus(); %>
                                      <% if("PENDIENTE".equals(oStatus)) { %><fmt:message key="orders.status.pending" /><% }
                                         else if("EN_PREPARACION".equals(oStatus)) { %><fmt:message key="orders.status.preparing" /><% }
                                         else if("ENVIADO".equals(oStatus)) { %><fmt:message key="orders.status.shipped" /><% }
                                         else if("ENTREGADO".equals(oStatus)) { %><fmt:message key="orders.status.delivered" /><% }
                                         else { %><%= oStatus %><% } %>
                                  </button>
                                  <ul class="dropdown-menu shadow">
                                      <li><a class="dropdown-item fw-bold text-warning" href="#" onclick="updateStatus(<%= o.getId() %>, 'PENDIENTE')"><fmt:message key="orders.status.pending" /></a></li>
                                      <li><a class="dropdown-item fw-bold text-info" href="#" onclick="updateStatus(<%= o.getId() %>, 'EN_PREPARACION')"><fmt:message key="orders.status.preparing" /></a></li>
                                      <li><a class="dropdown-item fw-bold text-primary" href="#" onclick="updateStatus(<%= o.getId() %>, 'ENVIADO')"><fmt:message key="orders.status.shipped" /></a></li>
                                      <li><a class="dropdown-item fw-bold text-success" href="#" onclick="updateStatus(<%= o.getId() %>, 'ENTREGADO')"><fmt:message key="orders.status.delivered" /></a></li>
                                  </ul>
                                  <% if ("COMPLETADO".equals(oStatus) || "ENVIADO".equals(oStatus) || "ENTREGADO".equals(oStatus) || "EN_PREPARACION".equals(oStatus)) { %>
                                  <a href="invoice.jsp?orderId=<%= o.getId() %>" class="btn btn-sm btn-outline-danger ms-2" target="_blank">
                                      <i class="bi bi-file-earmark-pdf-fill me-1"></i>Recibo PDF
                                  </a>
                                  <% } %>
                              </div>
                        </div>
                        
                        <div>
                            <p class="fw-bold mb-2"><fmt:message key="orders.items_label" />:</p>
                            <ul class="list-group list-group-flush bg-transparent" id="items-list-<%= o.getId() %>">
                                <!-- JS will populate this -->
                            </ul>
                            <script>
                                (function(){
                                    let items = <%= o.getItemsJson() %>;
                                    let list = document.getElementById('items-list-<%= o.getId() %>');
                                    items.forEach(i => {
                                        let li = document.createElement('li');
                                        li.className = "list-group-item bg-transparent text-white border-secondary px-0 py-1";
                                        li.innerHTML = "<span class='badge bg-secondary me-2'>" + i.qty + "x</span> " + i.name + " <span class='float-end'>$" + (i.price * i.qty).toFixed(2) + "</span>";
                                        // adapt colors for light mode dynamically or via css
                                        if(document.body.classList.contains('light-mode')) li.classList.replace('text-white', 'text-dark');
                                        list.appendChild(li);
                                    });
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
