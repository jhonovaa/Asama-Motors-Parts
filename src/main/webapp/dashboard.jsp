<%@ page import="com.adso.cheng.models.User" %>
<%@ page import="com.adso.cheng.models.Product" %>
<%@ page import="com.adso.cheng.utils.DbConnection" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String lang = (String) session.getAttribute("lang");
    if (lang == null) lang = "es";
    boolean isEn = "en".equals(lang);


    // Fetch stats
    double salesRevenue = 0.0;
    int totalProducts = 0;
    int lowStockCount = 0;
    int activeJobsCount = 0;
    int totalMotos = 0;
    
    // Client specific stats
    int clientPurchases = 0;
    int clientMotos = 0;
    int clientClaims = 0;
    
    // Mechanic specific stats
    int mechActiveJobs = 0;
    int mechCompletedJobs = 0;
    int mechTotalShopJobs = 0;
    
    // Accountant specific stats
    int accountantReportsCount = 0;

    // Lists for detailed sections
    List<Product> topProducts = new ArrayList<>();
    List<Integer> topSalesCount = new ArrayList<>();
    List<User> staffList = new ArrayList<>();
    List<String> staffRoleList = new ArrayList<>();
    List<Map<String, Object>> mechJobsList = new ArrayList<>();
    List<Map<String, Object>> accountantReportsList = new ArrayList<>();
    
    // Category sales labels and data for bar chart
    List<String> catLabels = new ArrayList<>();
    List<Integer> catData = new ArrayList<>();

    try (Connection conn = DbConnection.getConnection()) {
        // 1. Sales revenue in the last 30 days
        try (PreparedStatement stmt = conn.prepareStatement(
                "SELECT COALESCE(SUM(total_price), 0) FROM sales WHERE sale_date >= CURRENT_DATE - INTERVAL '30 days'")) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) salesRevenue = rs.getDouble(1);
        }
        
        // 2. Total products
        try (PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM products")) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) totalProducts = rs.getInt(1);
        }
        
        // 3. Low stock count (<= 20)
        try (PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM products WHERE stock <= 20")) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) lowStockCount = rs.getInt(1);
        }
        
        // 4. Active jobs count
        try (PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM maintenance_jobs WHERE status != 'ENTREGADO'")) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) activeJobsCount = rs.getInt(1);
        }
        
        // 5. Total motorcycles registered
        try (PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM motorcycles")) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) totalMotos = rs.getInt(1);
        }
        
        // 6. Role Specific queries
        if (user.getRoleId() == 5) { // Cliente
            try (PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM sales WHERE customer_id = ?")) {
                stmt.setInt(1, user.getId());
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) clientPurchases = rs.getInt(1);
            }
            try (PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM motorcycles WHERE customer_id = ?")) {
                stmt.setInt(1, user.getId());
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) clientMotos = rs.getInt(1);
            }
            try (PreparedStatement stmt = conn.prepareStatement(
                    "SELECT COUNT(*) FROM post_sale_requests pr JOIN sales s ON pr.sale_id = s.id " +
                    "WHERE s.customer_id = ? AND pr.status = 'PENDIENTE'")) {
                stmt.setInt(1, user.getId());
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) clientClaims = rs.getInt(1);
            }
        } else if (user.getRoleId() == 6) { // Mecanico
            try (PreparedStatement stmt = conn.prepareStatement(
                    "SELECT COUNT(*) FROM maintenance_jobs WHERE assignee_id = ? AND status IN ('PENDIENTE', 'EN_PROCESO', 'COMPLETADO')")) {
                stmt.setInt(1, user.getId());
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) mechActiveJobs = rs.getInt(1);
            }
            try (PreparedStatement stmt = conn.prepareStatement(
                    "SELECT COUNT(*) FROM maintenance_jobs WHERE assignee_id = ? AND status = 'ENTREGADO' " +
                    "AND delivery_date >= CURRENT_DATE - INTERVAL '30 days'")) {
                stmt.setInt(1, user.getId());
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) mechCompletedJobs = rs.getInt(1);
            }
            try (PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM maintenance_jobs WHERE status != 'ENTREGADO'")) {
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) mechTotalShopJobs = rs.getInt(1);
            }
            try (PreparedStatement stmt = conn.prepareStatement(
                     "SELECT id, plate, brand, model, description, price, status, entry_date " +
                     "FROM maintenance_jobs " +
                     "WHERE assignee_id = ? AND status != 'ENTREGADO' " +
                     "ORDER BY entry_date DESC LIMIT 5")) {
                stmt.setInt(1, user.getId());
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    Map<String, Object> job = new HashMap<>();
                    job.put("id", rs.getInt("id"));
                    job.put("plate", rs.getString("plate"));
                    job.put("brand", rs.getString("brand"));
                    job.put("model", rs.getString("model"));
                    job.put("description", rs.getString("description"));
                    job.put("price", rs.getDouble("price"));
                    job.put("status", rs.getString("status"));
                    job.put("entry_date", rs.getTimestamp("entry_date"));
                    mechJobsList.add(job);
                }
            }
        } else if (user.getRoleId() == 2) { // Contador
            try (PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM accountant_reports")) {
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) accountantReportsCount = rs.getInt(1);
            }
            try (PreparedStatement stmt = conn.prepareStatement(
                    "SELECT title, report_type, created_at, file_path FROM accountant_reports " +
                    "ORDER BY created_at DESC LIMIT 5")) {
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    Map<String, Object> rep = new HashMap<>();
                    rep.put("title", rs.getString("title"));
                    rep.put("report_type", rs.getString("report_type"));
                    rep.put("created_at", rs.getTimestamp("created_at"));
                    rep.put("file_path", rs.getString("file_path"));
                    accountantReportsList.add(rep);
                }
            }
        }

        // 7. General internal staff lists (Admin, Cashier, Warehouse)
        if (user.getRoleId() == 1 || user.getRoleId() == 3 || user.getRoleId() == 4) {
            // Top best selling products
            try (PreparedStatement stmt = conn.prepareStatement(
                    "SELECT p.id, p.name, p.brand, p.price, p.stock, p.barcode, p.image_url, COALESCE(SUM(s.quantity), 0) as sold_qty " +
                    "FROM products p " +
                    "LEFT JOIN sales s ON p.id = s.product_id " +
                    "GROUP BY p.id, p.name, p.brand, p.price, p.stock, p.barcode, p.image_url " +
                    "ORDER BY sold_qty DESC, p.id ASC LIMIT 4")) {
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    Product p = new Product();
                    p.setId(rs.getInt("id"));
                    p.setName(rs.getString("name"));
                    p.setBrand(rs.getString("brand"));
                    p.setPrice(rs.getDouble("price"));
                    p.setStock(rs.getInt("stock"));
                    p.setBarcode(rs.getString("barcode"));
                    p.setImageUrl(rs.getString("image_url"));
                    topProducts.add(p);
                    topSalesCount.add(rs.getInt("sold_qty"));
                }
            }
            
            // Staff List
            try (PreparedStatement stmt = conn.prepareStatement(
                    "SELECT u.id, u.full_name, u.email, u.document_id, r.role_name " +
                    "FROM users u " +
                    "JOIN roles r ON u.role_id = r.id " +
                    "WHERE u.role_id IN (1, 3, 4, 6) " +
                    "ORDER BY u.id ASC LIMIT 4")) {
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("id"));
                    u.setFullName(rs.getString("full_name"));
                    u.setEmail(rs.getString("email"));
                    u.setDocumentId(rs.getString("document_id"));
                    staffList.add(u);
                    staffRoleList.add(rs.getString("role_name"));
                }
            }

            // Sales by category for bar chart
            try (PreparedStatement stmt = conn.prepareStatement(
                    "SELECT COALESCE(p.part_category, 'General') as cat, SUM(s.quantity) as sold_qty " +
                    "FROM sales s " +
                    "JOIN products p ON s.product_id = p.id " +
                    "GROUP BY cat " +
                    "ORDER BY sold_qty DESC LIMIT 5")) {
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    catLabels.add(rs.getString("cat"));
                    catData.add(rs.getInt("sold_qty"));
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    // Convert category values to javascript Arrays format
    String catLabelsJson = "";
    String catDataJson = "";
    if (!catLabels.isEmpty()) {
        StringBuilder sbL = new StringBuilder();
        StringBuilder sbD = new StringBuilder();
        for (int i = 0; i < catLabels.size(); i++) {
            if (i > 0) {
                sbL.append(",");
                sbD.append(",");
            }
            sbL.append("'").append(catLabels.get(i).replace("'", "\\'")).append("'");
            sbD.append(catData.get(i));
        }
        catLabelsJson = sbL.toString();
        catDataJson = sbD.toString();
    } else {
        catLabelsJson = "'Lubricantes','Frenos','Motor','Llantas','Accesorios'";
        catDataJson = "12,19,8,5,2"; // fallback values
    }
%>
<!DOCTYPE html>
<html lang="<fmt:message key='app.lang' />">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="dashboard.title" /></title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="resources/theme.css?v=6">
    <style>
        /* --- ESTILOS DE DASHBOARD REDISEÑADO PREMIUM (ESTILO GYMOVE) --- */
        body {
            font-family: 'Outfit', 'Inter', sans-serif !important;
        }

        .text-secondary, .text-muted { 
            color: rgba(255, 255, 255, 0.75) !important; 
            font-weight: 500;
        }
        body.light-mode .text-secondary, body.light-mode .text-muted { 
            color: rgba(0, 0, 0, 0.6) !important; 
            font-weight: 600;
        }

        /* Formularios */
        .form-label {
            font-weight: 600 !important;
            color: var(--text-color) !important;
        }
        .form-control, .form-select {
            background-color: rgba(255, 255, 255, 0.05) !important;
            color: #ffffff !important;
            border: 1px solid rgba(255, 255, 255, 0.15) !important;
            font-weight: 500;
            border-radius: 10px !important;
        }
        .form-control::placeholder {
            color: rgba(255, 255, 255, 0.4) !important;
        }
        .form-control:focus, .form-select:focus {
            background-color: rgba(255, 255, 255, 0.08) !important;
            border-color: var(--accent-orange) !important;
            box-shadow: 0 0 0 0.25rem var(--accent-glow) !important;
        }
        body.light-mode .form-control, body.light-mode .form-select {
            background-color: #ffffff !important;
            color: #212529 !important;
            border-color: rgba(0, 0, 0, 0.15) !important;
        }
        body.light-mode .form-control::placeholder {
            color: rgba(0, 0, 0, 0.5) !important;
        }

        /* Tablas */
        .table { color: var(--text-color) !important; }
        .table th { font-weight: 700 !important; letter-spacing: 0.5px; font-size: 0.85rem; }
        .table td { font-weight: 500 !important; font-size: 0.95rem; }

        /* HEADER SUPERIOR DETALLADO */
        .dashboard-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
            flex-wrap: wrap;
            gap: 1rem;
        }
        
        .dashboard-search {
            position: relative;
            width: 320px;
        }
        .dashboard-search i {
            position: absolute;
            top: 50%;
            left: 18px;
            transform: translateY(-50%);
            color: rgba(255, 255, 255, 0.4);
            font-size: 0.95rem;
            transition: color 0.3s;
        }
        body.light-mode .dashboard-search i {
            color: rgba(0, 0, 0, 0.4);
        }
        .dashboard-search .form-control {
            border-radius: 50px !important;
            padding: 10px 15px 10px 48px !important;
            background: rgba(255, 255, 255, 0.04) !important;
            border: 1px solid rgba(255, 255, 255, 0.08) !important;
            color: #ffffff !important;
            font-weight: 500;
            font-size: 0.9rem;
        }
        body.light-mode .dashboard-search .form-control {
            background: rgba(0, 0, 0, 0.03) !important;
            border-color: rgba(0, 0, 0, 0.06) !important;
            color: #121417 !important;
        }
        .dashboard-search .form-control:focus + i {
            color: var(--accent-orange);
        }

        .dashboard-actions-group {
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        .action-icon-btn {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(255, 255, 255, 0.04) !important;
            border: 1px solid rgba(255, 255, 255, 0.08) !important;
            color: var(--text-color) !important;
            font-size: 1.1rem;
            position: relative;
            transition: all 0.3s ease;
        }
        body.light-mode .action-icon-btn {
            background: rgba(0, 0, 0, 0.03) !important;
            border-color: rgba(0, 0, 0, 0.06) !important;
        }
        .action-icon-btn:hover {
            background: var(--accent-orange) !important;
            color: #121417 !important;
            transform: scale(1.05);
            box-shadow: 0 4px 15px var(--accent-glow);
        }

        .user-profile-badge {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 4px 16px 4px 4px;
            border-radius: 50px;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-color: var(--card-border);
        }
        body.light-mode .user-profile-badge {
            background: rgba(0, 0, 0, 0.02);
            border-color: rgba(0, 0, 0, 0.05);
        }
        .user-avatar-circle {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background: var(--accent-orange);
            color: #121417;
            font-weight: 800;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 2px 10px var(--accent-glow);
        }

        /* WELCOME BANNER COMPACT */
        .dashboard-welcome-banner {
            background: linear-gradient(135deg, rgba(0, 229, 255, 0.06) 0%, rgba(30, 32, 36, 0.4) 100%) !important;
            border-radius: 20px;
            border: 1px solid var(--card-border) !important;
            box-shadow: 0 10px 30px rgba(0,0,0,0.05) !important;
        }
        body.light-mode .dashboard-welcome-banner {
            background: linear-gradient(135deg, rgba(255, 214, 0, 0.08) 0%, rgba(255, 255, 255, 0.9) 100%) !important;
        }

        /* TARJETAS MÉTRICAS */
        .metric-card {
            background: var(--card-bg) !important;
            border-radius: 20px;
            border: 1px solid var(--card-border) !important;
            padding: 24px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.03) !important;
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
            position: relative;
            overflow: hidden;
        }
        .metric-card::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 4px;
            border-radius: 0 0 20px 20px;
        }
        .metric-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 35px rgba(0,0,0,0.08) !important;
        }
        .metric-card.solid-accent {
            background: var(--accent-orange) !important;
            color: #121417 !important;
            border: none !important;
        }
        .metric-card.solid-accent .text-secondary {
            color: rgba(18, 20, 23, 0.7) !important;
        }
        .metric-card.solid-accent h3 {
            color: #121417 !important;
        }

        .icon-circle {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.35rem;
            transition: all 0.3s;
        }
        .icon-circle.green { background: rgba(0, 230, 118, 0.12) !important; color: #00E676 !important; }
        .icon-circle.purple { background: rgba(156, 39, 176, 0.12) !important; color: #9c27b0 !important; }
        .icon-circle.pink { background: rgba(233, 30, 99, 0.12) !important; color: #e91e63 !important; }
        .icon-circle.yellow { background: rgba(255, 193, 7, 0.12) !important; color: #ffc107 !important; }

        /* SECCIONES DEL DASHBOARD */
        .dashboard-section-card {
            background: var(--card-bg) !important;
            border-radius: 24px;
            border: 1px solid var(--card-border) !important;
            padding: 24px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.02) !important;
            height: 100%;
        }

        /* LISTADOS DESTACADOS (Featured Menu) */
        .featured-list {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }
        .featured-item-box {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 12px;
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid rgba(255, 255, 255, 0.05);
            border-radius: 16px;
            transition: all 0.2s;
        }
        body.light-mode .featured-item-box {
            background: rgba(0, 0, 0, 0.01);
            border-color: rgba(0, 0, 0, 0.03);
        }
        .featured-item-box:hover {
            background: rgba(255, 255, 255, 0.05);
            transform: translateX(4px);
        }
        body.light-mode .featured-item-box:hover {
            background: rgba(0, 0, 0, 0.02);
        }
        .featured-item-img {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            object-fit: cover;
            border: 1px solid var(--card-border);
        }

        /* PERSONAL DE TURNO (Recommended Trainers) */
        .staff-member-card {
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid rgba(255, 255, 255, 0.05);
            border-radius: 20px;
            padding: 20px 15px;
            text-align: center;
            transition: all 0.3s;
            box-shadow: 0 4px 15px rgba(0,0,0,0.01);
            height: 100%;
        }
        body.light-mode .staff-member-card {
            background: rgba(0, 0, 0, 0.01);
            border-color: rgba(0, 0, 0, 0.03);
        }
        .staff-member-card:hover {
            background: rgba(255, 255, 255, 0.05);
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.03);
        }
        body.light-mode .staff-member-card:hover {
            background: rgba(0, 0, 0, 0.02);
        }
        .staff-member-avatar {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            margin: 0 auto 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 1.25rem;
            color: #ffffff;
            box-shadow: 0 4px 10px rgba(0,0,0,0.15);
        }

        .rating-stars {
            color: #ffc107;
            font-size: 0.85rem;
            display: flex;
            justify-content: center;
            gap: 2px;
        }

        .staff-btn {
            font-size: 0.8rem;
            font-weight: 700;
            color: var(--accent-orange);
            background: transparent;
            border: none;
            text-decoration: none;
            transition: opacity 0.2s;
        }
        .staff-btn:hover {
            opacity: 0.8;
            color: var(--accent-orange);
        }


    </style>
</head>
<body>
<script src="resources/theme.js?v=2"></script>

<%@ include file="navbar.jsp" %>

<div class="container-fluid px-lg-5 pb-5 mb-5" style="margin-top: 100px;">
    
    <!-- Cabecera estilo Gymove -->
    <div class="dashboard-header mb-4">
        <div>
            <h1 class="fw-bolder mb-0" style="font-size: 1.8rem; letter-spacing: -0.5px;">Dashboard</h1>
            <p class="text-secondary mb-0 small">Asama Motors Parts — Gestión Integrada</p>
        </div>
    </div>

    <div class="row">
        <!-- ── CONTENIDO PRINCIPAL (Ancho Completo a la Derecha del Sidebar) ── -->
        <div class="col-12">
            <!-- Bienvenida banner -->
            <div class="dashboard-welcome-banner p-4 p-md-5 d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-4 mb-4">
                <div>
                    <h2 class="fw-bold mb-2" style="letter-spacing: -0.5px;"><fmt:message key="dashboard.welcome" /><span class="text-accent"><%= user.getFullName() %></span></h2>
                    <p class="text-secondary mb-0 fs-5"><fmt:message key="dashboard.select_module" /></p>
                </div>
                <div class="text-md-end">
                    <span class="badge role-badge px-4 py-2 fs-6 fw-bold">
                        <i class="bi bi-shield-check me-2"></i>
                        <% if(user.getRoleId() == 1) out.print("<fmt:message key='role.admin' />");
                           else if(user.getRoleId() == 2) out.print("<fmt:message key='role.accountant' />");
                           else if(user.getRoleId() == 3) out.print("<fmt:message key='role.warehouse' />");
                           else if(user.getRoleId() == 4) out.print("<fmt:message key='role.cashier' />");
                           else if(user.getRoleId() == 5) out.print("<fmt:message key='role.customer' />");
                           else if(user.getRoleId() == 6) out.print("<fmt:message key='role.mechanic' />"); %>
                    </span>
                    <p class="text-secondary small mt-2 mb-0 fw-bold"><i class="bi bi-person-vcard me-1"></i> ID: <%= user.getDocumentId() %></p>
                </div>
            </div>

            <!-- SECCIONES SEGÚN ROL -->
            <% if(user.getRoleId() == 2) { // Contador %>
                <!-- DASHBOARD CONTADOR -->
                <div class="row g-4 mb-4">
                    <div class="col-xl-3 col-sm-6">
                        <div class="metric-card d-flex flex-column h-100" style="border-bottom: 4px solid #00E676 !important;">
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div>
                                    <span class="text-secondary small fw-bold text-uppercase">Ventas del Mes</span>
                                    <h3 class="fw-extrabold mt-1 mb-0">$<%= String.format("%,.2f", salesRevenue) %></h3>
                                </div>
                                <div class="icon-circle green">
                                    <i class="bi bi-cash-stack"></i>
                                </div>
                            </div>
                            <div class="mt-auto pt-2">
                                <span class="text-secondary small"><i class="bi bi-arrow-up-short text-success"></i> Ingresos últimos 30 días</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-sm-6">
                        <div class="metric-card d-flex flex-column h-100" style="border-bottom: 4px solid #9c27b0 !important;">
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div>
                                    <span class="text-secondary small fw-bold text-uppercase">Reportes en BD</span>
                                    <h3 class="fw-extrabold mt-1 mb-0"><%= accountantReportsCount %></h3>
                                </div>
                                <div class="icon-circle purple">
                                    <i class="bi bi-file-earmark-bar-graph"></i>
                                </div>
                            </div>
                            <div class="mt-auto pt-2">
                                <span class="text-secondary small"><i class="bi bi-files"></i> Documentos contables</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-sm-6">
                        <div class="metric-card d-flex flex-column h-100" style="border-bottom: 4px solid #FF1744 !important;">
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div>
                                    <span class="text-secondary small fw-bold text-uppercase">Alertas de Stock</span>
                                    <h3 class="fw-extrabold mt-1 mb-0 <%= lowStockCount > 0 ? "text-danger" : "" %>"><%= lowStockCount %></h3>
                                </div>
                                <div class="icon-circle pink">
                                    <i class="bi bi-exclamation-triangle"></i>
                                </div>
                            </div>
                            <div class="mt-auto pt-2">
                                <span class="text-secondary small"><i class="bi bi-shield-alert text-danger"></i> Productos críticos</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-sm-6">
                        <div class="metric-card solid-accent d-flex flex-column h-100">
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div>
                                    <span class="text-dark small fw-bold text-uppercase" style="opacity: 0.8;">Módulo Activo</span>
                                    <h3 class="fw-extrabold text-dark mt-1 mb-0">Contabilidad</h3>
                                </div>
                                <div class="icon-circle shadow-sm" style="background: rgba(255,255,255,0.4); color: #121417;">
                                    <i class="bi bi-calculator"></i>
                                </div>
                            </div>
                            <div class="mt-auto pt-2">
                                <a href="accountant.jsp" class="text-dark fw-bold small text-decoration-none"><i class="bi bi-arrow-right-circle-fill me-1"></i>Ingresar ahora</a>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row g-4 mb-4">
                    <div class="col-lg-8">
                        <div class="dashboard-section-card">
                            <div class="d-flex justify-content-between align-items-center border-bottom border-secondary border-opacity-10 pb-3 mb-4">
                                <h5 class="fw-bold mb-0"><i class="bi bi-graph-up-arrow text-accent me-2"></i><fmt:message key="dashboard.acc_module" /></h5>
                            </div>
                            <div class="text-center p-5">
                                <div class="brand-icon-wrapper mb-4 mx-auto">
                                    <i class="bi bi-calculator fs-1 text-accent"></i>
                                </div>
                                <h4 class="fw-bold mb-3"><fmt:message key="dashboard.acc_module" /></h4>
                                <p class="text-secondary mb-4 fs-6"><fmt:message key="dashboard.acc_desc" /></p>
                                <a href="accountant.jsp" class="btn btn-accent px-5 py-2 rounded-pill fw-bold"><fmt:message key="dashboard.acc_btn" /></a>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-lg-4">
                        <div class="dashboard-section-card">
                            <h5 class="fw-bold mb-4 border-bottom border-secondary border-opacity-10 pb-3"><i class="bi bi-clock-history text-accent me-2"></i>Últimos Reportes</h5>
                            <div class="featured-list">
                                <% 
                                    if(!accountantReportsList.isEmpty()) {
                                        for(Map<String, Object> rep : accountantReportsList) {
                                %>
                                            <div class="featured-item-box">
                                                <div class="icon-circle purple me-2">
                                                    <i class="bi bi-file-earmark-pdf"></i>
                                                </div>
                                                <div class="min-w-0 flex-grow-1">
                                                    <h6 class="fw-bold mb-0 text-truncate" style="font-size: 0.9rem;"><%= rep.get("title") %></h6>
                                                    <span class="text-secondary small d-block" style="font-size: 0.75rem;"><%= rep.get("report_type") %></span>
                                                    <span class="text-secondary small d-block" style="font-size: 0.7rem; opacity: 0.7;"><%= rep.get("created_at").toString().substring(0, 16) %></span>
                                                </div>
                                                <a href="resources/reportes/<%= rep.get("file_path") %>" target="_blank" class="btn btn-sm btn-icon rounded-circle bg-opacity-10 bg-white text-white"><i class="bi bi-download"></i></a>
                                            </div>
                                <% 
                                        }
                                    } else {
                                %>
                                        <div class="text-center text-secondary py-5 fw-bold"><i class="bi bi-inbox fs-2 d-block mb-2"></i>Sin reportes creados</div>
                                <% 
                                    }
                                %>
                            </div>
                        </div>
                    </div>
                </div>



            <% } else if(user.getRoleId() == 5) { // Cliente %>
                <!-- DASHBOARD CLIENTE -->
                <div class="row g-4 mb-4">
                    <div class="col-xl-3 col-sm-6">
                        <div class="metric-card d-flex flex-column h-100" style="border-bottom: 4px solid #00E676 !important;">
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div>
                                    <span class="text-secondary small fw-bold text-uppercase">Compras Realizadas</span>
                                    <h3 class="fw-extrabold mt-1 mb-0"><%= clientPurchases %></h3>
                                </div>
                                <div class="icon-circle green">
                                    <i class="bi bi-bag-check"></i>
                                </div>
                            </div>
                            <div class="mt-auto pt-2">
                                <span class="text-secondary small"><i class="bi bi-cart3"></i> Transacciones en tienda</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-sm-6">
                        <div class="metric-card d-flex flex-column h-100" style="border-bottom: 4px solid #9c27b0 !important;">
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div>
                                    <span class="text-secondary small fw-bold text-uppercase">Mis Motocicletas</span>
                                    <h3 class="fw-extrabold mt-1 mb-0"><%= clientMotos %></h3>
                                </div>
                                <div class="icon-circle purple">
                                    <i class="bi bi-bicycle"></i>
                                </div>
                            </div>
                            <div class="mt-auto pt-2">
                                <span class="text-secondary small"><i class="bi bi-person-check"></i> Vehículos registrados</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-sm-6">
                        <div class="metric-card d-flex flex-column h-100" style="border-bottom: 4px solid #FF1744 !important;">
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div>
                                    <span class="text-secondary small fw-bold text-uppercase">Garantías Activas</span>
                                    <h3 class="fw-extrabold mt-1 mb-0 <%= clientClaims > 0 ? "text-danger" : "" %>"><%= clientClaims %></h3>
                                </div>
                                <div class="icon-circle pink">
                                    <i class="bi bi-shield-exclamation"></i>
                                </div>
                            </div>
                            <div class="mt-auto pt-2">
                                <span class="text-secondary small"><i class="bi bi-activity text-danger"></i> Casos pendientes</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-sm-6">
                        <div class="metric-card solid-accent d-flex flex-column h-100">
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div>
                                    <span class="text-dark small fw-bold text-uppercase" style="opacity: 0.8;">Buscador Inteligente</span>
                                    <h3 class="fw-extrabold text-dark mt-1 mb-0">Escanear IA</h3>
                                </div>
                                <div class="icon-circle shadow-sm" style="background: rgba(255,255,255,0.4); color: #121417;">
                                    <i class="bi bi-camera"></i>
                                </div>
                            </div>
                            <div class="mt-auto pt-2">
                                <a href="visual_scanner.jsp" class="text-dark fw-bold small text-decoration-none"><i class="bi bi-arrow-right-circle-fill me-1"></i>Probar Escáner IA</a>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row g-4 mb-4">
                    <!-- Formulario Perfil -->
                    <div class="col-lg-4">
                        <div class="dashboard-section-card p-4">
                            <h5 class="text-accent fw-bold border-bottom border-secondary border-opacity-10 pb-3 mb-4">
                                <i class="bi bi-person-circle me-2"></i><fmt:message key="dashboard.edit_profile" />
                            </h5>
                            <% if(request.getParameter("msg") != null) { %>
                                <div class="alert alert-success py-2 small rounded-3 bg-opacity-10 border-success text-success fw-bold">
                                    <i class="bi bi-check-circle me-1"></i><%= request.getParameter("msg") %>
                                </div>
                            <% } %>
                            <form action="profile" method="POST">
                                <div class="mb-3">
                                    <label class="form-label small"><fmt:message key="dashboard.full_name" /></label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-transparent border-end-0 border-secondary border-opacity-25"><i class="bi bi-person text-secondary"></i></span>
                                        <input type="text" name="fullName" class="form-control border-start-0 ps-0" value="<%= user.getFullName() %>" required>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label small"><fmt:message key="dashboard.document_id" /></label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-transparent border-end-0 border-secondary border-opacity-25"><i class="bi bi-card-text text-secondary"></i></span>
                                        <input type="text" name="documentId" class="form-control border-start-0 ps-0" value="<%= user.getDocumentId() %>" required>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label small"><fmt:message key="dashboard.email" /></label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-transparent border-end-0 border-secondary border-opacity-25"><i class="bi bi-envelope text-secondary"></i></span>
                                        <input type="email" name="email" class="form-control border-start-0 ps-0" value="<%= user.getEmail() %>" required>
                                    </div>
                                </div>
                                <div class="mb-4">
                                    <label class="form-label small"><fmt:message key="dashboard.new_password" /></label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-transparent border-end-0 border-secondary border-opacity-25"><i class="bi bi-lock text-secondary"></i></span>
                                        <input type="password" name="password" class="form-control border-start-0 ps-0" placeholder="<fmt:message key='dashboard.password_placeholder' />">
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-accent w-100 rounded-pill py-2 fw-bold"><fmt:message key="dashboard.save_changes" /></button>
                            </form>
                        </div>
                    </div>
                    
                    <!-- Historial de compras -->
                    <div class="col-lg-8">
                        <div class="dashboard-section-card p-4 d-flex flex-column">
                            <div class="d-flex justify-content-between align-items-center border-bottom border-secondary border-opacity-10 pb-3 mb-4">
                                <h5 class="text-accent fw-bold mb-0"><i class="bi bi-bag-check me-2"></i><fmt:message key="dashboard.purchase_history" /></h5>
                                <a href="catalog.jsp" class="btn btn-sm btn-moto-outline rounded-pill px-3 fw-bold"><fmt:message key="dashboard.go_store" /></a>
                            </div>
                            <div class="table-responsive flex-grow-1" style="max-height: 350px; overflow-y: auto;">
                                <table class="table table-hover align-middle table-borderless">
                                    <thead>
                                        <tr>
                                            <th class="text-secondary small text-uppercase"><fmt:message key="dashboard.date" /></th>
                                            <th class="text-secondary small text-uppercase"><fmt:message key="dashboard.part" /></th>
                                            <th class="text-secondary small text-uppercase text-center"><fmt:message key="dashboard.qty" /></th>
                                            <th class="text-secondary small text-uppercase text-end"><fmt:message key="dashboard.total" /></th>
                                            <th class="text-secondary small text-uppercase text-center"><fmt:message key="dashboard.actions" /></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                            try (Connection conn = DbConnection.getConnection();
                                                 PreparedStatement stmt = conn.prepareStatement(
                                                     "SELECT s.id, s.sale_date, p.name, s.quantity, s.total_price " +
                                                     "FROM sales s JOIN products p ON s.product_id = p.id " +
                                                     "WHERE s.customer_id = ? ORDER BY s.sale_date DESC")) {
                                                stmt.setInt(1, user.getId());
                                                ResultSet rs = stmt.executeQuery();
                                                boolean hasPurchases = false;
                                                while(rs.next()) {
                                                    hasPurchases = true;
                                        %>
                                        <tr>
                                            <td class="text-muted small"><%= rs.getTimestamp("sale_date").toString().substring(0, 16) %></td>
                                            <td class="fw-bold"><%= rs.getString("name") %></td>
                                            <td class="text-center"><span class="badge bg-secondary bg-opacity-25 text-light px-2"><%= rs.getInt("quantity") %></span></td>
                                            <td class="fw-bold text-end text-accent">$<%= String.format("%.2f", rs.getDouble("total_price")) %></td>
                                            <td class="text-center">
                                                <a href="post_sale_request.jsp?sale_id=<%= rs.getInt("id") %>" class="btn btn-sm btn-outline-warning rounded-pill px-3" title="<fmt:message key='dashboard.claim_title' />">
                                                    <i class="bi bi-shield-exclamation me-1"></i><fmt:message key="dashboard.claim" />
                                                </a>
                                            </td>
                                        </tr>
                                        <%
                                                }
                                                if(!hasPurchases) {
                                                    out.print("<tr><td colspan='5' class='text-center text-secondary py-5 fw-bold'><i class='bi bi-inbox fs-1 d-block mb-2'></i><fmt:message key='dashboard.no_purchases' /></td></tr>");
                                                }
                                            } catch(Exception e) { e.printStackTrace(); }
                                        %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Mis motocicletas -->
                <div class="row g-4 mb-4">
                    <div class="col-12">
                        <div class="dashboard-section-card p-4">
                            <div class="d-flex justify-content-between align-items-center border-bottom border-secondary border-opacity-10 pb-3 mb-4">
                                <h5 class="text-accent fw-bold mb-0"><i class="bi bi-bicycle me-2"></i><fmt:message key="dashboard.my_motorcycles" /></h5>
                                <button type="button" class="btn btn-sm btn-moto-outline rounded-pill px-3 fw-bold" data-bs-toggle="modal" data-bs-target="#motoModal"><fmt:message key="dashboard.register_moto" /></button>
                            </div>
                            <% if(request.getParameter("msgMoto") != null) { %>
                                <div class="alert alert-success py-2 small rounded-3 bg-opacity-10 border-success text-success fw-bold">
                                    <i class="bi bi-check-circle me-1"></i><%= request.getParameter("msgMoto") %>
                                </div>
                            <% } %>
                            <% if(request.getParameter("errorMoto") != null) { %>
                                <div class="alert alert-danger py-2 small rounded-3 bg-opacity-10 border-danger text-danger fw-bold">
                                    <i class="bi bi-exclamation-triangle me-1"></i><%= request.getParameter("errorMoto") %>
                                </div>
                            <% } %>
                            <div class="table-responsive" style="max-height: 250px; overflow-y: auto;">
                                <table class="table table-hover align-middle table-borderless">
                                    <thead>
                                        <tr>
                                            <th class="text-secondary small text-uppercase"><fmt:message key="dashboard.plate" /></th>
                                            <th class="text-secondary small text-uppercase"><fmt:message key="dashboard.brand" /></th>
                                            <th class="text-secondary small text-uppercase"><fmt:message key="dashboard.model" /></th>
                                            <th class="text-secondary small text-uppercase text-center"><fmt:message key="dashboard.year" /></th>
                                            <th class="text-secondary small text-uppercase text-end"><fmt:message key="dashboard.actions" /></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                            List<com.adso.cheng.models.Motorcycle> myMotos = new com.adso.cheng.dao.MotorcycleDAO().getMotorcyclesByCustomer(user.getId());
                                            if(!myMotos.isEmpty()) {
                                                for(com.adso.cheng.models.Motorcycle m : myMotos) {
                                        %>
                                        <tr>
                                            <td class="fw-bold fs-6"><%= m.getPlate() %></td>
                                            <td><%= m.getBrand() %></td>
                                            <td><%= m.getModel() %></td>
                                            <td class="text-center"><%= m.getYear() %></td>
                                            <td class="text-end">
                                                <form action="motorcycle" method="POST" class="d-inline" onsubmit="return confirm('<fmt:message key="dashboard.delete_confirm" />');">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="id" value="<%= m.getId() %>">
                                                    <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill px-2"><i class="bi bi-trash"></i></button>
                                                </form>
                                            </td>
                                        </tr>
                                        <%      }
                                            } else {
                                                out.print("<tr><td colspan='5' class='text-center text-secondary py-4 fw-bold'><i class='bi bi-inbox fs-2 d-block mb-2'></i><fmt:message key='dashboard.no_motos' /></td></tr>");
                                            }
                                        %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
                


            <% } else if(user.getRoleId() == 6) { // Mecanico %>
                <!-- DASHBOARD MECÁNICO -->
                <div class="row g-4 mb-4">
                    <div class="col-xl-3 col-sm-6">
                        <div class="metric-card d-flex flex-column h-100" style="border-bottom: 4px solid #00E676 !important;">
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div>
                                    <span class="text-secondary small fw-bold text-uppercase">Mis Trabajos Activos</span>
                                    <h3 class="fw-extrabold mt-1 mb-0"><%= mechActiveJobs %></h3>
                                </div>
                                <div class="icon-circle green">
                                    <i class="bi bi-wrench"></i>
                                </div>
                            </div>
                            <div class="mt-auto pt-2">
                                <span class="text-secondary small"><i class="bi bi-activity"></i> En curso en taller</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-sm-6">
                        <div class="metric-card d-flex flex-column h-100" style="border-bottom: 4px solid #9c27b0 !important;">
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div>
                                    <span class="text-secondary small fw-bold text-uppercase">Entregados (30 días)</span>
                                    <h3 class="fw-extrabold mt-1 mb-0"><%= mechCompletedJobs %></h3>
                                </div>
                                <div class="icon-circle purple">
                                    <i class="bi bi-check-circle"></i>
                                </div>
                            </div>
                            <div class="mt-auto pt-2">
                                <span class="text-secondary small"><i class="bi bi-clock-history"></i> Reparaciones finalizadas</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-sm-6">
                        <div class="metric-card d-flex flex-column h-100" style="border-bottom: 4px solid #FF1744 !important;">
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div>
                                    <span class="text-secondary small fw-bold text-uppercase">Total Cola Taller</span>
                                    <h3 class="fw-extrabold mt-1 mb-0"><%= mechTotalShopJobs %></h3>
                                </div>
                                <div class="icon-circle pink">
                                    <i class="bi bi-layout-text-sidebar-reverse"></i>
                                </div>
                            </div>
                            <div class="mt-auto pt-2">
                                <span class="text-secondary small"><i class="bi bi-people"></i> Todos los vehículos en taller</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-sm-6">
                        <div class="metric-card solid-accent d-flex flex-column h-100">
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div>
                                    <span class="text-dark small fw-bold text-uppercase" style="opacity: 0.8;">Operación Activa</span>
                                    <h3 class="fw-extrabold text-dark mt-1 mb-0">Taller Mecánico</h3>
                                </div>
                                <div class="icon-circle shadow-sm" style="background: rgba(255,255,255,0.4); color: #121417;">
                                    <i class="bi bi-tools"></i>
                                </div>
                            </div>
                            <div class="mt-auto pt-2">
                                <a href="maintenance" class="text-dark fw-bold small text-decoration-none"><i class="bi bi-arrow-right-circle-fill me-1"></i>Entrar al Taller</a>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row g-4 mb-4">
                    <!-- Lista de Trabajos asignados -->
                    <div class="col-12">
                        <div class="dashboard-section-card p-4">
                            <h5 class="fw-bold mb-4 border-bottom border-secondary border-opacity-10 pb-3"><i class="bi bi-wrench-adjustable text-accent me-2"></i>Mis Trabajos Asignados</h5>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle table-borderless">
                                    <thead>
                                        <tr>
                                            <th class="text-secondary small text-uppercase">Vehículo / Placa</th>
                                            <th class="text-secondary small text-uppercase">Descripción</th>
                                            <th class="text-secondary small text-uppercase text-center">Estado</th>
                                            <th class="text-secondary small text-uppercase text-end">Costo</th>
                                            <th class="text-secondary small text-uppercase text-center">Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                            if(!mechJobsList.isEmpty()) {
                                                for(Map<String, Object> job : mechJobsList) {
                                                    String status = (String) job.get("status");
                                                    String badgeClass = "bg-secondary";
                                                    if("PENDIENTE".equals(status)) badgeClass = "bg-warning text-dark";
                                                    else if("EN_PROCESO".equals(status)) badgeClass = "bg-info text-dark";
                                                    else if("COMPLETADO".equals(status)) badgeClass = "bg-success";
                                        %>
                                                    <tr>
                                                        <td class="fw-bold"><%= job.get("brand") %> <%= job.get("model") %><br><span class="badge bg-secondary bg-opacity-25 text-light text-uppercase mt-1"><%= job.get("plate") %></span></td>
                                                        <td class="text-wrap" style="max-width: 200px;"><%= job.get("description") %></td>
                                                        <td class="text-center"><span class="badge <%= badgeClass %> rounded-pill px-3 py-1 fw-bold"><%= status %></span></td>
                                                        <td class="fw-bold text-end text-accent">$<%= String.format("%.2f", (Double) job.get("price")) %></td>
                                                        <td class="text-center">
                                                            <a href="maintenance" class="btn btn-sm btn-accent rounded-pill px-3">Ver</a>
                                                        </td>
                                                    </tr>
                                        <% 
                                                }
                                            } else {
                                        %>
                                                <tr>
                                                    <td colspan="5" class="text-center text-secondary py-5 fw-bold"><i class="bi bi-check-circle fs-2 d-block mb-2"></i>No tienes trabajos asignados pendientes</td>
                                                </tr>
                                        <% 
                                            }
                                        %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

            <% } else { // Admin (1), Bodeguero (3), Cajero (4) %>
                <!-- DASHBOARD STAFF GENERAL -->
                <div class="row g-4 mb-4">
                    <!-- Card 1: Ventas del Mes -->
                    <div class="col-xl-3 col-sm-6">
                        <div class="metric-card d-flex flex-column h-100" style="border-bottom: 4px solid #00E676 !important;">
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div>
                                    <span class="text-secondary small fw-bold text-uppercase"><fmt:message key="dashboard.sales_30_days" /></span>
                                    <h3 class="fw-extrabold mt-1 mb-0">$<%= String.format("%,.2f", salesRevenue) %></h3>
                                </div>
                                <div class="icon-circle green">
                                    <i class="bi bi-graph-up-arrow"></i>
                                </div>
                            </div>
                            <div class="mt-auto pt-2">
                                <span class="text-secondary small"><i class="bi bi-arrow-up-short text-success"></i> <fmt:message key="dashboard.monthly_performance" /></span>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Card 2: Total Repuestos -->
                    <div class="col-xl-3 col-sm-6">
                        <div class="metric-card d-flex flex-column h-100" style="border-bottom: 4px solid #9c27b0 !important;">
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div>
                                    <span class="text-secondary small fw-bold text-uppercase"><fmt:message key="dashboard.total_parts" /></span>
                                    <h3 class="fw-extrabold mt-1 mb-0"><%= totalProducts %></h3>
                                </div>
                                <div class="icon-circle purple">
                                    <i class="bi bi-box-seam"></i>
                                </div>
                            </div>
                            <div class="mt-auto pt-2">
                                <span class="text-secondary small"><i class="bi bi-collection-fill text-purple"></i> <fmt:message key="dashboard.parts_in_warehouse" /></span>
                            </div>
                        </div>
                    </div>

                    <!-- Card 3: Alertas de Stock -->
                    <div class="col-xl-3 col-sm-6">
                        <div class="metric-card d-flex flex-column h-100" style="border-bottom: 4px solid #FF1744 !important;">
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div>
                                    <span class="text-secondary small fw-bold text-uppercase"><fmt:message key="dashboard.stock_alerts" /></span>
                                    <h3 class="fw-extrabold mt-1 mb-0 <%= lowStockCount > 0 ? "text-danger" : "" %>"><%= lowStockCount %></h3>
                                </div>
                                <div class="icon-circle pink">
                                    <i class="bi bi-exclamation-triangle"></i>
                                </div>
                            </div>
                            <div class="mt-auto pt-2">
                                <span class="text-secondary small"><i class="bi bi-shield-alert text-danger"></i> Stock <= 20</span>
                            </div>
                        </div>
                    </div>

                    <!-- Card 4: Trabajos de Taller -->
                    <div class="col-xl-3 col-sm-6">
                        <div class="metric-card solid-accent d-flex flex-column h-100">
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div>
                                    <span class="text-dark small fw-bold text-uppercase" style="opacity: 0.8;"><fmt:message key="dashboard.workshop_jobs" /></span>
                                    <h3 class="fw-extrabold text-dark mt-1 mb-0"><%= activeJobsCount %> <fmt:message key="dashboard.active_label" /></h3>
                                </div>
                                <div class="icon-circle shadow-sm" style="background: rgba(255,255,255,0.4); color: #121417;">
                                    <i class="bi bi-tools"></i>
                                </div>
                            </div>
                            <div class="mt-auto pt-2">
                                <span class="text-dark small" style="opacity: 0.8;"><i class="bi bi-clock-history"></i> <fmt:message key="dashboard.vehicles_in_workshop" /></span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- GRÁFICOS Y PRODUCTOS POPULARES -->
                <div class="row g-4 mb-4">
                    <!-- Line Chart: Flujo de Inventario -->
                    <div class="col-lg-8">
                        <div class="dashboard-section-card">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <div>
                                    <h5 class="fw-bold mb-0"><fmt:message key="dashboard.parts_flow" /></h5>
                                    <span class="text-secondary small"><fmt:message key="dashboard.parts_flow_desc" /></span>
                                </div>
                                <div>
                                    <span class="badge bg-secondary bg-opacity-25 text-light px-3 py-1 rounded-pill small"><fmt:message key="dashboard.last_30_days" /></span>
                                </div>
                            </div>
                            <div class="chart-container position-relative" style="height: 280px; width: 100%;">
                                <canvas id="salesChart"></canvas>
                            </div>
                        </div>
                    </div>

                    <!-- Repuestos Más Vendidos -->
                    <div class="col-lg-4">
                        <div class="dashboard-section-card d-flex flex-column">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <div>
                                    <h5 class="fw-bold mb-0"><fmt:message key="dashboard.popular_parts" /></h5>
                                    <span class="text-secondary small"><fmt:message key="dashboard.best_sellers" /></span>
                                </div>
                                <a href="inventory" class="btn btn-sm btn-moto-outline rounded-pill px-3"><fmt:message key="dashboard.view_warehouse" /></a>
                            </div>
                            <div class="featured-list flex-grow-1">
                                <% 
                                    if (!topProducts.isEmpty()) {
                                        for (int i = 0; i < topProducts.size(); i++) {
                                            Product p = topProducts.get(i);
                                            int sold = topSalesCount.get(i);
                                            String img = (p.getImageUrl() != null && !p.getImageUrl().isEmpty()) ? p.getImageUrl() : "https://via.placeholder.com/50x50?text=Moto";
                                            double rating = 4.3 + (p.getId() % 8) * 0.1;
                                            if (rating > 5.0) rating = 5.0;
                                %>
                                            <div class="featured-item-box">
                                                <img src="<%= img %>" class="featured-item-img shadow-sm">
                                                <div class="min-w-0 flex-grow-1">
                                                    <h6 class="fw-bold mb-0 text-truncate" style="font-size: 0.9rem;"><%= p.getName() %></h6>
                                                    <span class="text-secondary small d-block" style="font-size: 0.75rem;"><%= p.getBrand() %></span>
                                                    <div class="d-flex align-items-center gap-2 mt-1">
                                                        <span class="text-accent fw-bold" style="font-size: 0.85rem;">$<%= String.format("%.2f", p.getPrice()) %></span>
                                                        <span class="text-secondary small" style="font-size: 0.75rem;">| <%= sold %> <fmt:message key="dashboard.sold_count" /></span>
                                                    </div>
                                                </div>
                                                <div class="text-end">
                                                    <span class="badge bg-success bg-opacity-10 text-success rounded px-2 py-1 fs-6 small"><i class="bi bi-star-fill text-warning me-1"></i><%= String.format("%.1f", rating) %></span>
                                                </div>
                                            </div>
                                <% 
                                        }
                                    } else {
                                %>
                                        <div class="text-center text-secondary py-5 fw-bold"><i class="bi bi-inbox fs-2 d-block mb-2"></i><fmt:message key="dashboard.no_recent_sales" /></div>
                                <% 
                                    }
                                %>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- PERSONAL Y GRÁFICO DE CATEGORÍAS -->
                <div class="row g-4 mb-4">
                    <!-- Personal de Turno -->
                    <div class="col-lg-8">
                        <div class="dashboard-section-card">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <div>
                                    <h5 class="fw-bold mb-0"><fmt:message key="dashboard.team_staff" /></h5>
                                    <span class="text-secondary small"><fmt:message key="dashboard.active_staff_desc" /></span>
                                </div>
                                <a href="employees" class="btn btn-sm btn-moto-outline rounded-pill px-3"><fmt:message key="dashboard.manage_staff" /></a>
                            </div>
                            <div class="row g-3">
                                <% 
                                    if (!staffList.isEmpty()) {
                                        String[] colors = {"#00E676", "#9c27b0", "#ffc107", "#e91e63"};
                                        for (int i = 0; i < staffList.size(); i++) {
                                            User staff = staffList.get(i);
                                            String role = staffRoleList.get(i);
                                            String color = colors[i % colors.length];
                                            double rating = 4.5 + (staff.getId() % 6) * 0.1;
                                            if (rating > 5.0) rating = 5.0;
                                %>
                                            <div class="col-md-3 col-sm-6">
                                                <div class="staff-member-card">
                                                    <div class="staff-member-avatar" style="background-color: <%= color %>;">
                                                        <%= staff.getFullName().substring(0, Math.min(2, staff.getFullName().length())).toUpperCase() %>
                                                    </div>
                                                    <h6 class="fw-bold mb-1 text-truncate" style="font-size: 0.95rem;" title="<%= staff.getFullName() %>"><%= staff.getFullName() %></h6>
                                                    <span class="badge bg-secondary bg-opacity-25 text-light border border-secondary border-opacity-50 py-0 px-2 fw-semibold mb-2" style="font-size: 0.72rem;"><%= role %></span>
                                                    
                                                    <div class="rating-stars mb-3">
                                                        <% 
                                                            int stars = (int) Math.round(rating);
                                                            for(int s=0; s<5; s++) {
                                                                if (s < stars) {
                                                        %>
                                                                    <i class="bi bi-star-fill"></i>
                                                        <%      } else { %>
                                                                    <i class="bi bi-star"></i>
                                                        <%      }
                                                            }
                                                        %>
                                                    </div>
                                                    <a href="employees" class="staff-btn"><fmt:message key="dashboard.view_schedule" /></a>
                                                </div>
                                            </div>
                                <% 
                                        }
                                    } else {
                                %>
                                        <div class="text-center text-secondary py-5 fw-bold w-100"><i class="bi bi-people fs-2 d-block mb-2"></i><fmt:message key="dashboard.no_staff_registered" /></div>
                                <% 
                                    }
                                %>
                            </div>
                        </div>
                    </div>

                    <!-- Ventas por Categoría -->
                    <div class="col-lg-4">
                        <div class="dashboard-section-card">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <div>
                                    <h5 class="fw-bold mb-0"><fmt:message key="dashboard.sales_by_category" /></h5>
                                    <span class="text-secondary small"><fmt:message key="dashboard.category_chart_desc" /></span>
                                </div>
                                <div>
                                    <span class="badge bg-secondary bg-opacity-25 text-light px-3 py-1 rounded-pill small">Top 5</span>
                                </div>
                            </div>
                            <div class="chart-container position-relative" style="height: 220px; width: 100%;">
                                <canvas id="categoryChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>


            <% } %>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<% if(user.getRoleId() == 1 || user.getRoleId() == 3 || user.getRoleId() == 4) { %>
<script>
document.addEventListener("DOMContentLoaded", function() {
    // 1. Line Chart: Flujo de Inventario
    fetch('dashboardData?action=graphData')
        .then(res => res.json())
        .then(data => {
            const ctx = document.getElementById('salesChart').getContext('2d');
            const isLight = document.body.classList.contains('light-mode');
            
            const accentColor = getComputedStyle(document.documentElement).getPropertyValue('--accent-orange').trim() || '#00E5FF';
            const accentGlow = getComputedStyle(document.documentElement).getPropertyValue('--accent-glow').trim() || 'rgba(0, 229, 255, 0.4)';
            const secondaryColor = isLight ? '#6c757d' : '#E2E8F0';
            const secondaryBg = isLight ? 'rgba(108, 117, 125, 0.1)' : 'rgba(226, 232, 240, 0.1)';
            const gridColor = isLight ? 'rgba(0,0,0,0.05)' : 'rgba(255,255,255,0.05)';
            const textColor = isLight ? '#495057' : '#adb5bd';
            
            Chart.defaults.color = textColor;
            Chart.defaults.font.family = "'Outfit', 'Inter', sans-serif";
            
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: data.labels,
                    datasets: [
                        {
                            label: '<fmt:message key="dashboard.parts_entered" />',
                            data: data.entered,
                            borderColor: secondaryColor,
                            backgroundColor: secondaryBg,
                            borderWidth: 2,
                            pointBackgroundColor: secondaryColor,
                            pointBorderColor: isLight ? '#fff' : '#121417',
                            pointHoverRadius: 6,
                            tension: 0.4,
                            fill: true
                        },
                        {
                            label: '<fmt:message key="dashboard.parts_sold" />',
                            data: data.sold,
                            borderColor: accentColor,
                            backgroundColor: accentGlow,
                            borderWidth: 3,
                            pointBackgroundColor: accentColor,
                            pointBorderColor: isLight ? '#fff' : '#121417',
                            pointHoverRadius: 6,
                            tension: 0.4,
                            fill: true
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: {
                        mode: 'index',
                        intersect: false,
                    },
                    scales: {
                        y: { 
                            beginAtZero: true, 
                            grid: { color: gridColor, drawBorder: false },
                            border: { dash: [5, 5] }
                        },
                        x: { 
                            grid: { display: false },
                            border: { display: false }
                        }
                    },
                    plugins: {
                        legend: { 
                            position: 'top',
                            align: 'end',
                            labels: { usePointStyle: true, boxWidth: 8, padding: 20 }
                        },
                        tooltip: {
                            backgroundColor: isLight ? 'rgba(255,255,255,0.9)' : 'rgba(30,32,36,0.9)',
                            titleColor: isLight ? '#000' : '#fff',
                            bodyColor: isLight ? '#333' : '#ddd',
                            borderColor: gridColor,
                            borderWidth: 1,
                            padding: 12,
                            boxPadding: 6
                        }
                    }
                }
            });
        });

    // 2. Bar Chart: Ventas por Categoría (Calories Chart)
    const categoryCtx = document.getElementById('categoryChart');
    if (categoryCtx) {
        const isLight = document.body.classList.contains('light-mode');
        const accentColor = getComputedStyle(document.documentElement).getPropertyValue('--accent-orange').trim() || '#00E5FF';
        const textColor = isLight ? '#495057' : '#adb5bd';
        
        new Chart(categoryCtx, {
            type: 'bar',
            data: {
                labels: [<%= catLabelsJson %>].map(label => {
                    if (<%= isEn %>) {
                        const translationMap = {
                            "Lubricantes": "Lubricants",
                            "Frenos": "Brakes",
                            "Motor": "Engine",
                            "Llantas": "Tires",
                            "Accesorios": "Accessories"
                        };
                        return translationMap[label] || label;
                    }
                    return label;
                }),
                datasets: [{
                    label: <%= isEn %> ? 'Units Sold' : 'Unidades Vendidas',
                    data: [<%= catDataJson %>],
                    backgroundColor: accentColor,
                    borderColor: accentColor,
                    borderWidth: 0,
                    borderRadius: 6,
                    borderSkipped: false,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { display: false },
                        ticks: { color: textColor }
                    },
                    x: {
                        grid: { display: false },
                        ticks: { color: textColor }
                    }
                },
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        padding: 10
                    }
                }
            }
        });
    }
});
</script>
<% } %>

