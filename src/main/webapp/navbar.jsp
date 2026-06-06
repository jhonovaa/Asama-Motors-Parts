<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User navUser = (User) session.getAttribute("user");
    boolean navLoggedIn = navUser != null;
    int navRole = navLoggedIn ? navUser.getRoleId() : 0;
    String currentPage = request.getRequestURI();
%>
<link rel="stylesheet" href="resources/theme.css?v=6">
<script src="resources/theme.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

<%
    String alertMsg = request.getParameter("msg");
    if(alertMsg != null && !alertMsg.trim().isEmpty()) {
        boolean isError = alertMsg.toLowerCase().contains("error") || alertMsg.toLowerCase().contains("invalido") || alertMsg.toLowerCase().contains("fallo");
        String icon = isError ? "error" : "success";
        String title = isError ? "Oops..." : "Exito!";
%>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        Swal.fire({
            icon: '<%= icon %>',
            title: '<%= title %>',
            text: '<%= alertMsg %>',
            confirmButtonColor: getComputedStyle(document.documentElement).getPropertyValue('--accent-orange').trim() || '#ff6b00',
            background: document.body.classList.contains('light-mode') ? '#ffffff' : '#1e1e24',
            color: document.body.classList.contains('light-mode') ? '#333333' : '#f8f9fa',
            customClass: {
                popup: 'asama-swal-popup'
            }
        });
        
        // Limpiar URL despues de mostrar la alerta
        if(window.history.replaceState) {
            const url = new URL(window.location);
            url.searchParams.delete('msg');
            window.history.replaceState({path:url.href}, '', url.href);
        }
    });
</script>
<% } %>

<nav class="navbar navbar-expand-lg fixed-top shadow-sm asama-navbar modern-glass">
    <div class="container-fluid px-4 py-2">
        <a class="navbar-brand d-flex align-items-center gap-2 brand-hover" href="<%= navLoggedIn ? "dashboard.jsp" : "index.jsp" %>">
            <div class="brand-icon-wrapper">
                <i class="bi bi-gear-wide-connected fs-4 text-accent"></i>
            </div>
            <span class="fw-bold fs-4 tracking-tight asama-text">Asama<span class="text-accent fw-light">MotoParts</span></span>
        </a>
        
        <button class="navbar-toggler custom-toggler border-0 shadow-none" type="button" data-bs-toggle="collapse" data-bs-target="#asamaNavbar" aria-controls="asamaNavbar" aria-expanded="false" aria-label="Toggle navigation">
            <i class="bi bi-list fs-1 text-accent"></i>
        </button>
        
        <div class="collapse navbar-collapse" id="asamaNavbar">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0 ms-lg-4 gap-1 align-items-center asama-nav-links">
                <% if(!navLoggedIn) { %>
                    <li class="nav-item"><a class="nav-link custom-link" href="catalog.jsp"><i class="bi bi-grid-3x3-gap me-2"></i>Catalogo</a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="cart.jsp"><i class="bi bi-cart3 me-2"></i>Carrito</a></li>
                <% } else if(navRole == 1) { // Admin %>
                    <li class="nav-item"><a class="nav-link custom-link" href="dashboard.jsp"><i class="bi bi-speedometer2 me-1"></i> Panel</a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="inventory"><i class="bi bi-box-seam me-1"></i> Inventario</a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="cashier"><i class="bi bi-currency-dollar me-1"></i> Ventas</a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="employees"><i class="bi bi-people me-1"></i> Personal</a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="maintenance"><i class="bi bi-tools me-1"></i> Taller</a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="time_tracking.jsp"><i class="bi bi-clock-history me-1"></i> Asistencia</a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="sales_history.jsp"><i class="bi bi-journal-text me-1"></i> Historiales</a></li>
                <% } else if(navRole == 2) { // Contador %>
                    <li class="nav-item"><a class="nav-link custom-link" href="dashboard.jsp"><i class="bi bi-speedometer2 me-1"></i> Panel</a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="accountant.jsp"><i class="bi bi-calculator me-1"></i> Contabilidad</a></li>
                <% } else if(navRole == 3) { // Bodeguero %>
                    <li class="nav-item"><a class="nav-link custom-link" href="dashboard.jsp"><i class="bi bi-speedometer2 me-1"></i> Panel</a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="inventory"><i class="bi bi-box-seam me-1"></i> Inventario</a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="search_product.jsp"><i class="bi bi-search me-1"></i> Buscar</a></li>
                <% } else if(navRole == 4) { // Cajero %>
                    <li class="nav-item"><a class="nav-link custom-link" href="dashboard.jsp"><i class="bi bi-speedometer2 me-1"></i> Panel</a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="cashier"><i class="bi bi-currency-dollar me-1"></i> Ventas</a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="search_product.jsp"><i class="bi bi-search me-1"></i> Buscar</a></li>
                <% } else if(navRole == 5) { // Cliente %>
                    <li class="nav-item"><a class="nav-link custom-link" href="dashboard.jsp"><i class="bi bi-person-badge me-1"></i> Mi Panel</a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="catalog.jsp"><i class="bi bi-grid-3x3-gap me-1"></i> Catalogo</a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="cart.jsp"><i class="bi bi-cart3 me-1"></i> Carrito</a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="search_product.jsp"><i class="bi bi-search me-1"></i> Buscar</a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="visual_scanner.jsp"><i class="bi bi-camera me-1"></i> Escaner IA</a></li>
                <% } else if(navRole == 6) { // Mecanico %>
                    <li class="nav-item"><a class="nav-link custom-link" href="dashboard.jsp"><i class="bi bi-speedometer2 me-1"></i> Panel</a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="maintenance"><i class="bi bi-tools me-1"></i> Taller</a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="search_product.jsp"><i class="bi bi-search me-1"></i> Buscar</a></li>
                <% } %>
            </ul>
            
            <div class="d-flex align-items-center gap-3 ms-lg-auto mt-3 mt-lg-0 pb-3 pb-lg-0">
                <button onclick="toggleTheme()" class="btn btn-icon theme-toggle-btn rounded-circle transition-all" title="Cambiar tema">
                    <i id="themeIcon" class="bi bi-sun-fill fs-5"></i>
                </button>
                
                <% if(navLoggedIn) { %>
                    <div class="d-flex align-items-center gap-3">
                        <span class="badge rounded-pill role-badge px-3 py-2 fw-semibold d-flex align-items-center shadow-sm">
                            <i class="bi bi-shield-check me-2"></i>
                            <% if(navRole==1) out.print("Admin");
                               else if(navRole==2) out.print("Contador");
                               else if(navRole==3) out.print("Bodeguero");
                               else if(navRole==4) out.print("Cajero");
                               else if(navRole==5) out.print("Cliente");
                               else if(navRole==6) out.print("Mecanico"); %>
                        </span>
                        <a class="btn btn-outline-danger btn-sm px-4 py-2 rounded-pill fw-bold logout-btn d-flex align-items-center gap-2 transition-all" href="logout">
                            <span>Salir</span> <i class="bi bi-box-arrow-right"></i>
                        </a>
                    </div>
                <% } else { %>
                    <a class="btn btn-accent px-4 py-2 rounded-pill fw-bold login-btn shadow-sm d-flex align-items-center gap-2 transition-all" href="login.jsp">
                        <i class="bi bi-person-circle"></i> Iniciar Sesion
                    </a>
                <% } %>
            </div>
        </div>
    </div>
</nav>