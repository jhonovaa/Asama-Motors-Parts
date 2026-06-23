<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="com.adso.cheng.models.Product" %>
<%@ page import="com.adso.cheng.dao.ProductDAO" %>
<%@ page import="com.adso.cheng.models.User" %>
<%@ page import="com.adso.cheng.models.Motorcycle" %>
<%@ page import="com.adso.cheng.dao.MotorcycleDAO" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="catalog.title" /></title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="resources/theme.css?v=6">
    <style>
        body { font-family: 'Inter', sans-serif; background-color: var(--bg-color); color: var(--text-color); padding-top: 60px;}
        .product-card {
            background: var(--card-bg);
            border-radius: 15px;
            border: 1px solid var(--card-border);
            padding: 20px;
            text-align: center;
            transition: 0.3s;
            box-shadow: 0 10px 20px rgba(0,0,0,0.3);
            height: 100%;
        }
        .product-card:hover { transform: translateY(-5px); border-color: var(--accent-orange); }
        .product-img { width: 100%; height: 200px; object-fit: cover; border-radius: 10px; margin-bottom: 15px; cursor: zoom-in; transition: transform 0.3s; }
        .product-img:hover { transform: scale(1.05); }
        .btn-moto { background-color: var(--accent-orange); color: #fff; border: none; border-radius: 30px; padding: 8px 20px; font-weight: 600; transition: 0.3s; }
        .btn-moto:hover { background-color: #E55A2B; color: white;}
        .search-bar { background: var(--card-bg); border: 1px solid var(--card-border); color: var(--text-color); border-radius: 30px; padding: 12px 20px; width: 100%; max-width: 500px; margin: 0 auto; display: block;}
        .search-bar:focus { background: var(--card-bg); color: var(--text-color); border-color: var(--accent-orange); outline: none; box-shadow: 0 0 0 3px rgba(255,107,53,0.15);}
        .text-orange { color: var(--accent-orange) !important; }
    </style>
</head>
<body>
<script src="resources/theme.js?v=2"></script>

    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg fixed-top shadow-sm" style="background: var(--nav-bg); backdrop-filter: blur(15px); border-bottom: 1px solid var(--card-border);">
        <div class="container-fluid px-4 py-2">
            <a class="navbar-brand d-flex align-items-center gap-2" href="index.jsp" style="text-decoration: none;">
                <i class="bi bi-gear-wide-connected fs-4 text-orange"></i>
                <span class="fw-bold fs-4 asama-text" style="color: var(--text-color);">Asama<span class="text-orange fw-light">MotoParts</span></span>
            </a>
            
            <button class="navbar-toggler border-0 shadow-none" type="button" data-bs-toggle="collapse" data-bs-target="#simpleNavbar" aria-controls="simpleNavbar" aria-expanded="false" aria-label="Toggle navigation">
                <i class="bi bi-list fs-1 text-orange"></i>
            </button>
            
            <div class="collapse navbar-collapse" id="simpleNavbar">
                <ul class="navbar-nav me-auto mb-2 mb-lg-0 ms-lg-4 gap-1 align-items-center">
                    <li class="nav-item">
                        <a href="catalog.jsp" class="nav-link fw-bold" style="color: var(--text-color);"><i class="bi bi-grid-3x3-gap me-2"></i>Catálogo</a>
                    </li>
                </ul>
                <div class="d-flex gap-3 align-items-center ms-lg-auto mt-3 mt-lg-0">
                    <button onclick="toggleTheme()" class="btn btn-icon rounded-circle" style="background: var(--card-bg); border: 1px solid var(--card-border); color: var(--accent-orange);" title="Cambiar tema">
                        <i id="themeIcon" class="bi bi-sun-fill fs-5"></i>
                    </button>
                    <% if(session.getAttribute("user") != null) { %>
                        <a href="dashboard.jsp" class="btn btn-moto-outline rounded-pill px-4 fw-bold">Mi Panel</a>
                    <% } else { %>
                        <a href="login.jsp" class="btn btn-accent rounded-pill px-4 fw-bold" style="color: #121417 !important;"><i class="bi bi-person-circle me-2"></i>Iniciar Sesión</a>
                    <% } %>
                </div>
            </div>
        </div>
    </nav>

    <div class="container-fluid px-lg-5" style="margin-top: 40px; margin-bottom: 50px;">
        <div class="text-center mb-4">
            <h2 class="fw-bold"><fmt:message key="catalog.header" /></h2>
            <p class="text-secondary"><fmt:message key="catalog.subtitle" /></p>
        </div>
        
        <%
            ProductDAO dao = new ProductDAO();
            List<Product> products = dao.getAllProducts();
            
            // Extract unique categories and brands
            Set<String> categories = new HashSet<>();
            Set<String> partBrands = new HashSet<>();
            for (Product p : products) {
                if (p.getPartCategory() != null && !p.getPartCategory().trim().isEmpty()) {
                    categories.add(p.getPartCategory());
                }
                if (p.getBrand() != null && !p.getBrand().trim().isEmpty()) {
                    partBrands.add(p.getBrand());
                }
            }
            
            // User's motorcycles
            User currentUser = (User) session.getAttribute("user");
            List<Motorcycle> myMotos = new java.util.ArrayList<>();
            if (currentUser != null && currentUser.getRoleId() == 5) {
                myMotos = new MotorcycleDAO().getMotorcyclesByCustomer(currentUser.getId());
            }
        %>

        <!-- Mobile Filter Button -->
        <div class="d-lg-none mb-4 text-center">
            <button class="btn btn-moto rounded-pill px-4 shadow-sm" type="button" data-bs-toggle="offcanvas" data-bs-target="#filterOffcanvas">
                <i class="bi bi-funnel-fill me-2"></i>Filtros Avanzados
            </button>
        </div>

        <div class="row g-4">
            <!-- Sidebar / Offcanvas for Filters -->
            <div class="col-lg-3">
                <div class="offcanvas-lg offcanvas-start" tabindex="-1" id="filterOffcanvas" style="background: var(--bg-color);">
                    <div class="offcanvas-header border-bottom" style="border-color: var(--card-border) !important;">
                        <h5 class="offcanvas-title fw-bold" style="color: var(--text-color);">Filtros Avanzados</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="offcanvas" data-bs-target="#filterOffcanvas" aria-label="Close"></button>
                    </div>
                    <div class="offcanvas-body d-block">
                        <div class="card w-100 border-0 shadow-sm" style="background: var(--card-bg); border: 1px solid var(--card-border) !important; border-radius: 15px;">
                            <div class="card-body p-4">
                                <h6 class="fw-bold mb-3"><i class="bi bi-search text-orange me-2"></i>Búsqueda</h6>
                                <input type="text" id="searchInput" class="form-control mb-4" placeholder="<fmt:message key='catalog.search' />" onkeyup="filterProducts()" style="background: var(--bg-color); color: var(--text-color); border: 1px solid var(--card-border); border-radius: 10px;">
                                
                                <% if (currentUser != null && currentUser.getRoleId() == 5) { %>
                                <h6 class="fw-bold mb-3"><i class="bi bi-bicycle text-orange me-2"></i>Mi Moto (Compatibles)</h6>
                                <select id="motoFilter" class="form-select mb-4" onchange="filterProducts()" style="background: var(--bg-color); color: var(--text-color); border: 1px solid var(--card-border); border-radius: 10px;">
                                    <option value="">Cualquier moto / Sin filtrar</option>
                                    <% for(Motorcycle m : myMotos) { %>
                                        <option value="<%= m.getBrand().toLowerCase() %>|<%= m.getModel().toLowerCase() %>"><%= m.getBrand() %> <%= m.getModel() %> (<%= m.getYear() %>)</option>
                                    <% } %>
                                </select>
                                <% } %>

                                <h6 class="fw-bold mb-3"><i class="bi bi-tags text-orange me-2"></i>Categoría</h6>
                                <select id="categoryFilter" class="form-select mb-4" onchange="filterProducts()" style="background: var(--bg-color); color: var(--text-color); border: 1px solid var(--card-border); border-radius: 10px;">
                                    <option value="">Todas las categorías</option>
                                    <% for(String cat : categories) { %>
                                        <option value="<%= cat %>"><%= cat %></option>
                                    <% } %>
                                </select>

                                <h6 class="fw-bold mb-3"><i class="bi bi-star text-orange me-2"></i>Marca de Repuesto</h6>
                                <select id="brandFilter" class="form-select mb-4" onchange="filterProducts()" style="background: var(--bg-color); color: var(--text-color); border: 1px solid var(--card-border); border-radius: 10px;">
                                    <option value="">Todas las marcas</option>
                                    <% for(String br : partBrands) { %>
                                        <option value="<%= br.toLowerCase() %>"><%= br %></option>
                                    <% } %>
                                </select>

                                <h6 class="fw-bold mb-3"><i class="bi bi-currency-dollar text-orange me-2"></i>Precio Máximo</h6>
                                <input type="range" class="form-range" id="priceFilter" min="10000" max="1000000" step="10000" value="1000000" oninput="updatePriceLabel(); filterProducts();">
                                <div class="text-center mt-2 fw-bold text-orange" id="priceValue">Cualquier Precio</div>
                                <button class="btn btn-outline-secondary w-100 mt-4 btn-sm rounded-pill" onclick="resetFilters()">Limpiar Filtros</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Product Grid -->
            <div class="col-lg-9">
                <div class="row g-4" id="productGrid">
                    <% for(Product p : products) { %>
                    <div class="col-md-4 product-item" 
                         data-name="<%= p.getName().toLowerCase() %>" 
                         data-brand="<%= p.getBrand() != null ? p.getBrand().toLowerCase() : "" %>"
                         data-category="<%= p.getPartCategory() != null ? p.getPartCategory() : "" %>"
                         data-moto-brand="<%= p.getMotorcycleBrand() != null ? p.getMotorcycleBrand().toLowerCase() : "" %>"
                         data-moto-model="<%= p.getMotorcycleModel() != null ? p.getMotorcycleModel().toLowerCase() : "" %>"
                         data-price="<%= p.getPrice() %>">
                <div class="product-card">
                    <% if(p.getImageUrl() != null && !p.getImageUrl().isEmpty()) { %>
                        <div style="overflow: hidden; border-radius: 10px; margin-bottom: 15px;">
                            <img src="<%= p.getImageUrl() %>" alt="<%= p.getName() %>" class="product-img mb-0" onclick="openZoomModal(this.src, '<%= p.getName() %>')">
                        </div>
                    <% } else { %>
                        <div class="product-img d-flex align-items-center justify-content-center text-secondary" style="background: var(--card-border);">
                            <i class="bi bi-tools fs-1"></i>
                        </div>
                    <% } %>
                    <h5 class="fw-bold mb-1"><%= p.getName() %></h5>
                    <p class="text-secondary small mb-2"><%= p.getBrand() != null ? p.getBrand() : "<fmt:message key='catalog.generic' />" %></p>
                    <h4 class="text-orange fw-bold mb-3">$<%= String.format("%.2f", p.getPrice()) %></h4>
                    <% if(p.getStock() > 0) { %>
                        <button class="btn btn-moto w-100" onclick="addToCart(<%= p.getId() %>, '<%= p.getName().replace("'", "\\'") %>', <%= p.getPrice() %>, <%= p.getStock() %>)"><fmt:message key="catalog.add_cart" /></button>
                    <% } else { %>
                        <button class="btn btn-secondary w-100" disabled><fmt:message key="catalog.out_of_stock" /></button>
                    <% } %>
                </div>
            </div>
            <% } %>
        </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Botón Flotante del Carrito -->
    <a href="cart.jsp" class="btn btn-moto shadow-lg d-flex align-items-center justify-content-center" style="position: fixed; bottom: 30px; right: 30px; border-radius: 50%; width: 65px; height: 65px; font-size: 28px; z-index: 1000; transition: transform 0.3s;">
        <i class="bi bi-cart3"></i>
        <span id="cartBadge" class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" style="font-size: 0.85rem; display: none;">
            0
        </span>
    </a>

    <script>
        let isLoggedIn = <%= session.getAttribute("user") != null %>;
        let roleId = <%= session.getAttribute("user") != null ? ((com.adso.cheng.models.User)session.getAttribute("user")).getRoleId() : 0 %>;
        let currentUserId = <%= session.getAttribute("user") != null ? ((com.adso.cheng.models.User)session.getAttribute("user")).getId() : -1 %>;
        let cartKey = 'asama_cart_' + currentUserId;
        let cart = isLoggedIn ? (JSON.parse(localStorage.getItem(cartKey)) || []) : [];

        function updateCartBadge() {
            let badge = document.getElementById('cartBadge');
            let totalItems = cart.reduce((sum, item) => sum + item.qty, 0);
            if(totalItems > 0) {
                badge.innerText = totalItems;
                badge.style.display = 'block';
            } else {
                badge.style.display = 'none';
            }
        }

        function addToCart(id, name, price, maxStock) {
            if (!isLoggedIn) {
                window.location.href = "login.jsp?msg=" + encodeURIComponent("<fmt:message key='catalog.login_required' />");
                return;
            }
            let item = cart.find(i => i.id === id);
            if(item) {
                if(item.qty >= maxStock) {
                    if(typeof Swal !== 'undefined') {
                        Swal.fire({ toast: true, position: 'bottom-end', icon: 'error', title: 'Stock límite alcanzado', text: 'Solo hay ' + maxStock + ' disponibles.', showConfirmButton: false, timer: 2000, background: document.body.classList.contains('light-mode') ? '#ffffff' : '#1e1e24', color: document.body.classList.contains('light-mode') ? '#333333' : '#f8f9fa' });
                    }
                    return;
                }
                item.qty++;
            } else {
                if(maxStock <= 0) return;
                cart.push({id, name, price, qty: 1});
            }
            localStorage.setItem(cartKey, JSON.stringify(cart));
            updateCartBadge();
            
            // Show a tiny toast or alert
            if(typeof Swal !== 'undefined') {
                Swal.fire({
                    toast: true, position: 'bottom-end', icon: 'success',
                    title: name + ' <fmt:message key="catalog.added" />',
                    showConfirmButton: false, timer: 1500,
                    background: document.body.classList.contains('light-mode') ? '#ffffff' : '#1e1e24',
                    color: document.body.classList.contains('light-mode') ? '#333333' : '#f8f9fa'
                });
            } else {
                alert(name + " <fmt:message key='catalog.added' />");
            }
        }

        document.addEventListener("DOMContentLoaded", function() {
            updateCartBadge();
        });

        function updatePriceLabel() {
            let val = document.getElementById('priceFilter').value;
            let label = val == 1000000 ? "Cualquier Precio" : "$" + val.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
            document.getElementById('priceValue').innerText = label;
        }

        function resetFilters() {
            document.getElementById('searchInput').value = "";
            let moto = document.getElementById('motoFilter'); if(moto) moto.value = "";
            document.getElementById('categoryFilter').value = "";
            document.getElementById('brandFilter').value = "";
            document.getElementById('priceFilter').value = "1000000";
            updatePriceLabel();
            filterProducts();
        }

        function filterProducts() {
            let input = document.getElementById('searchInput').value.toLowerCase();
            let motoSelect = document.getElementById('motoFilter');
            let selectedMoto = motoSelect ? motoSelect.value : "";
            let motoBrandFilter = selectedMoto.split('|')[0] || "";
            let motoModelFilter = selectedMoto.split('|')[1] || "";
            let categoryFilter = document.getElementById('categoryFilter').value;
            let brandFilter = document.getElementById('brandFilter').value;
            let maxPrice = parseInt(document.getElementById('priceFilter').value);

            let items = document.getElementsByClassName('product-item');
            
            for (let i = 0; i < items.length; i++) {
                let name = items[i].getAttribute('data-name');
                let brand = items[i].getAttribute('data-brand');
                let category = items[i].getAttribute('data-category');
                let pMotoBrand = items[i].getAttribute('data-moto-brand');
                let pMotoModel = items[i].getAttribute('data-moto-model');
                let price = parseFloat(items[i].getAttribute('data-price'));

                let matchesText = name.includes(input) || brand.includes(input);
                let matchesCategory = categoryFilter === "" || category === categoryFilter;
                let matchesBrand = brandFilter === "" || brand === brandFilter;
                let matchesPrice = maxPrice == 1000000 || price <= maxPrice;
                
                // Compatibilidad: Repuestos universales (sin moto asignada) o repuestos exactos para el modelo
                let isUniversal = pMotoBrand === "";
                let isCompatible = pMotoBrand === motoBrandFilter && (pMotoModel === "" || pMotoModel === motoModelFilter);
                let matchesMoto = selectedMoto === "" || isUniversal || isCompatible;

                if (matchesText && matchesCategory && matchesBrand && matchesPrice && matchesMoto) {
                    items[i].style.display = "block";
                } else {
                    items[i].style.display = "none";
                }
            }
        }

        function openZoomModal(src, title) {
            Swal.fire({
                title: title,
                imageUrl: src,
                imageAlt: title,
                width: 'auto',
                padding: '1em',
                background: 'var(--card-bg)',
                color: 'var(--text-color)',
                showConfirmButton: false,
                showCloseButton: true,
                customClass: {
                    image: 'rounded-3 shadow-lg max-w-100',
                    popup: 'border border-secondary border-opacity-25'
                }
            });
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</body>
</html>
