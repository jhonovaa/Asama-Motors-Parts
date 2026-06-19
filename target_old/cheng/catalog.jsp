<%@ page import="java.util.List" %>
<%@ page import="com.adso.cheng.models.Product" %>
<%@ page import="com.adso.cheng.dao.ProductDAO" %>
<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Catálogo - Asama Moto Parts</title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
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
        .product-img { width: 100%; height: 200px; object-fit: cover; border-radius: 10px; margin-bottom: 15px; }
        .btn-moto { background-color: var(--accent-orange); color: #fff; border: none; border-radius: 30px; padding: 8px 20px; font-weight: 600; transition: 0.3s; }
        .btn-moto:hover { background-color: #E55A2B; color: white;}
        .search-bar { background: var(--card-bg); border: 1px solid var(--card-border); color: var(--text-color); border-radius: 30px; padding: 12px 20px; width: 100%; max-width: 500px; margin: 0 auto; display: block;}
        .search-bar:focus { background: var(--card-bg); color: var(--text-color); border-color: var(--accent-orange); outline: none; box-shadow: 0 0 0 3px rgba(255,107,53,0.15);}
        .text-orange { color: var(--accent-orange) !important; }
    </style>
</head>
<body>

    <%@ include file="navbar.jsp" %>

    <div class="container" style="margin-top: 40px; margin-bottom: 50px;">
        <div class="text-center mb-4">
            <h2 class="fw-bold">Catálogo de Repuestos</h2>
            <p class="text-secondary">Encuentra todo lo que necesitas para tu moto</p>
        </div>
        
        <input type="text" id="searchInput" class="search-bar mb-5" placeholder="Buscar por nombre o marca..." onkeyup="filterProducts()">

        <div class="row g-4" id="productGrid">
            <%
                ProductDAO dao = new ProductDAO();
                List<Product> products = dao.getAllProducts();
                for(Product p : products) {
            %>
            <div class="col-md-3 product-item" data-name="<%= p.getName().toLowerCase() %>" data-brand="<%= p.getBrand() != null ? p.getBrand().toLowerCase() : "" %>">
                <div class="product-card">
                    <% if(p.getImageUrl() != null && !p.getImageUrl().isEmpty()) { %>
                        <img src="<%= p.getImageUrl() %>" alt="<%= p.getName() %>" class="product-img">
                    <% } else { %>
                        <div class="product-img d-flex align-items-center justify-content-center text-secondary" style="background: var(--card-border);">
                            <i class="bi bi-tools fs-1"></i>
                        </div>
                    <% } %>
                    <h5 class="fw-bold mb-1"><%= p.getName() %></h5>
                    <p class="text-secondary small mb-2"><%= p.getBrand() != null ? p.getBrand() : "Genérico" %></p>
                    <h4 class="text-orange fw-bold mb-3">$<%= String.format("%.2f", p.getPrice()) %></h4>
                    <% if(p.getStock() > 0) { %>
                        <button class="btn btn-moto w-100" onclick="addToCart(<%= p.getId() %>, '<%= p.getName() %>', <%= p.getPrice() %>)">Añadir al Carrito</button>
                    <% } else { %>
                        <button class="btn btn-secondary w-100" disabled>Agotado</button>
                    <% } %>
                </div>
            </div>
            <% } %>
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

        function addToCart(id, name, price) {
            if (!isLoggedIn) {
                window.location.href = "login.jsp?msg=Debes+iniciar+sesion+para+añadir+al+carrito";
                return;
            }
            let item = cart.find(i => i.id === id);
            if(item) {
                item.qty++;
            } else {
                cart.push({id, name, price, qty: 1});
            }
            localStorage.setItem(cartKey, JSON.stringify(cart));
            updateCartBadge();
            
            // Show a tiny toast or alert
            if(typeof Swal !== 'undefined') {
                Swal.fire({
                    toast: true, position: 'bottom-end', icon: 'success',
                    title: name + ' añadido al carrito',
                    showConfirmButton: false, timer: 1500,
                    background: document.body.classList.contains('light-mode') ? '#ffffff' : '#1e1e24',
                    color: document.body.classList.contains('light-mode') ? '#333333' : '#f8f9fa'
                });
            } else {
                alert(name + " añadido al carrito");
            }
        }

        document.addEventListener("DOMContentLoaded", function() {
            updateCartBadge();
        });

        function filterProducts() {
            let input = document.getElementById('searchInput').value.toLowerCase();
            let items = document.getElementsByClassName('product-item');
            
            for (let i = 0; i < items.length; i++) {
                let name = items[i].getAttribute('data-name');
                let brand = items[i].getAttribute('data-brand');
                if (name.includes(input) || brand.includes(input)) {
                    items[i].style.display = "block";
                } else {
                    items[i].style.display = "none";
                }
            }
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
