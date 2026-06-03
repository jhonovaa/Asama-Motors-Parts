<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User user = (User) session.getAttribute("user");
    boolean isLoggedIn = user != null;
    int roleId = isLoggedIn ? user.getRoleId() : 0;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Carrito de Compras - Asama Moto Parts</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --bg-color: #0a0a0a;
            --text-color: #f0f0f0;
            --card-bg: #1a1a1a;
            --accent-orange: #FF6B35;
        }
        body { font-family: 'Inter', sans-serif; background-color: var(--bg-color); color: var(--text-color); padding-top: 60px; }
        .cart-container { background: var(--card-bg); border-radius: 15px; padding: 30px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); border: 1px solid rgba(255,255,255,0.05); }
        .table { color: var(--text-color); }
        .table td, .table th { border-color: rgba(255,255,255,0.1); background-color: transparent; vertical-align: middle; }
        .btn-moto { background-color: var(--accent-orange); color: #fff; border: none; border-radius: 30px; padding: 10px 25px; font-weight: 600; transition: 0.3s; }
        .btn-moto:hover { background-color: #E55A2B; color: white;}
        .qty-btn { background: #2D3436; color: white; border: none; width: 30px; height: 30px; border-radius: 5px; }
        .text-orange { color: var(--accent-orange) !important; }
    </style>
</head>
<body>

    <%@ include file="navbar.jsp" %>

    <div class="container" style="margin-top: 50px; margin-bottom: 50px;">
        <div class="cart-container">
            <h3 class="fw-bold mb-4"><i class="bi bi-cart3 text-orange me-2"></i> Tu Carrito</h3>
            
            <div id="cartContent">
                <table class="table table-hover table-dark">
                    <thead>
                        <tr>
                            <th>Producto</th>
                            <th>Precio</th>
                            <th class="text-center">Cantidad</th>
                            <th>Subtotal</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody id="cartItems">
                        <!-- Items rendered by JS -->
                    </tbody>
                </table>
                
                <div class="d-flex justify-content-between align-items-center mt-4 pt-3 border-top border-secondary">
                    <h4 class="fw-bold m-0">Total: <span class="text-orange" id="cartTotal">$0.00</span></h4>
                    <button class="btn btn-moto" onclick="processCheckout()">Proceder al Pago <i class="bi bi-arrow-right ms-1"></i></button>
                </div>
            </div>
            
            <div id="emptyCart" style="display: none;" class="text-center py-5">
                <i class="bi bi-cart-x text-secondary" style="font-size: 4rem;"></i>
                <h4 class="mt-3 text-secondary">Tu carrito está vacío</h4>
                <a href="catalog.jsp" class="btn btn-outline-light mt-3" style="border-radius: 20px;">Volver al Catálogo</a>
            </div>
        </div>
    </div>

    <script>
        let cart = JSON.parse(localStorage.getItem('asama_cart')) || [];
        let isLoggedIn = <%= isLoggedIn %>;
        let roleId = <%= roleId %>;

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
                tr.innerHTML = `
                    <td class="fw-bold">${item.name}</td>
                    <td>$${item.price.toFixed(2)}</td>
                    <td class="text-center">
                        <button class="qty-btn" onclick="updateQty(${index}, -1)">-</button>
                        <span class="mx-3 fw-bold">${item.qty}</span>
                        <button class="qty-btn" onclick="updateQty(${index}, 1)">+</button>
                    </td>
                    <td class="fw-bold">$${subtotal.toFixed(2)}</td>
                    <td class="text-end">
                        <button class="btn btn-sm btn-outline-danger" onclick="removeFromCart(${index})" style="border-radius: 5px;">
                            <i class="bi bi-trash"></i>
                        </button>
                    </td>
                `;
                tbody.appendChild(tr);
            });
            
            totalSpan.innerText = '$' + total.toFixed(2);
        }

        function updateQty(index, change) {
            cart[index].qty += change;
            if(cart[index].qty <= 0) {
                cart.splice(index, 1);
            }
            localStorage.setItem('asama_cart', JSON.stringify(cart));
            renderCart();
        }

        function removeFromCart(index) {
            cart.splice(index, 1);
            localStorage.setItem('asama_cart', JSON.stringify(cart));
            renderCart();
        }

        function processCheckout() {
            if(!isLoggedIn) {
                window.location.href = 'login.jsp';
                return;
            }
            if(roleId !== 5) {
                alert("Solo los Clientes pueden realizar compras online.");
                return;
            }
            window.location.href = 'checkout.jsp';
        }

        renderCart();
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
