<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi Perfil | Asama Moto Parts</title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        .profile-header {
            text-align: center;
            margin-bottom: 2rem;
            position: relative;
        }
        .profile-avatar-large {
            width: 120px;
            height: 120px;
            font-size: 3rem;
            border-radius: 50%;
            background: var(--accent-orange);
            color: #121417;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 15px;
            box-shadow: 0 10px 30px var(--accent-glow);
            font-weight: 800;
        }
        .form-control:disabled {
            background-color: rgba(255, 255, 255, 0.02) !important;
            opacity: 0.7;
            cursor: not-allowed;
        }
        body.light-mode .form-control:disabled {
            background-color: rgba(0, 0, 0, 0.02) !important;
        }
        .btn-edit {
            position: absolute;
            top: 0;
            right: 0;
            background: transparent;
            border: 2px solid var(--accent-orange);
            color: var(--accent-orange);
            border-radius: 30px;
            padding: 8px 20px;
            font-weight: bold;
            transition: all 0.3s ease;
        }
        .btn-edit:hover {
            background: var(--accent-orange);
            color: #1a1a1a;
            box-shadow: 0 4px 15px var(--accent-glow);
        }
    </style>
</head>
<body>
    <script src="resources/theme.js?v=2"></script>
    <jsp:include page="navbar.jsp" />
    
    <div class="container py-5 mt-5">
        <div class="row justify-content-center">
            <div class="col-md-8 col-lg-6">
                <div class="card p-4 p-md-5">
                    <div class="profile-header">
                        <button type="button" class="btn-edit" id="enableEditBtn" onclick="enableEdit()">
                            <i class="bi bi-pencil-square me-2"></i> Editar
                        </button>
                        <div class="profile-avatar-large">
                            <%= user.getFullName().substring(0, Math.min(2, user.getFullName().length())).toUpperCase() %>
                        </div>
                        <h3 class="fw-bold mb-1"><%= user.getFullName() %></h3>
                        <p class="text-secondary mb-0">Mi Información de Cuenta</p>
                    </div>

                    <form action="profile" method="POST" id="profileForm">
                        <div class="mb-4">
                            <label class="form-label text-secondary small fw-bold">Nombre Completo</label>
                            <input type="text" name="fullName" class="form-control" value="<%= user.getFullName() %>" required disabled>
                        </div>
                        <div class="mb-4">
                            <label class="form-label text-secondary small fw-bold">Documento (CC)</label>
                            <input type="text" name="documentId" class="form-control" value="<%= user.getDocumentId() %>" required disabled>
                        </div>
                        <div class="mb-4">
                            <label class="form-label text-secondary small fw-bold">Correo Electrónico</label>
                            <input type="email" name="email" class="form-control" value="<%= user.getEmail() %>" required disabled>
                            <div class="form-text text-warning small mt-2 d-none" id="emailWarning">
                                <i class="bi bi-info-circle-fill me-1"></i> Si cambias tu correo electrónico, te enviaremos un código de seguridad al nuevo correo para validarlo.
                            </div>
                        </div>

                        <!-- Action Buttons (Hidden by default) -->
                        <div class="d-flex gap-3 d-none" id="actionButtons">
                            <button type="button" class="btn btn-outline-secondary w-50 rounded-pill fw-bold" onclick="cancelEdit()">Cancelar</button>
                            <button type="submit" class="btn btn-accent w-50 rounded-pill fw-bold">Guardar Cambios</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const form = document.getElementById('profileForm');
        const inputs = form.querySelectorAll('input');
        const enableEditBtn = document.getElementById('enableEditBtn');
        const actionButtons = document.getElementById('actionButtons');
        const emailWarning = document.getElementById('emailWarning');
        const originalEmail = "<%= user.getEmail() %>";

        function enableEdit() {
            inputs.forEach(input => input.disabled = false);
            enableEditBtn.classList.add('d-none');
            actionButtons.classList.remove('d-none');
            inputs[0].focus();
        }

        function cancelEdit() {
            inputs.forEach(input => {
                input.disabled = true;
                // reset values
                input.value = input.defaultValue;
            });
            enableEditBtn.classList.remove('d-none');
            actionButtons.classList.add('d-none');
            emailWarning.classList.add('d-none');
        }

        // Show warning if email changes
        document.querySelector('input[name="email"]').addEventListener('input', function(e) {
            if(e.target.value !== originalEmail) {
                emailWarning.classList.remove('d-none');
            } else {
                emailWarning.classList.add('d-none');
            }
        });
    </script>
</body>
</html>
