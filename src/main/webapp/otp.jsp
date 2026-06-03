<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
    <title>Verificación OTP - Asama Moto Parts</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root { --accent-orange: #FF6B35; }
        body {
            font-family: 'Inter', sans-serif;
            background: #0a0a0a;
            color: #f0f0f0;
            display: flex; align-items: center; justify-content: center; min-height: 100vh;
        }
        .otp-card {
            background: #1a1a1a;
            border-radius: 20px;
            padding: 40px;
            width: 100%; max-width: 420px;
            box-shadow: 0 20px 60px rgba(255,107,53,0.08);
            border: 1px solid rgba(255,255,255,0.06);
            text-align: center;
        }
        .otp-icon {
            width: 70px; height: 70px;
            background: linear-gradient(135deg, var(--accent-orange), #E55A2B);
            border-radius: 50%; display: flex; align-items: center; justify-content: center;
            margin: 0 auto 20px; font-size: 1.8rem; color: #fff;
        }
        .otp-display {
            background: #2D3436;
            border: 2px dashed var(--accent-orange);
            border-radius: 12px;
            padding: 15px;
            font-size: 2rem;
            font-weight: 800;
            letter-spacing: 12px;
            color: var(--accent-orange);
            margin: 20px 0;
            font-family: 'Courier New', monospace;
        }
        .form-control {
            background: #2D3436; border: 1px solid rgba(255,255,255,0.1); color: #fff;
            border-radius: 12px; padding: 14px; font-size: 1.2rem; text-align: center;
            letter-spacing: 8px; font-weight: 700;
        }
        .form-control:focus { background: #2D3436; color: #fff; border-color: var(--accent-orange); box-shadow: 0 0 0 3px rgba(255,107,53,0.15); }
        .btn-verify {
            background: var(--accent-orange); color: #fff; border: none;
            border-radius: 30px; padding: 12px; font-weight: 600; width: 100%;
            transition: 0.3s; font-size: 1rem;
        }
        .btn-verify:hover { background: #E55A2B; color: #fff; transform: translateY(-1px); }
        .sim-badge {
            display: inline-block; padding: 4px 12px; border-radius: 20px;
            font-size: 0.7rem; font-weight: 600; background: rgba(255,107,53,0.15);
            color: var(--accent-orange); border: 1px solid rgba(255,107,53,0.3);
            margin-bottom: 10px;
        }
    </style>
    <link rel="stylesheet" href="resources/theme.css">
</head>
<body>
<script src="resources/theme.js"></script>
    <div style="position:fixed; top:16px; right:16px; z-index:1000;">
        <button onclick="toggleTheme()" class="theme-toggle-btn" title="Cambiar tema">
            <i id="themeIcon" class="bi bi-sun-fill"></i>
        </button>
    </div>
    <div class="otp-card">
        <div class="otp-icon"><i class="bi bi-shield-lock"></i></div>
        <h3 class="fw-bold mb-1">Verificación OTP</h3>
        <p class="text-secondary small mb-3">Ingresa el código de seguridad para acceder</p>
        
        <span class="sim-badge"><i class="bi bi-info-circle me-1"></i>Simulación — Tu código es:</span>
        <div class="otp-display"><%= otpCode %></div>
        
        <% if(request.getAttribute("error") != null) { %>
            <div class="alert alert-danger py-2 small mb-3"><%= request.getAttribute("error") %></div>
        <% } %>
        
        <form action="verifyOtp" method="POST">
            <div class="mb-3">
                <input type="text" name="otp" class="form-control" placeholder="------" maxlength="6" required autofocus
                       pattern="[0-9]{6}" title="Ingresa los 6 dígitos">
            </div>
            <button type="submit" class="btn-verify">Verificar e Ingresar</button>
        </form>
        <div class="text-center mt-3">
            <a href="login.jsp" class="text-secondary text-decoration-none small"><i class="bi bi-arrow-left me-1"></i>Volver al login</a>
        </div>
    </div>
</body>
</html>
