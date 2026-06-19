<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%
    User navUser = (User) session.getAttribute("user");
    boolean navLoggedIn = navUser != null;
    int navRole = navLoggedIn ? navUser.getRoleId() : 0;
    String currentPage = request.getRequestURI();
    String navUserAgent = request.getHeader("User-Agent");
    boolean isApp = navUserAgent != null && navUserAgent.contains("ChengAndroidApp");
%>
<link rel="stylesheet" href="resources/theme.css?v=6">
<script src="resources/theme.js?v=2"></script>
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

    const savedTheme = localStorage.getItem('asama_theme') || 'dark';
    if(savedTheme === 'light') {
        document.body.classList.add('light-mode');
        document.getElementById('themeIcon').classList.replace('bi-sun-fill', 'bi-moon-fill');
    }

    <% if(navRole == 1 || navRole == 4) { %>
    function checkNotifications() {
        fetch('api/notifications')
            .then(res => res.json())
            .then(data => {
                if(data.error) return;
                const badge = document.getElementById('orderNotificationBadge');
                if(badge) {
                    if(data.unreadCount > 0) {
                        badge.innerText = data.unreadCount;
                        badge.style.display = 'block';
                    } else {
                        badge.style.display = 'none';
                    }
                }
            }).catch(console.error);
    }
    document.addEventListener("DOMContentLoaded", function() {
        checkNotifications();
        setInterval(checkNotifications, 15000);
    });
    <% } %>
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
                    <li class="nav-item"><a class="nav-link custom-link" href="catalog.jsp"><i class="bi bi-grid-3x3-gap me-2"></i><fmt:message key="nav.catalog"/></a></li>
                <% } else if(navRole == 1) { // Admin %>
                    <% if(isApp) { %>
                        <li class="nav-item"><a class="nav-link custom-link" href="dashboard.jsp"><i class="bi bi-speedometer2 me-1"></i> <fmt:message key="nav.stats"/></a></li>
                        <li class="nav-item"><a class="nav-link custom-link" href="inventory"><i class="bi bi-box-seam me-1"></i> <fmt:message key="nav.inventory"/></a></li>
                        <li class="nav-item"><a class="nav-link custom-link" href="time_tracking.jsp"><i class="bi bi-clock-history me-1"></i> <fmt:message key="nav.attendance"/></a></li>
                        <li class="nav-item"><a class="nav-link custom-link" href="sales_history.jsp"><i class="bi bi-journal-text me-1"></i> <fmt:message key="nav.history"/></a></li>
                    <% } else { %>
                        <li class="nav-item"><a class="nav-link custom-link" href="dashboard.jsp"><i class="bi bi-speedometer2 me-1"></i> <fmt:message key="nav.dashboard"/></a></li>
                        <li class="nav-item"><a class="nav-link custom-link" href="inventory"><i class="bi bi-box-seam me-1"></i> <fmt:message key="nav.inventory"/></a></li>
                        <li class="nav-item"><a class="nav-link custom-link" href="cashier"><i class="bi bi-currency-dollar me-1"></i> <fmt:message key="nav.sales"/></a></li>
                        <li class="nav-item"><a class="nav-link custom-link" href="employees"><i class="bi bi-people me-1"></i> <fmt:message key="nav.staff"/></a></li>
                        <li class="nav-item"><a class="nav-link custom-link" href="maintenance"><i class="bi bi-tools me-1"></i> <fmt:message key="nav.workshop"/></a></li>
                        <li class="nav-item"><a class="nav-link custom-link" href="time_tracking.jsp"><i class="bi bi-clock-history me-1"></i> <fmt:message key="nav.attendance"/></a></li>
                        <li class="nav-item"><a class="nav-link custom-link" href="admin_logs.jsp"><i class="bi bi-shield-lock me-1"></i> <fmt:message key="nav.audit"/></a></li>
                        <li class="nav-item"><a class="nav-link custom-link" href="sales_history.jsp"><i class="bi bi-journal-text me-1"></i> <fmt:message key="nav.history"/></a></li>
                    <% } %>
                <% } else if(navRole == 2) { // Contador %>
                    <li class="nav-item"><a class="nav-link custom-link" href="dashboard.jsp"><i class="bi bi-speedometer2 me-1"></i> <fmt:message key="nav.dashboard"/></a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="accountant.jsp"><i class="bi bi-calculator me-1"></i> <fmt:message key="nav.accounting"/></a></li>
                <% } else if(navRole == 3) { // Bodeguero %>
                    <li class="nav-item"><a class="nav-link custom-link" href="dashboard.jsp"><i class="bi bi-speedometer2 me-1"></i> <fmt:message key="nav.dashboard"/></a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="inventory"><i class="bi bi-box-seam me-1"></i> <fmt:message key="nav.inventory"/></a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="search_product.jsp"><i class="bi bi-search me-1"></i> <fmt:message key="nav.search"/></a></li>
                <% } else if(navRole == 4) { // Cajero %>
                    <li class="nav-item"><a class="nav-link custom-link" href="dashboard.jsp"><i class="bi bi-speedometer2 me-1"></i> <fmt:message key="nav.dashboard"/></a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="cashier"><i class="bi bi-currency-dollar me-1"></i> <fmt:message key="nav.sales"/></a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="search_product.jsp"><i class="bi bi-search me-1"></i> <fmt:message key="nav.search"/></a></li>
                <% } else if(navRole == 5) { // Cliente %>
                    <% if(isApp) { %>
                        <li class="nav-item"><a class="nav-link custom-link" href="catalog.jsp"><i class="bi bi-grid-3x3-gap me-1"></i> <fmt:message key="nav.catalog"/></a></li>
                        <li class="nav-item"><a class="nav-link custom-link" href="cart.jsp"><i class="bi bi-cart3 me-1"></i> <fmt:message key="nav.order"/></a></li>
                        <li class="nav-item"><a class="nav-link custom-link" href="maintenance"><i class="bi bi-tools me-1"></i> <fmt:message key="nav.workshop"/></a></li>
                    <% } else { %>
                        <li class="nav-item"><a class="nav-link custom-link" href="dashboard.jsp"><i class="bi bi-person-badge me-1"></i> <fmt:message key="nav.my_dashboard"/></a></li>
                        <li class="nav-item"><a class="nav-link custom-link" href="catalog.jsp"><i class="bi bi-grid-3x3-gap me-1"></i> <fmt:message key="nav.catalog"/></a></li>
                        <li class="nav-item"><a class="nav-link custom-link" href="cart.jsp"><i class="bi bi-cart3 me-1"></i> <fmt:message key="nav.cart"/></a></li>
                        <li class="nav-item"><a class="nav-link custom-link" href="search_product.jsp"><i class="bi bi-search me-1"></i> <fmt:message key="nav.search"/></a></li>
                        <li class="nav-item"><a class="nav-link custom-link" href="visual_scanner.jsp"><i class="bi bi-camera me-1"></i> <fmt:message key="nav.scanner"/></a></li>
                    <% } %>
                <% } else if(navRole == 6) { // Mecanico %>
                    <li class="nav-item"><a class="nav-link custom-link" href="dashboard.jsp"><i class="bi bi-speedometer2 me-1"></i> <fmt:message key="nav.dashboard"/></a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="maintenance"><i class="bi bi-tools me-1"></i> <fmt:message key="nav.workshop"/></a></li>
                    <li class="nav-item"><a class="nav-link custom-link" href="search_product.jsp"><i class="bi bi-search me-1"></i> <fmt:message key="nav.search"/></a></li>
                <% } %>
            </ul>
            
            <div class="d-flex align-items-center gap-3 ms-lg-auto mt-3 mt-lg-0 pb-3 pb-lg-0">
                <% if(navRole == 1 || navRole == 4) { %>
                <div class="position-relative">
                    <a href="online_orders.jsp" class="btn btn-icon rounded-circle transition-all d-flex align-items-center justify-content-center" title="<fmt:message key='nav.online_orders'/>">
                        <i class="bi bi-bell-fill fs-5"></i>
                        <span id="orderNotificationBadge" class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" style="display: none;">0</span>
                    </a>
                </div>
                <% } %>
                
                <div class="dropdown">
                    <button class="btn btn-icon rounded-circle transition-all dropdown-toggle d-flex align-items-center justify-content-center" type="button" id="languageDropdown" data-bs-toggle="dropdown" aria-expanded="false" title="<fmt:message key='nav.lang_title'/>">
                        <i class="bi bi-globe fs-5"></i>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow-sm" aria-labelledby="languageDropdown">
                        <li><a class="dropdown-item d-flex align-items-center" href="<%= currentPage %>?lang=es"><img src="https://flagcdn.com/w20/es.png" alt="ES" class="me-2" style="width: 20px;"> Español</a></li>
                        <li><a class="dropdown-item d-flex align-items-center" href="<%= currentPage %>?lang=en"><img src="https://flagcdn.com/w20/us.png" alt="EN" class="me-2" style="width: 20px;"> English</a></li>
                    </ul>
                </div>
                
                <button onclick="toggleTheme()" class="btn btn-icon theme-toggle-btn rounded-circle transition-all" title="<fmt:message key='nav.theme_title'/>">
                    <i id="themeIcon" class="bi bi-sun-fill fs-5"></i>
                </button>
                
                <% if(navLoggedIn) { %>
                    <div class="d-flex align-items-center gap-3">
                        <span class="badge rounded-pill role-badge px-3 py-2 fw-semibold d-flex align-items-center shadow-sm">
                            <i class="bi bi-shield-check me-2"></i>
                            <% if(navRole==1) out.print("<fmt:message key='role.admin'/>");
                               else if(navRole==2) out.print("<fmt:message key='role.accountant'/>");
                               else if(navRole==3) out.print("<fmt:message key='role.warehouse'/>");
                               else if(navRole==4) out.print("<fmt:message key='role.cashier'/>");
                               else if(navRole==5) out.print("<fmt:message key='role.customer'/>");
                               else if(navRole==6) out.print("<fmt:message key='role.mechanic'/>"); %>
                        </span>
                        <a class="btn btn-outline-danger btn-sm px-4 py-2 rounded-pill fw-bold logout-btn d-flex align-items-center gap-2 transition-all" href="logout">
                            <span><fmt:message key="nav.logout"/></span> <i class="bi bi-box-arrow-right"></i>
                        </a>
                    </div>
                <% } else { %>
                    <a class="btn btn-accent px-4 py-2 rounded-pill fw-bold login-btn shadow-sm d-flex align-items-center gap-2 transition-all" href="login.jsp">
                        <i class="bi bi-person-circle"></i> <fmt:message key="nav.login"/>
                    </a>
                <% } %>
            </div>
        </div>
    </div>
