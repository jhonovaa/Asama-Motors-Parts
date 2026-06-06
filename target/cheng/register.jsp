<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Cliente - Asama Moto Parts</title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <link rel="stylesheet" href="resources/theme.css?v=6">
</head>
<body class="body-center">
<script src="resources/theme.js"></script>
    <div style="position:fixed; top:16px; right:16px; z-index:1000;">
        <button onclick="toggleTheme()" class="theme-toggle-btn" title="Cambiar tema">
            <i id="themeIcon" class="bi bi-sun-fill"></i>
        </button>
    </div>

    <div class="register-card">
        <div class="text-center mb-4">
            <div class="brand-icon"><i class="bi bi-bicycle"></i></div>
            <h3 class="fw-bold mb-1">Crea tu cuenta</h3>
            <p class="text-secondary small">Únete a Asama Moto Parts y compra online</p>
        </div>

        <!-- SweetAlert2 for Registration Errors -->
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <% if(request.getAttribute("error") != null) { %>
            <script>
                document.addEventListener("DOMContentLoaded", function() {
                    Swal.fire({
                        icon: 'error',
                        title: 'No pudimos registrarte',
                        text: '<%= request.getAttribute("error") %>',
                        confirmButtonColor: getComputedStyle(document.documentElement).getPropertyValue('--accent-orange').trim(),
                        background: document.body.classList.contains('light-mode') ? '#fff' : '#1a1a1a',
                        color: document.body.classList.contains('light-mode') ? '#000' : '#fff'
                    });
                });
            </script>
        <% } %>

        <form action="register" method="POST">
            <div class="mb-3">
                <input type="text" name="fullName" class="form-control" placeholder="Nombre Completo" required>
            </div>
            <div class="mb-3">
                <input type="text" name="documentId" class="form-control" placeholder="Cédula / Documento" required>
            </div>
            <div class="mb-3">
                <input type="email" name="email" class="form-control" placeholder="Correo Electrónico" required>
            </div>
            <div class="mb-4">
                <input type="password" name="password" class="form-control" placeholder="Contraseña" required>
            </div>
            <button type="submit" class="btn-moto">Registrarme</button>
        </form>

        <div class="text-center mt-4">
            <span class="text-secondary small">¿Ya tienes cuenta? </span>
            <a href="login.jsp" class="text-orange text-decoration-none small fw-bold">Inicia Sesión</a>
        </div>
    </div>

</body>
</html>
