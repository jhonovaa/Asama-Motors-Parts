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
        .form-control { background: var(--card-bg); border: 1px solid var(--card-border); color: var(--text-color); border-radius: 8px; }
        .form-control:focus { background: var(--card-bg); color: var(--text-color); border-color: var(--accent-orange); box-shadow: 0 0 0 3px rgba(255,107,53,0.15); }
        .form-control:disabled { background: var(--bg-color); color: var(--text-color); opacity: 0.7; }
        .btn-moto { background-color: var(--accent-orange); color: #fff; border: none; border-radius: 30px; padding: 12px; font-weight: 600; width: 100%; transition: 0.3s; }
        .btn-moto:hover { background-color: #E55A2B; color: white; transform: translateY(-1px); }
        .mp-badge { background: #009ee3; color: white; padding: 5px 10px; border-radius: 5px; font-weight: bold; font-size: 0.8rem; }
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
                        <span class="mp-badge"><i class="bi bi-credit-card-2-front"></i> Mercado Pago</span>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label text-secondary small"><fmt:message key="checkout.card_number" /></label>
                        <input type="text" class="form-control" placeholder="4545 4545 4545 4545" value="4545 4545 4545 4545" disabled>
                    </div>
                    
                    <div class="row mb-4">
                        <div class="col-6">
                            <label class="form-label text-secondary small"><fmt:message key="checkout.expiry" /></label>
                            <input type="text" class="form-control" placeholder="MM/YY" value="12/30" disabled>
                        </div>
                        <div class="col-6">
                            <label class="form-label text-secondary small"><fmt:message key="checkout.cvc" /></label>
                            <input type="text" class="form-control" placeholder="123" value="123" disabled>
                        </div>
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

                    <div class="alert alert-warning py-2 small">
                        <i class="bi bi-info-circle"></i> <fmt:message key="checkout.simulation_warning" />
                    </div>

                    <button class="btn btn-moto mt-3" id="btnPay" onclick="submitOrder()"><fmt:message key="checkout.confirm_pay" /></button>
                </div>

                <div class="checkout-card text-center" id="successMessage" style="display: none;">
                    <i class="bi bi-check-circle-fill text-success" style="font-size: 4rem;"></i>
                    <h3 class="mt-3"><fmt:message key="checkout.success_title" /></h3>
                    <p class="text-secondary"><fmt:message key="checkout.success_text" /></p>
                    <a href="dashboard.jsp" class="btn btn-moto-outline mt-3" style="border-radius: 20px;"><fmt:message key="checkout.go_to_panel" /></a>
                </div>
            </div>
        </div>
    </div>

    <script>
        function loadSummary() {
            let currentUserId = <%= user != null ? user.getId() : -1 %>;
            let cartKey = 'asama_cart_' + currentUserId;
            let cart = JSON.parse(localStorage.getItem(cartKey)) || [];
            
            let subtotal = 0;
            let totalItems = 0;
            
            cart.forEach(item => {
                subtotal += (item.price * item.qty);
                totalItems += item.qty;
            });
            
            // Algorithmic Shipping Logic:
            // Estimate 1.2 kg per item + 0.5 kg box base weight
            let estWeight = (totalItems * 1.2) + 0.5;
            
            // Shipping Cost: Base $5.00 + $1.50 per Kg
            let shipping = 5.00 + (estWeight * 1.50);
            
            // Free shipping on orders over $500
            if (subtotal >= 500) {
                shipping = 0;
            }
            if (subtotal === 0) {
                shipping = 0;
                estWeight = 0;
            }
            
            let totalPay = subtotal + shipping;
            
            document.getElementById('summarySubtotal').innerText = '$' + subtotal.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('summaryWeight').innerText = estWeight.toFixed(1) + ' kg';
            document.getElementById('summaryShipping').innerText = shipping === 0 ? (subtotal > 0 ? 'FREE' : '$0.00') : '$' + shipping.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('summaryTotal').innerText = '$' + totalPay.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        }
        
        window.onload = function() {
            loadSummary();
        };

        function submitOrder() {
            let currentUserId = <%= user != null ? user.getId() : -1 %>;
            let cartKey = 'asama_cart_' + currentUserId;
            let cart = localStorage.getItem(cartKey);
            if(!cart || cart === '[]') {
                alert("<fmt:message key='checkout.cart_empty' />");
                window.location.href = 'catalog.jsp';
                return;
            }

            document.getElementById('btnPay').innerText = '<fmt:message key="checkout.processing" />';
            document.getElementById('btnPay').disabled = true;

            fetch('checkout', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'cartData=' + encodeURIComponent(cart)
            })
            .then(response => {
                if(response.ok) {
                    localStorage.removeItem(cartKey);
                    document.getElementById('paymentForm').style.display = 'none';
                    document.getElementById('successMessage').style.display = 'block';
                } else {
                    alert("<fmt:message key='checkout.error' />");
                    document.getElementById('btnPay').innerText = '<fmt:message key="checkout.confirm_pay" />';
                    document.getElementById('btnPay').disabled = false;
                }
            });
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
