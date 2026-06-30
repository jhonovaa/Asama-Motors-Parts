<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    User user = (User) session.getAttribute("user");
    boolean isLoggedIn = user != null;
%>
<!DOCTYPE html>
<html lang="<fmt:message key='app.lang' />">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="index.title" /></title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=5">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;900&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="resources/theme.css?v=6">
    <style>
        /* --- CSS Animations --- */
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(50px); }
            to { opacity: 1; transform: translateY(0); }
        }
        @keyframes float {
            0% { transform: translateY(0px); }
            50% { transform: translateY(-15px); }
            100% { transform: translateY(0px); }
        }
        
        .animate-on-scroll {
            opacity: 0;
            transform: translateY(50px);
            transition: opacity 0.8s ease-out, transform 0.8s ease-out;
        }
        .animate-on-scroll.visible {
            opacity: 1;
            transform: translateY(0);
        }

        .delay-1 { transition-delay: 0.2s; }
        .delay-2 { transition-delay: 0.4s; }
        .delay-3 { transition-delay: 0.6s; }
        
        .floating-img {
            animation: float 6s ease-in-out infinite;
        }

        /* --- Hero Rediseñado --- */
        .hero-section {
            min-height: 100vh;
            display: flex;
            align-items: center;
            background: var(--body-bg);
            padding-top: 80px; 
            overflow: hidden;
            position: relative;
        }
        
        .hero-section::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background: radial-gradient(circle at top right, var(--accent-cyan) 0%, transparent 40%),
                        radial-gradient(circle at bottom left, var(--accent-orange) 0%, transparent 30%);
            opacity: 0.05;
            pointer-events: none;
        }
        
        @media (max-width: 991px) {
            .hero-title { font-size: 3rem !important; text-align: center; }
            .hero-subtitle { font-size: 1.1rem !important; text-align: center; margin: 0 auto; }
            .hero-buttons { justify-content: center; width: 100%; }
            .hero-section { text-align: center; }
            .hero-img-col { display: none; } 
            .team-card { margin-bottom: 20px; }
        }

        /* --- Tarjetas (Features) --- */
        .feature-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 40px 30px;
            height: 100%;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0,0,0,0.05);
        }
        .feature-card:hover {
            transform: translateY(-10px);
            border-color: var(--accent-cyan);
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
        }
        .feature-icon {
            font-size: 3.5rem;
            color: var(--accent-orange);
            margin-bottom: 1.5rem;
        }

        /* --- Location Section --- */
        .location-section {
            padding: 80px 0;
            position: relative;
        }
        
        .map-container {
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 15px 40px rgba(0,0,0,0.1);
            border: 1px solid var(--card-border);
            background: var(--card-bg);
            padding: 10px;
        }

        /* --- Team Cards --- */
        .team-section {
            padding: 100px 0;
            background: var(--body-bg);
            position: relative;
        }
        .team-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 40px 30px;
            height: 100%;
            transition: all 0.4s ease;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            position: relative;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.05);
        }
        .team-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 4px;
            background: linear-gradient(90deg, var(--accent-cyan), var(--accent-orange));
            opacity: 0;
            transition: opacity 0.4s ease;
        }
        .team-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
        }
        .team-card:hover::before {
            opacity: 1;
        }
        .team-avatar {
            width: 130px;
            height: 130px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--accent-cyan), var(--accent-orange));
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 3.5rem;
            color: #fff;
            margin-bottom: 1.5rem;
            box-shadow: 0 10px 25px rgba(0,0,0,0.15);
            font-weight: 900;
            border: 4px solid var(--card-bg);
        }
        .team-role {
            color: var(--accent-orange);
            font-weight: 700;
            font-size: 0.95rem;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            margin-bottom: 20px;
        }
        .team-desc {
            color: var(--text-color);
            opacity: 0.75;
            font-size: 0.95rem;
            line-height: 1.6;
            margin-bottom: 25px;
        }
        
    </style>
