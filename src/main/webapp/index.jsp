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
    <title>Asama Moto Parts — Repuestos para Motos</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;900&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --bg-color: #0a0a0a;
            --accent-orange: #FF6B35;
            --accent-dark: #2D3436;
            --card-bg: #1a1a1a;
            --text-color: #f0f0f0;
            --nav-bg: rgba(10, 10, 10, 0.85);
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg-color);
            color: var(--text-color);
            overflow-x: hidden;
        }

        /* ── Navbar ─────────────────────────────────── */
        .navbar {
            background-color: var(--nav-bg);
            backdrop-filter: blur(24px);
            -webkit-backdrop-filter: blur(24px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.06);
            padding: 14px 0;
            transition: background-color 0.3s;
        }
        .navbar.scrolled { background-color: rgba(10, 10, 10, 0.96); }

        .navbar-brand {
            color: #fff !important;
            font-weight: 900;
            letter-spacing: -1px;
            font-size: 1.55rem;
            text-decoration: none;
        }
        .navbar-brand span { color: var(--accent-orange); }

        .nav-link-custom {
            color: rgba(255, 255, 255, 0.75);
            text-decoration: none;
            font-weight: 500;
            font-size: 0.95rem;
            transition: color 0.25s;
        }
        .nav-link-custom:hover { color: var(--accent-orange); }

        /* ── Buttons ────────────────────────────────── */
        .btn-primary-moto {
            background-color: var(--accent-orange);
            color: #fff;
            border: none;
            border-radius: 30px;
            padding: 15px 42px;
            font-weight: 600;
            font-size: 1.05rem;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }
        .btn-primary-moto:hover {
            background-color: #e85a25;
            color: #fff;
            transform: translateY(-2px);
            box-shadow: 0 8px 28px rgba(255, 107, 53, 0.35);
        }

        .btn-outline-moto {
            background-color: transparent;
            color: #fff;
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 30px;
            padding: 15px 42px;
            font-weight: 600;
            font-size: 1.05rem;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }
        .btn-outline-moto:hover {
            background-color: rgba(255, 107, 53, 0.1);
            border-color: var(--accent-orange);
            color: var(--accent-orange);
        }

        .btn-outline-moto-sm {
            background-color: transparent;
            color: #fff;
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 30px;
            padding: 8px 22px;
            font-weight: 600;
            font-size: 0.875rem;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }
        .btn-outline-moto-sm:hover {
            background-color: var(--accent-orange);
            border-color: var(--accent-orange);
            color: #fff;
        }

        /* ── Hero Section ───────────────────────────── */
        .hero-section {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            background: radial-gradient(ellipse at 50% 40%, #2D3436 0%, #141414 45%, #0a0a0a 100%);
            position: relative;
            overflow: hidden;
        }

        /* Subtle noise/texture overlay */
        .hero-section::before {
            content: '';
            position: absolute;
            inset: 0;
            background: repeating-conic-gradient(rgba(255,255,255,0.01) 0% 25%, transparent 0% 50%) 0 0 / 4px 4px;
            pointer-events: none;
            z-index: 1;
        }

        /* Decorative orange glow */
        .hero-section::after {
            content: '';
            position: absolute;
            width: 600px;
            height: 600px;
            background: radial-gradient(circle, rgba(255,107,53,0.08) 0%, transparent 70%);
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            pointer-events: none;
            z-index: 1;
        }

        .hero-content {
            z-index: 2;
            max-width: 820px;
            padding: 0 24px;
        }

        .hero-badge {
            display: inline-block;
            background: rgba(255, 107, 53, 0.12);
            border: 1px solid rgba(255, 107, 53, 0.25);
            color: var(--accent-orange);
            padding: 6px 18px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
            letter-spacing: 1px;
            text-transform: uppercase;
            margin-bottom: 28px;
        }

        .hero-title {
            font-size: clamp(2.8rem, 6vw, 4.8rem);
            font-weight: 900;
            letter-spacing: -2.5px;
            line-height: 1.05;
            background: linear-gradient(135deg, #ffffff 0%, #b0b0b0 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 24px;
        }

        .hero-title .accent {
            background: linear-gradient(135deg, var(--accent-orange) 0%, #ff8f5e 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .hero-subtitle {
            font-size: 1.2rem;
            color: #999;
            font-weight: 400;
            line-height: 1.7;
            margin-bottom: 44px;
            max-width: 620px;
            margin-left: auto;
            margin-right: auto;
        }

        /* ── Features Section ───────────────────────── */
        .features-section {
            padding: 110px 0;
            background-color: var(--card-bg);
            border-top: 1px solid rgba(255, 255, 255, 0.04);
        }

        .features-section .section-label {
            text-align: center;
            margin-bottom: 60px;
        }
        .features-section .section-label h2 {
            font-size: 2rem;
            font-weight: 800;
            letter-spacing: -1px;
            color: #fff;
        }
        .features-section .section-label p {
            color: #777;
            font-size: 1.05rem;
            margin-top: 8px;
        }

        .feature-card {
            text-align: center;
            padding: 48px 28px;
            border-radius: 16px;
            background: rgba(255, 255, 255, 0.025);
            border: 1px solid rgba(255, 255, 255, 0.05);
            transition: all 0.35s ease;
        }
        .feature-card:hover {
            background: rgba(255, 107, 53, 0.04);
            border-color: rgba(255, 107, 53, 0.15);
            transform: translateY(-6px);
        }

        .feature-icon {
            font-size: 2.8rem;
            color: var(--accent-orange);
            margin-bottom: 22px;
            display: inline-block;
        }

        .feature-card h4 {
            font-weight: 700;
            font-size: 1.15rem;
            color: #fff;
            margin-bottom: 12px;
        }

        .feature-card p {
            color: #888;
            font-size: 0.95rem;
            line-height: 1.65;
            margin-bottom: 0;
        }

        /* ── Footer ─────────────────────────────────── */
        .footer-section {
            padding: 40px 0;
            background-color: var(--bg-color);
            border-top: 1px solid rgba(255, 255, 255, 0.04);
            text-align: center;
        }
        .footer-section p {
            color: #555;
            font-size: 0.85rem;
            margin: 0;
        }

        /* ── Responsive ─────────────────────────────── */
        @media (max-width: 768px) {
            .hero-title { letter-spacing: -1.5px; }
            .hero-subtitle { font-size: 1.05rem; }
            .btn-primary-moto,
            .btn-outline-moto {
                padding: 13px 32px;
                font-size: 0.95rem;
            }
            .hero-buttons { flex-direction: column; align-items: center; }
        }
    </style>
</head>
<body>

    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark fixed-top">
        <div class="container">
            <a class="navbar-brand" href="index.jsp">Asama<span>MotoParts</span></a>
            <div class="d-flex gap-3 align-items-center">
                <a href="catalog.jsp" class="nav-link-custom me-2">Catálogo</a>
                <% if(isLoggedIn) { %>
                    <a href="dashboard.jsp" class="btn-outline-moto-sm">Mi Panel</a>
                <% } else { %>
                    <a href="login.jsp" class="btn-outline-moto-sm">Iniciar Sesión</a>
                <% } %>
            </div>
        </div>
    </nav>

    <!-- Hero -->
    <section class="hero-section">
        <div class="hero-content">
            <div class="hero-badge">Repuestos para motos</div>
            <h1 class="hero-title">Potencia en cada <span class="accent">repuesto.</span></h1>
            <p class="hero-subtitle">
                Descubre el catálogo más completo de repuestos para motocicletas.
                Piezas OEM y aftermarket con calidad certificada para que tu moto
                siempre rinda al máximo.
            </p>
            <div class="d-flex gap-3 justify-content-center flex-wrap hero-buttons">
                <a href="catalog.jsp" class="btn-primary-moto">Ver Catálogo</a>
                <a href="#features" class="btn-outline-moto">Saber más</a>
            </div>
        </div>
    </section>

    <!-- Features -->
    <section id="features" class="features-section">
        <div class="container">
            <div class="section-label">
                <h2>¿Por qué elegirnos?</h2>
                <p>Todo lo que tu moto necesita, en un solo lugar.</p>
            </div>
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="feature-card">
                        <i class="bi bi-shield-check feature-icon"></i>
                        <h4>Repuestos Certificados</h4>
                        <p>Trabajamos con piezas OEM y aftermarket certificadas bajo los más altos estándares de la industria de motocicletas.</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="feature-card">
                        <i class="bi bi-lightning-charge feature-icon"></i>
                        <h4>Envío Express</h4>
                        <p>Despacho rápido gracias a nuestro sistema moderno de inventario. Tus repuestos llegan cuando los necesitas.</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="feature-card">
                        <i class="bi bi-wrench feature-icon"></i>
                        <h4>Taller Especializado</h4>
                        <p>Contamos con taller especializado en mantenimiento y reparación de motocicletas. Manos expertas para tu moto.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer-section">
        <div class="container">
            <p>&copy; 2026 Asama Moto Parts. Todos los derechos reservados.</p>
        </div>
    </footer>

    <!-- Navbar scroll effect -->
    <script>
        window.addEventListener('scroll', function () {
            const nav = document.querySelector('.navbar');
            nav.classList.toggle('scrolled', window.scrollY > 40);
        });
    </script>

</body>
</html>
