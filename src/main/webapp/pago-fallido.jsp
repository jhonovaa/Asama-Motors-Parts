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
    <title>Pago Fallido</title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body { font-family: 'Inter', sans-serif; background-color: var(--bg-color, #f8f9fa); padding-top: 80px; }
        .failure-card { background: white; border-radius: 15px; padding: 40px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); border: none; max-width: 500px; margin: auto; text-align: center; }
        .btn-moto { background-color: #ff6b35; color: white; border-radius: 30px; padding: 10px 30px; font-weight: 600; text-decoration: none; }
        .btn-moto-outline { border: 2px solid #ff6b35; color: #ff6b35; border-radius: 30px; padding: 10px 30px; font-weight: 600; text-decoration: none; }
    </style>
</head>
<body>
    <div class="container">
        <div class="failure-card">
            <i class="bi bi-x-circle-fill text-danger" style="font-size: 5rem;"></i>
            <h2 class="mt-4 fw-bold">Pago Rechazado</h2>
            <p class="text-secondary mt-3">Hubo un problema al procesar tu pago en Mercado Pago o lo has cancelado. Tu pedido sigue guardado en el carrito.</p>
            
            <div class="mt-4 d-flex justify-content-center gap-3">
                <a href="checkout.jsp" class="btn btn-moto">Reintentar Pago</a>
                <a href="catalog.jsp" class="btn btn-moto-outline">Seguir Comprando</a>
            </div>
        </div>
    </div>
</body>
</html>
