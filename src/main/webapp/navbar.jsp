<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User navUser = (User) session.getAttribute("user");
    boolean navLoggedIn = navUser != null;
    int navRole = navLoggedIn ? navUser.getRoleId() : 0;
    String currentPage = request.getRequestURI();
%>
<style>
    .asama-navbar {
        background: rgba(10, 10, 10, 0.95);
        backdrop-filter: blur(20px);
        border-bottom: 1px solid rgba(255,255,255,0.06);
        padding: 8px 0;
    }
    .asama-navbar .navbar-brand { color: #fff !important; font-weight: 800; font-size: 1.15rem; text-decoration: none; }
    .asama-navbar .navbar-brand span { color: #FF6B35; }
    .asama-nav-link {
        color: #999 !important; font-size: 0.85rem; font-weight: 500;
        padding: 6px 14px !important; border-radius: 20px; transition: 0.2s;
        text-decoration: none;
    }
    .asama-nav-link:hover { color: #fff !important; background: rgba(255,255,255,0.06); }
    .asama-nav-link.active-link { color: #FF6B35 !important; background: rgba(255,107,53,0.1); }
    .nav-role-badge {
        display: inline-block; padding: 3px 10px; border-radius: 20px;
        font-size: 0.7rem; font-weight: 600; background: rgba(255,107,53,0.12);
        color: #FF6B35; border: 1px solid rgba(255,107,53,0.25);
    }
    .btn-nav-logout {
        background: transparent; color: #FF6B35; border: 1px solid #FF6B35;
        border-radius: 20px; padding: 5px 16px; font-size: 0.8rem; font-weight: 600;
        transition: 0.3s; text-decoration: none;
    }
    .btn-nav-logout:hover { background: #FF6B35; color: #fff; }
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
                <% } else if(navRole == 6) { // Mecánico %>
                    <li class="nav-item"><a class="asama-nav-link" href="dashboard.jsp">Panel</a></li>
                    <li class="nav-item"><a class="asama-nav-link" href="maintenance">Taller</a></li>
                    <li class="nav-item"><a class="asama-nav-link" href="search_product.jsp">Buscar</a></li>
                <% } %>
            </ul>
            
            <div class="d-flex align-items-center gap-2">
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
