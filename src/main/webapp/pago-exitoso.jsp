<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.adso.cheng.models.User" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Pedido Confirmado - Asama Motors</title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body { font-family: 'Inter', sans-serif; background-color: var(--bg-color); color: var(--text-color); padding-top: 60px; }
        .success-card {
            background: var(--card-bg);
            border-radius: 20px;
            padding: 50px 40px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            border: 1px solid var(--card-border);
            text-align: center;
            max-width: 500px;
            margin: 60px auto;
        }
        .success-icon {
            font-size: 5rem;
            color: #28a745;
            animation: bounceIn 0.8s ease;
        }
        .btn-moto {
            background-color: var(--accent-orange);
            color: #fff;
            border: none;
            border-radius: 30px;
            padding: 12px 30px;
            font-weight: 600;
            transition: 0.3s;
        }
        .btn-moto:hover { background-color: #E55A2B; color: white; }
        @keyframes bounceIn {
            0% { transform: scale(0); opacity: 0; }
            50% { transform: scale(1.2); }
            100% { transform: scale(1); opacity: 1; }
        }
        .confetti { position: fixed; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; z-index: 9999; }
    </style>
</head>
<body>
    <%@ include file="navbar.jsp" %>

    <canvas class="confetti" id="confettiCanvas"></canvas>

    <div class="success-card">
        <i class="bi bi-check-circle-fill success-icon"></i>
        <h2 class="fw-bold mt-4">¡Pedido Confirmado!</h2>
        <p class="text-secondary mt-3 mb-1">Tu pedido ha sido registrado correctamente y está en proceso de despacho.</p>
        <p class="text-secondary mb-4">El pago se acordará con nuestro equipo o al momento de la entrega.</p>

        <div class="d-flex flex-column gap-2 mt-4">
            <a href="catalog.jsp" class="btn btn-moto">
                <i class="bi bi-bag-check me-2"></i>Seguir Comprando
            </a>
            <a href="dashboard.jsp" class="btn btn-outline-secondary" style="border-radius: 30px;">
                <i class="bi bi-speedometer2 me-2"></i>Ir a Mi Panel
            </a>
        </div>
    </div>

    <script>
        // Process pending order and clear cart on successful payment
        let currentUserId = <%= user != null ? user.getId() : -1 %>;
        let cartKey = 'asama_cart_' + currentUserId;
        let pendingOrderId = localStorage.getItem('asama_pending_order_' + currentUserId);

        // If there's a pending order from Mercado Pago, complete it
        if (pendingOrderId) {
            fetch('PaymentSuccessServlet?status=approved&external_reference=' + pendingOrderId)
                .then(() => {
                    console.log('Orden ' + pendingOrderId + ' procesada exitosamente');
                })
                .catch(err => console.error('Error procesando orden:', err));
        }

        localStorage.removeItem(cartKey);
        localStorage.removeItem('asama_pending_order_' + currentUserId);

        // Simple confetti animation
        (function() {
            const canvas = document.getElementById('confettiCanvas');
            const ctx = canvas.getContext('2d');
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
            const colors = ['#FF6B35', '#009ee3', '#28a745', '#ffc107', '#e83e8c', '#6f42c1'];
            const particles = [];

            for (let i = 0; i < 120; i++) {
                particles.push({
                    x: Math.random() * canvas.width,
                    y: Math.random() * canvas.height - canvas.height,
                    w: Math.random() * 10 + 5,
                    h: Math.random() * 6 + 3,
                    color: colors[Math.floor(Math.random() * colors.length)],
                    speed: Math.random() * 3 + 2,
                    angle: Math.random() * Math.PI * 2,
                    spin: (Math.random() - 0.5) * 0.2
                });
            }

            let frame = 0;
            function animate() {
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                particles.forEach(p => {
                    p.y += p.speed;
                    p.x += Math.sin(p.angle) * 1;
                    p.angle += p.spin;
                    ctx.save();
                    ctx.translate(p.x, p.y);
                    ctx.rotate(p.angle);
                    ctx.fillStyle = p.color;
                    ctx.fillRect(-p.w / 2, -p.h / 2, p.w, p.h);
                    ctx.restore();
                });
                frame++;
                if (frame < 300) requestAnimationFrame(animate);
                else ctx.clearRect(0, 0, canvas.width, canvas.height);
            }
            animate();
        })();
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
