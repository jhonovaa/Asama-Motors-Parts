<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User navUser = (User) session.getAttribute("user");
    boolean navLoggedIn = navUser != null;
    int navRole = navLoggedIn ? navUser.getRoleId() : 0;
    String currentPage = request.getRequestURI();
%>
<!-- Theme CSS & JS -->
<link rel="stylesheet" href="resources/theme.css">
<script src="resources/theme.js"></script>
<!-- SweetAlert2 -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<%
    String alertMsg = request.getParameter("msg");
    if(alertMsg != null && !alertMsg.trim().isEmpty()) {
        boolean isError = alertMsg.toLowerCase().contains("error") || alertMsg.toLowerCase().contains("inválido") || alertMsg.toLowerCase().contains("falló");
        String icon = isError ? "error" : "success";
        String title = isError ? "Oops..." : "¡Éxito!";
%>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        Swal.fire({
            icon: '<%= icon %>',
            title: '<%= title %>',
            text: '<%= alertMsg %>',
            confirmButtonColor: '#FF6B35',
            background: document.body.classList.contains('light-mode') ? '#fff' : '#1a1a1a',
            color: document.body.classList.contains('light-mode') ? '#000' : '#fff'
        });
        
        // Clean URL after showing alert
        if(window.history.replaceState) {
            const url = new URL(window.location);
            url.searchParams.delete('msg');
            window.history.replaceState({path:url.href}, '', url.href);
        }
    });
</script>
<% } %>

