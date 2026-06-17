<%@ page import="java.util.List" %>
<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || sessionUser.getRoleId() != 1) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="<fmt:message key='app.lang' />">
<head>
    <meta charset="UTF-8">
    <title><fmt:message key="employees.title" /></title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <script src="https://cdn.jsdelivr.net/npm/jsbarcode@3.11.5/dist/JsBarcode.all.min.js"></script>
    <link rel="stylesheet" href="resources/theme.css?v=6">
    <style>

        /* El fondo del codigo de barras SIEMPRE debe ser blanco */
        .carnet-barcode-container {
            background: #ffffff !important;
            padding: 10px;
            border-radius: 8px;
            margin-top: 15px;
        }
        .carnet-barcode-container svg { width: 100%; height: 50px; }
        
        @media print {
            body * { visibility: hidden; }
            #printArea, #printArea * { visibility: visible; }
            #printArea { position: absolute; left: 0; top: 0; width: 100%; }
            body { background: white !important; }
        }
    </style>
</head>
<body>
<script src="resources/theme.js"></script>

<%@ include file="navbar.jsp" %>

<div class="container pb-5 mb-5" style="margin-top: 100px;">
    <div class="row g-4">
        <div class="col-lg-4 col-md-5">
            <div class="action-card h-100">
                <div class="card-header border-bottom border-secondary pb-3 mb-3">
                    <h5 class="text-accent fw-bold mb-0"><i class="bi bi-person-plus me-2"></i><fmt:message key="employees.register" /></h5>
                </div>
                <div class="card-body px-4 pb-4">
                    <form action="employees" method="POST" enctype="multipart/form-data">
                        <div class="mb-3">
                            <label class="form-label small text-secondary fw-semibold"><fmt:message key="employees.full_name" /></label>
                            <input type="text" name="fullName" class="form-control" placeholder="<fmt:message key='employees.full_name_ph' />" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small text-secondary fw-semibold"><fmt:message key="employees.document" /></label>
                            <input type="text" name="documentId" class="form-control" placeholder="<fmt:message key='employees.document_ph' />" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small text-secondary fw-semibold"><fmt:message key="employees.email" /></label>
                            <input type="email" name="email" class="form-control" placeholder="<fmt:message key='employees.email_ph' />" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small text-secondary fw-semibold"><fmt:message key="employees.temp_password" /></label>
                            <input type="password" name="password" class="form-control" placeholder="<fmt:message key='employees.temp_password_ph' />" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small text-secondary fw-semibold"><fmt:message key="employees.role" /></label>
                            <select name="roleId" class="form-select" required>
                                <option value="" disabled selected><fmt:message key="employees.sel_role" /></option>
                                <option value="1"><fmt:message key="role.admin" /></option>
                                <option value="2"><fmt:message key="role.accountant" /></option>
                                <option value="3"><fmt:message key="role.warehouse" /></option>
                                <option value="4"><fmt:message key="role.cashier" /></option>
                                <option value="6"><fmt:message key="role.mechanic" /></option>
                            </select>
                        </div>
                        <div class="mb-4">
                            <label class="form-label text-secondary small fw-semibold"><fmt:message key="employees.photo" /></label>
                            <input type="file" name="photo" class="form-control" accept="image/jpeg, image/png" required>
                        </div>
                        <button type="submit" class="btn btn-accent w-100 rounded-pill fw-bold py-2">
                            <i class="bi bi-check2-circle me-1"></i> <fmt:message key="employees.btn_register" />
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <div class="col-lg-8 col-md-7">
            <div class="d-flex justify-content-between align-items-center mb-4 border-bottom border-secondary pb-3">
                <h4 class="fw-bold mb-0 text-accent"><i class="bi bi-person-badge me-2"></i><fmt:message key="employees.generated" /></h4>
                <button class="btn btn-moto-outline btn-sm rounded-pill px-3" onclick="window.print()">
                    <i class="bi bi-printer me-1"></i> <fmt:message key="employees.print" />
                </button>
            </div>
            
            <div class="row g-3" id="printArea">
                <% 
                    List<User> list = (List<User>) request.getAttribute("employees");
                    if(list != null && !list.isEmpty()) {
                        for(User u : list) {
                %>
                <div class="col-xl-6 col-lg-12">
                    <div class="carnet-card d-flex flex-column h-100">
                        <% if(u.getPhotoPath() != null && !u.getPhotoPath().isEmpty()) { %>
                            <img src="<%= u.getPhotoPath() %>?t=<%= System.currentTimeMillis() %>" class="carnet-photo mx-auto" alt="Foto">
                        <% } else { %>
                            <div class="carnet-photo mx-auto">
                                <b><%= u.getFullName().substring(0,1).toUpperCase() %></b>
                            </div>
                        <% } %>
                        <h5 class="mb-1 fw-bold text-truncate"><%= u.getFullName() %></h5>
                        <p class="mb-3 text-secondary small">ID: <%= u.getDocumentId() %></p>
                        
                        <% 
                            String role = "<fmt:message key='employees.role_employee' />";
                            if(u.getRoleId() == 1) role = "<fmt:message key='role.admin' />";
                            else if(u.getRoleId() == 2) role = "<fmt:message key='role.accountant' />";
                            else if(u.getRoleId() == 3) role = "<fmt:message key='role.warehouse' />";
                            else if(u.getRoleId() == 4) role = "<fmt:message key='role.cashier' />";
                            else if(u.getRoleId() == 6) role = "<fmt:message key='role.mechanic' />";
                        %>
                        <div class="mt-auto">
                            <span class="badge role-badge px-3 py-2 fs-6 mb-2"><%= role %></span>
                            
                            <div class="carnet-barcode-container">
                                <svg id="barcode-<%= u.getId() %>"></svg>
                                <script>
                                    JsBarcode("#barcode-<%= u.getId() %>", "<%= u.getBarcode() %>", {
                                        format: "CODE128",
                                        displayValue: true,
                                        height: 40,
                                        fontSize: 14,
                                        margin: 0,
                                        background: "#ffffff",
                                        lineColor: "#000000"
                                    });
                                </script>
                            </div>
                            
                            <div class="d-flex justify-content-center gap-2 mt-4 d-print-none">
                                <button class="btn btn-sm btn-outline-warning rounded-pill px-3" onclick="openEditModal(<%= u.getId() %>, '<%= u.getFullName().replace("'", "\\'") %>', '<%= u.getDocumentId() %>', '<%= u.getEmail() %>', <%= u.getRoleId() %>)">
                                    <i class="bi bi-pencil"></i> <fmt:message key="employees.btn_edit" />
                                </button>
                                <% if(u.getId() != 1) { %>
                                <form action="employees" method="POST" class="d-inline" onsubmit="return confirm('<fmt:message key="employees.del_confirm" />');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<%= u.getId() %>">
                                    <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill px-3"><i class="bi bi-trash"></i></button>
                                </form>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
                <%      }
                    } else {
                        out.print("<div class='col-12 text-center text-secondary py-5'><i class='bi bi-people fs-1 d-block mb-3'></i><fmt:message key='employees.empty' /></div>");
                    }
                %>
            </div>
        </div>
    </div>
</div>

<div class="modal fade d-print-none" id="editModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-secondary">
      <div class="modal-header border-secondary">
        <h5 class="modal-title text-accent fw-bold"><i class="bi bi-person-lines-fill me-2"></i><fmt:message key="employees.edit_title" /></h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter: var(--close-btn-filter);"></button>
      </div>
      <form action="employees" method="POST" enctype="multipart/form-data">
          <div class="modal-body p-4">
              <input type="hidden" name="action" value="edit">
              <input type="hidden" name="id" id="editId">
              <div class="mb-3">
                  <label class="form-label text-secondary small fw-semibold"><fmt:message key="employees.full_name" /></label>
                  <input type="text" name="fullName" id="editName" class="form-control" required>
              </div>
              <div class="mb-3">
                  <label class="form-label text-secondary small fw-semibold"><fmt:message key="employees.edit_doc" /></label>
                  <input type="text" name="documentId" id="editDoc" class="form-control" required>
              </div>
              <div class="mb-3">
                  <label class="form-label text-secondary small fw-semibold"><fmt:message key="employees.edit_email" /></label>
                  <input type="email" name="email" id="editEmail" class="form-control" required>
              </div>
              <div class="mb-3">
                  <label class="form-label text-secondary small fw-semibold"><fmt:message key="employees.edit_role" /></label>
                  <select name="roleId" id="editRole" class="form-select" required>
                      <option value="1"><fmt:message key="role.admin" /></option>
                      <option value="2"><fmt:message key="role.accountant" /></option>
                      <option value="3"><fmt:message key="role.warehouse" /></option>
                      <option value="4"><fmt:message key="role.cashier" /></option>
                      <option value="6"><fmt:message key="role.mechanic" /></option>
                  </select>
              </div>
              <div class="mb-3">
                  <label class="form-label text-secondary small fw-semibold"><fmt:message key="employees.edit_pwd" /></label>
                  <input type="password" name="password" id="editPassword" class="form-control" placeholder="<fmt:message key='employees.edit_pwd_ph' />">
              </div>
              <div class="mb-3">
                  <label class="form-label text-secondary small fw-semibold"><fmt:message key="employees.upd_photo" /></label>
                  <input type="file" name="photo" class="form-control" accept="image/jpeg, image/png">
              </div>
          </div>
          <div class="modal-footer border-secondary">
            <button type="button" class="btn btn-outline-secondary rounded-pill" data-bs-dismiss="modal"><fmt:message key="employees.cancel" /></button>
            <button type="submit" class="btn btn-accent rounded-pill fw-bold"><fmt:message key="employees.save" /></button>
          </div>
      </form>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function openEditModal(id, name, doc, email, roleId) {
        document.getElementById('editId').value = id;
        document.getElementById('editName').value = name;
        document.getElementById('editDoc').value = doc;
        document.getElementById('editEmail').value = email;
        document.getElementById('editRole').value = roleId;
        new bootstrap.Modal(document.getElementById('editModal')).show();
    }
    
    // Invertir el color del boton cerrar del modal en modo oscuro
    document.addEventListener("DOMContentLoaded", function() {
        const isLight = document.body.classList.contains('light-mode');
        document.documentElement.style.setProperty('--close-btn-filter', isLight ? 'none' : 'invert(1) grayscale(100%) brightness(200%)');
    });
</script>
</body>
</html>