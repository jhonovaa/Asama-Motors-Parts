<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRoleId() != 5) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title><fmt:message key="checkout.title" /></title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body { font-family: 'Inter', sans-serif; background-color: var(--bg-color); color: var(--text-color); padding-top: 60px; }
        .checkout-card { background: var(--card-bg); border-radius: 15px; padding: 30px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); border: 1px solid var(--card-border); }
        .btn-moto { background-color: var(--accent-orange); color: #fff; border: none; border-radius: 30px; padding: 14px; font-weight: 700; width: 100%; font-size: 1.1rem; transition: 0.3s; display: flex; align-items: center; justify-content: center; gap: 10px; }
        .btn-moto:hover { background-color: #E55A2B; color: white; transform: translateY(-2px); box-shadow: 0 8px 25px rgba(229,90,43,0.4); }
        .btn-moto:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }
        .security-info { background: rgba(40,167,69,0.1); border: 1px solid rgba(40,167,69,0.3); border-radius: 10px; padding: 15px; margin-bottom: 20px; }
        .security-info i { color: #28a745; }
        .spinner-border-sm { width: 1rem; height: 1rem; border-width: 0.15em; }
    </style>
</head>
<body>

    <%@ include file="navbar.jsp" %>

    <div class="container" style="margin-top: 40px;">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="checkout-card" id="paymentForm">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h4 class="fw-bold m-0"><fmt:message key="checkout.details" /></h4>
                        <span class="badge bg-success py-2 px-3 rounded-pill"><i class="bi bi-box-seam me-1"></i> Envío a Domicilio</span>
                    </div>

                    <div class="security-info">
                        <p class="mb-1 small fw-medium"><i class="bi bi-shield-lock-fill me-2"></i>Pago Seguro con Mercado Pago</p>
                        <p class="mb-0 small text-secondary">Serás redirigido a Mercado Pago para realizar tu pago. Tu pedido será registrado, pero el stock solo se descontará una vez que el pago sea exitoso.</p>
                    </div>

                    <hr class="my-4 border-secondary border-opacity-50">
                    <h5 class="fw-bold mb-3"><fmt:message key="checkout.order_summary" /></h5>
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-secondary"><fmt:message key="checkout.subtotal" /></span>
                        <span class="fw-medium" id="summarySubtotal">$0.00</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-secondary"><fmt:message key="checkout.est_weight" /></span>
                        <span class="fw-medium text-accent" id="summaryWeight">0 kg</span>
                    </div>
                    <div class="d-flex justify-content-between mb-3">
                        <span class="text-secondary"><fmt:message key="checkout.shipping_cost" /> <i class="bi bi-truck ms-1"></i></span>
                        <span class="fw-medium" id="summaryShipping">$0.00</span>
                    </div>
                    <div class="d-flex justify-content-between border-top pt-3 mb-4">
                        <span class="fw-bold fs-5"><fmt:message key="checkout.total_pay" /></span>
                        <span class="fw-bolder fs-4 text-accent" id="summaryTotal">$0.00</span>
                    </div>

                    <div id="paymentBrick_container"></div>
                </div>
            </div>
        </div>
    </div>

    <!-- SDK MercadoPago.js V2 -->
    <script src="https://sdk.mercadopago.com/js/v2"></script>

    <script>
        let totalPayGlobal = 0;

        function loadSummary() {
            let currentUserId = <%= user != null ? user.getId() : -1 %>;
            let cartKey = 'asama_cart_' + currentUserId;
            let cartStr = localStorage.getItem(cartKey);
            if(!cartStr || cartStr === '[]') {
                alert("<fmt:message key='checkout.cart_empty' />");
                window.location.href = 'catalog.jsp';
                return 0;
            }
            let cart = JSON.parse(cartStr);

            let subtotal = 0;
            let totalWeight = 0;

            cart.forEach(item => {
                subtotal += (item.price * item.qty);
                totalWeight += ((item.weight || 0) * item.qty);
            });

            let shipping = 0;
            if (totalWeight > 16.0) {
                shipping = 16000;
            }

            let totalPay = subtotal + shipping;
            totalPayGlobal = totalPay;

            document.getElementById('summarySubtotal').innerText = '$' + subtotal.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('summaryWeight').innerText = totalWeight.toFixed(1) + ' kg';
            document.getElementById('summaryShipping').innerText = shipping === 0 ? (subtotal > 0 ? 'FREE' : '$0.00') : '$' + shipping.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('summaryTotal').innerText = '$' + totalPay.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});

            return totalPay;
        }

        window.onload = async function() {
            let amount = loadSummary();
            if (amount > 0) {
                await renderPaymentBrick(amount);
            }
        };

        const mp = new MercadoPago('TEST-5078b5d5-347a-4228-b46a-ae17dd4fe78e', {
            locale: 'es-CO'
        });
        const bricksBuilder = mp.bricks();

        const renderPaymentBrick = async (amount) => {
            const settings = {
                initialization: {
                    amount: amount,
                },
                customization: {
                    visual: {
                        style: {
                            theme: 'default',
                        }
                    },
                    paymentMethods: {
                        creditCard: "all",
                        debitCard: "all"
                    }
                },
                callbacks: {
                    onReady: () => {
                        // Brick is ready
                    },
                    onSubmit: ({ selectedPaymentMethod, formData }) => {
                        return new Promise((resolve, reject) => {
                            let currentUserId = <%= user != null ? user.getId() : -1 %>;
                            let cartKey = 'asama_cart_' + currentUserId;
                            let cart = localStorage.getItem(cartKey);

                            fetch("api/process_payment", {
                                method: "POST",
                                headers: {
                                    "Content-Type": "application/json",
                                },
                                body: JSON.stringify({
                                    cartData: cart,
                                    formData: formData
                                }),
                            })
                            .then((response) => response.json())
                            .then((response) => {
                                resolve();
                                if (response.success && response.status === 'approved') {
                                    // Limpiar cart
                                    localStorage.removeItem(cartKey);
                                    // Llamar a PaymentSuccessServlet para completar stock y notificaciones
                                    window.location.href = 'PaymentSuccessServlet?status=approved&external_reference=' + response.orderId;
                                } else {
                                    let errorMsg = response.error ? response.error : response.status;
                                    alert("Hubo un error con tu pago: " + errorMsg + ". Por favor verifica los datos o usa otra tarjeta.");
                                }
                            })
                            .catch((error) => {
                                reject();
                                alert("Error procesando pago. Inténtalo de nuevo.");
                                console.error(error);
                            });
                        });
                    },
                    onError: (error) => {
                        console.error(error);
                    },
                },
            };
            
            window.paymentBrickController = await bricksBuilder.create(
                "payment",
                "paymentBrick_container",
                settings
            );
        };
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
