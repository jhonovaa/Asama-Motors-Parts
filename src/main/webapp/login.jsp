<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="login.title" /></title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="resources/theme.css?v=6">
    <style>
        /* --- ESTILOS MEJORADOS PARA FORMULARIOS --- */
        .form-control {
            background-color: rgba(255, 255, 255, 0.05) !important;
            color: #ffffff !important;
            border: 1px solid rgba(255, 255, 255, 0.15) !important;
            font-weight: 500;
            padding: 12px 20px;
            border-radius: 12px;
            letter-spacing: 0.5px;
        }
        .form-control::placeholder {
            color: rgba(255, 255, 255, 0.4) !important;
        }
        .form-control:focus {
            background-color: rgba(255, 255, 255, 0.08) !important;
            border-color: var(--accent-orange) !important;
            box-shadow: 0 0 0 0.25rem var(--accent-glow) !important;
        }

        /* Compatibilidad Modo Claro */
        body.light-mode .form-control {
            background-color: #ffffff !important;
            color: #212529 !important;
            border-color: rgba(0, 0, 0, 0.15) !important;
        }
        body.light-mode .form-control::placeholder {
            color: rgba(0, 0, 0, 0.5) !important;
        }

        .text-secondary { color: rgba(255, 255, 255, 0.7) !important; }
        body.light-mode .text-secondary { color: rgba(0, 0, 0, 0.6) !important; }

        .brand-logo-img {
            width: 80px;
            height: 80px;
            object-fit: contain;
            margin-bottom: 15px;
            filter: drop-shadow(0 4px 10px rgba(0,0,0,0.3));
        }
    </style>
</head>
<body class="body-center" style="background: radial-gradient(circle at center, var(--card-bg) 0%, var(--bg-color) 100%);">
<script src="resources/theme.js"></script>

    <!-- Boton de Tema -->
    <div style="position:fixed; top:20px; right:20px; z-index:1000;">
        <button onclick="toggleTheme()" class="btn btn-icon theme-toggle-btn rounded-circle transition-all shadow-lg" title="<fmt:message key='login.change_theme' />">
            <i id="themeIcon" class="bi bi-sun-fill fs-5"></i>
        </button>
    </div>

    <div class="login-card p-4 p-md-5 shadow-lg" style="width: 100%; max-width: 420px; border-radius: 20px;">
        <div class="text-center mb-4">
            <!-- Aqui insertamos el nuevo logo que te genere -->
            <img src="resources/logo-asama.png" alt="<fmt:message key='login.alt_logo' />" class="brand-logo-img" onerror="this.outerHTML='<div class=\'brand-icon mx-auto mb-3\'><i class=\'bi bi-gear-wide-connected\'></i></div>'">
            
            <h3 class="brand-title fw-bold letter-spacing-tight mb-1">Asama<span class="text-accent">MotoParts</span></h3>
            <p class="text-secondary small fw-medium"><fmt:message key="login.login_msg" /></p>
        </div>

        <% if(request.getAttribute("error") != null) { %>
            <div class="alert bg-danger bg-opacity-10 border border-danger text-danger py-2 px-3 text-center rounded-3 small fw-bold mb-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <!-- SweetAlert2 for Registration Success & System Messages -->
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <% if("1".equals(request.getParameter("success"))) { %>
            <script>
                document.addEventListener("DOMContentLoaded", function() {
                    const isLight = document.body.classList.contains('light-mode');
                    Swal.fire({
                        icon: 'success',
                        title: '<fmt:message key="login.alert_created_title" />',
                        text: '<fmt:message key="login.alert_created_text" />',
                        confirmButtonColor: getComputedStyle(document.documentElement).getPropertyValue('--accent-orange').trim() || '#00E5FF',
                        background: isLight ? '#ffffff' : '#1e1e24',
                        color: isLight ? '#333333' : '#f8f9fa',
                        customClass: { popup: 'rounded-4 border border-secondary border-opacity-25' }
                    });
                    
                    if(window.history.replaceState) {
                        const url = new URL(window.location);
                        url.searchParams.delete('success');
                        window.history.replaceState({path:url.href}, '', url.href);
                    }
                });
            </script>
        <% } %>

        <% String sysMsg = request.getParameter("msg"); 
           if(sysMsg != null && !sysMsg.trim().isEmpty()) { %>
            <script>
                document.addEventListener("DOMContentLoaded", function() {
                    const isLight = document.body.classList.contains('light-mode');
                    let titleText = '<fmt:message key="login.info" />';
                    let iconType = 'info';
                    
                    if ('<%= sysMsg %>'.toLowerCase().includes('inactividad')) {
                        titleText = '<fmt:message key="login.security" />';
                        iconType = 'warning';
                    }
                    
                    Swal.fire({
                        icon: iconType,
                        title: titleText,
                        text: '<%= sysMsg %>',
                        confirmButtonColor: getComputedStyle(document.documentElement).getPropertyValue('--accent-orange').trim() || '#ff6b00',
                        background: isLight ? '#ffffff' : '#1e1e24',
                        color: isLight ? '#333333' : '#f8f9fa',
                        customClass: { popup: 'rounded-4 border border-secondary border-opacity-25' }
                    });
                    
                    if(window.history.replaceState) {
                        const url = new URL(window.location);
                        url.searchParams.delete('msg');
                        window.history.replaceState({path:url.href}, '', url.href);
                    }
                });
            </script>
        <% } %>

        <form action="login" method="POST">
            <div class="mb-3 position-relative">
                <div class="position-absolute top-50 start-0 translate-middle-y ps-3 text-secondary">
                    <i class="bi bi-envelope"></i>
                </div>
                <input type="email" name="email" class="form-control ps-5" placeholder="<fmt:message key='login.email' />" required autofocus>
            </div>
            <div class="mb-4 position-relative">
                <div class="position-absolute top-50 start-0 translate-middle-y ps-3 text-secondary">
                    <i class="bi bi-lock"></i>
                </div>
                <input type="password" name="password" class="form-control ps-5" placeholder="<fmt:message key='login.password' />" required>
            </div>
            <button type="submit" class="btn btn-accent w-100 rounded-pill fw-bold py-2 fs-5 shadow-sm transition-all d-flex justify-content-center align-items-center gap-2">
                <fmt:message key="login.enter" /> <i class="bi bi-arrow-right-short"></i>
            </button>
        </form>

        <div class="text-center mt-4 pt-3 border-top border-secondary border-opacity-25 d-flex flex-column gap-2">
            <span class="text-secondary small"><fmt:message key="login.no_account" /> <a href="register.jsp" class="text-accent text-decoration-none fw-bold"><fmt:message key="login.create_account" /></a></span>
            <a href="index.jsp" class="text-secondary text-decoration-none small hover-accent transition-all"><i class="bi bi-house me-1"></i><fmt:message key="login.back_home" /></a>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>