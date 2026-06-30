<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    if (session.getAttribute("pendingProfileUpdate") == null || session.getAttribute("profileOtp") == null) {
        response.sendRedirect("profile.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verificar Nuevo Correo | Asama Moto Parts</title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="resources/theme.css?v=6">
</head>
<body class="body-center" style="background: radial-gradient(circle at center, var(--card-bg) 0%, var(--bg-color) 100%);">
<script src="resources/theme.js?v=2"></script>

    <div class="otp-card text-center shadow-lg" style="border-radius: 20px;">
        <div class="otp-icon">
            <i class="bi bi-envelope-check-fill"></i>
        </div>
        <h3 class="fw-bold mb-2">Verifica tu Correo</h3>
        <p class="text-secondary small mb-4">Hemos enviado un código de seguridad de 6 dígitos al nuevo correo electrónico. Por favor, ingrésalo a continuación para confirmar el cambio.</p>
        
        <% if(request.getAttribute("error") != null) { %>
            <div class="alert bg-danger bg-opacity-10 border border-danger text-danger py-2 px-3 rounded-3 small fw-bold mb-4">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <form action="profile" method="POST">
            <input type="hidden" name="action" value="verifyEmailOtp">
            <div class="mb-4">
                <input type="text" name="otp" class="form-control text-center py-3 fs-3 fw-bold letter-spacing-tight" style="letter-spacing: 8px;" placeholder="------" maxlength="6" required autofocus>
            </div>
            <button type="submit" class="btn btn-accent w-100 rounded-pill fw-bold py-3 fs-5 shadow-sm transition-all">
                Confirmar Cambio
            </button>
        </form>

        <div class="mt-4">
            <form action="profile" method="POST">
                <input type="hidden" name="action" value="cancelUpdate">
                <button type="submit" class="btn btn-link text-secondary text-decoration-none small hover-accent p-0 border-0 bg-transparent">Cancelar y volver al perfil</button>
            </form>
        </div>
    </div>
</body>
</html>
