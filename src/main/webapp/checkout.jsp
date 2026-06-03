<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
    <title>Pago - Asama Moto Parts</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --bg-color: #0a0a0a;
            --text-color: #f0f0f0;
            --card-bg: #1a1a1a;
            --accent-orange: #FF6B35;
        }
        body { font-family: 'Inter', sans-serif; background-color: var(--bg-color); color: var(--text-color); padding-top: 60px; }
        .checkout-card { background: var(--card-bg); border-radius: 15px; padding: 30px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); border: 1px solid rgba(255,255,255,0.05); }
        .form-control { background: #2D3436; border: 1px solid rgba(255,255,255,0.1); color: #fff; border-radius: 8px; }
        .form-control:focus { background: #2D3436; color: #fff; border-color: var(--accent-orange); box-shadow: 0 0 0 3px rgba(255,107,53,0.15); }
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
                        <h4 class="fw-bold m-0">Detalles de Pago</h4>
                        <span class="mp-badge"><i class="bi bi-credit-card-2-front"></i> Mercado Pago</span>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label text-secondary small">Número de Tarjeta</label>
                        <input type="text" class="form-control" placeholder="4545 4545 4545 4545" value="4545 4545 4545 4545" disabled>
                    </div>
                    
                    <div class="row mb-4">
                        <div class="col-6">
                            <label class="form-label text-secondary small">Vencimiento</label>
                            <input type="text" class="form-control" placeholder="MM/YY" value="12/30" disabled>
                        </div>
                        <div class="col-6">
                            <label class="form-label text-secondary small">CVC</label>
                            <input type="text" class="form-control" placeholder="123" value="123" disabled>
                        </div>
                    </div>

                    <div class="alert alert-warning py-2 small bg-dark text-warning border-warning">
                        <i class="bi bi-info-circle"></i> Simulación de pasarela de pago. Su pedido será procesado inmediatamente.
                    </div>

                    <button class="btn btn-moto mt-3" id="btnPay" onclick="submitOrder()">Confirmar Pago Seguro</button>
                </div>

                <div class="checkout-card text-center" id="successMessage" style="display: none;">
                    <i class="bi bi-check-circle-fill text-success" style="font-size: 4rem;"></i>
                    <h3 class="mt-3">¡Pago Exitoso!</h3>
                    <p class="text-secondary">Tu pedido ha sido registrado y será enviado pronto.</p>
                    <a href="dashboard.jsp" class="btn btn-outline-light mt-3" style="border-radius: 20px;">Ir a mi panel</a>
                </div>
            </div>
        </div>
    </div>

    <script>
        function submitOrder() {
            let cart = localStorage.getItem('asama_cart');
            if(!cart || cart === '[]') {
                alert("El carrito está vacío");
                window.location.href = 'catalog.jsp';
                return;
            }

            document.getElementById('btnPay').innerText = 'Procesando...';
            document.getElementById('btnPay').disabled = true;

            fetch('checkout', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'cartData=' + encodeURIComponent(cart)
            })
            .then(response => {
                if(response.ok) {
                    localStorage.removeItem('asama_cart');
                    document.getElementById('paymentForm').style.display = 'none';
                    document.getElementById('successMessage').style.display = 'block';
                } else {
                    alert("Hubo un error al procesar el pago. Revisa el stock.");
                    document.getElementById('btnPay').innerText = 'Confirmar Pago Seguro';
                    document.getElementById('btnPay').disabled = false;
                }
            });
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