<!-- Modal Registrar Moto -->
<div class="modal fade" id="motoModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-secondary shadow-lg">
      <div class="modal-header border-secondary">
        <h5 class="modal-title text-accent fw-bold"><i class="bi bi-plus-circle me-2"></i><fmt:message key="dashboard.register_moto_modal" /></h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter: var(--close-btn-filter);"></button>
      </div>
      <form action="motorcycle" method="POST">
          <div class="modal-body p-4">
              <input type="hidden" name="action" value="add">
              <div class="mb-3">
                  <label class="form-label"><fmt:message key="dashboard.plate" /></label>
                  <input type="text" name="plate" class="form-control text-uppercase" placeholder="<fmt:message key='dashboard.ex_plate' />" required maxlength="20">
              </div>
              <div class="mb-3">
                  <label class="form-label"><fmt:message key="dashboard.moto_brand" /></label>
                  <select name="brand" id="clientMotoBrand" class="form-select" onchange="updateClientModels()" required>
                      <option value=""><fmt:message key="dashboard.sel_brand" /></option>
                  </select>
              </div>
              <div class="mb-3">
                  <label class="form-label"><fmt:message key="dashboard.model" /></label>
                  <select name="model" id="clientMotoModel" class="form-select" required>
                      <option value=""><fmt:message key="dashboard.sel_model" /></option>
                  </select>
              </div>
              <div class="mb-3">
                  <label class="form-label"><fmt:message key="dashboard.year" /></label>
                  <input type="number" name="year" class="form-control" placeholder="<fmt:message key='dashboard.ex_year' />" required min="1950" max="2030">
              </div>
          </div>
          <div class="modal-footer border-secondary">
            <button type="button" class="btn btn-outline-secondary rounded-pill fw-bold" data-bs-dismiss="modal"><fmt:message key="dashboard.cancel" /></button>
            <button type="submit" class="btn btn-accent rounded-pill fw-bold"><fmt:message key="dashboard.register" /></button>
          </div>
      </form>
    </div>
  </div>
