<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User user = (User) session.getAttribute("user");
    boolean isLoggedIn = user != null;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Asama Moto Parts - Repuestos para Motos</title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;900&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="resources/theme.css?v=6">
    <style>
        /* --- Ajustes Responsivos Especificos del Landing --- */
        @media (max-width: 768px) {
            .hero-title { letter-spacing: -1.5px !important; font-size: 2.8rem !important; }
            .hero-subtitle { font-size: 1.05rem !important; padding: 0 15px; }
            .btn-moto, .btn-moto-outline { 
                padding: 14px 28px !important; 
                width: 100%; 
                margin-bottom: 12px; 
            }
            .hero-buttons { flex-direction: column; align-items: center; width: 100%; padding: 0 20px; }
        }
        
        /* --- Tarjetas de Caracteristicas --- */
        .feature-card {
            padding: 45px 30px;
            height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
        }
        .feature-card p { margin-bottom: 0; line-height: 1.6; }
    </style>
</head>
<body class="no-pad">
<script src="resources/theme.js"></script>

    <%@ include file="navbar.jsp" %>

    <section class="hero-section">
        <div class="hero-content mt-5">
            <h1 class="hero-title">Potencia en cada <span class="text-accent text-shadow">repuesto.</span></h1>
            <p class="hero-subtitle">
                Descubre el catalogo mas completo de piezas para motocicletas.
                Repuestos OEM y aftermarket con calidad certificada para que tu moto
                siempre rinda al maximo nivel.
            </p>
            <div class="d-flex gap-3 justify-content-center flex-wrap hero-buttons mt-5">
                <a href="catalog.jsp" class="btn btn-accent rounded-pill fw-bold shadow-lg d-flex align-items-center justify-content-center px-4 py-2 fs-5">
                    <i class="bi bi-grid-3x3-gap me-2"></i>Ver Catalogo
                </a>
                <a href="#features" class="btn btn-moto-outline rounded-pill fw-bold d-flex align-items-center justify-content-center px-4 py-2 fs-5">
                    Saber mas
                </a>
            </div>
        </div>
    </section>

    <section id="features" class="features-section">
        <div class="container">
            <div class="section-label mb-5 pb-3 text-center">
                <h2 class="fw-bold mb-3">¿Por que elegirnos?</h2>
                <p class="text-secondary fs-5">Todo lo que tu vehiculo necesita, en un solo lugar y con la mejor atencion.</p>
            </div>
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="feature-card shadow-sm transition-all">
                        <i class="bi bi-shield-check feature-icon mb-4 fs-1"></i>
                        <h4 class="fw-bold mb-3">Piezas Certificadas</h4>
                        <p class="text-secondary small">Trabajamos con repuestos OEM y aftermarket bajo los mas altos estandares de la industria del motociclismo.</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="feature-card shadow-sm transition-all">
                        <i class="bi bi-lightning-charge feature-icon mb-4 fs-1"></i>
                        <h4 class="fw-bold mb-3">Envio Express</h4>
                        <p class="text-secondary small">Despacho rapido gracias a nuestro sistema moderno de inventario. Tus repuestos llegan justo cuando los necesitas.</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="feature-card shadow-sm transition-all">
                        <i class="bi bi-wrench-adjustable feature-icon mb-4 fs-1"></i>
                        <h4 class="fw-bold mb-3">Taller Especializado</h4>
                        <p class="text-secondary small">Contamos con taller especializado en mantenimiento y reparacion. Manos expertas cuidando de tu vehiculo.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <footer class="footer-section py-4 border-top border-secondary border-opacity-25" style="background: var(--nav-bg);">
        <div class="container text-center">
            <p class="text-secondary small mb-0">&copy; 2026 Asama Moto Parts. Todos los derechos reservados.</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Efecto visual para el navbar al hacer scroll (Si el theme.css usa la clase .scrolled)
        window.addEventListener('scroll', function () {
            const nav = document.querySelector('.navbar');
            if(nav) {
                nav.classList.toggle('scrolled', window.scrollY > 40);
            }
        });
    </script>

</body>
</html>