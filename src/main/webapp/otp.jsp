<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String otpCode = (String) session.getAttribute("otp");
    if (otpCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verificacion OTP - Asama Moto Parts</title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="resources/theme.css?v=6">
    <style>
        /* --- LEGIBILIDAD EXTREMA --- */
        /* Hacemos que los textos secundarios sean casi blancos para que resalten */
        .text-secondary, .text-muted { 
            color: rgba(255, 255, 255, 0.85) !important; 
            font-weight: 500;
        }
        body.light-mode .text-secondary, body.light-mode .text-muted { 
            color: rgba(0, 0, 0, 0.75) !important; 
            font-weight: 600;
        }

        /* Input de Codigo OTP Gigante y Claro */
        .form-control {
            background-color: rgba(255, 255, 255, 0.08) !important;
            color: #ffffff !important;
            border: 2px solid rgba(255, 255, 255, 0.2) !important;
            font-weight: 800;
            padding: 15px 20px;
            border-radius: 12px;
            letter-spacing: 12px; 
            font-size: 1.8rem;
        }
        .form-control::placeholder {
            color: rgba(255, 255, 255, 0.5) !important;
            letter-spacing: 12px;
            font-weight: 600;
        }
        .form-control:focus {
            background-color: rgba(255, 255, 255, 0.12) !important;
            border-color: var(--accent-orange) !important;
            box-shadow: 0 0 0 0.3rem var(--accent-glow) !important;
        }

        /* Compatibilidad Modo Claro para el Input */
        body.light-mode .form-control {
            background-color: #ffffff !important;
            color: #121417 !important;
            border-color: rgba(0, 0, 0, 0.25) !important;
        }
        body.light-mode .form-control::placeholder {
            color: rgba(0, 0, 0, 0.4) !important;
        }

        /* Estilo de la caja OTP simulada (Super visible) */
        .otp-display-box {
            background: rgba(0, 229, 255, 0.1);
            border: 2px dashed var(--accent-orange);
            border-radius: 12px;
            padding: 15px;
            font-size: 2.5rem;
            font-weight: 900;
            letter-spacing: 15px;
            color: var(--accent-orange);
            margin: 15px 0 25px;
            font-family: 'Courier New', monospace;
            box-shadow: inset 0 0 15px rgba(0,0,0,0.3);
            text-shadow: 0 0 10px var(--accent-glow);
        }
        
        body.light-mode .otp-display-box {
            background: rgba(255, 214, 0, 0.15);
            text-shadow: none;
            box-shadow: inset 0 0 10px rgba(0,0,0,0.05);
        }
    </style>
</head>
<body class="body-center" style="background: radial-gradient(circle at center, var(--card-bg) 0%, var(--bg-color) 100%);">
<script src="resources/theme.js"></script>

    <!-- Boton de Tema -->
    <div style="position:fixed; top:20px; right:20px; z-index:1000;">
        <button onclick="toggleTheme()" class="btn btn-icon theme-toggle-btn rounded-circle transition-all shadow-lg" title="Cambiar tema">
            <i id="themeIcon" class="bi bi-sun-fill fs-5"></i>
        </button>
    </div>

    <div class="login-card p-4 p-md-5 shadow-lg text-center" style="width: 100%; max-width: 480px; border-radius: 20px;">
        <div class="brand-icon mx-auto mb-3" style="width: 75px; height: 75px; font-size: 35px; background-color: var(--accent-orange); color: #121417; border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 15px var(--accent-glow);">
            <i class="bi bi-shield-lock-fill"></i>
        </div>
        
        <h2 class="fw-bold mb-2 title-main text-white">Verificacion OTP</h2>
        <p class="text-secondary mb-4 fs-6">Ingresa el codigo de seguridad de 6 digitos para acceder a tu cuenta.</p>
        
        <!-- Simulacion OTP -->
        <div class="bg-dark bg-opacity-50 rounded-4 p-4 mb-4 border border-secondary border-opacity-50 shadow-sm">
            <span class="badge bg-secondary bg-opacity-75 text-light mb-3 fw-bold border border-secondary border-opacity-50 px-3 py-2 fs-6">
                <i class="bi bi-info-circle-fill me-2"></i>Simulacion de Envio
            </span>
            <div class="otp-display-box mx-auto d-flex justify-content-center align-items-center"><%= otpCode %></div>
            <p class="small text-muted mb-0 fw-bold">En produccion real, este codigo se enviara a tu correo electronico.</p>
        </div>
        
        <% if(request.getAttribute("error") != null) { %>
            <div class="alert bg-danger bg-opacity-25 border border-danger text-danger py-3 px-3 text-center rounded-3 fw-bold mb-4 shadow-sm fs-6" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i> <%= request.getAttribute("error") %>
            </div>
        <% } %>
        
        <form action="verifyOtp" method="POST">
            <div class="mb-4">
                <input type="text" name="otp" class="form-control text-center shadow-sm" placeholder="------" maxlength="6" required autofocus pattern="[0-9]{6}" title="Ingresa los 6 digitos exactos">
            </div>
            <button type="submit" class="btn btn-accent w-100 rounded-pill fw-bold py-3 fs-5 shadow-lg transition-all d-flex justify-content-center align-items-center gap-2">
                <i class="bi bi-check-circle-fill"></i> Verificar e Ingresar
            </button>
        </form>
        
        <div class="text-center mt-4 pt-4 border-top border-secondary border-opacity-25">
            <a href="login.jsp" class="text-secondary text-decoration-none hover-accent transition-all fw-bold fs-6">
                <i class="bi bi-arrow-left-circle-fill me-2"></i> Volver al inicio de sesion
            </a>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Correccion automatica para que el titulo principal sea negro en modo claro
        document.addEventListener("DOMContentLoaded", function() {
            const title = document.querySelector('.title-main');
            
            function updateTitleColor() {
                if(document.body.classList.contains('light-mode')) {
                    title.classList.remove('text-white');
                    title.classList.add('text-dark');
                } else {
                    title.classList.remove('text-dark');
                    title.classList.add('text-white');
                }
            }
            
            updateTitleColor(); // Ejecutar al cargar
            
            const themeBtn = document.querySelector('.theme-toggle-btn');
            themeBtn.addEventListener('click', () => {
                setTimeout(updateTitleColor, 50); // Esperar a que theme.js cambie la clase
            });
        });
    </script>
</body>
</html>