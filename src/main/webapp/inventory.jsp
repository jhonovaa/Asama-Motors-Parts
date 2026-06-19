<%@ page import="java.util.List" %>
<%@ page import="com.adso.cheng.models.Product" %>
<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || (sessionUser.getRoleId() != 1 && sessionUser.getRoleId() != 3)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<%!
    public String getStockBadgeHTML(int stock) {
        if (stock == 0) {
            return "<span class='badge badge-stock-zero px-3 py-2 rounded-pill fw-bold fs-6'><i class='bi bi-slash-circle me-1'></i>" + stock + "</span>";
        } else if (stock <= 20) {
            return "<span class='badge badge-stock-low px-3 py-2 rounded-pill fw-bold fs-6'><i class='bi bi-exclamation-triangle me-1'></i>" + stock + "</span>";
        } else if (stock <= 50) {
            return "<span class='badge badge-stock-medium px-3 py-2 rounded-pill fw-bold fs-6'><i class='bi bi-info-circle me-1'></i>" + stock + "</span>";
        } else {
            return "<span class='badge badge-stock-high px-3 py-2 rounded-pill fw-bold fs-6'><i class='bi bi-check-circle me-1'></i>" + stock + "</span>";
        }
    }

    public String getStockAlertBadgeHTML(int stock) {
        if (stock == 0) {
            return "<span class='badge badge-stock-zero px-3 py-2 rounded-pill fw-bold fs-6 d-inline-flex align-items-center'><span class='stock-dot-zero me-2'></span>Sin Stock</span>";
        } else if (stock <= 20) {
            return "<span class='badge badge-stock-low px-3 py-2 rounded-pill fw-bold fs-6 d-inline-flex align-items-center'><span class='stock-dot-low me-2'></span>Stock Bajo</span>";
        } else if (stock <= 50) {
            return "<span class='badge badge-stock-medium px-3 py-2 rounded-pill fw-bold fs-6 d-inline-flex align-items-center'><span class='stock-dot-medium me-2'></span>Stock Medio</span>";
        } else {
            return "<span class='badge badge-stock-high px-3 py-2 rounded-pill fw-bold fs-6 d-inline-flex align-items-center'><span class='stock-dot-high me-2'></span>Con Stock</span>";
        }
    }
