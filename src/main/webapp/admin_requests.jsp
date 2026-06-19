<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
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
    <title><fmt:message key="admin_requests.title" /></title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
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

        /* Formularios */
        .form-label {
            font-weight: 600 !important;
            color: var(--text-color) !important;
            font-size: 0.95rem;
            margin-bottom: 0.5rem;
        }
        .form-control, .form-select, textarea {
            background-color: rgba(255, 255, 255, 0.05) !important;
            color: #ffffff !important;
            border: 1px solid rgba(255, 255, 255, 0.15) !important;
            font-weight: 500;
            padding: 10px 15px;
        }
        .form-control::placeholder, textarea::placeholder {
            color: rgba(255, 255, 255, 0.4) !important;
        }
        .form-control:focus, .form-select:focus, textarea:focus {
            background-color: rgba(255, 255, 255, 0.08) !important;
            border-color: var(--accent-orange) !important;
            box-shadow: 0 0 0 0.25rem var(--accent-glow) !important;
        }
        body.light-mode .form-control, body.light-mode .form-select, body.light-mode textarea {
            background-color: #ffffff !important;
            color: #212529 !important;
            border-color: rgba(0, 0, 0, 0.15) !important;
        }
        body.light-mode .form-control::placeholder, body.light-mode textarea::placeholder {
            color: rgba(0, 0, 0, 0.5) !important;
        }

        /* Tablas: Forzar contraste sobreescribiendo Bootstrap */
        .table { 
            --bs-table-bg: transparent;
            --bs-table-color: var(--text-color);
            color: var(--text-color) !important; 
        }
        .table th { 
            font-weight: 700 !important; 
            letter-spacing: 0.5px; 
            font-size: 0.85rem; 
            border-bottom: 2px solid var(--card-border) !important; 
            color: rgba(255, 255, 255, 0.7) !important;
        }
        body.light-mode .table th {
            color: rgba(0, 0, 0, 0.6) !important;
        }
        .table td { 
            font-weight: 600 !important; 
            font-size: 0.95rem !important; 
            border-bottom: 1px solid var(--card-border) !important; 
            vertical-align: middle; 
            color: var(--text-color) !important; 
        }
        .table tbody tr:hover td { 
            background-color: rgba(255, 255, 255, 0.08) !important; 
        }
        body.light-mode .table tbody tr:hover td { 
            background-color: rgba(0, 0, 0, 0.04) !important; 
        }
    </style>
</head>
<body>
<script src="resources/theme.js?v=2"></script>

<%@ include file="navbar.jsp" %>

