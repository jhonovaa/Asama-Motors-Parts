<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || (sessionUser.getRoleId() != 1 && sessionUser.getRoleId() != 4)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Punto de Venta - Cajero</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --bg-color: #0f1013;
            --text-color: #f1f2f6;
            --nav-bg: rgba(15, 16, 19, 0.85);
            --metallic-chrome: #E5E4E2;
            --metallic-gunmetal: #1a1d24;
            --card-bg: #2a2e35;
            --accent-orange: #FF6B35;
        }
        body { font-family: 'Inter', sans-serif; background-color: var(--bg-color); color: var(--text-color); }
        .navbar { background-color: var(--nav-bg); backdrop-filter: blur(20px); border-bottom: 1px solid rgba(255, 255, 255, 0.08); }
        .navbar-brand { color: var(--metallic-chrome) !important; font-weight: 700; }
        .pos-panel { background: var(--metallic-gunmetal); border-radius: 15px; padding: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.5); border: 1px solid rgba(255,255,255,0.05); height: 100%; }
        #barcodeInput { background: var(--card-bg); color: white; font-size: 1.5rem; letter-spacing: 2px; text-align: center; border: 1px solid rgba(255,255,255,0.1); border-radius: 10px; }
        #barcodeInput:focus { box-shadow: 0 0 10px rgba(211,47,47,0.3); border-color: var(--accent-orange); }
        
        /* Ajustes para la tabla transparente */
        .table { 
            --bs-table-bg: transparent; 
            color: var(--text-color); 
        }
        .table th, .table td { 
            background-color: transparent !important; 
            border-color: rgba(255,255,255,0.1); 
            color: var(--text-color) !important;
        }
        .table-dark { background-color: transparent; }
        
        .btn-moto { background-color: var(--accent-orange); color: #fff; border: none; border-radius: 30px; padding: 10px 20px; font-weight: 600; transition: 0.3s; }
        .btn-moto:hover { background-color: #E55A2B; }
        .btn-moto-outline { border: 1px solid var(--accent-orange); color: var(--accent-orange); background: transparent; border-radius: 30px; padding: 5px 15px; transition: 0.3s; }
        .btn-moto-outline:hover { background: var(--accent-red); color: white; }
        
        .pulse-scanner { animation: pulseRed 2s infinite; }
        @keyframes pulseRed {
            0% { box-shadow: 0 0 0 0 rgba(211, 47, 47, 0.7); }
            70% { box-shadow: 0 0 0 10px rgba(211, 47, 47, 0); }
            100% { box-shadow: 0 0 0 0 rgba(211, 47, 47, 0); }
        }
    </style>
    <link rel="stylesheet" href="resources/theme.css">
</head>
<body>
<script src="resources/theme.js"></script>

<%@ include file="navbar.jsp" %>

<div class="container mt-4">
    <div class="row g-4 pb-4">
        <div class="col-md-5">
            <div class="pos-panel text-center">
                <i class="bi bi-upc-scan fs-1 text-danger mb-3 pulse-scanner d-inline-block rounded-circle p-2"></i>
                <h4 class="mb-4">Escaner Activo</h4>
                <p class="text-secondary small">El sistema esta escuchando el escaner de codigo de barras en todo momento. Simplemente apunte y dispare al producto.</p>
                <div class="mb-3 mt-4 text-start">
                    <label class="form-label text-muted small">Entrada Manual (Opcional):</label>
                    <input type="text" id="barcodeInput" class="form-control form-control-lg" placeholder="|||| |||||| ||||" autocomplete="off">
                </div>
                <div id="scanStatus" class="alert d-none mt-3" role="alert"></div>
            </div>
        </div>
        
        <div class="col-md-7">
            <div class="pos-panel d-flex flex-column">
                <h4 class="mb-4 text-white"><i class="bi bi-cart"></i> Cuenta Actual</h4>
                <div class="table-responsive flex-grow-1" style="max-height: 400px;">
                    <table class="table table-borderless table-sm">
                        <thead style="border-bottom: 1px solid rgba(255,255,255,0.1);">
                            <tr>
                                <th class="text-secondary">Producto</th>
                                <th class="text-secondary">Cant.</th>
                                <th class="text-secondary">P. Unit.</th>
                                <th class="text-secondary text-end">Subtotal</th>
                            </tr>
                        </thead>
                        <tbody id="cartBody">
                            </tbody>
                    </table>
                </div>
                <hr style="border-color: rgba(255,255,255,0.1);">
                <div class="d-flex justify-content-between align-items-center mt-3">
                    <h3 class="mb-0 text-white">Total: <span class="text-danger fw-bold" id="totalPrice">$0.00</span></h3>
                    <button id="payBtn" class="btn btn-moto btn-lg px-5" disabled>Cobrar (Enter)</button>
                </div>
            </div>
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

    // Global Scanner listener. Buffers fast keystrokes ending in Enter.
    document.addEventListener('keypress', function(e) {
        // If user is manually typing in the input, let the input's own listener handle it
        if(document.activeElement === barcodeInput) return;

        if (e.key === 'Enter') {
            e.preventDefault();
            if (barcodeBuffer.trim() !== '') {
                processScan(barcodeBuffer.trim());
                barcodeBuffer = '';
            } else if(cart.length > 0) {
                // If enter pressed empty, maybe trigger pay
                payBtn.click();
            }
        } else {
            barcodeBuffer += e.key;
            clearTimeout(barcodeTimer);
            // Clear buffer if more than 50ms pass between keystrokes (humans type slower, scanners type fast)
            // Increased to 200ms to be safe with slower scanners
            barcodeTimer = setTimeout(() => { barcodeBuffer = ''; }, 200); 
        }
    });

    // Manual input listener
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
                showStatus(data.error, 'danger');
            } else {
                addToCart(data);
                showStatus('✔ ' + data.name, 'success');
            }
        }).catch(err => {
            showStatus('Error de conexion', 'danger');
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
        cart.forEach(item => {
            let subtotal = item.qty * item.price;
            total += subtotal;
            cartBody.innerHTML += `
                <tr>
                    <td><strong class="text-white">${item.name}</strong> <br><small class="text-secondary">${item.brand}</small></td>
                    <td><span class="badge bg-secondary">${item.qty}</span></td>
                    <td>$${item.price.toFixed(2)}</td>
                    <td class="text-end fw-bold text-white">$${subtotal.toFixed(2)}</td>
                </tr>
            `;
        });
        
        if(cart.length === 0) {
            cartBody.innerHTML = '<tr><td colspan="4" class="text-center text-muted py-4">Esperando articulos...</td></tr>';
        }
        
        totalPriceEl.innerText = '$' + total.toFixed(2);
        payBtn.disabled = cart.length === 0;
    }

    function showStatus(msg, type) {
        scanStatus.className = 'alert alert-' + type;
        scanStatus.innerText = msg;
        setTimeout(() => { scanStatus.className = 'alert d-none'; }, 2000);
    }

    payBtn.addEventListener('click', () => {
        if(cart.length === 0) return;
        
        let promises = cart.map(item => {
            let sub = item.qty * item.price;
            return fetch('cashier', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: `action=pay&productId=${item.id}&quantity=${item.qty}&total=${sub}`
            });
        });

        Promise.all(promises).then(() => {
            showStatus('Venta procesada con exito', 'success');
            cart = [];
            renderCart();
        }).catch(() => {
            alert('Error al procesar la venta');
        });
    });
    
    // Initial render
    renderCart();
</script>
</body>
</html>