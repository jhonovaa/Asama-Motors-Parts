<%@ page import="com.adso.cheng.models.User" %>
<%@ page import="com.adso.cheng.models.Product" %>
<%@ page import="com.adso.cheng.dao.ProductDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.TreeSet" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || (sessionUser.getRoleId() != 1 && sessionUser.getRoleId() != 4)) {
        response.sendRedirect("login.jsp");
        return;
    }

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
<html lang="<fmt:message key='app.lang' />">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="cashier.title" /></title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="resources/theme.css?v=6">
    <style>
        /* --- ANIMACION Y ESTILOS DEL ESCANER --- */
        @keyframes scannerPulse {
            0% { box-shadow: 0 0 0 0 var(--accent-glow); transform: scale(1); }
            70% { box-shadow: 0 0 0 20px rgba(0,0,0,0); transform: scale(1.1); }
            100% { box-shadow: 0 0 0 0 rgba(0,0,0,0); transform: scale(1); }
        }
        
        .pulse-scanner {
            animation: scannerPulse 2s infinite;
            color: var(--accent-orange) !important;
            background: rgba(128, 128, 128, 0.1);
            width: 80px;
            height: 80px;
            display: flex !important;
            align-items: center;
            justify-content: center;
            margin: 0 auto;
        }

        /* --- LEGIBILIDAD EXTREMA --- */
        .text-secondary, .text-muted {
            color: rgba(255, 255, 255, 0.75) !important;
        }
        body.light-mode .text-secondary, body.light-mode .text-muted {
            color: rgba(0, 0, 0, 0.65) !important;
        }
        
        /* Formularios consistentes */
        .form-control {
            background-color: rgba(255, 255, 255, 0.05) !important;
            color: #ffffff !important;
            border: 1px solid rgba(255, 255, 255, 0.15) !important;
            font-weight: 600;
            letter-spacing: 1px;
        }
        .form-control::placeholder {
            color: rgba(255, 255, 255, 0.3) !important;
        }
        .form-control:focus {
            background-color: rgba(255, 255, 255, 0.08) !important;
            border-color: var(--accent-orange) !important;
            box-shadow: 0 0 0 0.25rem var(--accent-glow) !important;
        }

        body.light-mode .form-control {
            background-color: #ffffff !important;
            color: #212529 !important;
            border-color: rgba(0, 0, 0, 0.15) !important;
        }
        body.light-mode .form-control::placeholder {
            color: rgba(0, 0, 0, 0.3) !important;
        }

        /* Tabla del carrito */
        .cart-table th { font-weight: 700; letter-spacing: 0.5px; font-size: 0.85rem; border-bottom: 2px solid var(--card-border); }
        .cart-table td { font-weight: 500; font-size: 0.95rem; border-bottom: 1px solid var(--card-border); vertical-align: middle; }
    </style>
</head>
<body>
<script src="resources/theme.js?v=2"></script>

<%@ include file="navbar.jsp" %>

