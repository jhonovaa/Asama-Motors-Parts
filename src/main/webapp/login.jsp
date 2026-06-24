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
        /* Estilos de Split Login Card */
        .login-split-card {
            display: flex;
            flex-direction: column;
            width: 100%;
            max-width: 900px;
            min-height: 520px;
            border-radius: 24px;
            background-color: var(--card-bg);
            border: 1px solid var(--card-border);
            overflow: hidden;
            margin: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
            z-index: 5;
            backdrop-filter: blur(10px);
        }
        
        .brand-panel {
            position: relative;
            background: linear-gradient(135deg, #0d1b2a 0%, #1b263b 50%, #415a77 100%);
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px;
            transition: all 0.4s ease;
        }
        
        body.light-mode .brand-panel {
            background: linear-gradient(135deg, #0052d4 0%, #4364f7 50%, #6fb1fc 100%);
        }
        
        .brand-content {
            position: relative;
            z-index: 2;
        }
        
        .form-panel {
            padding: 40px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            transition: background-color 0.4s ease;
        }
        
        .form-panel .form-control {
            border-radius: 30px !important;
            padding: 14px 24px 14px 50px !important; /* Extra padding on left for icons */
            background-color: rgba(255, 255, 255, 0.05) !important;
            border: 1px solid var(--card-border) !important;
            height: auto !important;
            color: #ffffff !important;
        }
        
        body.light-mode .form-panel .form-control {
            background-color: #f8fafc !important;
            border: 1px solid #cbd5e1 !important;
            color: #1e293b !important;
        }
        
        body.light-mode .form-panel .form-control::placeholder {
            color: #64748b !important;
        }
        
        .form-panel .form-control:focus {
            background-color: rgba(255, 255, 255, 0.08) !important;
            border-color: var(--accent-orange) !important;
            box-shadow: 0 0 0 0.25rem var(--accent-glow) !important;
        }
        
        body.light-mode .form-panel .form-control:focus {
            background-color: #ffffff !important;
        }
        
        /* Ajustar icono absoluto */
        .position-absolute.top-50.translate-middle-y {
            z-index: 10;
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

        .brand-icon {
            font-size: 3rem;
            color: #ffffff;
            text-shadow: 0 4px 10px rgba(0,0,0,0.3);
        }
        
        @media (min-width: 768px) {
            .login-split-card {
                flex-direction: row;
            }
            .brand-panel {
                width: 45%;
                min-height: 520px;
            }
            .form-panel {
                width: 55%;
                min-height: 520px;
                padding: 50px 60px;
            }
        }
        
        @media (max-width: 767px) {
            .brand-panel {
                width: 100%;
                height: 200px;
                padding: 30px 20px;
            }
            .form-panel {
                width: 100%;
                padding: 40px 25px;
            }
            .brand-logo-img {
                width: 60px !important;
                height: 60px !important;
                margin-bottom: 8px !important;
            }
            .brand-title {
                font-size: 1.6rem;
            }
        }
    </style>
</head>
<body class="body-center" style="background: radial-gradient(circle at center, var(--card-bg) 0%, var(--bg-color) 100%);">
<script src="resources/theme.js?v=2"></script>

    <!-- Boton de Tema -->
    <div style="position:fixed; top:20px; right:20px; z-index:1000;">
        <button onclick="toggleTheme()" class="btn btn-icon theme-toggle-btn rounded-circle transition-all shadow-lg" title="<fmt:message key='login.change_theme' />">
            <i id="themeIcon" class="bi bi-sun-fill fs-5"></i>
        </button>
    </div>

    <div class="login-split-card">
        <!-- Brand Panel (Left / Top) -->
        <div class="brand-panel">
            <!-- Wavy background layers using SVG -->
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 320" preserveAspectRatio="none" style="position: absolute; bottom: 0; left: 0; width: 100%; height: 100%; opacity: 0.15; pointer-events: none;">
                <path fill="#ffffff" d="M0,96L48,112C96,128,192,160,288,186.7C384,213,480,235,576,218.7C672,203,768,149,864,128C960,107,1056,117,1152,138.7C1248,160,1344,192,1392,208L1440,224L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z"></path>
            </svg>
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 320" preserveAspectRatio="none" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; opacity: 0.1; transform: scaleY(-1); pointer-events: none;">
                <path fill="#ffffff" d="M0,64L48,80C96,96,192,128,288,112C384,96,480,32,576,32C672,32,768,96,864,128C960,160,1056,160,1152,138.7C1248,117,1344,75,1392,53.3L1440,32L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z"></path>
            </svg>
            
            <div class="brand-content text-center">
                <img src="resources/logo-asama.png" alt="Logo" class="brand-logo-img mb-3" onerror="this.outerHTML='<div class=\'brand-icon mx-auto mb-3\'><i class=\'bi bi-gear-wide-connected\'></i></div>'">
                <h2 class="brand-title fw-bold text-white mb-2">Asama<span style="color: var(--accent-orange);">MotoParts</span></h2>
                <p class="text-white text-opacity-75 small px-4 px-md-5 mb-0">
                    Calidad y confianza en repuestos para tu motocicleta.
                </p>
            </div>
        </div>
        
        <!-- Form Panel (Right / Bottom) -->
        <div class="form-panel">
            <h3 class="form-title fw-bold text-center mb-1"><fmt:message key="login.title" /></h3>
            <p class="text-secondary small fw-medium text-center mb-4"><fmt:message key="login.login_msg" /></p>
            
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
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