</nav>

<% if (navLoggedIn) { %>
<script>
    // Inactivity auto-logout (15 minutes)
    let inactivityTimer;
    const timeoutMS = 15 * 60 * 1000;

    function resetTimer() {
        clearTimeout(inactivityTimer);
        inactivityTimer = setTimeout(() => {
            if (typeof Swal !== 'undefined') {
                Swal.fire({
                    icon: 'warning',
                    title: 'Sesión Expirada',
                    text: 'Tu sesión se ha cerrado automáticamente por seguridad debido a 15 minutos de inactividad.',
                    showConfirmButton: false,
                    timer: 1500,
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                    backdrop: `rgba(0,0,0,0.95)`
                }).then(() => {
                    window.location.href = "logout?msg=Sesion+expirada+por+inactividad";
                });
            } else {
                window.location.href = "logout";
            }
        }, timeoutMS);
    }

    // Listen to user interactions to reset the timer
    ['mousedown', 'mousemove', 'keypress', 'scroll', 'touchstart'].forEach(evt => 
        document.addEventListener(evt, resetTimer, true)
    );

    // Start timer on page load
    resetTimer();

    <% if(navRole == 1 || navRole == 4) { %>
    // checkNotifications ya está definida arriba, solo reiniciar el intervalo si es necesario
    if (typeof checkNotifications === 'function') {
        checkNotifications();
        setInterval(checkNotifications, 15000);
    }
    <% } %>
</script>
<% } %>