<div class="container-fluid px-4 pb-5 mb-5" style="margin-top: 100px;">
    <div class="row g-4">
        
        <div class="col-lg-4 col-md-5">
            <div class="action-card h-100 d-flex flex-column text-center p-4 p-xl-5">
                <div class="flex-grow-1 d-flex flex-column justify-content-center">
                    <div class="pulse-scanner rounded-circle mb-4">
                        <i class="bi bi-upc-scan fs-1"></i>
                    </div>
                    <h4 class="fw-bold mb-3"><fmt:message key="cashier.scanner_active" /></h4>
                    <p class="text-secondary small mb-4"><fmt:message key="cashier.scanner_desc" /></p>
                </div>
                
                <div class="mt-auto border-top border-secondary border-opacity-25 pt-4 text-start">
                    <label class="form-label text-secondary fw-semibold small mb-2"><i class="bi bi-keyboard me-2"></i><fmt:message key="cashier.manual_input" /></label>
                    <input type="text" id="barcodeInput" class="form-control form-control-lg text-center" placeholder="|||| |||||| ||||" autocomplete="off">
                </div>
                <div id="scanStatus" class="alert d-none mt-3 fw-bold small py-2 rounded-pill" role="alert"></div>
            </div>
        </div>
        
        <div class="col-lg-8 col-md-7">
            <div class="action-card h-100 d-flex flex-column p-4">
                <div class="d-flex justify-content-between align-items-center border-bottom border-secondary pb-3 mb-3">
                    <h4 class="fw-bold mb-0 text-accent"><i class="bi bi-cart3 me-2"></i><fmt:message key="cashier.account" /></h4>
                    <button class="btn btn-sm btn-outline-danger rounded-pill px-3" onclick="clearCart()" title="<fmt:message key='cashier.empty_cart' />"><i class="bi bi-trash"></i></button>
                </div>
                
                <div class="table-responsive flex-grow-1" style="min-height: 350px; max-height: 50vh; overflow-y: auto;">
                    <table class="table table-borderless cart-table mb-0">
                        <thead class="sticky-top" style="background: var(--card-bg);">
                            <tr>
                                <th class="text-secondary text-uppercase pb-2"><fmt:message key="cashier.th_product" /></th>
                                <th class="text-secondary text-uppercase pb-2 text-center"><fmt:message key="cashier.th_qty" /></th>
                                <th class="text-secondary text-uppercase pb-2 text-end"><fmt:message key="cashier.th_unit_price" /></th>
                                <th class="text-secondary text-uppercase pb-2 text-end"><fmt:message key="cashier.th_subtotal" /></th>
                            </tr>
                        </thead>
                        <tbody id="cartBody">
                            </tbody>
                    </table>
                </div>
                
                <div class="mt-4 pt-3 border-top border-secondary border-opacity-25">
                    <div class="d-flex justify-content-between align-items-end">
                        <div>
                            <p class="text-secondary fw-bold mb-1"><fmt:message key="cashier.total_to_pay" /></p>
                            <h2 class="mb-0 fw-bold text-accent" id="totalPrice" style="font-size: 2.5rem; letter-spacing: -1px;">$0.00</h2>
                        </div>
                        <button id="payBtn" class="btn btn-accent btn-lg rounded-pill px-5 fw-bold shadow-lg d-flex align-items-center gap-2 transition-all" disabled>
                            <i class="bi bi-cash-coin fs-4"></i> <fmt:message key="cashier.charge" />
                        </button>
                    </div>
                </div>
            </div>
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
                        <button class="btn btn-sm btn-outline-warning w-100 fw-bold" onclick="addFromSearch(<%= p.getId() %>, '<%= p.getName().replace("'", "\\'") %>', <%= p.getPrice() %>, '<%= p.getBrand() != null ? p.getBrand().replace("'", "\\'") : "Genérico" %>')">
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

