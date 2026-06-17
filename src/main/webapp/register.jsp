<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="register.title" /></title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <link rel="stylesheet" href="resources/theme.css?v=6">
</head>
<body class="body-center">
<script src="resources/theme.js"></script>
    <div style="position:fixed; top:16px; right:16px; z-index:1000;">
        <button onclick="toggleTheme()" class="theme-toggle-btn" title="<fmt:message key='register.theme_toggle' />">
            <i id="themeIcon" class="bi bi-sun-fill"></i>
        </button>
    </div>

    <div class="register-card">
        <div class="text-center mb-4">
            <div class="brand-icon"><i class="bi bi-bicycle"></i></div>
            <h3 class="fw-bold mb-1"><fmt:message key="register.create_account" /></h3>
            <p class="text-secondary small"><fmt:message key="register.join_us" /></p>
        </div>

        <!-- SweetAlert2 for Registration Errors -->
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <% if(request.getAttribute("error") != null) { %>
            <script>
                document.addEventListener("DOMContentLoaded", function() {
                    Swal.fire({
                        icon: 'error',
                        title: '<fmt:message key="register.error_title" />',
                        text: '<%= request.getAttribute("error") %>',
                        confirmButtonColor: getComputedStyle(document.documentElement).getPropertyValue('--accent-orange').trim(),
                        background: document.body.classList.contains('light-mode') ? '#fff' : '#1a1a1a',
                        color: document.body.classList.contains('light-mode') ? '#000' : '#fff'
                    });
                });
            </script>
        <% } %>

        <form action="register" method="POST">
            <div class="mb-3">
                <input type="text" name="fullName" class="form-control" placeholder="<fmt:message key='register.fullname' />" required>
            </div>
            <div class="mb-3">
                <input type="text" name="documentId" class="form-control" placeholder="<fmt:message key='register.document' />" required>
            </div>
            <div class="mb-3">
                <input type="email" name="email" class="form-control" placeholder="<fmt:message key='register.email' />" required>
            </div>
            <div class="mb-3">
                <input type="password" id="password" name="password" class="form-control" placeholder="<fmt:message key='register.password' />" required>
                <div id="passwordStrength" class="form-text mt-1" style="font-size: 0.8rem;"></div>
            </div>
            <div class="mb-4">
                <input type="password" id="confirmPassword" class="form-control" placeholder="<fmt:message key='register.confirm_password' />" required>
                <div id="passwordMatchError" class="text-danger mt-1" style="display: none; font-size: 0.8rem;"><fmt:message key="register.password_mismatch" /></div>
            </div>
            <button type="submit" id="submitBtn" class="btn-moto" disabled><fmt:message key="register.submit" /></button>
        </form>

        <div class="text-center mt-4">
            <span class="text-secondary small"><fmt:message key="register.have_account" /> </span>
            <a href="login.jsp" class="text-orange text-decoration-none small fw-bold"><fmt:message key="register.login" /></a>
        </div>
    </div>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const password = document.getElementById('password');
            const confirmPassword = document.getElementById('confirmPassword');
            const strengthText = document.getElementById('passwordStrength');
            const matchError = document.getElementById('passwordMatchError');
            const submitBtn = document.getElementById('submitBtn');

            function checkPasswordStrength(pass) {
                if (pass.length === 0) return { text: '', color: '' };
                if (pass.length < 6) return { text: '<fmt:message key="register.pwd_too_short" />', color: 'text-danger' };
                if (pass.length > 20) return { text: '<fmt:message key="register.pwd_too_long" />', color: 'text-danger' };
                
                let strength = 0;
                if (pass.match(/[a-z]+/)) strength += 1;
                if (pass.match(/[A-Z]+/)) strength += 1;
                if (pass.match(/[0-9]+/)) strength += 1;
                if (pass.match(/[\W]+/)) strength += 1;

                if (strength <= 2) return { text: '<fmt:message key="register.pwd_unsafe" />', color: 'text-warning' };
                if (strength === 3) return { text: '<fmt:message key="register.pwd_good" />', color: 'text-primary' };
                return { text: '<fmt:message key="register.pwd_strong" />', color: 'text-success' };
            }

            function validateForm() {
                const passValue = password.value;
                const confirmValue = confirmPassword.value;
                
                const strength = checkPasswordStrength(passValue);
                strengthText.textContent = strength.text;
                strengthText.className = 'form-text mt-1 fw-bold ' + strength.color;

                let isValid = true;

                if (passValue.length < 6 || passValue.length > 20) {
                    isValid = false;
                }

                if (confirmValue.length > 0) {
                    if (passValue !== confirmValue) {
                        matchError.style.display = 'block';
                        isValid = false;
                    } else {
                        matchError.style.display = 'none';
                    }
                } else {
                    matchError.style.display = 'none';
                    isValid = false;
                }

                submitBtn.disabled = !isValid;
            }

            password.addEventListener('input', validateForm);
            confirmPassword.addEventListener('input', validateForm);
        });
    </script>
</body>
</html>
