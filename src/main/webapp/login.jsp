<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar Sesión - Asama Moto Parts</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; }

        body {
            font-family: 'Inter', sans-serif;
            background-color: #0a0a0a;
            color: #e0e0e0;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
            position: relative;
            overflow: hidden;
        }

        /* Subtle radial glow behind the card */
        body::before {
            content: '';
            position: absolute;
            width: 500px;
            height: 500px;
            background: radial-gradient(circle, rgba(255,107,53,0.08) 0%, transparent 70%);
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            pointer-events: none;
            z-index: 0;
        }

        .login-card {
            background: #1a1a1a;
            border-radius: 16px;
            padding: 44px 36px 36px;
            width: 100%;
            max-width: 420px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.6), 0 0 0 1px rgba(255,255,255,0.04);
            position: relative;
            z-index: 1;
        }

        .brand-icon {
            width: 56px;
            height: 56px;
            border-radius: 14px;
            background: linear-gradient(135deg, #FF6B35 0%, #E55A2B 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 18px;
            font-size: 26px;
            color: #fff;
            box-shadow: 0 4px 20px rgba(255,107,53,0.3);
        }

        .brand-title {
            font-size: 1.55rem;
            font-weight: 700;
            letter-spacing: -0.5px;
            color: #ffffff;
        }

        .brand-title span {
            color: #FF6B35;
        }

        .brand-subtitle {
            color: #6b6b6b;
            font-size: 0.88rem;
            font-weight: 400;
            margin-top: 4px;
        }

        .form-control {
            background-color: #2D3436;
            border: 1.5px solid rgba(255,255,255,0.06);
            color: #f0f0f0;
            padding: 13px 16px;
            border-radius: 10px;
            font-size: 0.92rem;
            transition: border-color 0.25s ease, box-shadow 0.25s ease;
        }

        .form-control::placeholder {
            color: #6b7280;
        }

        .form-control:focus {
            background-color: #2D3436;
            color: #f0f0f0;
            border-color: #FF6B35;
            box-shadow: 0 0 0 3px rgba(255,107,53,0.15);
        }

        .btn-login {
            background-color: #FF6B35;
            color: #ffffff;
            border: none;
            border-radius: 10px;
            padding: 13px;
            font-weight: 600;
            font-size: 0.95rem;
            width: 100%;
            transition: background-color 0.25s ease, transform 0.15s ease;
            cursor: pointer;
        }

        .btn-login:hover {
            background-color: #E55A2B;
            color: #ffffff;
            transform: translateY(-1px);
        }

        .btn-login:active {
            transform: translateY(0);
        }

        .alert-danger {
            background-color: rgba(220,53,69,0.12);
            border: 1px solid rgba(220,53,69,0.25);
            color: #ff6b6b;
            border-radius: 10px;
            font-size: 0.88rem;
        }

        .footer-links a {
            color: #6b6b6b;
            text-decoration: none;
            font-size: 0.85rem;
            transition: color 0.2s ease;
        }

        .footer-links a:hover {
            color: #FF6B35;
        }

        .divider {
            color: #333;
            margin: 0 8px;
            font-size: 0.85rem;
        }
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
    <div class="login-card">
        <div class="text-center mb-4">
            <div class="brand-icon">
                <i class="bi bi-bicycle"></i>
            </div>
            <h3 class="brand-title">Asama<span>MotoParts</span></h3>
            <p class="brand-subtitle">Inicia sesión en tu cuenta</p>
        </div>

        <% if(request.getAttribute("error") != null) { %>
            <div class="alert alert-danger py-2 text-center" role="alert">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <!-- SweetAlert2 for Registration Success -->
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <% if("1".equals(request.getParameter("success"))) { %>
            <script>
                document.addEventListener("DOMContentLoaded", function() {
                    Swal.fire({
                        icon: 'success',
                        title: '¡Cuenta creada!',
                        text: 'Te has registrado exitosamente como Cliente. Ahora puedes iniciar sesión.',
                        confirmButtonColor: '#FF6B35',
                        background: document.body.classList.contains('light-mode') ? '#fff' : '#1a1a1a',
                        color: document.body.classList.contains('light-mode') ? '#000' : '#fff'
                    });
                    
                    if(window.history.replaceState) {
                        const url = new URL(window.location);
                        url.searchParams.delete('success');
                        window.history.replaceState({path:url.href}, '', url.href);
                    }
                });
            </script>
        <% } %>

        <form action="login" method="POST">
            <div class="mb-3">
                <input type="email" name="email" class="form-control" placeholder="Correo electrónico" required autofocus>
            </div>
            <div class="mb-4">
                <input type="password" name="password" class="form-control" placeholder="Contraseña" required>
            </div>
            <button type="submit" class="btn-login">Ingresar</button>
        </form>

        <div class="text-center mt-4 footer-links">
            <a href="register.jsp">Crear cuenta</a>
            <span class="divider">·</span>
            <a href="index.jsp">Volver al inicio</a>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
