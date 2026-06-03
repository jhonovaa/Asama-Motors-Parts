<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Cliente - Asama Moto Parts</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --bg-color: #0a0a0a;
            --text-color: #f0f0f0;
            --accent-orange: #FF6B35;
        }
        body { font-family: 'Inter', sans-serif; background-color: var(--bg-color); color: var(--text-color); display: flex; align-items: center; justify-content: center; min-height: 100vh; }
        .register-card { background: #1a1a1a; border-radius: 15px; padding: 40px; width: 100%; max-width: 450px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); border: 1px solid rgba(255,255,255,0.05); }
        .brand-icon { width: 60px; height: 60px; background: linear-gradient(135deg, var(--accent-orange), #E55A2B); border-radius: 15px; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px; font-size: 30px; color: white; box-shadow: 0 5px 15px rgba(255,107,53,0.3); }
        .form-control { background: #2D3436; border: 1px solid rgba(255,255,255,0.1); color: #fff; border-radius: 10px; padding: 12px 15px; }
        .form-control:focus { background: #2D3436; color: #fff; border-color: var(--accent-orange); box-shadow: 0 0 0 3px rgba(255,107,53,0.15); }
        .btn-moto { background-color: var(--accent-orange); color: #fff; border: none; border-radius: 10px; padding: 12px; font-weight: 600; width: 100%; transition: 0.3s; }
        .btn-moto:hover { background-color: #E55A2B; color: white; transform: translateY(-1px); }
        .text-orange { color: var(--accent-orange) !important; }
    </style>
    <link rel="stylesheet" href="resources/theme.css">
</head>
<body>
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
                        confirmButtonColor: '#FF6B35',
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
