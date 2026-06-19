<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRoleId() != 5) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title><fmt:message key="checkout.title" /></title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body { font-family: 'Inter', sans-serif; background-color: var(--bg-color); color: var(--text-color); padding-top: 60px; }
        .checkout-card { background: var(--card-bg); border-radius: 15px; padding: 30px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); border: 1px solid var(--card-border); }
        .btn-moto { background-color: var(--accent-orange); color: #fff; border: none; border-radius: 30px; padding: 14px; font-weight: 700; width: 100%; font-size: 1.1rem; transition: 0.3s; display: flex; align-items: center; justify-content: center; gap: 10px; }
        .btn-moto:hover { background-color: #E55A2B; color: white; transform: translateY(-2px); box-shadow: 0 8px 25px rgba(229,90,43,0.4); }
        .btn-moto:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }
        .security-info { background: rgba(40,167,69,0.1); border: 1px solid rgba(40,167,69,0.3); border-radius: 10px; padding: 15px; margin-bottom: 20px; }
        .security-info i { color: #28a745; }
        .spinner-border-sm { width: 1rem; height: 1rem; border-width: 0.15em; }
    </style>
</head>
<body>

    <%@ include file="navbar.jsp" %>

    <div class="container" style="margin-top: 40px;">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="checkout-card" id="paymentForm">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h4 class="fw-bold m-0"><fmt:message key="checkout.details" /></h4>
                        <span class="badge bg-success py-2 px-3 rounded-pill"><i class="bi bi-box-seam me-1"></i> Envío a Domicilio</span>
                    </div>

                    <div class="security-info">
                        <p class="mb-1 small fw-medium"><i class="bi bi-check-circle-fill me-2"></i>Pedido Directo</p>
                        <p class="mb-0 small text-secondary">Al confirmar, tu pedido será registrado y descontado del inventario. El pago se acordará de manera externa.</p>
                    </div>

                    <hr class="my-4 border-secondary border-opacity-50">
                    <h5 class="fw-bold mb-3"><fmt:message key="checkout.order_summary" /></h5>
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-secondary"><fmt:message key="checkout.subtotal" /></span>
                        <span class="fw-medium" id="summarySubtotal">$0.00</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-secondary"><fmt:message key="checkout.est_weight" /></span>
                        <span class="fw-medium text-accent" id="summaryWeight">0 kg</span>
                    </div>
                    <div class="d-flex justify-content-between mb-3">
                        <span class="text-secondary"><fmt:message key="checkout.shipping_cost" /> <i class="bi bi-truck ms-1"></i></span>
                        <span class="fw-medium" id="summaryShipping">$0.00</span>
                    </div>
                    <div class="d-flex justify-content-between border-top pt-3 mb-4">
                        <span class="fw-bold fs-5"><fmt:message key="checkout.total_pay" /></span>
                        <span class="fw-bolder fs-4 text-accent" id="summaryTotal">$0.00</span>
                    </div>

                    <button class="btn btn-moto" id="btnPay" onclick="processPayment()">
                        <i class="bi bi-check2-circle"></i>
                        Confirmar Pedido
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        function loadSummary() {
            let currentUserId = <%= user != null ? user.getId() : -1 %>;
            let cartKey = 'asama_cart_' + currentUserId;
            let cartStr = localStorage.getItem(cartKey);
            if(!cartStr || cartStr === '[]') {
                alert("<fmt:message key='checkout.cart_empty' />");
                window.location.href = 'catalog.jsp';
                return 0;
            }
            let cart = JSON.parse(cartStr);

            let subtotal = 0;
            let totalItems = 0;

            cart.forEach(item => {
                subtotal += (item.price * item.qty);
                totalItems += item.qty;
            });

            let estWeight = (totalItems * 1.2) + 0.5;
            let shipping = 5.00 + (estWeight * 1.50);
            if (subtotal >= 500) shipping = 0;
            if (subtotal === 0) { shipping = 0; estWeight = 0; }

            let totalPay = subtotal + shipping;

            document.getElementById('summarySubtotal').innerText = '$' + subtotal.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('summaryWeight').innerText = estWeight.toFixed(1) + ' kg';
            document.getElementById('summaryShipping').innerText = shipping === 0 ? (subtotal > 0 ? 'FREE' : '$0.00') : '$' + shipping.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('summaryTotal').innerText = '$' + totalPay.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});

            return totalPay;
        }

        window.onload = function() {
            loadSummary();
        };

        function processPayment() {
            let currentUserId = <%= user != null ? user.getId() : -1 %>;
            let cartKey = 'asama_cart_' + currentUserId;
            let cart = localStorage.getItem(cartKey);
            if(!cart || cart === '[]') {
                alert("<fmt:message key='checkout.cart_empty' />");
                window.location.href = 'catalog.jsp';
                return;
            }

            let btn = document.getElementById('btnPay');
            btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Procesando...';
            btn.disabled = true;

            fetch('checkout', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'cartData=' + encodeURIComponent(cart)
            })
            .then(response => response.json())
            .then(data => {
                if(data.success && data.init_point) {
                    // Guardar orderId para procesarlo al volver de Mercado Pago
                    let currentUserId = <%= user != null ? user.getId() : -1 %>;
                    localStorage.setItem('asama_pending_order_' + currentUserId, data.orderId);
                    // Redirigir al Sandbox de Mercado Pago
                    window.location.href = data.init_point;
                } else {
                    alert("<fmt:message key='checkout.error' />: " + data.error);
                    btn.innerHTML = '<i class="bi bi-check2-circle"></i> Confirmar Pedido';
                    btn.disabled = false;
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert("Error de conexión");
                btn.innerHTML = '<i class="bi bi-check2-circle"></i> Confirmar Pedido';
                btn.disabled = false;
            });
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
