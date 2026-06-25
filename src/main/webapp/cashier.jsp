<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || (sessionUser.getRoleId() != 1 && sessionUser.getRoleId() != 4)) {
        response.sendRedirect("login.jsp");
        return;
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
        
        @media print {
            body * { visibility: hidden; }
            #invoiceSection, #invoiceSection * { visibility: visible; }
            #invoiceSection { position: absolute; left: 0; top: 0; width: 100%; margin: 0; padding: 0; box-shadow: none !important; }
            .d-print-none { display: none !important; }
            @page { margin: 0; }
            
            /* Ticket Styles (Thermal Printer) ONLY ON PRINT */
            .ticket-receipt {
                background-color: #ffffff !important;
                color: #000000 !important;
                width: 100%;
                max-width: 380px;
                margin: 0 auto;
                padding: 20px;
                font-family: 'Courier New', Courier, monospace !important;
                border-radius: 0 !important;
            }
            .ticket-receipt * {
                color: #000000 !important;
                font-family: 'Courier New', Courier, monospace !important;
            }
            .ticket-receipt th, .ticket-receipt td {
                padding: 4px 0 !important;
                border-color: #000000 !important;
                font-size: 0.85rem;
            }
            .ticket-receipt .border-bottom-dashed {
                border-bottom: 1px dashed #000000 !important;
            }
            .ticket-receipt .border-top-dashed {
                border-top: 1px dashed #000000 !important;
            }
        }

        /* Screen ticket styles (Responsive to Dark/Light mode) */
        .ticket-receipt-screen {
            background-color: var(--card-bg) !important;
            color: var(--text-color) !important;
            width: 100%;
            max-width: 380px;
            margin: 0 auto;
            padding: 20px;
            font-family: 'Courier New', Courier, monospace !important;
            border-radius: 12px !important;
            border: 1px solid var(--card-border);
        }
        .ticket-receipt-screen * {
            color: var(--text-color) !important;
            font-family: 'Courier New', Courier, monospace !important;
        }
        .ticket-receipt-screen th, .ticket-receipt-screen td {
            padding: 4px 0 !important;
            border-color: var(--card-border) !important;
            font-size: 0.85rem;
        }
        .ticket-receipt-screen .border-bottom-dashed {
            border-bottom: 1px dashed var(--text-muted) !important;
        }
        .ticket-receipt-screen .border-top-dashed {
            border-top: 1px dashed var(--text-muted) !important;
        }
    </style>
</head>
<body>
<script src="resources/theme.js?v=2"></script>

<%@ include file="navbar.jsp" %>

<div class="container-fluid px-4 pb-5 mb-5" style="margin-top: 100px;">
    <div class="row g-4" id="mainCashierView">
        
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
    
    <!-- Invoice Section -->
    <div id="invoiceSection" class="d-none mt-4 pb-5 mb-5 mx-auto">
        <div class="d-flex justify-content-center gap-3 mb-4 d-print-none">
            <button class="btn btn-outline-secondary rounded-pill px-4 fw-bold bg-dark text-white" onclick="returnToCashier()">
                <i class="bi bi-arrow-left me-2"></i> Volver a la Caja
            </button>
            <button class="btn btn-accent rounded-pill px-4 fw-bold" onclick="window.print()">
                <i class="bi bi-printer-fill me-2"></i> Imprimir Ticket
            </button>
        </div>
        
        <div class="card border-0 shadow-lg ticket-receipt ticket-receipt-screen" id="printArea">
            <div class="text-center mb-3">
                <h4 class="fw-bolder mb-1">ASAMA MOTORS PARTS</h4>
                <div class="small fw-bold">NIT: 900.123.456-7</div>
                <div class="small fw-bold">Régimen Común</div>
                <div class="small fw-bold">Calle Principal #123, Ciudadela</div>
                <div class="small fw-bold mt-2 border-bottom-dashed pb-2">Documento Equivalente POS</div>
                <div class="small fw-bold mt-2 text-start">Fecha: <span id="invoiceDate"></span></div>
            </div>
            
            <table class="table table-sm table-borderless mb-2">
                <thead class="border-bottom-dashed">
                    <tr>
                        <th class="text-start">DESCRIPCIÓN</th>
                        <th class="text-center">CANT</th>
                        <th class="text-end">TOTAL</th>
                    </tr>
                </thead>
                <tbody id="invoiceItems" class="border-bottom-dashed">
                    <!-- Items injected here -->
                </tbody>
            </table>
            
            <div class="mt-2">
                <div class="d-flex justify-content-between mb-1">
                    <span class="fw-bold">Subtotal:</span>
                    <span class="fw-bold" id="invSubtotal">$0.00</span>
                </div>
                <div class="d-flex justify-content-between mb-1">
                    <span class="fw-bold">IVA (19%):</span>
                    <span class="fw-bold">Incluido</span>
                </div>
                <div class="d-flex justify-content-between mt-2 pt-2 border-top-dashed">
                    <span class="fw-bolder fs-6">TOTAL:</span>
                    <span class="fw-bolder fs-6" id="invTotal">$0.00</span>
                </div>
                <div class="d-flex justify-content-between mt-2">
                    <span class="fw-bold">Efectivo:</span>
                    <span class="fw-bold" id="invTendered">$0.00</span>
                </div>
                <div class="d-flex justify-content-between mb-3">
                    <span class="fw-bold">Vueltos:</span>
                    <span class="fw-bold" id="invChange">$0.00</span>
                </div>
            </div>
            
            <div class="text-center mt-3 pt-2 border-top-dashed">
                <div class="fw-bolder mb-1">¡Gracias por su compra!</div>
                <div class="small" style="font-size: 0.75rem;">Conserve este ticket para cualquier reclamo o garantía.</div>
            </div>
        </div>
    </div>
</div>

<!-- Payment Modal -->
<div class="modal fade" id="paymentModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-secondary shadow-lg">
      <div class="modal-header border-secondary pb-3">
        <h5 class="modal-title text-accent fw-bolder fs-4">
            <i class="bi bi-cash-coin me-2"></i> Confirmar Pago
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter: invert(1) grayscale(100%) brightness(200%);"></button>
      </div>
      <div class="modal-body p-4">
          <div class="text-center mb-4">
              <h6 class="text-secondary fw-bold text-uppercase mb-1">Total a Pagar</h6>
              <h2 class="text-accent fw-bolder mb-0" id="modalTotalPay" style="font-size: 2.8rem; letter-spacing: -1px;">$0.00</h2>
          </div>
          <div class="mb-4">
              <label class="form-label text-warning fw-bold">Monto Recibido ($)</label>
              <input type="number" step="0.01" id="amountTendered" class="form-control form-control-lg text-center fw-bold fs-4" placeholder="0.00" autocomplete="off">
          </div>
          <div class="p-3 rounded-3" style="background-color: rgba(255, 255, 255, 0.05); border: 1px dashed var(--card-border);">
              <div class="d-flex justify-content-between align-items-center">
                  <span class="text-secondary fw-bold fs-5">Vueltos:</span>
                  <span class="text-success fw-bolder fs-3" id="changeDue">$0.00</span>
              </div>
          </div>
      </div>
      <div class="modal-footer border-secondary pt-3">
        <button type="button" class="btn btn-outline-secondary rounded-pill fw-bold px-4 py-2" data-bs-dismiss="modal">Cancelar</button>
        <button type="button" id="confirmPaymentBtn" class="btn btn-accent rounded-pill fw-bolder px-5 py-2 shadow-sm" disabled>
            <i class="bi bi-check-circle-fill me-2"></i> Completar Pago
        </button>
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
    
    const modalTotalPay = document.getElementById('modalTotalPay');
    const amountTendered = document.getElementById('amountTendered');
    const changeDue = document.getElementById('changeDue');
    const confirmPaymentBtn = document.getElementById('confirmPaymentBtn');
    const invoiceSection = document.getElementById('invoiceSection');
    const mainCashierView = document.getElementById('mainCashierView');
    let paymentModal;
    
    document.addEventListener("DOMContentLoaded", () => {
        paymentModal = new bootstrap.Modal(document.getElementById('paymentModal'));
    });
    
    let cart = [];
    let globalTotal = 0;
    let barcodeBuffer = '';
    let barcodeTimer = null;

    // Escucha global para el escaner fisico
    document.addEventListener('keypress', function(e) {
        if(document.activeElement === barcodeInput || document.activeElement === amountTendered) return;

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
        
        globalTotal = total;
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
        modalTotalPay.innerText = '$' + globalTotal.toFixed(2);
        amountTendered.value = '';
        changeDue.innerText = '$0.00';
        changeDue.className = 'text-success fw-bolder fs-3';
        confirmPaymentBtn.disabled = true;
        paymentModal.show();
        setTimeout(() => amountTendered.focus(), 500);
    });

    amountTendered.addEventListener('input', () => {
        let tendered = parseFloat(amountTendered.value) || 0;
        let change = tendered - globalTotal;
        if(change >= 0 && tendered > 0) {
            changeDue.innerText = '$' + change.toFixed(2);
            changeDue.className = 'text-success fw-bolder fs-3';
            confirmPaymentBtn.disabled = false;
        } else {
            changeDue.innerText = 'Monto Insuficiente';
            changeDue.className = 'text-danger fw-bolder fs-4';
            confirmPaymentBtn.disabled = true;
        }
    });

    confirmPaymentBtn.addEventListener('click', () => {
        confirmPaymentBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span> Procesando...';
        confirmPaymentBtn.disabled = true;

        let promises = cart.map(item => {
            let sub = item.qty * item.price;
            return fetch('cashier', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'action=pay&productId=' + item.id + '&quantity=' + item.qty + '&total=' + sub
            });
        });

        Promise.all(promises).then(() => {
            paymentModal.hide();
            confirmPaymentBtn.innerHTML = '<i class="bi bi-check-circle-fill me-2"></i> Completar Pago';
            
            showStatus('<i class="bi bi-bag-check-fill me-2"></i><fmt:message key="cashier.sale_success" />', 'success');
            
            generateInvoice(parseFloat(amountTendered.value), parseFloat(amountTendered.value) - globalTotal);
            
            cart = [];
            renderCart();
        }).catch(() => {
            alert('<fmt:message key="cashier.sale_error" />');
            confirmPaymentBtn.innerHTML = '<i class="bi bi-check-circle-fill me-2"></i> Completar Pago';
            confirmPaymentBtn.disabled = false;
        });
    });

    function generateInvoice(tendered, change) {
        mainCashierView.classList.add('d-none');
        invoiceSection.classList.remove('d-none');
        
        document.getElementById('invoiceDate').innerText = new Date().toLocaleString('es-CO');
        
        const tbody = document.getElementById('invoiceItems');
        tbody.innerHTML = '';
        cart.forEach(item => {
            let sub = item.qty * item.price;
            let itemName = item.name ? item.name : 'Producto';
            let shortName = itemName.length > 20 ? itemName.substring(0, 20) + '...' : itemName;
            let priceFormatted = item.price.toFixed(2);
            let subFormatted = sub.toFixed(2);
            
            tbody.innerHTML += 
                '<tr>' +
                    '<td class="text-start">' +
                        '<div class="fw-bold">' + shortName + '</div>' +
                        '<div class="small">$' + priceFormatted + ' c/u</div>' +
                    '</td>' +
                    '<td class="text-center align-middle fw-bold">' + item.qty + '</td>' +
                    '<td class="text-end align-middle fw-bolder">$' + subFormatted + '</td>' +
                '</tr>';
        });
        
        document.getElementById('invSubtotal').innerText = '$' + globalTotal.toFixed(2);
        document.getElementById('invTotal').innerText = '$' + globalTotal.toFixed(2);
        document.getElementById('invTendered').innerText = '$' + tendered.toFixed(2);
        document.getElementById('invChange').innerText = '$' + change.toFixed(2);
    }

    function returnToCashier() {
        invoiceSection.classList.add('d-none');
        mainCashierView.classList.remove('d-none');
        barcodeInput.focus();
    }
    
    // Renderizado inicial
    renderCart();
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