%>
<!DOCTYPE html>
<html lang="<fmt:message key='app.lang' />">
<head>
    <meta charset="UTF-8">
    <title><fmt:message key="inventory.title" /></title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <script src="https://cdn.jsdelivr.net/npm/jsbarcode@3.11.5/dist/JsBarcode.all.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <link rel="stylesheet" href="resources/theme.css?v=6">
    <style>
        /* --- LEGIBILIDAD EXTREMA --- */
        .text-secondary, .text-muted { 
            color: rgba(255, 255, 255, 0.9) !important; 
            font-weight: 600;
        }
        body.light-mode .text-secondary, body.light-mode .text-muted { 
            color: rgba(0, 0, 0, 0.8) !important; 
            font-weight: 700;
        }

        /* Formularios */
        .form-label {
            font-weight: 700 !important;
            color: var(--text-color) !important;
            font-size: 1rem;
            margin-bottom: 0.5rem;
            letter-spacing: 0.3px;
        }
        .form-control, textarea {
            background-color: rgba(255, 255, 255, 0.08) !important;
            color: #ffffff !important;
            border: 2px solid rgba(255, 255, 255, 0.2) !important;
            font-weight: 600;
            padding: 12px 18px;
            font-size: 1.05rem;
        }
        .form-control::placeholder, textarea::placeholder {
            color: rgba(255, 255, 255, 0.5) !important;
            font-weight: 500;
        }
        .form-control:focus, textarea:focus {
            background-color: rgba(255, 255, 255, 0.12) !important;
            border-color: var(--accent-orange) !important;
            box-shadow: 0 0 0 0.3rem var(--accent-glow) !important;
        }
        body.light-mode .form-control, body.light-mode textarea {
            background-color: #ffffff !important;
            color: #121417 !important;
            border-color: rgba(0, 0, 0, 0.3) !important;
        }
        body.light-mode .form-control::placeholder, body.light-mode textarea::placeholder {
            color: rgba(0, 0, 0, 0.6) !important;
        }

        /* Boton de archivo */
        .form-control::file-selector-button {
            background-color: var(--accent-orange);
            color: #121417;
            border: none;
            border-radius: 6px;
            padding: 6px 18px;
            margin-right: 15px;
            font-weight: 800;
            transition: all 0.3s ease;
            cursor: pointer;
        }
        .form-control::file-selector-button:hover {
            filter: brightness(1.2);
        }

        /* Tablas: Forzar contraste sobreescribiendo Bootstrap */
        .table { 
            --bs-table-bg: transparent;
            --bs-table-color: var(--text-color);
            color: var(--text-color) !important; 
        }
        .table th { 
            font-weight: 800 !important; 
            letter-spacing: 1px; 
            font-size: 0.9rem; 
            border-bottom: 3px solid var(--card-border) !important; 
            color: rgba(255, 255, 255, 0.9) !important;
        }
        body.light-mode .table th {
            color: rgba(0, 0, 0, 0.8) !important;
        }
        .table td { 
            font-weight: 700 !important; 
            font-size: 1.05rem !important; 
            border-bottom: 1px solid var(--card-border) !important; 
            vertical-align: middle; 
            color: var(--text-color) !important; 
        }
        .table tbody tr:hover td { 
            background-color: rgba(255, 255, 255, 0.1) !important; 
        }
        body.light-mode .table tbody tr:hover td { 
            background-color: rgba(0, 0, 0, 0.05) !important; 
        }

        /* Codigo de Barras Blanco para Escaneres */
        .inventory-barcode-container {
            background: #ffffff !important;
            padding: 6px;
            border-radius: 8px;
            display: inline-block;
        }
        .inventory-barcode-container svg { height: 38px; width: auto; }

        /* Estilo para los Codigos de Barras de las Tarjetas */
        .card-barcode-container {
            background: #ffffff !important;
            padding: 8px 14px;
            border-radius: 8px;
            display: inline-flex;
            justify-content: center;
            align-items: center;
            border: 1px solid rgba(0,0,0,0.06);
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05) !important;
            max-width: 90%;
            margin: 0 auto;
            overflow: hidden;
        }
        .card-barcode-container svg {
            display: block;
            height: 25px !important;
            width: auto !important;
            max-width: 100%;
        }

        /* Estilos de Stock Personalizados */
        .badge-stock-zero {
            background-color: rgba(108, 117, 125, 0.15) !important;
            color: #a0a0a0 !important;
            border: 1px solid rgba(108, 117, 125, 0.3) !important;
        }
        body.light-mode .badge-stock-zero {
            background-color: rgba(108, 117, 125, 0.15) !important;
            color: #495057 !important;
            border-color: rgba(108, 117, 125, 0.3) !important;
        }

        .badge-stock-low {
            background-color: rgba(220, 53, 69, 0.15) !important;
            color: #ff4d4d !important;
            border: 1px solid rgba(220, 53, 69, 0.3) !important;
        }
        body.light-mode .badge-stock-low {
            background-color: rgba(220, 53, 69, 0.1) !important;
            color: #dc3545 !important;
            border-color: rgba(220, 53, 69, 0.25) !important;
        }

        .badge-stock-medium {
            background-color: rgba(255, 140, 0, 0.15) !important;
            color: #ff8c00 !important;
            border: 1px solid rgba(255, 140, 0, 0.3) !important;
        }
        body.light-mode .badge-stock-medium {
            background-color: rgba(255, 140, 0, 0.1) !important;
            color: #fd7e14 !important;
            border-color: rgba(255, 140, 0, 0.25) !important;
        }

        .badge-stock-high {
            background-color: rgba(40, 167, 69, 0.15) !important;
            color: #28a745 !important;
            border: 1px solid rgba(40, 167, 69, 0.3) !important;
        }
        body.light-mode .badge-stock-high {
            background-color: rgba(40, 167, 69, 0.1) !important;
            color: #198754 !important;
            border-color: rgba(40, 167, 69, 0.25) !important;
        }

        .stock-dot-zero, .stock-dot-low, .stock-dot-medium, .stock-dot-high {
            display: inline-block;
            width: 8px;
            height: 8px;
            border-radius: 50%;
        }
        .stock-dot-zero { background-color: #888888; box-shadow: 0 0 5px rgba(136, 136, 136, 0.5); }
        .stock-dot-low { background-color: #ff4d4d; box-shadow: 0 0 5px rgba(255, 77, 77, 0.5); }
        .stock-dot-medium { background-color: #ff8c00; box-shadow: 0 0 5px rgba(255, 140, 0, 0.5); }
        .stock-dot-high { background-color: #28a745; box-shadow: 0 0 5px rgba(40, 167, 69, 0.5); }

        /* Estilos para Pestañas Modernas */
        .nav-tabs-custom .nav-link {
            color: var(--text-color) !important;
            border: 2px solid rgba(255, 255, 255, 0.15) !important;
            background: transparent !important;
            transition: all 0.3s ease;
        }
        body.light-mode .nav-tabs-custom .nav-link {
            border-color: rgba(0, 0, 0, 0.15) !important;
        }
        .nav-tabs-custom .nav-link.active {
            background-color: var(--accent-orange) !important;
            color: #121417 !important;
            border-color: var(--accent-orange) !important;
            box-shadow: 0 4px 15px var(--accent-glow);
        }
        
        /* Columnas de Alerta de Stock (Grid) */
        .stock-column-card {
            background: rgba(30, 32, 36, 0.4);
            border: 1px solid var(--card-border);
            backdrop-filter: blur(12px);
            transition: all 0.3s ease;
        }
        body.light-mode .stock-column-card {
            background: rgba(255, 255, 255, 0.8);
            border-color: rgba(0, 0, 0, 0.08);
        }
    </style>
</head>
<body>
<script src="resources/theme.js?v=2"></script>

<%@ include file="navbar.jsp" %>

<div class="container-fluid px-4 pb-5 mb-5" style="margin-top: 100px;">
    <div class="row">
        
        <%
            int countZero = 0;
            int countLow = 0;
            int countMedium = 0;
            int countHigh = 0;
            List<Product> productsList = (List<Product>) request.getAttribute("products");
            if (productsList != null) {
                for (Product p : productsList) {
                    if (p.getStock() == 0) countZero++;
                    else if (p.getStock() <= 20) countLow++;
                    else if (p.getStock() <= 50) countMedium++;
                    else countHigh++;
                }
            }
        %>
        
        <div class="col-12">
            <div class="action-card h-100 d-flex flex-column">
                <div class="card-header border-bottom border-secondary pb-3 mb-3 px-4 pt-4 d-flex justify-content-between align-items-center flex-wrap gap-3">
                    <ul class="nav nav-pills nav-tabs-custom gap-2 mb-2 mb-md-0" id="inventoryTabs" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active px-4 py-2 rounded-pill fw-bold border border-2 d-flex align-items-center gap-2" 
                                    id="tracker-tab" data-bs-toggle="tab" data-bs-target="#tracker-tab-pane" type="button" role="tab" 
                                    aria-controls="tracker-tab-pane" aria-selected="true">
                                <i class="bi bi-grid-3x3-gap-fill"></i> Control de Inventario
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link px-4 py-2 rounded-pill fw-bold border border-2 d-flex align-items-center gap-2" 
                                    id="alert-tab" data-bs-toggle="tab" data-bs-target="#alert-tab-pane" type="button" role="tab" 
                                    aria-controls="alert-tab-pane" aria-selected="false">
                                <i class="bi bi-columns-gap"></i> Alerta de Stock
                            </button>
                        </li>
                    </ul>
                    <div class="d-flex align-items-center gap-3">
                        <button class="btn btn-accent rounded-pill px-4 py-2 fw-bolder d-flex align-items-center gap-2" data-bs-toggle="modal" data-bs-target="#newProductModal">
                            <i class="bi bi-plus-circle-fill fs-5"></i> Nuevo Producto
                        </button>
                        <button class="btn btn-outline-warning rounded-pill px-4 py-2 fw-bolder border-2 d-flex align-items-center gap-2" style="color: var(--accent-orange); border-color: var(--accent-orange);" data-bs-toggle="modal" data-bs-target="#massUploadModal">
                            <i class="bi bi-file-earmark-spreadsheet-fill fs-5"></i> Carga Masiva
                        </button>
                        <span class="badge bg-secondary bg-opacity-25 text-light px-4 py-2 rounded-pill fw-bolder fs-6 border border-secondary border-opacity-50">
                            Total: <%= productsList != null ? productsList.size() : 0 %>
                        </span>
                    </div>
                </div>
                
                <div class="tab-content flex-grow-1" id="inventoryTabContent">
                    <!-- TAB 1: Control de Inventario -->
                    <div class="tab-pane fade show active px-3" id="tracker-tab-pane" role="tabpanel" aria-labelledby="tracker-tab" tabindex="0">
                        <div class="table-responsive" style="max-height: 62vh; overflow-y: auto;">
                            <table class="table align-middle table-borderless table-hover">
                                <thead class="sticky-top" style="background: var(--card-bg); z-index: 10;">
                                    <tr>
                                        <th class="text-uppercase pb-3 pt-3">Foto</th>
                                        <th class="text-uppercase pb-3 pt-3">Repuesto</th>
                                        <th class="text-uppercase pb-3 pt-3">Marca</th>
                                        <th class="text-uppercase pb-3 pt-3 text-center">Código de Barras</th>
                                        <th class="text-uppercase pb-3 pt-3 text-center">Cantidad</th>
                                        <th class="text-uppercase pb-3 pt-3 text-center">Alerta de Stock</th>
                                        <th class="text-uppercase pb-3 pt-3 text-center">Ubicación</th>
                                        <th class="text-uppercase pb-3 pt-3 text-end">Precio</th>
                                        <th class="text-uppercase pb-3 pt-3 text-center">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% 
                                        if(productsList != null && !productsList.isEmpty()) {
                                            for(Product p : productsList) {
                                                String img = (p.getImageUrl() != null && !p.getImageUrl().isEmpty()) ? p.getImageUrl() : "https://via.placeholder.com/50x50?text=No+Img";
                                    %>
                                    <tr>
                                        <td class="py-3">
                                            <img src="<%= img %>" width="55" height="55" class="rounded-3 shadow-sm" style="object-fit:cover; border: 2px solid var(--card-border);">
                                        </td>
                                        <td class="fw-bolder fs-5 text-wrap" style="max-width: 250px;"><%= p.getName() %></td>
                                        <td><span class="badge bg-secondary bg-opacity-25 text-light border border-secondary border-opacity-50 py-2 px-3 fw-bold fs-6"><%= p.getBrand() %></span></td>
                                        <td class="text-center">
                                            <div class="inventory-barcode-container shadow-sm">
                                                <svg id="barcode-<%= p.getId() %>"></svg>
                                                <script>
                                                    JsBarcode("#barcode-<%= p.getId() %>", "<%= p.getBarcode() %>", {
                                                        format: "CODE128",
                                                        displayValue: true,
                                                        height: 30,
                                                        fontSize: 13,
                                                        fontOptions: "bold",
                                                        margin: 0,
                                                        background: "#ffffff",
                                                        lineColor: "#000000"
                                                    });
                                                </script>
                                            </div>
                                        </td>
                                        <td class="text-center fw-bold fs-5">
                                            <%= p.getStock() %>
                                        </td>
                                        <td class="text-center">
                                            <%= getStockAlertBadgeHTML(p.getStock()) %>
                                        </td>
                                        <td class="text-center fw-bolder fs-6 text-secondary">
                                            <%= (p.getEstante() != null ? p.getEstante() : "-") %> / <%= (p.getFila() != null ? p.getFila() : "-") %>
                                        </td>
                                        <td class="fw-bolder text-end text-accent fs-5">$<%= String.format("%.2f", p.getPrice()) %></td>
                                        <td class="text-center">
                                            <div class="d-flex justify-content-center gap-2">
                                                <button class="btn btn-outline-warning rounded-circle p-2 fw-bold d-flex align-items-center justify-content-center shadow-sm" style="width: 40px; height: 40px;" onclick="openEditModal(<%= p.getId() %>, '<%= p.getName().replace("'", "\\'") %>', '<%= p.getBrand().replace("'", "\\'") %>', '<%= (p.getDescription() != null ? p.getDescription().replace("'", "\\'") : "") %>', <%= p.getPrice() %>, <%= p.getStock() %>, '<%= (p.getEstante() != null ? p.getEstante().replace("'", "\\'") : "") %>', '<%= (p.getFila() != null ? p.getFila().replace("'", "\\'") : "") %>', <%= p.getMinimoProgramado() %>, '<%= (p.getMotorcycleBrand() != null ? p.getMotorcycleBrand() : "") %>', '<%= (p.getMotorcycleModel() != null ? p.getMotorcycleModel() : "") %>', '<%= (p.getPartCategory() != null ? p.getPartCategory() : "") %>')" title="Editar">
                                                    <i class="bi bi-pencil-fill fs-5"></i>
                                                </button>
                                                <form action="inventory" method="POST" class="d-inline" onsubmit="return confirm('Seguro que desea eliminar el producto <%= p.getName().replace("'", "\\'") %>?');">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="id" value="<%= p.getId() %>">
                                                    <button type="submit" class="btn btn-outline-danger rounded-circle p-2 fw-bold d-flex align-items-center justify-content-center shadow-sm" style="width: 40px; height: 40px;" title="Eliminar"><i class="bi bi-trash-fill fs-5"></i></button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                    <%      }
                                        } else {
                                            out.print("<tr><td colspan='9' class='text-center text-secondary py-5 fw-bolder fs-5'><i class='bi bi-inbox fs-1 d-block mb-3'></i>El inventario está vacío.</td></tr>");
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    
                    <!-- TAB 2: Alerta de Stock -->
                    <div class="tab-pane fade p-3" id="alert-tab-pane" role="tabpanel" aria-labelledby="alert-tab" tabindex="0">
                        <div class="row g-3">
                            <!-- Columna Gris: Sin Stock -->
                            <div class="col-lg-3 col-md-6">
                                <div class="stock-column-card p-3 rounded-4 h-100 d-flex flex-column" style="min-height: 500px; border-top: 5px solid #888888 !important;">
                                    <div class="d-flex justify-content-between align-items-center mb-3">
                                        <span class="badge badge-stock-zero px-3 py-2 rounded-pill fw-bold fs-6 d-inline-flex align-items-center">
                                            <span class="stock-dot-zero me-2"></span> Sin Stock
                                        </span>
                                        <span class="badge bg-secondary rounded-pill text-white fw-bold"><%= countZero %></span>
                                    </div>
                                    <div class="d-flex flex-column gap-3 overflow-auto flex-grow-1" style="max-height: 52vh;">
                                        <% 
                                            boolean hasZero = false;
                                            if(productsList != null) {
                                                for(Product p : productsList) {
                                                    if(p.getStock() == 0) {
                                                        hasZero = true;
                                                        String img = (p.getImageUrl() != null && !p.getImageUrl().isEmpty()) ? p.getImageUrl() : "https://via.placeholder.com/50x50?text=No+Img";
                                        %>
                                                        <div class="card p-3 border-0 shadow-sm position-relative" style="background: var(--card-bg); border-radius: 12px; border-left: 4px solid #888888 !important; box-shadow: 0 4px 15px rgba(0,0,0,0.15) !important;">
                                                            <div class="d-flex align-items-center gap-3 mb-2">
                                                                <img src="<%= img %>" width="40" height="40" class="rounded-2 shadow-sm" style="object-fit: cover;">
                                                                <div class="min-w-0">
                                                                    <h6 class="fw-bolder mb-1 text-truncate text-white" title="<%= p.getName() %>" style="font-size: 0.95rem;"><%= p.getName() %></h6>
                                                                    <div class="d-flex align-items-center gap-2">
                                                                        <span class="badge bg-secondary bg-opacity-25 text-light border border-secondary border-opacity-50 py-0 px-2 fw-semibold" style="font-size: 0.72rem;"><%= p.getBrand() %></span>
                                                                        <span class="fw-bold text-muted" style="font-size: 0.8rem;">Cant: <%= p.getStock() %></span>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="text-center mt-2">
                                                                <div class="card-barcode-container">
                                                                    <svg id="barcode-card-zero-<%= p.getId() %>"></svg>
                                                                    <script>
                                                                        JsBarcode("#barcode-card-zero-<%= p.getId() %>", "<%= p.getBarcode() %>", {
                                                                            format: "CODE128",
                                                                            displayValue: true,
                                                                            height: 25,
                                                                            width: 1.1,
                                                                            fontSize: 10,
                                                                            fontOptions: "bold",
                                                                            margin: 0,
                                                                            background: "#ffffff",
                                                                            lineColor: "#000000"
                                                                        });
                                                                    </script>
                                                                </div>
                                                            </div>
                                                        </div>
                                        <% 
                                                    }
                                                }
                                            }
                                            if(!hasZero) {
                                        %>
                                            <div class="text-center text-secondary py-5 fw-semibold"><i class="bi bi-check-circle fs-3 d-block mb-2"></i>Vacío</div>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Columna Rojo: Stock Bajo -->
                            <div class="col-lg-3 col-md-6">
                                <div class="stock-column-card p-3 rounded-4 h-100 d-flex flex-column" style="min-height: 500px; border-top: 5px solid #ff4d4d !important;">
                                    <div class="d-flex justify-content-between align-items-center mb-3">
                                        <span class="badge badge-stock-low px-3 py-2 rounded-pill fw-bold fs-6 d-inline-flex align-items-center">
                                            <span class="stock-dot-low me-2"></span> Stock Bajo (<= 20)
                                        </span>
                                        <span class="badge bg-danger rounded-pill text-white fw-bold"><%= countLow %></span>
                                    </div>
                                    <div class="d-flex flex-column gap-3 overflow-auto flex-grow-1" style="max-height: 52vh;">
                                        <% 
                                            boolean hasLow = false;
                                            if(productsList != null) {
                                                for(Product p : productsList) {
                                                    if(p.getStock() > 0 && p.getStock() <= 20) {
                                                        hasLow = true;
                                                        String img = (p.getImageUrl() != null && !p.getImageUrl().isEmpty()) ? p.getImageUrl() : "https://via.placeholder.com/50x50?text=No+Img";
                                        %>
                                                        <div class="card p-3 border-0 shadow-sm position-relative" style="background: var(--card-bg); border-radius: 12px; border-left: 4px solid #ff4d4d !important; box-shadow: 0 4px 15px rgba(0,0,0,0.15) !important;">
                                                            <div class="d-flex align-items-center gap-3 mb-2">
                                                                <img src="<%= img %>" width="40" height="40" class="rounded-2 shadow-sm" style="object-fit: cover;">
                                                                <div class="min-w-0">
                                                                    <h6 class="fw-bolder mb-1 text-truncate text-white" title="<%= p.getName() %>" style="font-size: 0.95rem;"><%= p.getName() %></h6>
                                                                    <div class="d-flex align-items-center gap-2">
                                                                        <span class="badge bg-secondary bg-opacity-25 text-light border border-secondary border-opacity-50 py-0 px-2 fw-semibold" style="font-size: 0.72rem;"><%= p.getBrand() %></span>
                                                                        <span class="fw-bold text-danger" style="font-size: 0.8rem;">Cant: <%= p.getStock() %></span>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="text-center mt-2">
                                                                <div class="card-barcode-container">
                                                                    <svg id="barcode-card-low-<%= p.getId() %>"></svg>
                                                                    <script>
                                                                        JsBarcode("#barcode-card-low-<%= p.getId() %>", "<%= p.getBarcode() %>", {
                                                                            format: "CODE128",
                                                                            displayValue: true,
                                                                            height: 25,
                                                                            width: 1.1,
                                                                            fontSize: 10,
                                                                            fontOptions: "bold",
                                                                            margin: 0,
                                                                            background: "#ffffff",
                                                                            lineColor: "#000000"
                                                                        });
                                                                    </script>
                                                                </div>
                                                            </div>
                                                        </div>
                                        <% 
                                                    }
                                                }
                                            }
                                            if(!hasLow) {
                                        %>
                                            <div class="text-center text-secondary py-5 fw-semibold"><i class="bi bi-check-circle fs-3 d-block mb-2"></i>Vacío</div>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Columna Anaranjado: Stock Medio -->
                            <div class="col-lg-3 col-md-6">
                                <div class="stock-column-card p-3 rounded-4 h-100 d-flex flex-column" style="min-height: 500px; border-top: 5px solid #ff8c00 !important;">
                                    <div class="d-flex justify-content-between align-items-center mb-3">
                                        <span class="badge badge-stock-medium px-3 py-2 rounded-pill fw-bold fs-6 d-inline-flex align-items-center">
                                            <span class="stock-dot-medium me-2"></span> Stock Medio (21-50)
                                        </span>
                                        <span class="badge rounded-pill text-white fw-bold" style="background-color: #ff8c00;"><%= countMedium %></span>
                                    </div>
                                    <div class="d-flex flex-column gap-3 overflow-auto flex-grow-1" style="max-height: 52vh;">
                                        <% 
                                            boolean hasMedium = false;
                                            if(productsList != null) {
                                                for(Product p : productsList) {
                                                    if(p.getStock() >= 21 && p.getStock() <= 50) {
                                                        hasMedium = true;
                                                        String img = (p.getImageUrl() != null && !p.getImageUrl().isEmpty()) ? p.getImageUrl() : "https://via.placeholder.com/50x50?text=No+Img";
                                        %>
                                                        <div class="card p-3 border-0 shadow-sm position-relative" style="background: var(--card-bg); border-radius: 12px; border-left: 4px solid #ff8c00 !important; box-shadow: 0 4px 15px rgba(0,0,0,0.15) !important;">
                                                            <div class="d-flex align-items-center gap-3 mb-2">
                                                                <img src="<%= img %>" width="40" height="40" class="rounded-2 shadow-sm" style="object-fit: cover;">
                                                                <div class="min-w-0">
                                                                    <h6 class="fw-bolder mb-1 text-truncate text-white" title="<%= p.getName() %>" style="font-size: 0.95rem;"><%= p.getName() %></h6>
                                                                    <div class="d-flex align-items-center gap-2">
                                                                        <span class="badge bg-secondary bg-opacity-25 text-light border border-secondary border-opacity-50 py-0 px-2 fw-semibold" style="font-size: 0.72rem;"><%= p.getBrand() %></span>
                                                                        <span class="fw-bold text-warning" style="font-size: 0.8rem;">Cant: <%= p.getStock() %></span>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="text-center mt-2">
                                                                <div class="card-barcode-container">
                                                                    <svg id="barcode-card-med-<%= p.getId() %>"></svg>
                                                                    <script>
                                                                        JsBarcode("#barcode-card-med-<%= p.getId() %>", "<%= p.getBarcode() %>", {
                                                                            format: "CODE128",
                                                                            displayValue: true,
                                                                            height: 25,
                                                                            width: 1.1,
                                                                            fontSize: 10,
                                                                            fontOptions: "bold",
                                                                            margin: 0,
                                                                            background: "#ffffff",
                                                                            lineColor: "#000000"
                                                                        });
                                                                    </script>
                                                                </div>
                                                            </div>
                                                        </div>
                                        <% 
                                                    }
                                                }
                                            }
                                            if(!hasMedium) {
                                        %>
                                            <div class="text-center text-secondary py-5 fw-semibold"><i class="bi bi-check-circle fs-3 d-block mb-2"></i>Vacío</div>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Columna Verde: Con Stock -->
                            <div class="col-lg-3 col-md-6">
                                <div class="stock-column-card p-3 rounded-4 h-100 d-flex flex-column" style="min-height: 500px; border-top: 5px solid #28a745 !important;">
                                    <div class="d-flex justify-content-between align-items-center mb-3">
                                        <span class="badge badge-stock-high px-3 py-2 rounded-pill fw-bold fs-6 d-inline-flex align-items-center">
                                            <span class="stock-dot-high me-2"></span> Con Stock (> 50)
                                        </span>
                                        <span class="badge bg-success rounded-pill text-white fw-bold"><%= countHigh %></span>
                                    </div>
                                    <div class="d-flex flex-column gap-3 overflow-auto flex-grow-1" style="max-height: 52vh;">
                                        <% 
                                            boolean hasHigh = false;
                                            if(productsList != null) {
                                                for(Product p : productsList) {
                                                    if(p.getStock() > 50) {
                                                        hasHigh = true;
                                                        String img = (p.getImageUrl() != null && !p.getImageUrl().isEmpty()) ? p.getImageUrl() : "https://via.placeholder.com/50x50?text=No+Img";
                                        %>
                                                        <div class="card p-3 border-0 shadow-sm position-relative" style="background: var(--card-bg); border-radius: 12px; border-left: 4px solid #28a745 !important; box-shadow: 0 4px 15px rgba(0,0,0,0.15) !important;">
                                                            <div class="d-flex align-items-center gap-3 mb-2">
                                                                <img src="<%= img %>" width="40" height="40" class="rounded-2 shadow-sm" style="object-fit: cover;">
                                                                <div class="min-w-0">
                                                                    <h6 class="fw-bolder mb-1 text-truncate text-white" title="<%= p.getName() %>" style="font-size: 0.95rem;"><%= p.getName() %></h6>
                                                                    <div class="d-flex align-items-center gap-2">
                                                                        <span class="badge bg-secondary bg-opacity-25 text-light border border-secondary border-opacity-50 py-0 px-2 fw-semibold" style="font-size: 0.72rem;"><%= p.getBrand() %></span>
                                                                        <span class="fw-bold text-success" style="font-size: 0.8rem;">Cant: <%= p.getStock() %></span>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="text-center mt-2">
                                                                <div class="card-barcode-container">
                                                                    <svg id="barcode-card-high-<%= p.getId() %>"></svg>
                                                                    <script>
                                                                        JsBarcode("#barcode-card-high-<%= p.getId() %>", "<%= p.getBarcode() %>", {
                                                                            format: "CODE128",
                                                                            displayValue: true,
                                                                            height: 25,
                                                                            width: 1.1,
                                                                            fontSize: 10,
                                                                            fontOptions: "bold",
                                                                            margin: 0,
                                                                            background: "#ffffff",
                                                                            lineColor: "#000000"
                                                                        });
                                                                    </script>
                                                                </div>
                                                            </div>
                                                        </div>
                                        <% 
                                                    }
                                                }
                                            }
                                            if(!hasHigh) {
                                        %>
                                            <div class="text-center text-secondary py-5 fw-semibold"><i class="bi bi-check-circle fs-3 d-block mb-2"></i>Vacío</div>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div></div>
</div>
<!-- Modal Nuevo Producto -->
<div class="modal fade" id="newProductModal" tabindex="-1" aria-labelledby="newProductModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-secondary shadow-lg">
      <div class="modal-header border-secondary pb-3">
        <h5 class="modal-title text-accent fw-bolder fs-4" id="newProductModalLabel">
            <i class="bi bi-plus-circle-fill me-2"></i> Nuevo Producto
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter: var(--close-btn-filter);"></button>
      </div>
      <form action="inventory" method="POST" enctype="multipart/form-data">
          <div class="modal-body p-4">
              <div class="mb-3">
                  <label class="form-label">Nombre del Repuesto</label>
                  <input type="text" name="name" class="form-control" placeholder="Ej. Filtro de Aceite" required>
              </div>
              <div class="mb-3">
                  <label class="form-label">Marca (Repuesto)</label>
                  <input type="text" name="brand" class="form-control" placeholder="Ej. Yamaha" required>
              </div>
              
              <!-- Categoría y Moto -->
              <div class="mb-3">
                  <label class="form-label text-warning">Categoría de Repuesto</label>
                  <select name="part_category" id="partCategoryNew" class="form-control" required>
                      <option value="">Seleccione una categoría...</option>
                  </select>
              </div>
              <div class="row g-2 mb-3">
                  <div class="col-6">
                      <label class="form-label text-warning">Marca de Moto</label>
                      <select name="motorcycle_brand" id="motoBrandNew" class="form-control" onchange="updateModels('motoBrandNew', 'motoModelNew')" required>
                          <option value="">Seleccione marca...</option>
                      </select>
                  </div>
                  <div class="col-6">
                      <label class="form-label text-warning">Modelo de Moto</label>
                      <select name="motorcycle_model" id="motoModelNew" class="form-control" required>
                          <option value="">Seleccione modelo...</option>
                      </select>
                  </div>
              </div>

              <div class="mb-3">
                  <label class="form-label">Descripción (Opcional)</label>
                  <textarea name="description" class="form-control" rows="2" placeholder="Detalles del producto..."></textarea>
              </div>
              
              <div class="row g-2 mb-3">
                  <div class="col-6">
                      <label class="form-label">Precio ($)</label>
                      <input type="number" step="0.01" name="price" class="form-control" placeholder="0.00" required>
                  </div>
                  <div class="col-6">
                      <label class="form-label">Stock Inicial</label>
                      <input type="number" name="stock" class="form-control" placeholder="0" required>
                  </div>
              </div>
              
              <div class="row g-2 mb-3">
                  <div class="col-6">
                      <label class="form-label">Estante</label>
                      <input type="text" name="estante" class="form-control" placeholder="Ej. A">
                  </div>
                  <div class="col-6">
                      <label class="form-label">Fila</label>
                      <input type="text" name="fila" class="form-control" placeholder="Ej. 1">
                  </div>
              </div>
              
              <div class="mb-3">
                  <label class="form-label">Mínimo Programado</label>
                  <input type="number" name="minimo_programado" class="form-control" value="5" required>
              </div>
              
              <div class="mb-3">
                  <label class="form-label">Código de Barras</label>
                  <input type="text" name="barcode" class="form-control" placeholder="Vacío para autogenerar">
              </div>
              
              <div class="mb-4">
                  <label class="form-label">Imagen del Repuesto</label>
                  <input type="file" name="image" class="form-control" accept=".jpg,.jpeg">
                  <small class="text-muted mt-2 d-block fw-bold" style="font-size: 0.85rem;">Solo formatos: JPG, JPEG.</small>
              </div>
          </div>
          <div class="modal-footer border-secondary pt-3">
            <button type="button" class="btn btn-outline-secondary rounded-pill fw-bold px-4 py-2" data-bs-dismiss="modal">Cancelar</button>
            <button type="submit" class="btn btn-accent rounded-pill fw-bolder px-4 py-2">Guardar Producto</button>
          </div>
      </form>
    </div>
  </div>
</div>

<div class="modal fade" id="editModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-secondary shadow-lg">
      <div class="modal-header border-secondary pb-3">
        <h5 class="modal-title text-accent fw-bolder fs-4"><i class="bi bi-pencil-square me-2"></i><fmt:message key="inventory.edit_title" /></h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter: var(--close-btn-filter);"></button>
      </div>
      <form action="inventory" method="POST" enctype="multipart/form-data">
          <div class="modal-body p-4">
              <input type="hidden" name="action" value="edit">
              <input type="hidden" name="id" id="editId">
              <div class="mb-3">
                  <label class="form-label"><fmt:message key="inventory.part_name" /></label>
                  <input type="text" name="name" id="editName" class="form-control" required>
              </div>
              <div class="mb-3">
                  <label class="form-label"><fmt:message key="inventory.part_brand" /></label>
                  <input type="text" name="brand" id="editBrand" class="form-control" required>
              </div>

              <!-- EDITAR CAMPOS: Filtro por Moto y Categoria -->
              <div class="mb-3">
                  <label class="form-label text-warning"><fmt:message key="inventory.category" /></label>
                  <select name="part_category" id="partCategoryEdit" class="form-control" required>
                      <option value=""><fmt:message key="inventory.sel_category" /></option>
                  </select>
              </div>
              <div class="row g-2 mb-3">
                  <div class="col-6">
                      <label class="form-label text-warning"><fmt:message key="inventory.moto_brand" /></label>
                      <select name="motorcycle_brand" id="motoBrandEdit" class="form-control" onchange="updateModels('motoBrandEdit', 'motoModelEdit')" required>
                          <option value=""><fmt:message key="inventory.sel_moto_brand" /></option>
                      </select>
                  </div>
                  <div class="col-6">
                      <label class="form-label text-warning"><fmt:message key="inventory.moto_model" /></label>
                      <select name="motorcycle_model" id="motoModelEdit" class="form-control" required>
                          <option value=""><fmt:message key="inventory.sel_moto_model" /></option>
                      </select>
                  </div>
              </div>
              <!-- FIN EDITAR CAMPOS -->

              <div class="mb-3">
                  <label class="form-label"><fmt:message key="inventory.edit_desc" /></label>
                  <textarea name="description" id="editDesc" class="form-control" rows="2"></textarea>
              </div>
              <div class="row g-3 mb-3">
                  <div class="col-6">
                      <label class="form-label"><fmt:message key="inventory.price" /></label>
                      <input type="number" step="0.01" name="price" id="editPrice" class="form-control" required>
                  </div>
                  <div class="col-6">
                      <label class="form-label"><fmt:message key="inventory.cur_stock" /></label>
                      <input type="number" name="stock" id="editStock" class="form-control" required>
                  </div>
              </div>
              <div class="row g-3 mb-3">
                  <div class="col-6">
                      <label class="form-label"><fmt:message key="inventory.shelf" /></label>
                      <input type="text" name="estante" id="editEstante" class="form-control">
                  </div>
                  <div class="col-6">
                      <label class="form-label"><fmt:message key="inventory.row" /></label>
                      <input type="text" name="fila" id="editFila" class="form-control">
                  </div>
              </div>
              <div class="mb-3">
                  <label class="form-label"><fmt:message key="inventory.min_prog" /></label>
                  <input type="number" name="minimo_programado" id="editMinimoProgramado" class="form-control" required>
              </div>
              <div class="mb-4">
                  <label class="form-label"><fmt:message key="inventory.upd_image" /></label>
                  <input type="file" name="image" class="form-control" accept=".jpg,.jpeg">
              </div>
          </div>
          <div class="modal-footer border-secondary pt-3">
            <button type="button" class="btn btn-outline-secondary rounded-pill fw-bold px-4 py-2" data-bs-dismiss="modal"><fmt:message key="inventory.cancel" /></button>
            <button type="submit" class="btn btn-accent rounded-pill fw-bolder px-4 py-2"><fmt:message key="inventory.save_changes" /></button>
          </div>
      </form>
    </div>
  </div>
</div>

<div class="modal fade" id="massUploadModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered modal-lg">
    <div class="modal-content border-secondary shadow-lg">
      <div class="modal-header border-secondary pb-3">
        <h5 class="modal-title text-accent fw-bolder fs-4"><i class="bi bi-file-earmark-spreadsheet-fill me-2"></i><fmt:message key="inventory.mass_title" /></h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter: var(--close-btn-filter);"></button>
      </div>
      <div class="modal-body p-4 p-md-5">
          <div class="alert alert-info bg-opacity-10 border-info border-opacity-25 text-info mb-4 rounded-4 p-4 shadow-sm">
              <div class="d-flex align-items-center mb-3">
                  <i class="bi bi-info-circle-fill fs-3 me-3"></i>
                  <h5 class="fw-bolder mb-0"><fmt:message key="inventory.inst_title" /></h5>
              </div>
              <p class="fw-medium mb-3 fs-6"><fmt:message key="inventory.inst_p1" /></p>
              
              <div class="bg-dark bg-opacity-50 p-3 rounded-3 mb-4 border border-info border-opacity-25">
                  <span class="d-block fw-bold text-white mb-2 small"><fmt:message key="inventory.col_order" /></span>
                  <code class="fs-6" style="color: #00e5ff; font-weight: 700; word-break: break-all;">Nombre, Marca, Descripcion, Precio, Stock, Estante, Fila, MinimoProgramado, CodigoBarras</code>
              </div>
              
              <div class="d-flex flex-column flex-md-row align-items-center justify-content-between gap-3 bg-dark bg-opacity-25 p-4 rounded-4 border border-secondary border-opacity-50 shadow-inner">
                  <div class="d-flex align-items-center gap-3">
                      <div class="bg-info bg-opacity-10 p-3 rounded-circle text-info">
                          <i class="bi bi-filetype-csv fs-2"></i>
                      </div>
                      <div class="text-start">
                          <h6 class="mb-1 fw-bolder text-white fs-5"><fmt:message key="inventory.template_title" /></h6>
                          <span class="text-secondary fw-medium small"><fmt:message key="inventory.template_desc" /></span>
                      </div>
                  </div>
                  <button type="button" onclick="downloadTemplateCsv()" class="btn btn-outline-info rounded-pill px-4 py-2 fw-bolder shadow-sm w-100 w-md-auto">
                      <i class="bi bi-download me-2"></i> <fmt:message key="inventory.download_csv" />
                  </button>
              </div>
              
              <p class="text-muted fw-bold small mt-4 mb-0 text-center"><i class="bi bi-exclamation-triangle-fill me-1"></i> <fmt:message key="inventory.req_fields" /></p>
          </div>
          
          <form id="massUploadForm">
              <div class="mb-2">
                  <label class="form-label fs-5"><fmt:message key="inventory.sel_file" /></label>
                  <input type="file" id="csvFileInput" class="form-control form-control-lg p-3 fw-bold" accept=".csv" required>
              </div>
          </form>
      </div>
      <div class="modal-footer border-secondary pt-3 pb-4 px-4">
        <button type="button" class="btn btn-outline-secondary rounded-pill fw-bold px-4 py-2" data-bs-dismiss="modal"><fmt:message key="inventory.cancel" /></button>
        <button type="button" class="btn btn-accent rounded-pill fw-bolder px-5 py-2 fs-6 shadow-sm" onclick="uploadCsv()">
            <i class="bi bi-cloud-upload-fill me-2"></i> <fmt:message key="inventory.upload_btn" />
        </button>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
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

    const categoriesData = [
        'Llantas', 'Partes Carburador', 'Inyección', 'Bujes y Rodamientos', 
        'Frenos', 'Motor', 'Suspensión', 'Eléctrico', 'Transmisión', 
        'Chasis y Plásticos', 'Accesorios', 'Aceites y Líquidos', 'General/Otras'
    ];

    function populateSelects(brandId, catId) {
        const brandSelect = document.getElementById(brandId);
        const catSelect = document.getElementById(catId);
        
        if (brandSelect.options.length <= 1) {
            Object.keys(motoData).forEach(brand => {
                let opt = document.createElement('option');
                opt.value = brand; opt.textContent = brand;
                brandSelect.appendChild(opt);
            });
        }
        
        if (catSelect.options.length <= 1) {
            categoriesData.forEach(cat => {
                let opt = document.createElement('option');
                opt.value = cat; opt.textContent = cat;
                catSelect.appendChild(opt);
            });
        }
    }

    function updateModels(brandId, modelId, selectedModel = '') {
        const brand = document.getElementById(brandId).value;
        const modelSelect = document.getElementById(modelId);
        modelSelect.innerHTML = '<option value="">Seleccione modelo...</option>';
        if (brand && motoData[brand]) {
            motoData[brand].forEach(mod => {
                let opt = document.createElement('option');
                opt.value = mod; opt.textContent = mod;
                if (mod === selectedModel) opt.selected = true;
                modelSelect.appendChild(opt);
            });
            let genOpt = document.createElement('option');
            genOpt.value = 'Genérico / Todos'; genOpt.textContent = '<fmt:message key="inventory.generic_all" />';
            if ('Genérico / Todos' === selectedModel) genOpt.selected = true;
            modelSelect.appendChild(genOpt);
        }
    }

    function openEditModal(id, name, brand, desc, price, stock, estante, fila, minimoProgramado, motoBrand, motoModel, partCat) {
        document.getElementById('editId').value = id;
        document.getElementById('editName').value = name;
        document.getElementById('editBrand').value = brand;
        document.getElementById('editDesc').value = (desc === 'null' || !desc) ? '' : desc;
        document.getElementById('editPrice').value = price;
        document.getElementById('editStock').value = stock;
        document.getElementById('editEstante').value = (estante === 'null' || !estante) ? '' : estante;
        document.getElementById('editFila').value = (fila === 'null' || !fila) ? '' : fila;
        document.getElementById('editMinimoProgramado').value = minimoProgramado;
        
        document.getElementById('motoBrandEdit').value = motoBrand || '';
        updateModels('motoBrandEdit', 'motoModelEdit', motoModel);
        document.getElementById('partCategoryEdit').value = partCat || '';

        new bootstrap.Modal(document.getElementById('editModal')).show();
    }
    
    function uploadCsv() {
        const fileInput = document.getElementById('csvFileInput');
        if (!fileInput.files.length) {
            Swal.fire({ icon: 'warning', title: '<fmt:message key="inventory.miss_file" />', text: '<fmt:message key="inventory.miss_file_desc" />', background: document.body.classList.contains('light-mode') ? '#ffffff' : '#1e1e24', color: document.body.classList.contains('light-mode') ? '#333' : '#fff' });
            return;
        }

        const formData = new FormData();
        formData.append('csvFile', fileInput.files[0]);

        bootstrap.Modal.getInstance(document.getElementById('massUploadModal')).hide();

        Swal.fire({
            title: '<fmt:message key="inventory.processing" />',
            text: '<fmt:message key="inventory.processing_desc" />',
            allowOutsideClick: false,
            background: document.body.classList.contains('light-mode') ? '#ffffff' : '#1e1e24',
            color: document.body.classList.contains('light-mode') ? '#333' : '#fff',
            didOpen: () => { Swal.showLoading(); }
        });

        fetch('MassInventoryServlet', {
            method: 'POST',
            body: formData
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                Swal.fire({ icon: 'success', title: '<fmt:message key="inventory.upload_success" />', text: data.message, background: document.body.classList.contains('light-mode') ? '#ffffff' : '#1e1e24', color: document.body.classList.contains('light-mode') ? '#333' : '#fff' }).then(() => {
                    location.reload();
                });
            } else {
                Swal.fire({ icon: 'error', title: '<fmt:message key="inventory.error" />', text: data.message, background: document.body.classList.contains('light-mode') ? '#ffffff' : '#1e1e24', color: document.body.classList.contains('light-mode') ? '#333' : '#fff' });
            }
        })
        .catch(err => {
            Swal.fire({ icon: 'error', title: '<fmt:message key="inventory.error" />', text: '<fmt:message key="inventory.error_comm" />', background: document.body.classList.contains('light-mode') ? '#ffffff' : '#1e1e24', color: document.body.classList.contains('light-mode') ? '#333' : '#fff' });
        });
    }

    function downloadTemplateCsv() {
        const generateBarcode = () => 'PRD' + Math.random().toString(16).substring(2, 10).toUpperCase();
        
        let csvContent = "\uFEFF"; 
        csvContent += "sep=;\n"; 
        csvContent += "Nombre;Marca;Descripcion;Precio;Stock;Estante;Fila;MinimoProgramado;CodigoBarras\n";
        csvContent += `"Filtro de Aire";"Yamaha";"Filtro original";15.50;50;"A";"1";5;"\${generateBarcode()}"\n`;
        csvContent += `"Luz LED";"Philips";"Luz blanca brillante";22.00;30;"C";"4";10;"\${generateBarcode()}"\n`;
        csvContent += `"Aceite Motul";"Motul";"";12.00;100;"B";"2";10;""\n`;

        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);
        const link = document.createElement("a");
        link.setAttribute("href", url);
        link.setAttribute("download", "Plantilla_Inventario.csv");
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    document.addEventListener("DOMContentLoaded", function() {
        populateSelects('motoBrandNew', 'partCategoryNew');
        populateSelects('motoBrandEdit', 'partCategoryEdit');

        const isLight = document.body.classList.contains('light-mode');
        document.documentElement.style.setProperty('--close-btn-filter', isLight ? 'none' : 'invert(1) grayscale(100%) brightness(200%)');
    });
</script>

</body>
</html>
