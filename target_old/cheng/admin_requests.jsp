<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRoleId() != 1) { // Solo administradores
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Garantías y Devoluciones - Asama Moto Parts</title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="resources/theme.css?v=6">
</head>
<body>
<script src="resources/theme.js"></script>

<%@ include file="navbar.jsp" %>

<div class="container py-5 mt-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold"><i class="bi bi-shield-check text-accent me-2"></i>Gestión de Garantías y Devoluciones</h2>
    </div>

    <div class="card-custom">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Fecha</th>
                        <th>Cliente</th>
                        <th>Repuesto</th>
                        <th>Tipo</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody id="requestsTableBody">
                    <tr><td colspan="7" class="text-center">Cargando solicitudes...</td></tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Modal para Ver y Contestar -->
<div class="modal fade" id="requestModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content asama-modal">
            <div class="modal-header">
                <h5 class="modal-title fw-bold">Detalles de Solicitud #<span id="modalReqId"></span></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="adminRequests" method="POST">
                <div class="modal-body">
                    <input type="hidden" name="request_id" id="formReqId">
                    <input type="hidden" name="action" value="process">
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <p class="mb-1 text-secondary small">Cliente:</p>
                            <p class="fw-medium" id="modalClient"></p>
                        </div>
                        <div class="col-md-6">
                            <p class="mb-1 text-secondary small">Repuesto:</p>
                            <p class="fw-medium" id="modalProduct"></p>
                        </div>
                        <div class="col-md-6">
                            <p class="mb-1 text-secondary small">Motivo / Daño:</p>
                            <p class="fw-medium" id="modalDamage"></p>
                        </div>
                        <div class="col-md-6">
                            <p class="mb-1 text-secondary small">Tipo:</p>
                            <p class="fw-medium" id="modalType"></p>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <p class="mb-1 text-secondary small">Descripción proporcionada:</p>
                        <div class="p-3 bg-secondary bg-opacity-10 rounded border border-secondary border-opacity-25" id="modalDesc"></div>
                    </div>

                    <div class="mb-3 text-center">
                        <p class="mb-1 text-secondary small text-start">Imagen Adjunta:</p>
                        <img id="modalImage" src="" alt="Imagen adjunta" class="img-fluid rounded" style="max-height: 300px; display: none;">
                        <a id="modalImageLink" href="#" target="_blank" class="btn btn-sm btn-outline-secondary mt-2" style="display: none;"><i class="bi bi-box-arrow-up-right me-1"></i>Abrir en nueva pestaña</a>
                    </div>

                    <hr>

                    <h6 class="fw-bold mb-3 text-accent">Resolución del Administrador</h6>
                    <div class="mb-3">
                        <label class="form-label">Estado de la Solicitud</label>
                        <select name="status" id="formStatus" class="form-select" required>
                            <option value="PENDIENTE">PENDIENTE</option>
                            <option value="APROBADA">APROBADA (Generar Reporte)</option>
                            <option value="RECHAZADA">RECHAZADA</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Respuesta al Cliente</label>
                        <textarea name="admin_reply" id="formReply" class="form-control" rows="3" placeholder="Escribe el motivo de la aprobación o rechazo..." required></textarea>
                    </div>

                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Cerrar</button>
                    <button type="submit" class="btn btn-accent rounded-pill">Guardar Resolución</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        fetch('adminRequests?action=list')
            .then(res => res.json())
            .then(data => {
                const tbody = document.getElementById('requestsTableBody');
                tbody.innerHTML = '';
                if(data.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="7" class="text-center text-muted py-4">No hay solicitudes registradas.</td></tr>';
                    return;
                }
                
                data.forEach(req => {
                    let badgeClass = req.status === 'PENDIENTE' ? 'bg-warning text-dark' : 
                                    (req.status === 'APROBADA' ? 'bg-success' : 'bg-danger');
                                    
                    tbody.innerHTML += `
                        <tr>
                            <td>#`+req.id+`</td>
                            <td>`+req.created_at+`</td>
                            <td class="fw-medium">`+req.customer_name+`</td>
                            <td>`+req.product_name+`</td>
                            <td><span class="badge bg-secondary">`+req.request_type+`</span></td>
                            <td><span class="badge `+badgeClass+`">`+req.status+`</span></td>
                            <td>
                                <button class="btn btn-sm btn-outline-info rounded-pill px-3" onclick='openModal(`+JSON.stringify(req)+`)'>
                                    Ver Detalle
                                </button>
                            </td>
                        </tr>
                    `;
                });
            });
    });

    function openModal(req) {
        document.getElementById('modalReqId').textContent = req.id;
        document.getElementById('formReqId').value = req.id;
        document.getElementById('modalClient').textContent = req.customer_name;
        document.getElementById('modalProduct').textContent = req.product_name;
        document.getElementById('modalDamage').textContent = req.damage;
        document.getElementById('modalType').textContent = req.request_type;
        document.getElementById('modalDesc').textContent = req.description;
        
        document.getElementById('formStatus').value = req.status;
        document.getElementById('formReply').value = req.admin_reply || '';
        
        const img = document.getElementById('modalImage');
        const imgLink = document.getElementById('modalImageLink');
        if(req.image_path) {
            img.src = req.image_path;
            img.style.display = 'inline-block';
            imgLink.href = req.image_path;
            imgLink.style.display = 'inline-block';
        } else {
            img.style.display = 'none';
            imgLink.style.display = 'none';
        }
        
        const modal = new bootstrap.Modal(document.getElementById('requestModal'));
        modal.show();
    }
</script>
</body>
</html>