<script>
    const barcodeInput = document.getElementById('barcodeInput');
    const scanStatus = document.getElementById('scanStatus');
    const cartBody = document.getElementById('cartBody');
    const totalPriceEl = document.getElementById('totalPrice');
    const payBtn = document.getElementById('payBtn');
    
    let cart = [];
    let barcodeBuffer = '';
    let barcodeTimer = null;

    // Escucha global para el escaner fisico
    document.addEventListener('keypress', function(e) {
        if(document.activeElement === barcodeInput) return;

        if (e.key === 'Enter') {
            e.preventDefault();
            if (barcodeBuffer.trim() !== '') {
                processScan(barcodeBuffer.trim());
                barcodeBuffer = '';
            } else if(cart.length > 0) {
                payBtn.click();
            }
        } else {
            barcodeBuffer += e.key;
            clearTimeout(barcodeTimer);
            barcodeTimer = setTimeout(() => { barcodeBuffer = ''; }, 200); 
        }
    });

    // Entrada manual desde el input
    barcodeInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            let barcode = this.value.trim();
            if (barcode !== "") {
                processScan(barcode);
            }
            this.value = '';
        }
    });

    function processScan(barcode) {
        fetch('cashier', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'action=scan&barcode=' + encodeURIComponent(barcode)
        })
        .then(response => response.json())
        .then(data => {
            if(data.error) {
                showStatus('<i class="bi bi-exclamation-triangle-fill me-2"></i>' + data.error, 'danger');
            } else {
                addToCart(data);
                showStatus('<i class="bi bi-check-circle-fill me-2"></i>' + data.name + ' <fmt:message key="cashier.added" />', 'success');
            }
        }).catch(err => {
            showStatus('<i class="bi bi-wifi-off me-2"></i><fmt:message key="cashier.conn_error" />', 'danger');
        });
    }

    function addToCart(product) {
        let existing = cart.find(item => item.id === product.id);
        if (existing) {
            existing.qty++;
        } else {
            product.qty = 1;
            cart.push(product);
        }
        renderCart();
    }

    function renderCart() {
        cartBody.innerHTML = '';
        let total = 0;
        
        if(cart.length === 0) {
            cartBody.innerHTML = '<tr><td colspan="4" class="text-center text-secondary py-5"><i class="bi bi-cart-x fs-1 d-block mb-3"></i><fmt:message key="cashier.waiting_items" /></td></tr>';
            totalPriceEl.innerText = '$0.00';
            payBtn.disabled = true;
            return;
        }

        cart.forEach(item => {
            let subtotal = item.qty * item.price;
            total += subtotal;
            cartBody.innerHTML +=
                '<tr>' +
                    '<td>' +
                        '<strong class="fw-bold" style="color: var(--text-color);">' + item.name + '</strong><br>' +
                        '<span class="badge border border-secondary text-secondary mt-1">' + item.brand + '</span>' +
                    '</td>' +
                    '<td class="text-center align-middle">' +
                        '<span class="badge bg-secondary bg-opacity-25 text-light border border-secondary border-opacity-25 px-3 py-2 fs-6">' + item.qty + '</span>' +
                    '</td>' +
                    '<td class="text-end align-middle fw-medium">$' + item.price.toFixed(2) + '</td>' +
                    '<td class="text-end align-middle fw-bold text-accent fs-5">$' + subtotal.toFixed(2) + '</td>' +
                '</tr>';
        });
        
        totalPriceEl.innerText = '$' + total.toFixed(2);
        payBtn.disabled = false;
    }

    function showStatus(msg, type) {
        // Adaptamos el color del alert para que no desentone con el theme
        let alertClass = type === 'success' ? 'bg-success text-success bg-opacity-10 border-success' : 'bg-danger text-danger bg-opacity-10 border-danger';
        scanStatus.className = 'alert mt-3 fw-bold small py-2 rounded-pill border ' + alertClass;
        scanStatus.innerHTML = msg;
        setTimeout(() => { scanStatus.className = 'alert d-none'; }, 2500);
    }

    function clearCart() {
        if(cart.length > 0 && confirm('<fmt:message key="cashier.empty_confirm" />')) {
            cart = [];
            renderCart();
        }
    }

    payBtn.addEventListener('click', () => {
        if(cart.length === 0) return;
        
        payBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span> <fmt:message key="cashier.processing" />';
        payBtn.disabled = true;

        let promises = cart.map(item => {
            let sub = item.qty * item.price;
            return fetch('cashier', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'action=pay&productId=' + item.id + '&quantity=' + item.qty + '&total=' + sub
            });
        });

        Promise.all(promises).then(() => {
            showStatus('<i class="bi bi-bag-check-fill me-2"></i><fmt:message key="cashier.sale_success" />', 'success');
            cart = [];
            renderCart();
            payBtn.innerHTML = '<i class="bi bi-cash-coin fs-4"></i> <fmt:message key="cashier.charge" />';
        }).catch(() => {
            alert('<fmt:message key="cashier.sale_error" />');
            payBtn.innerHTML = '<i class="bi bi-cash-coin fs-4"></i> <fmt:message key="cashier.charge" />';
            payBtn.disabled = false;
        });
    });
    
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

    function addFromSearch(id, name, price, brand) {
        addToCart({id: id, name: name, price: price, brand: brand});
        showStatus('<i class="bi bi-check-circle-fill me-2"></i>' + name + ' agregado desde búsqueda', 'success');
    }
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
