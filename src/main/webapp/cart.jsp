<%@ page import="com.adso.cheng.models.User" %>
<%@ page import="com.adso.cheng.models.Product" %>
<%@ page import="com.adso.cheng.dao.ProductDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.TreeSet" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    User user = (User) session.getAttribute("user");
    boolean isLoggedIn = user != null;
    int roleId = isLoggedIn ? user.getRoleId() : 0;
    
    ProductDAO dao = new ProductDAO();
    List<Product> products = dao.getAllProducts();
    Set<String> brands = new TreeSet<>();
    Set<String> categories = new TreeSet<>();
    for(Product p : products) {
        if(p.getBrand() != null && !p.getBrand().trim().isEmpty()) brands.add(p.getBrand());
        if(p.getPartCategory() != null && !p.getPartCategory().trim().isEmpty()) categories.add(p.getPartCategory());
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="cart.title" /></title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="resources/theme.css?v=6">
    <style>
        /* --- LEGIBILIDAD EXTREMA --- */
        .text-secondary, .text-muted { 
            color: rgba(255, 255, 255, 0.85) !important; 
            font-weight: 500;
        }
        body.light-mode .text-secondary, body.light-mode .text-muted { 
            color: rgba(0, 0, 0, 0.75) !important; 
            font-weight: 600;
        }

        /* Botones de Cantidad Interactivos */
        .qty-btn { 
            background: rgba(255, 255, 255, 0.1); 
            color: var(--text-color); 
            border: 1px solid rgba(255, 255, 255, 0.2); 
            width: 38px; 
            height: 38px; 
            border-radius: 10px; 
            font-weight: bold;
            font-size: 1.2rem;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }
        .qty-btn:hover { 
            background: var(--accent-orange); 
            color: #121417; 
            border-color: var(--accent-orange); 
            box-shadow: 0 0 12px var(--accent-glow);
        }
        
        body.light-mode .qty-btn {
            background: rgba(0, 0, 0, 0.05);
            border-color: rgba(0, 0, 0, 0.15);
        }

        /* Tablas: Forzar contraste sobreescribiendo Bootstrap */
        .table { 
            --bs-table-bg: transparent;
            --bs-table-color: var(--text-color);
            color: var(--text-color) !important; 
        }
        .table th { 
            font-weight: 700 !important; 
            letter-spacing: 0.5px; 
            font-size: 0.85rem; 
            border-bottom: 2px solid var(--card-border) !important; 
            color: rgba(255, 255, 255, 0.7) !important;
        }
        body.light-mode .table th {
            color: rgba(0, 0, 0, 0.6) !important;
        }
        .table td { 
            font-weight: 600 !important; 
            font-size: 1.05rem !important; 
            border-bottom: 1px solid var(--card-border) !important; 
            vertical-align: middle; 
            color: var(--text-color) !important; 
        }
        .table tbody tr:hover td { 
            background-color: rgba(255, 255, 255, 0.05) !important; 
        }
        body.light-mode .table tbody tr:hover td { 
            background-color: rgba(0, 0, 0, 0.03) !important; 
        }
    </style>
</head>
<body>
<script src="resources/theme.js"></script>

    <%@ include file="navbar.jsp" %>

    <div class="container-fluid px-4 pb-5 mb-5" style="margin-top: 100px; max-width: 1200px;">
        <div class="action-card h-100 d-flex flex-column p-4 p-md-5">
            <div class="border-bottom border-secondary pb-3 mb-4 d-flex align-items-center">
                <div class="brand-icon me-3" style="width: 55px; height: 55px; font-size: 26px; background-color: var(--accent-orange); color: #121417; border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 15px var(--accent-glow);">
                    <i class="bi bi-cart3"></i>
                </div>
                <h3 class="fw-bold mb-0 text-accent"><fmt:message key="cart.header" /></h3>
            </div>
            
            <div id="cartContent" class="flex-grow-1">
                <div class="table-responsive pe-2" style="max-height: 55vh; overflow-y: auto;">
                    <table class="table table-hover align-middle table-borderless mb-0">
                        <thead class="sticky-top" style="background: var(--card-bg); z-index: 10;">
                            <tr>
                                <th class="text-uppercase pb-3"><fmt:message key="cart.th.product" /></th>
                                <th class="text-uppercase pb-3"><fmt:message key="cart.th.price" /></th>
                                <th class="text-uppercase pb-3 text-center"><fmt:message key="cart.th.quantity" /></th>
                                <th class="text-uppercase pb-3 text-end"><fmt:message key="cart.th.subtotal" /></th>
                                <th class="text-uppercase pb-3 text-center"><fmt:message key="cart.th.remove" /></th>
                            </tr>
                        </thead>
                        <tbody id="cartItems">
                            </tbody>
                    </table>
                </div>
                
                <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center mt-5 pt-4 border-top border-secondary border-opacity-50">
                    <div class="mb-4 mb-md-0">
                        <p class="text-secondary fw-bold mb-1 fs-5"><fmt:message key="cart.total_to_pay" /></p>
                        <h2 class="fw-bolder mb-0 text-accent" style="font-size: 2.5rem; letter-spacing: -1px;" id="cartTotal">$0.00</h2>
                    </div>
                    <button class="btn btn-accent rounded-pill fw-bold px-5 py-3 fs-5 shadow-lg d-flex align-items-center gap-2 transition-all justify-content-center" onclick="processCheckout()">
                        <i class="bi bi-credit-card-fill"></i> <fmt:message key="cart.proceed_checkout" />
                    </button>
                </div>
            </div>
            
            <div id="emptyCart" style="display: none;" class="text-center py-5 my-4">
                <div class="mx-auto mb-4" style="width: 120px; height: 120px; background: rgba(255,255,255,0.05); border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: inset 0 0 20px rgba(0,0,0,0.2);">
                    <i class="bi bi-cart-x text-secondary" style="font-size: 4rem;"></i>
                </div>
                <h3 class="fw-bold mb-3"><fmt:message key="cart.empty_title" /></h3>
                <p class="text-secondary fs-5 mb-5 fw-medium"><fmt:message key="cart.empty_text" /></p>
                <a href="catalog.jsp" class="btn btn-moto-outline rounded-pill px-5 py-3 fw-bold fs-5">
                    <i class="bi bi-search me-2"></i> <fmt:message key="cart.explore_catalog" />
                </a>
            </div>
        </div>
    </div>

    <!-- Floating Action Button for Advanced Search -->
    <button class="btn btn-warning rounded-circle shadow-lg" type="button" data-bs-toggle="offcanvas" data-bs-target="#advancedSearchOffcanvas" style="position: fixed; bottom: 30px; right: 30px; width: 65px; height: 65px; font-size: 24px; z-index: 1040;">
        <i class="bi bi-search"></i>
    </button>

    <!-- Advanced Search Offcanvas -->
    <div class="offcanvas offcanvas-end" tabindex="-1" id="advancedSearchOffcanvas" aria-labelledby="advancedSearchOffcanvasLabel" style="width: 450px; background-color: var(--bg-color); color: var(--text-color);">
        <div class="offcanvas-header border-bottom border-secondary border-opacity-25">
            <h5 class="offcanvas-title fw-bold" id="advancedSearchOffcanvasLabel"><i class="bi bi-funnel-fill text-orange me-2"></i> Búsqueda Avanzada</h5>
            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="offcanvas" aria-label="Close"></button>
        </div>
        <div class="offcanvas-body">
            <div class="mb-3">
                <input type="text" id="advSearchText" class="form-control" placeholder="Buscar por nombre o descripción..." onkeyup="applyAdvancedFilters()">
            </div>
            <div class="row g-2 mb-3">
                <div class="col-6">
                    <select id="advSearchBrand" class="form-select" onchange="applyAdvancedFilters()">
                        <option value="">Todas las Marcas</option>
                        <% for(String b : brands) { %>
                            <option value="<%= b.toLowerCase() %>"><%= b %></option>
                        <% } %>
                    </select>
                </div>
                <div class="col-6">
                    <select id="advSearchCategory" class="form-select" onchange="applyAdvancedFilters()">
                        <option value="">Todas las Categorías</option>
                        <% for(String c : categories) { %>
                            <option value="<%= c.toLowerCase() %>"><%= c %></option>
                        <% } %>
                    </select>
                </div>
            </div>
            <div class="mb-4">
                <label class="form-label text-secondary small">Precio Máximo: $<span id="advPriceLabel">2000000</span></label>
                <input type="range" class="form-range" id="advSearchPrice" min="0" max="2000000" step="10000" value="2000000" oninput="document.getElementById('advPriceLabel').innerText = this.value; applyAdvancedFilters()">
            </div>

            <h6 class="fw-bold mb-3 border-bottom border-secondary border-opacity-25 pb-2">Resultados</h6>
            
            <div id="advSearchResults" class="d-flex flex-column gap-3">
                <% for(Product p : products) { %>
                <div class="card bg-transparent border border-secondary border-opacity-25 adv-product-item" 
                     data-name="<%= p.getName() != null ? p.getName().toLowerCase() : "" %>" 
                     data-desc="<%= p.getDescription() != null ? p.getDescription().toLowerCase() : "" %>" 
                     data-brand="<%= p.getBrand() != null ? p.getBrand().toLowerCase() : "" %>" 
                     data-category="<%= p.getPartCategory() != null ? p.getPartCategory().toLowerCase() : "" %>" 
                     data-price="<%= p.getPrice() %>">
                    <div class="card-body p-3">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <h6 class="fw-bold m-0" style="max-width: 75%;"><%= p.getName() %></h6>
                            <span class="badge bg-secondary"><%= p.getBrand() != null ? p.getBrand() : "Genérico" %></span>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <h5 class="text-orange fw-bold m-0">$<%= String.format("%.2f", p.getPrice()) %></h5>
                            <small class="<%= p.getStock() > 0 ? "text-success" : "text-danger" %> fw-bold"><%= p.getStock() %> en stock</small>
                        </div>
                        <div class="text-secondary small mb-3">
                            <i class="bi bi-tag-fill"></i> <%= p.getPartCategory() != null ? p.getPartCategory() : "Sin Categoría" %> <br>
                            <i class="bi bi-geo-alt-fill"></i> Ubicación: Estante <%= p.getEstante() != null && !p.getEstante().isEmpty() ? p.getEstante() : "N/A" %> - Fila <%= p.getFila() != null && !p.getFila().isEmpty() ? p.getFila() : "N/A" %>
                        </div>
                        <% if(p.getStock() > 0) { %>
                            <button class="btn btn-sm btn-outline-warning w-100 fw-bold" onclick="addFromSearch(<%= p.getId() %>, '<%= p.getName().replace("'", "\\'") %>', <%= p.getPrice() %>)">
                                <i class="bi bi-cart-plus"></i> Añadir
                            </button>
                        <% } else { %>
                            <button class="btn btn-sm btn-secondary w-100" disabled>Agotado</button>
                        <% } %>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        let isLoggedIn = <%= isLoggedIn %>;
        let roleId = <%= roleId %>;
        let currentUserId = <%= session.getAttribute("user") != null ? ((com.adso.cheng.models.User)session.getAttribute("user")).getId() : -1 %>;
        if (!isLoggedIn) {
            window.location.href = "login.jsp?msg=" + encodeURIComponent("<fmt:message key='cart.login_required' />");
        }
        let cartKey = 'asama_cart_' + currentUserId;
        let cart = isLoggedIn ? (JSON.parse(localStorage.getItem(cartKey)) || []) : [];

        // Set Light/Dark colors for SweetAlert
        const getSwalBg = () => document.body.classList.contains('light-mode') ? '#ffffff' : '#1e1e24';
        const getSwalColor = () => document.body.classList.contains('light-mode') ? '#333333' : '#f8f9fa';

        function renderCart() {
            let tbody = document.getElementById('cartItems');
            let contentDiv = document.getElementById('cartContent');
            let emptyDiv = document.getElementById('emptyCart');
            let totalSpan = document.getElementById('cartTotal');
            
            if(cart.length === 0) {
                contentDiv.style.display = 'none';
                emptyDiv.style.display = 'block';
                return;
            }
            
            contentDiv.style.display = 'block';
            emptyDiv.style.display = 'none';
            
            tbody.innerHTML = '';
            let total = 0;
            
            cart.forEach((item, index) => {
                let subtotal = item.price * item.qty;
                total += subtotal;
                
                let tr = document.createElement('tr');
                tr.innerHTML = 
                    '<td class="fw-bold text-wrap" style="max-width: 250px;">' + item.name + '</td>' +
                    '<td class="fw-medium">$' + item.price.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) + '</td>' +
                    '<td class="text-center">' +
                        '<div class="d-inline-flex align-items-center bg-dark bg-opacity-25 rounded-3 p-1 border border-secondary border-opacity-25">' +
                            '<button class="qty-btn" onclick="updateQty(' + index + ', -1)">-</button>' +
                            '<span class="mx-3 fw-bolder fs-5 text-accent" style="min-width: 20px;">' + item.qty + '</span>' +
                            '<button class="qty-btn" onclick="updateQty(' + index + ', 1)">+</button>' +
                        '</div>' +
                    '</td>' +
                    '<td class="fw-bolder text-accent fs-5 text-end">$' + subtotal.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) + '</td>' +
                    '<td class="text-center">' +
                        '<button class="btn btn-sm btn-outline-danger rounded-pill px-3 py-2 fw-bold" onclick="removeFromCart(' + index + ')" title="<fmt:message key="cart.remove" />">' +
                            '<i class="bi bi-trash-fill"></i>' +
                        '</button>' +
                    '</td>';
                tbody.appendChild(tr);
            });
            
            totalSpan.innerText = '$' + total.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        }

        function updateQty(index, change) {
            cart[index].qty += change;
            if(cart[index].qty <= 0) {
                removeFromCart(index);
                return;
            }
            localStorage.setItem(cartKey, JSON.stringify(cart));
            renderCart();
        }

        function removeFromCart(index) {
            cart.splice(index, 1);
            localStorage.setItem(cartKey, JSON.stringify(cart));
            renderCart();
        }

        function processCheckout() {
            if(!isLoggedIn) {
                window.location.href = 'login.jsp';
                return;
            }
            if(roleId !== 5) {
                Swal.fire({
                    icon: 'warning',
                    title: '<fmt:message key="cart.restricted_access_title" />',
                    text: '<fmt:message key="cart.restricted_access_text" />',
                    confirmButtonColor: getComputedStyle(document.documentElement).getPropertyValue('--accent-orange').trim() || '#FF6B35',
                    background: getSwalBg(),
                    color: getSwalColor()
                });
                return;
            }
            window.location.href = 'checkout.jsp';
        }

        // Renderizado inicial
        renderCart();

        function applyAdvancedFilters() {
            let text = document.getElementById('advSearchText').value.toLowerCase();
            let brand = document.getElementById('advSearchBrand').value;
            let category = document.getElementById('advSearchCategory').value;
            let maxPrice = parseFloat(document.getElementById('advSearchPrice').value);
            
            let items = document.getElementsByClassName('adv-product-item');
            for(let i=0; i<items.length; i++) {
                let el = items[i];
                let pName = el.getAttribute('data-name');
                let pDesc = el.getAttribute('data-desc');
                let pBrand = el.getAttribute('data-brand');
                let pCategory = el.getAttribute('data-category');
                let pPrice = parseFloat(el.getAttribute('data-price'));
                
                let matchText = (pName.includes(text) || pDesc.includes(text));
                let matchBrand = (brand === "" || pBrand === brand);
                let matchCategory = (category === "" || pCategory === category);
                let matchPrice = (pPrice <= maxPrice);
                
                if(matchText && matchBrand && matchCategory && matchPrice) {
                    el.style.display = 'block';
                } else {
                    el.style.display = 'none';
                }
            }
        }

        function addFromSearch(id, name, price) {
            let existing = cart.find(i => i.id === id);
            if(existing) {
                existing.qty++;
            } else {
                cart.push({id: id, name: name, price: price, qty: 1});
            }
            localStorage.setItem(cartKey, JSON.stringify(cart));
            renderCart();
            
            if(typeof Swal !== 'undefined') {
                Swal.fire({
                    toast: true, position: 'bottom-end', icon: 'success',
                    title: name + ' añadido al carrito',
                    showConfirmButton: false, timer: 1500,
                    background: getSwalBg(), color: getSwalColor()
                });
            }
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>