<div class="container-fluid px-4 py-5 mb-5" style="margin-top: 100px; max-width: 1400px;">
    <div class="d-flex align-items-center mb-4 border-bottom border-secondary pb-3">
        <div class="brand-icon me-3" style="width: 50px; height: 50px; font-size: 24px; background-color: var(--accent-orange); color: #121417; border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 15px var(--accent-glow);">
            <i class="bi bi-shield-check"></i>
        </div>
        <h2 class="fw-bold mb-0 text-accent"><fmt:message key="admin_requests.header" /></h2>
    </div>

    <div class="action-card p-4">
        <div class="table-responsive" style="max-height: 65vh; overflow-y: auto;">
            <table class="table table-hover align-middle table-borderless">
                <thead class="sticky-top" style="background: var(--card-bg); z-index: 10;">
                    <tr>
                        <th class="text-uppercase pb-3"><fmt:message key="admin_requests.th.id" /></th>
                        <th class="text-uppercase pb-3"><fmt:message key="admin_requests.th.date" /></th>
                        <th class="text-uppercase pb-3"><fmt:message key="admin_requests.th.client" /></th>
                        <th class="text-uppercase pb-3"><fmt:message key="admin_requests.th.spare" /></th>
                        <th class="text-uppercase pb-3 text-center"><fmt:message key="admin_requests.th.type" /></th>
                        <th class="text-uppercase pb-3 text-center"><fmt:message key="admin_requests.th.status" /></th>
                        <th class="text-uppercase pb-3 text-center"><fmt:message key="admin_requests.th.actions" /></th>
                    </tr>
                </thead>
                <tbody id="requestsTableBody">
                    <tr><td colspan="7" class="text-center text-secondary py-5 fw-bold"><div class="spinner-border spinner-border-sm me-2"></div><fmt:message key="admin_requests.loading" /></td></tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<div class="modal fade" id="requestModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content border-secondary shadow-lg" style="background-color: var(--card-bg); color: var(--text-color);">
            <div class="modal-header border-secondary border-opacity-25 pb-3">
                <h5 class="modal-title fw-bold text-accent"><i class="bi bi-file-earmark-text me-2"></i><fmt:message key="admin_requests.modal.title" /><span id="modalReqId"></span></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" style="filter: var(--close-btn-filter);"></button>
            </div>
            <form action="adminRequests" method="POST">
                <div class="modal-body p-4">
                    <input type="hidden" name="request_id" id="formReqId">
                    <input type="hidden" name="action" value="process">
                    
                    <div class="bg-dark bg-opacity-25 rounded-4 p-4 mb-4 border border-secondary border-opacity-25 shadow-sm">
                        <div class="row g-4">
                            <div class="col-md-6">
                                <p class="mb-1 text-secondary small fw-bold text-uppercase letter-spacing-1"><i class="bi bi-person me-1"></i> <fmt:message key="admin_requests.modal.client" /></p>
                                <p class="fw-bolder fs-5 mb-0" id="modalClient"></p>
                            </div>
                            <div class="col-md-6">
                                <p class="mb-1 text-secondary small fw-bold text-uppercase letter-spacing-1"><i class="bi bi-box-seam me-1"></i> <fmt:message key="admin_requests.modal.spare" /></p>
                                <p class="fw-bolder fs-5 mb-0" id="modalProduct"></p>
                            </div>
                            <div class="col-md-6">
                                <p class="mb-1 text-secondary small fw-bold text-uppercase letter-spacing-1"><i class="bi bi-exclamation-triangle me-1"></i> <fmt:message key="admin_requests.modal.reason" /></p>
                                <p class="fw-bold fs-6 mb-0" id="modalDamage"></p>
                            </div>
                            <div class="col-md-6">
                                <p class="mb-1 text-secondary small fw-bold text-uppercase letter-spacing-1"><i class="bi bi-tag me-1"></i> <fmt:message key="admin_requests.modal.type" /></p>
                                <p class="fw-bold fs-6 mb-0" id="modalType"></p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="mb-4">
                        <p class="mb-2 text-secondary small fw-bold text-uppercase letter-spacing-1"><i class="bi bi-chat-left-text me-1"></i> <fmt:message key="admin_requests.modal.desc" /></p>
                        <div class="p-3 rounded-3 border border-secondary border-opacity-25 shadow-inner" style="background-color: rgba(255,255,255,0.03); min-height: 80px;" id="modalDesc"></div>
                    </div>

                    <div class="mb-4 text-center">
                        <p class="mb-2 text-secondary small fw-bold text-uppercase letter-spacing-1 text-start"><i class="bi bi-image me-1"></i> <fmt:message key="admin_requests.modal.evidence" /></p>
                        <img id="modalImage" src="" alt="<fmt:message key='admin_requests.alt_image' />" class="img-fluid rounded-3 shadow-sm border border-secondary border-opacity-25" style="max-height: 250px; display: none;">
                        <a id="modalImageLink" href="#" target="_blank" class="btn btn-sm btn-moto-outline mt-3 rounded-pill fw-bold" style="display: none;"><i class="bi bi-box-arrow-up-right me-1"></i><fmt:message key="admin_requests.open_image" /></a>
                    </div>

                    <hr class="border-secondary opacity-25 my-4">

                    <h6 class="fw-bold mb-3 text-accent fs-5"><i class="bi bi-hammer me-2"></i><fmt:message key="admin_requests.admin_resolution" /></h6>
                    <div class="mb-3">
                        <label class="form-label"><fmt:message key="admin_requests.request_status" /></label>
                        <select name="status" id="formStatus" class="form-select fw-bold" required>
                            <option value="PENDIENTE"><fmt:message key="admin_requests.status.pending" /></option>
                            <option value="APROBADA"><fmt:message key="admin_requests.status.approved" /></option>
                            <option value="RECHAZADA"><fmt:message key="admin_requests.status.rejected" /></option>
                        </select>
                    </div>
                    <div class="mb-2">
                        <label class="form-label"><fmt:message key="admin_requests.official_reply" /></label>
                        <textarea name="admin_reply" id="formReply" class="form-control" rows="3" placeholder="<fmt:message key='admin_requests.placeholder_reply' />" required></textarea>
                    </div>

                </div>
                <div class="modal-footer border-secondary border-opacity-25 pt-3">
                    <button type="button" class="btn btn-outline-secondary rounded-pill fw-bold px-4" data-bs-dismiss="modal"><fmt:message key="admin_requests.close" /></button>
                    <button type="submit" class="btn btn-accent rounded-pill fw-bold px-4"><i class="bi bi-save me-1"></i> <fmt:message key="admin_requests.save" /></button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const isLight = document.body.classList.contains('light-mode');
        document.documentElement.style.setProperty('--close-btn-filter', isLight ? 'none' : 'invert(1) grayscale(100%) brightness(200%)');

        fetch('adminRequests?action=list')
            .then(res => res.json())
            .then(data => {
                const tbody = document.getElementById('requestsTableBody');
                tbody.innerHTML = '';
                if(data.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="7" class="text-center text-secondary py-5 fw-bold"><i class="bi bi-inbox fs-1 d-block mb-3"></i><fmt:message key="admin_requests.no_requests" /></td></tr>';
                    return;
                }
                
                data.forEach(req => {
                    let badgeClass = req.status === 'PENDIENTE' ? 'bg-warning text-dark border-warning' : 
                                     (req.status === 'APROBADA' ? 'bg-success border-success' : 'bg-danger border-danger');
                    let badgeOpacity = 'bg-opacity-25 border border-opacity-50 px-3 py-2';
                    
                    let typeBadge = req.request_type === 'Garantia' ? 'bg-info text-info' : 'bg-primary text-primary';
                                        
                    tbody.innerHTML += `
                        <tr>
                            <td class="text-muted fw-bold">#`+req.id+`</td>
                            <td class="text-secondary small">`+req.created_at+`</td>
                            <td class="fw-bolder">`+req.customer_name+`</td>
                            <td class="fw-medium">`+req.product_name+`</td>
                            <td class="text-center"><span class="badge `+typeBadge+` bg-opacity-10 border border-opacity-25 px-2 py-1 fs-6">`+req.request_type+`</span></td>
                            <td class="text-center"><span class="badge `+badgeClass+` `+badgeOpacity+` rounded-pill fw-bolder fs-6">`+req.status+`</span></td>
                            <td class="text-center">
                                <button class="btn btn-sm btn-moto-outline rounded-pill px-4 fw-bold shadow-sm" onclick='openModal(`+JSON.stringify(req)+`)'>
                                    <i class="bi bi-eye"></i> <fmt:message key="admin_requests.review" />
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
        
        let typeIcon = req.request_type === 'Garantia' ? '<i class="bi bi-shield-check text-info me-1"></i>' : '<i class="bi bi-arrow-return-left text-primary me-1"></i>';
        document.getElementById('modalType').innerHTML = typeIcon + req.request_type;
        
        document.getElementById('modalDesc').textContent = req.description || '<fmt:message key="admin_requests.no_desc" />';
        
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