<style>
    .asama-navbar {
        background: rgba(15, 16, 19, 0.85);
        backdrop-filter: blur(16px);
        -webkit-backdrop-filter: blur(16px);
        border-bottom: 1px solid rgba(255, 255, 255, 0.08);
        padding: 12px 0;
        box-shadow: 0 4px 30px rgba(0, 0, 0, 0.5);
    }
    .asama-navbar .navbar-brand { color: #f1f2f6 !important; font-weight: 800; font-size: 1.25rem; text-decoration: none; letter-spacing: -0.5px; }
    .asama-navbar .navbar-brand span { color: #FF6B35; }
    .asama-nav-link {
        color: #a0a5b1 !important; font-size: 0.9rem; font-weight: 500;
        padding: 8px 16px !important; border-radius: 8px; transition: all 0.3s ease;
        text-decoration: none; margin: 0 4px;
    }
    .asama-nav-link:hover { color: #ffffff !important; background: rgba(255, 255, 255, 0.08); transform: translateY(-1px); }
    .asama-nav-link.active-link { color: #FF6B35 !important; background: rgba(255, 107, 53, 0.1); font-weight: 600; }
    .nav-role-badge {
        display: inline-block; padding: 5px 12px; border-radius: 6px;
        font-size: 0.75rem; font-weight: 600; background: rgba(255, 107, 53, 0.15);
        color: #FF6B35; border: 1px solid rgba(255, 107, 53, 0.3); text-transform: uppercase; letter-spacing: 0.5px;
    }
    .btn-nav-logout {
        background: transparent; color: #f1f2f6; border: 1px solid rgba(255,255,255,0.2);
        border-radius: 6px; padding: 6px 18px; font-size: 0.85rem; font-weight: 600;
        transition: all 0.3s ease; text-decoration: none;
    }
    .btn-nav-logout:hover { background: rgba(255,255,255,0.1); color: #fff; border-color: rgba(255,255,255,0.4); }
    .theme-toggle-btn {
        background: rgba(255,255,255,0.05);
        border: 1px solid rgba(255,255,255,0.1);
        border-radius: 8px;
        width: 36px; height: 36px;
        display: flex; align-items: center; justify-content: center;
        cursor: pointer;
        color: #FF6B35;
        transition: all 0.3s ease;
        font-size: 1rem;
    }
    .theme-toggle-btn:hover { background: rgba(255,107,53,0.15); border-color: #FF6B35; transform: scale(1.05); }
</style>

<nav class="navbar navbar-expand-lg navbar-dark asama-navbar">
    <div class="container-fluid px-3">
        <a class="navbar-brand" href="<%= navLoggedIn ? "dashboard.jsp" : "index.jsp" %>">
            <i class="bi bi-gear-wide-connected me-1"></i>Asama<span>MotoParts</span>
        </a>
        
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#asamaNavbar" style="border-color: rgba(255,255,255,0.1);">
            <span class="navbar-toggler-icon"></span>
        </button>
        
        <div class="collapse navbar-collapse" id="asamaNavbar">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0 ms-3">
                <% if(!navLoggedIn) { %>
                    <li class="nav-item"><a class="asama-nav-link" href="catalog.jsp">Catálogo</a></li>
                    <li class="nav-item"><a class="asama-nav-link" href="cart.jsp"><i class="bi bi-cart me-1"></i>Carrito</a></li>
                <% } else if(navRole == 1) { // Admin %>
                    <li class="nav-item"><a class="asama-nav-link" href="dashboard.jsp">Panel</a></li>
                    <li class="nav-item"><a class="asama-nav-link" href="inventory">Inventario</a></li>
                    <li class="nav-item"><a class="asama-nav-link" href="cashier">Ventas</a></li>
                    <li class="nav-item"><a class="asama-nav-link" href="employees">Personal</a></li>
                    <li class="nav-item"><a class="asama-nav-link" href="maintenance">Taller</a></li>
                    <li class="nav-item"><a class="asama-nav-link" href="time_tracking.jsp">Asistencia</a></li>
                    <li class="nav-item"><a class="asama-nav-link" href="sales_history.jsp">Historiales</a></li>
                <% } else if(navRole == 2) { // Contador %>
                    <li class="nav-item"><a class="asama-nav-link" href="dashboard.jsp">Panel</a></li>
                    <li class="nav-item"><a class="asama-nav-link" href="accountant.jsp">Contabilidad</a></li>
                <% } else if(navRole == 3) { // Bodeguero %>
                    <li class="nav-item"><a class="asama-nav-link" href="dashboard.jsp">Panel</a></li>
                    <li class="nav-item"><a class="asama-nav-link" href="inventory">Inventario</a></li>
                    <li class="nav-item"><a class="asama-nav-link" href="search_product.jsp">Buscar</a></li>
                <% } else if(navRole == 4) { // Cajero %>
                    <li class="nav-item"><a class="asama-nav-link" href="dashboard.jsp">Panel</a></li>
                    <li class="nav-item"><a class="asama-nav-link" href="cashier">Ventas</a></li>
                    <li class="nav-item"><a class="asama-nav-link" href="search_product.jsp">Buscar</a></li>
                <% } else if(navRole == 5) { // Cliente %>
                    <li class="nav-item"><a class="asama-nav-link" href="dashboard.jsp">Mi Panel</a></li>
                    <li class="nav-item"><a class="asama-nav-link" href="catalog.jsp">Catálogo</a></li>
                    <li class="nav-item"><a class="asama-nav-link" href="cart.jsp"><i class="bi bi-cart me-1"></i>Carrito</a></li>
                    <li class="nav-item"><a class="asama-nav-link" href="search_product.jsp">Buscar</a></li>
                    <li class="nav-item"><a class="asama-nav-link" href="visual_scanner.jsp"><i class="bi bi-camera me-1"></i>Escáner IA</a></li>
                <% } else if(navRole == 6) { // Mecánico %>
                    <li class="nav-item"><a class="asama-nav-link" href="dashboard.jsp">Panel</a></li>
                    <li class="nav-item"><a class="asama-nav-link" href="maintenance">Taller</a></li>
                    <li class="nav-item"><a class="asama-nav-link" href="search_product.jsp">Buscar</a></li>
                <% } %>
            </ul>
            
            <div class="d-flex align-items-center gap-3">
                <!-- Theme Toggle -->
                <button onclick="toggleTheme()" class="theme-toggle-btn" title="Cambiar tema">
                    <i id="themeIcon" class="bi bi-sun-fill"></i>
                </button>
                <% if(navLoggedIn) { %>
                    <span class="nav-role-badge">
                        <% if(navRole==1) out.print("Admin");
                           else if(navRole==2) out.print("Contador");
                           else if(navRole==3) out.print("Bodeguero");
                           else if(navRole==4) out.print("Cajero");
                           else if(navRole==5) out.print("Cliente");
                           else if(navRole==6) out.print("Mecánico"); %>
                    </span>
                    <a class="btn-nav-logout" href="logout">Salir</a>
                <% } else { %>
                    <a class="btn-nav-logout" href="login.jsp">Iniciar Sesión</a>
                <% } %>
            </div>
        </div>
    </div>
</nav>
