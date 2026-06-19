<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    String otpCode = (String) session.getAttribute("otp");
    if (otpCode == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="otp.title" /></title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
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

        /* --- INPUTS OTP MODERNOS (6 CASILLAS) --- */
        .otp-inputs-container {
            display: flex;
            justify-content: space-between;
            gap: 10px;
            margin-bottom: 25px;
        }
        
        .otp-box {
            width: 55px;
            height: 65px;
            text-align: center;
            font-size: 2rem !important;
            font-weight: 800 !important;
            border-radius: 12px !important;
            background-color: rgba(255, 255, 255, 0.08) !important;
            color: #ffffff !important;
            border: 2px solid rgba(255, 255, 255, 0.2) !important;
            padding: 0 !important;
            transition: all 0.2s ease;
        }
        
        .otp-box:focus {
            background-color: rgba(255, 255, 255, 0.12) !important;
            border-color: var(--accent-orange) !important;
            box-shadow: 0 0 15px var(--accent-glow) !important;
            transform: translateY(-2px);
        }

        /* Compatibilidad Modo Claro para las casillas */
        body.light-mode .otp-box {
            background-color: #ffffff !important;
            color: #121417 !important;
            border-color: rgba(0, 0, 0, 0.25) !important;
        }
        body.light-mode .otp-box:focus {
            background-color: #ffffff !important;
        }

        /* Efecto de pulso en el icono principal */
        @keyframes pulseGlow {
            0% { box-shadow: 0 0 0 0 var(--accent-glow); }
            70% { box-shadow: 0 0 0 15px rgba(0,0,0,0); }
            100% { box-shadow: 0 0 0 0 rgba(0,0,0,0); }
        }
        .icon-pulse {
            animation: pulseGlow 2s infinite;
        }
    </style>
</head>
<body class="body-center" style="background: radial-gradient(circle at center, var(--card-bg) 0%, var(--bg-color) 100%);">
<script src="resources/theme.js"></script>

    <div style="position:fixed; top:20px; right:20px; z-index:1000;">
        <button onclick="toggleTheme()" class="btn btn-icon theme-toggle-btn rounded-circle transition-all shadow-lg" title="<fmt:message key='otp.theme_toggle' />">
            <i id="themeIcon" class="bi bi-sun-fill fs-5"></i>
        </button>
    </div>

    <div class="login-card p-4 p-md-5 shadow-lg text-center" style="width: 100%; max-width: 480px; border-radius: 20px;">
        
        <div class="brand-icon mx-auto mb-4 icon-pulse" style="width: 80px; height: 80px; font-size: 38px; background-color: var(--accent-orange); color: #121417; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
            <i class="bi bi-shield-lock-fill"></i>
        </div>
        
        <h2 class="fw-bold mb-2 title-main text-white"><fmt:message key="otp.account_security" /></h2>
        <p class="text-secondary mb-4 fs-6"><fmt:message key="otp.instruction" /></p>
        
        <% if(request.getAttribute("error") != null) { %>
            <div class="alert bg-danger bg-opacity-25 border border-danger text-danger py-3 px-3 text-center rounded-3 fw-bold mb-4 shadow-sm fs-6" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i> <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <% if(session.getAttribute("emailWarning") != null) { %>
            <div class="alert bg-warning bg-opacity-25 border border-warning text-warning py-3 px-3 text-center rounded-3 fw-bold mb-4 shadow-sm fs-6" role="alert">
                <i class="bi bi-info-circle-fill me-2 fs-5"></i> <%= session.getAttribute("emailWarning") %>
            </div>
        <% } %>
        
        <form action="verifyOtp" method="POST" id="otpForm">
            <input type="hidden" name="otp" id="realOtpInput" required pattern="[0-9]{6}">
            
            <div class="otp-inputs-container">
                <input type="text" class="form-control otp-box" maxlength="1" pattern="[0-9]" inputmode="numeric" autocomplete="one-time-code" autofocus>
                <input type="text" class="form-control otp-box" maxlength="1" pattern="[0-9]" inputmode="numeric">
                <input type="text" class="form-control otp-box" maxlength="1" pattern="[0-9]" inputmode="numeric">
                <input type="text" class="form-control otp-box" maxlength="1" pattern="[0-9]" inputmode="numeric">
                <input type="text" class="form-control otp-box" maxlength="1" pattern="[0-9]" inputmode="numeric">
                <input type="text" class="form-control otp-box" maxlength="1" pattern="[0-9]" inputmode="numeric">
            </div>
            
            <button type="submit" class="btn btn-accent w-100 rounded-pill fw-bold py-3 fs-5 shadow-lg transition-all d-flex justify-content-center align-items-center gap-2">
                <i class="bi bi-check-circle-fill"></i> <fmt:message key="otp.verify_button" />
            </button>
        </form>

        <div class="mt-3">
            <button id="resendBtn" class="btn btn-outline-secondary w-100 rounded-pill fw-bold py-2 transition-all d-flex justify-content-center align-items-center gap-2" disabled>
                <i class="bi bi-arrow-clockwise"></i> <span id="countdownSpan"><fmt:message key="otp.resend_60s" /></span>
            </button>
        </div>
        
        <div class="text-center mt-4 pt-4 border-top border-secondary border-opacity-25">
            <a href="login.jsp" class="text-secondary text-decoration-none hover-accent transition-all fw-bold fs-6">
                <i class="bi bi-arrow-left-circle-fill me-2"></i> <fmt:message key="otp.back_login" />
            </a>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            // --- LOGICA DE CASILLAS OTP AUTOMATICAS ---
            const inputs = document.querySelectorAll('.otp-box');
            const hiddenInput = document.getElementById('realOtpInput');
            const form = document.getElementById('otpForm');

            inputs.forEach((input, index) => {
                input.addEventListener('focus', () => {
                    input.select();
                });

                input.addEventListener('input', (e) => {
                    e.target.value = e.target.value.replace(/[^0-9]/g, '');
                    if (e.target.value !== '') {
                        if (index < inputs.length - 1) {
                            inputs[index + 1].focus();
                        }
                    }
                    updateHiddenInput();
                });

                input.addEventListener('keydown', (e) => {
                    if (e.key === 'Backspace' && e.target.value === '') {
                        if (index > 0) {
                            inputs[index - 1].focus();
                        }
                    }
                });

                input.addEventListener('paste', (e) => {
                    e.preventDefault();
                    const pastedData = e.clipboardData.getData('text').replace(/[^0-9]/g, '').slice(0, 6);
                    if (pastedData) {
                        for (let i = 0; i < pastedData.length; i++) {
                            if (inputs[i]) {
                                inputs[i].value = pastedData[i];
                            }
                        }
                        updateHiddenInput();
                        const nextEmpty = Math.min(pastedData.length, 5);
                        inputs[nextEmpty].focus();
                    }
                });
            });

            function updateHiddenInput() {
                let otpValue = '';
                inputs.forEach(input => {
                    otpValue += input.value;
                });
                hiddenInput.value = otpValue;
            }

            const title = document.querySelector('.title-main');
            
            function updateTitleColor() {
                if(document.body.classList.contains('light-mode')) {
                    title.classList.remove('text-white');
                    title.classList.add('text-dark');
                } else {
                    title.classList.remove('text-dark');
                    title.classList.add('text-white');
                }
            }
            
            updateTitleColor();
            
            const themeBtn = document.querySelector('.theme-toggle-btn');
            themeBtn.addEventListener('click', () => {
                setTimeout(updateTitleColor, 50);
            });
            
            let timeLeft = 60;
            const resendBtn = document.getElementById('resendBtn');
            const countdownSpan = document.getElementById('countdownSpan');
            
            let timer = setInterval(() => {
                timeLeft--;
                countdownSpan.innerText = `<fmt:message key="otp.resend_in" /> ${timeLeft}s`;
                if (timeLeft <= 0) {
                    clearInterval(timer);
                    resendBtn.disabled = false;
                    resendBtn.classList.remove('btn-outline-secondary');
                    resendBtn.classList.add('btn-outline-light');
                    countdownSpan.innerText = '<fmt:message key="otp.resend_code" />';
                }
            }, 1000);

            resendBtn.addEventListener('click', (e) => {
                e.preventDefault();
                resendBtn.disabled = true;
                resendBtn.classList.remove('btn-outline-light');
                resendBtn.classList.add('btn-outline-secondary');
                countdownSpan.innerText = '<fmt:message key="otp.sending" />';
                
                fetch('resendOtp', { method: 'POST' })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            timeLeft = 60;
                            countdownSpan.innerText = `<fmt:message key="otp.resend_in" /> ${timeLeft}s`;
                            timer = setInterval(() => {
                                timeLeft--;
                                countdownSpan.innerText = `<fmt:message key="otp.resend_in" /> ${timeLeft}s`;
                                if (timeLeft <= 0) {
                                    clearInterval(timer);
                                    resendBtn.disabled = false;
                                    resendBtn.classList.remove('btn-outline-secondary');
                                    resendBtn.classList.add('btn-outline-light');
                                    countdownSpan.innerText = '<fmt:message key="otp.resend_code" />';
                                }
                            }, 1000);
                        } else {
                            alert('<fmt:message key="otp.error_resend" /> ' + (data.message || '<fmt:message key="otp.unknown_error" />'));
                            countdownSpan.innerText = '<fmt:message key="otp.resend_code" />';
                            resendBtn.disabled = false;
                            resendBtn.classList.remove('btn-outline-secondary');
                            resendBtn.classList.add('btn-outline-light');
                        }
                    }).catch(err => {
                        alert('<fmt:message key="otp.network_error" />');
                        countdownSpan.innerText = '<fmt:message key="otp.resend_code" />';
                        resendBtn.disabled = false;
                        resendBtn.classList.remove('btn-outline-secondary');
                        resendBtn.classList.add('btn-outline-light');
                    });
            });
        });
    </script>
</body>
</html>