</head>
<body class="no-pad">
<script src="resources/theme.js?v=2"></script>

    <%@ include file="navbar.jsp" %>

    <!-- HERO SECTION -->
    <section class="hero-section">
        <div class="container position-relative z-1">
            <div class="row align-items-center">
                <div class="col-lg-7 animate-on-scroll">
                    <div class="pe-lg-5 text-center text-lg-start">
                        <div class="badge bg-opacity-10 border border-secondary text-warning rounded-pill px-4 py-2 mb-4 d-inline-block shadow-sm" style="background-color: var(--card-bg);">
                            <i class="bi bi-star-fill me-2"></i> Excelencia en Partes y Servicios
                        </div>
                        <h1 class="hero-title fw-bold mb-4" style="font-size: 4.5rem; line-height: 1.1; letter-spacing: -1px; color: var(--text-color);">
                            <fmt:message key="index.hero_title" /> <br>
                            <span class="text-accent text-shadow"><fmt:message key="index.hero_title_accent" /></span>
                        </h1>
                        <p class="hero-subtitle fs-5 mb-5 mx-auto mx-lg-0" style="max-width: 600px; line-height: 1.7; color: var(--text-color); opacity: 0.85;">
                            <fmt:message key="index.hero_subtitle" />
                            Contamos con el stock más completo y un servicio de taller especializado para garantizar que tu moto siempre rinda al máximo nivel.
                        </p>
                        <div class="d-flex gap-3 flex-wrap hero-buttons justify-content-center justify-content-lg-start">
                            <a href="catalog.jsp" class="btn btn-accent rounded-pill fw-bold shadow-lg d-flex align-items-center justify-content-center px-4 py-2 fs-5">
                                <i class="bi bi-grid-3x3-gap-fill me-2"></i> Explorar Catálogo
                            </a>
                            <a href="#features" class="btn btn-moto-outline rounded-pill fw-bold d-flex align-items-center justify-content-center px-4 py-2 fs-5">
                                Saber Más
                            </a>
                        </div>
                    </div>
                </div>
                <div class="col-lg-5 hero-img-col text-center">
                    <img src="resources/logo-asama.png" alt="Asama Motors" class="img-fluid floating-img animate-on-scroll delay-1" style="max-width: 85%; filter: drop-shadow(0 20px 30px rgba(0,0,0,0.15)); border-radius: 20px;">
                </div>
            </div>
        </div>
    </section>

    <!-- LOCATION SECTION (GOOGLE MAPS) -->
    <section class="location-section border-top border-secondary border-opacity-10">
        <div class="container">
            <div class="row justify-content-center text-center animate-on-scroll">
                <div class="col-12 mb-4">
                    <h2 class="fw-bold mb-3" style="font-size: 2.5rem; color: var(--text-color);">Encuéntranos Aquí</h2>
                    <p class="fs-5" style="color: var(--text-color); opacity: 0.8;">SENA CIMM SOGAMOSO - Cra. 12 #54-359 a 54-321</p>
                </div>
            </div>
            
            <div class="row justify-content-center">
                <div class="col-md-10 col-lg-8 animate-on-scroll delay-1">
                    <div class="map-container">
                        <iframe src="https://maps.google.com/maps?q=SENA%20CIMM%20Sogamoso&t=&z=15&ie=UTF8&iwloc=&output=embed" width="100%" height="350" style="border:0; border-radius: 10px;" allowfullscreen="" loading="lazy"></iframe>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- FEATURES SECTION -->
    <section id="features" class="py-5 my-3">
        <div class="container">
            <div class="section-label mb-5 pb-4 text-center animate-on-scroll">
                <h2 class="fw-bold mb-3" style="font-size: 2.5rem; color: var(--text-color);"><fmt:message key="index.features_title" /></h2>
                <p class="fs-5" style="color: var(--text-color); opacity: 0.8;"><fmt:message key="index.features_subtitle" /></p>
            </div>
            <div class="row g-4">
                <div class="col-md-4 animate-on-scroll delay-1">
                    <div class="feature-card">
                        <i class="bi bi-shield-check feature-icon"></i>
                        <h4 class="fw-bold mb-3" style="color: var(--text-color);"><fmt:message key="index.feature1_title" /></h4>
                        <p style="line-height: 1.6; color: var(--text-color); opacity: 0.8;"><fmt:message key="index.feature1_desc" /></p>
                    </div>
                </div>
                <div class="col-md-4 animate-on-scroll delay-2">
                    <div class="feature-card">
                        <i class="bi bi-lightning-charge feature-icon"></i>
                        <h4 class="fw-bold mb-3" style="color: var(--text-color);"><fmt:message key="index.feature2_title" /></h4>
                        <p style="line-height: 1.6; color: var(--text-color); opacity: 0.8;"><fmt:message key="index.feature2_desc" /></p>
                    </div>
                </div>
                <div class="col-md-4 animate-on-scroll delay-3">
                    <div class="feature-card">
                        <i class="bi bi-wrench-adjustable feature-icon"></i>
                        <h4 class="fw-bold mb-3" style="color: var(--text-color);"><fmt:message key="index.feature3_title" /></h4>
                        <p style="line-height: 1.6; color: var(--text-color); opacity: 0.8;"><fmt:message key="index.feature3_desc" /></p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- TEAM SECTION -->
    <section id="team" class="team-section border-top border-secondary border-opacity-10">
        <div class="container">
            <div class="text-center mb-5 pb-3 animate-on-scroll">
                <div class="badge bg-opacity-10 text-accent-cyan border border-secondary border-opacity-25 rounded-pill px-3 py-2 mb-3" style="background-color: var(--card-bg);">
                    <i class="bi bi-code-slash me-2"></i>Creadores del Proyecto
                </div>
                <h2 class="fw-bold mb-3" style="font-size: 2.5rem; color: var(--text-color);">Nuestro Equipo Desarrollador</h2>
                <p class="fs-5" style="max-width: 700px; margin: 0 auto; color: var(--text-color); opacity: 0.8;">Conoce a las mentes detrás de la arquitectura y diseño de Asama Motors Parts.</p>
            </div>
            
            <div class="row g-4 justify-content-center">
                <!-- Mariana -->
                <div class="col-lg-4 col-md-6 animate-on-scroll delay-1">
                    <div class="team-card">
                        <div class="team-avatar" style="background: linear-gradient(135deg, #FF416C, #FF4B2B);">M</div>
                        <h4 class="fw-bold mb-1" style="color: var(--text-color);">Mariana Gonzales</h4>
                        <div class="team-role" style="color: #FF4B2B;">FrontEnd & Documentación</div>
                        <p class="team-desc">Especialista en interfaces de usuario (UI), experiencia interactiva (UX) y arquitectura de la documentación técnica del proyecto.</p>
                        <div class="d-flex flex-wrap justify-content-center gap-2 mt-auto">
                            <span class="badge border border-secondary px-3 py-2 rounded-pill" style="color: var(--text-color); background: var(--body-bg);"><i class="bi bi-palette me-1"></i> UI/UX</span>
                            <span class="badge border border-secondary px-3 py-2 rounded-pill" style="color: var(--text-color); background: var(--body-bg);"><i class="bi bi-file-text me-1"></i> Docs</span>
                        </div>
                    </div>
                </div>
                
                <!-- Johann -->
                <div class="col-lg-4 col-md-6 animate-on-scroll delay-2">
                    <div class="team-card">
                        <div class="team-avatar" style="background: linear-gradient(135deg, #00C9FF, #92FE9D);">J</div>
                        <h4 class="fw-bold mb-1" style="color: var(--text-color);">Johann Salazar</h4>
                        <div class="team-role" style="color: #00C9FF;">Backend Developer</div>
                        <p class="team-desc">Encargado de la lógica de servidores, controladores, enrutamiento, seguridad integral y optimización del núcleo del sistema.</p>
                        <div class="d-flex flex-wrap justify-content-center gap-2 mt-auto">
                            <span class="badge border border-secondary px-3 py-2 rounded-pill" style="color: var(--text-color); background: var(--body-bg);"><i class="bi bi-cup-hot me-1"></i> Java</span>
                            <span class="badge border border-secondary px-3 py-2 rounded-pill" style="color: var(--text-color); background: var(--body-bg);"><i class="bi bi-server me-1"></i> Servidores</span>
                        </div>
                    </div>
                </div>
                
                <!-- Jhon -->
                <div class="col-lg-4 col-md-6 animate-on-scroll delay-3">
                    <div class="team-card">
                        <div class="team-avatar" style="background: linear-gradient(135deg, #FDC830, #F37335);">J</div>
                        <h4 class="fw-bold mb-1" style="color: var(--text-color);">Jhon Ovallos</h4>
                        <div class="team-role" style="color: #FDC830;">Backend & Bases de Datos</div>
                        <p class="team-desc">Arquitecto de bases de datos relacionales, diseñador de consultas SQL avanzadas y gestor de infraestructura lógica y de inventarios.</p>
                        <div class="d-flex flex-wrap justify-content-center gap-2 mt-auto">
                            <span class="badge border border-secondary px-3 py-2 rounded-pill" style="color: var(--text-color); background: var(--body-bg);"><i class="bi bi-database me-1"></i> PostgreSQL</span>
                            <span class="badge border border-secondary px-3 py-2 rounded-pill" style="color: var(--text-color); background: var(--body-bg);"><i class="bi bi-gear me-1"></i> Lógica</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <footer class="footer-section py-4 border-top border-secondary border-opacity-25" style="background: var(--card-bg);">
        <div class="container text-center">
            <p class="small mb-0" style="color: var(--text-color); opacity: 0.6;">&copy; 2026 Asama Moto Parts. <fmt:message key="index.rights" /></p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Animaciones CSS nativas al hacer scroll
        document.addEventListener("DOMContentLoaded", function() {
            const elements = document.querySelectorAll('.animate-on-scroll');
            
            // Función inicial para animar los elementos visibles al cargar
            setTimeout(() => { checkVisibility(); }, 100);

            function checkVisibility() {
                const triggerBottom = window.innerHeight * 0.85;
                
                elements.forEach(element => {
                    const boxTop = element.getBoundingClientRect().top;
                    if(boxTop < triggerBottom) {
                        element.classList.add('visible');
                    }
                });
            }

            window.addEventListener('scroll', checkVisibility);
        });

        // Efecto visual para el navbar al hacer scroll
        window.addEventListener('scroll', function () {
            const nav = document.querySelector('.navbar');
            if(nav) {
                nav.classList.toggle('scrolled', window.scrollY > 40);
            }
        });
    </script>
</body>
</html>