</div>

<script>
    const motoData = {
        'Suzuki': ['gn125', 'gixxer 150', 'gixxer 250', 'dr150', 'v-strom 250', 'v-strom 650', 'gsx-r150', 'burgman 125', 'address'],
        'Yamaha': ['fz25', 'fz-s 3.0', 'mt-15', 'mt-03', 'mt-09', 'r15', 'r3', 'xtz 125', 'xtz 150', 'nmax', 'aerox', 'crypton'],
        'Honda': ['cb125f', 'cb160f', 'cb190r', 'cbf150', 'xr150l', 'xr190l', 'xre300', 'pcx150', 'wave110', 'navi'],
        'Kawasaki': ['ninja 300', 'ninja 400', 'z400', 'z650', 'z900', 'versys-x 300', 'versys 650', 'klx 150'],
        'KTM': ['duke 200', 'duke 250', 'duke 390', 'rc 200', 'rc 390', 'adventure 250', 'adventure 390'],
        'Bajaj': ['pulsar ns200', 'pulsar ns160', 'pulsar n250', 'dominar 400', 'dominar 250', 'boxer ct100', 'discover 125'],
        'Hero': ['eco deluxe', 'ignitor 125', 'hunk 160r', 'xpulse 200', 'thriller 200r', 'dash 125'],
        'AKT': ['nkd 125', 'cr4 125', 'cr4 162', 'rtx 150', 'flex 125', 'dynamic pro', 'adventure 250']
    };

    function updateClientModels() {
        const brand = document.getElementById('clientMotoBrand').value;
        const modelSelect = document.getElementById('clientMotoModel');
        modelSelect.innerHTML = '<option value="">Seleccione modelo...</option>';
        if (brand && motoData[brand]) {
            motoData[brand].forEach(mod => {
                let opt = document.createElement('option');
                opt.value = mod; opt.textContent = mod;
                modelSelect.appendChild(opt);
            });
            let genOpt = document.createElement('option');
            genOpt.value = 'Otro / No lista'; genOpt.textContent = '<fmt:message key="dashboard.other_not_listed" />';
            modelSelect.appendChild(genOpt);
        }
    }

    document.addEventListener("DOMContentLoaded", function() {
        const isLight = document.body.classList.contains('light-mode');
        document.documentElement.style.setProperty('--close-btn-filter', isLight ? 'none' : 'invert(1) grayscale(100%) brightness(200%)');
        
        const brandSelect = document.getElementById('clientMotoBrand');
        if (brandSelect) {
            Object.keys(motoData).forEach(brand => {
                let opt = document.createElement('option');
                opt.value = brand; opt.textContent = brand;
                brandSelect.appendChild(opt);
            });
        }
    });
</script>

</body>
</html>
