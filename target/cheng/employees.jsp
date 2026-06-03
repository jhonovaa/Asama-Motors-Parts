<%@ page import="java.util.List" %>
<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || sessionUser.getRoleId() != 1) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Gestión de Empleados - Asama Moto Parts</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <script src="https://cdn.jsdelivr.net/npm/jsbarcode@3.11.5/dist/JsBarcode.all.min.js"></script>
    <style>
        :root {
            --bg-color: #0a0a0a;
            --text-color: #f0f0f0;
            --card-bg: #1a1a1a;
            --accent-orange: #FF6B35;
        }
        body { font-family: 'Inter', sans-serif; background-color: var(--bg-color); color: var(--text-color); padding-top: 60px;}
        
        .card { background: var(--card-bg); border-radius: 15px; border: 1px solid rgba(255,255,255,0.05); color: #fff; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        .card-header { background: transparent !important; border-bottom: 1px solid rgba(255,255,255,0.1); font-weight: 600; padding: 15px 20px; }
        .form-control, .form-select { background: #2D3436; border: 1px solid rgba(255,255,255,0.1); color: #fff; border-radius: 10px; }
        .form-control:focus, .form-select:focus { background: #2D3436; color: #fff; border-color: var(--accent-orange); box-shadow: 0 0 0 3px rgba(255,107,53,0.15); }
        
        .btn-moto { background-color: var(--accent-orange); color: #fff; border: none; border-radius: 10px; padding: 10px; transition: 0.3s; font-weight: 600;}
        .btn-moto:hover { background-color: #E55A2B; color: white;}
        
        .carnet-card {
            background: linear-gradient(135deg, #1a1a1a, #2D3436);
            color: white;
            border-radius: 15px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 10px 20px rgba(0,0,0,0.3);
            border: 1px solid var(--accent-orange);
            margin-bottom: 20px;
            page-break-inside: avoid;
        }
        .carnet-photo {
            width: 90px; height: 90px;
            background: #2D3436;
            border-radius: 50%;
            margin: 0 auto 15px auto;
            display: flex; align-items: center; justify-content: center;
            color: var(--accent-orange); font-size: 2.5rem;
            border: 3px solid var(--accent-orange);
            object-fit: cover;
        }
        .carnet-barcode {
            background: white;
            padding: 10px;
            border-radius: 8px;
            margin-top: 15px;
        }
        .carnet-barcode svg { width: 100%; height: 50px; }
        .text-orange { color: var(--accent-orange) !important; }
        
        @media print {
            body * { visibility: hidden; }
            #printArea, #printArea * { visibility: visible; }
            #printArea { position: absolute; left: 0; top: 0; width: 100%; }
        }
    </style>
</head>
<body>

<%@ include file="navbar.jsp" %>

<div class="container mt-4">
    <div class="row">
        <!-- Add Employee Form -->
        <div class="col-md-4 mb-4">
            <div class="card shadow-sm">
                <div class="card-header text-orange"><i class="bi bi-person-plus"></i> Registrar Empleado</div>
                <div class="card-body">
                    <form action="employees" method="POST" enctype="multipart/form-data">
                        <div class="mb-3">
                            <input type="text" name="fullName" class="form-control" placeholder="Nombre Completo" required>
                        </div>
                        <div class="mb-3">
                            <input type="text" name="documentId" class="form-control" placeholder="Cédula / Documento" required>
                        </div>
                        <div class="mb-3">
                            <input type="email" name="email" class="form-control" placeholder="Correo Electrónico" required>
                        </div>
                        <div class="mb-3">
                            <input type="password" name="password" class="form-control" placeholder="Contraseña Temporal" required>
                        </div>
                        <div class="mb-3">
                            <select name="roleId" class="form-select" required>
                                <option value="" disabled selected>Seleccione el Rol</option>
                                <option value="1">Administrador</option>
                                <option value="2">Contador</option>
                                <option value="3">Bodeguero</option>
                                <option value="4">Cajero</option>
                                <option value="6">Mecánico</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-secondary small">Foto de Perfil (Reconocimiento Facial)</label>
                            <input type="file" name="photo" class="form-control" accept="image/jpeg, image/png" required>
                        </div>
                        <button type="submit" class="btn btn-moto w-100">Registrar y Generar Carnet</button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Carnets / IDs List -->
        <div class="col-md-8">
            <div class="d-flex justify-content-between mb-3 align-items-center">
                <h4 class="fw-bold">Carnets Generados</h4>
                <button class="btn btn-secondary btn-sm" style="border-radius: 20px;" onclick="window.print()"><i class="bi bi-printer"></i> Imprimir Carnets</button>
            </div>
            
            <div class="row" id="printArea">
                <% 
                    List<User> list = (List<User>) request.getAttribute("employees");
                    if(list != null) {
                        for(User u : list) {
                %>
                <div class="col-md-6">
                    <div class="carnet-card">
                        <% if(u.getPhotoPath() != null && !u.getPhotoPath().isEmpty()) { %>
                            <img src="<%= u.getPhotoPath() %>" class="carnet-photo" alt="Foto">
                        <% } else { %>
                            <div class="carnet-photo">
                                <b><%= u.getFullName().substring(0,1).toUpperCase() %></b>
                            </div>
                        <% } %>
                        <h5 class="mb-1"><%= u.getFullName() %></h5>
                        <p class="mb-0 text-secondary small">ID: <%= u.getDocumentId() %></p>
                        
                        <% 
                            String role = "Empleado";
                            if(u.getRoleId() == 1) role = "Administrador";
                            else if(u.getRoleId() == 2) role = "Contador";
                            else if(u.getRoleId() == 3) role = "Bodeguero";
                            else if(u.getRoleId() == 4) role = "Cajero";
                            else if(u.getRoleId() == 6) role = "Mecánico";
                        %>
                        <span class="badge" style="background: rgba(255,107,53,0.2); color: var(--accent-orange); border: 1px solid var(--accent-orange);"><%= role %></span>
                        
                        <div class="carnet-barcode">
                            <svg id="barcode-<%= u.getId() %>"></svg>
                            <script>
                                JsBarcode("#barcode-<%= u.getId() %>", "<%= u.getBarcode() %>", {
                                    format: "CODE128",
                                    displayValue: true,
                                    height: 35,
                                    fontSize: 12,
                                    margin: 0
                                });
                            </script>
                        </div>
                    </div>
                </div>
                <%      }
                    }
                %>
            </div>
        </div>
    </div>
</div>
</body>
</html>
