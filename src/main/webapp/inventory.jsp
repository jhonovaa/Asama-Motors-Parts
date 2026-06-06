<%@ page import="java.util.List" %>
<%@ page import="com.adso.cheng.models.Product" %>
<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || (sessionUser.getRoleId() != 1 && sessionUser.getRoleId() != 3)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Inventario - Asama Moto Parts</title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <script src="https://cdn.jsdelivr.net/npm/jsbarcode@3.11.5/dist/JsBarcode.all.min.js"></script>
    <link rel="stylesheet" href="resources/theme.css?v=6">
    <style>

        /* Codigo de Barras Blanco para Escaneres */
        .inventory-barcode-container {
            background: #ffffff !important;
            padding: 5px;
            border-radius: 8px;
            display: inline-block;
        }
        .inventory-barcode-container svg { height: 35px; width: auto; }
    </style>
</head>
<body>
<script src="resources/theme.js"></script>

<%@ include file="navbar.jsp" %>

<div class="container-fluid px-4 pb-5 mb-5" style="margin-top: 100px;">
    <div class="row g-4">
        
        <div class="col-lg-3 col-md-4">
            <div class="action-card h-100">
                <div class="card-header border-bottom border-secondary pb-3 mb-3 px-4 pt-4">
                    <h5 class="text-accent fw-bold mb-0"><i class="bi bi-box-seam me-2"></i>Nuevo Producto</h5>
                </div>
                <div class="card-body px-4 pb-4">
                    <form action="inventory" method="POST" enctype="multipart/form-data">
                        <div class="mb-3">
                            <label class="form-label">Nombre del Repuesto</label>
                            <input type="text" name="name" class="form-control" placeholder="Ej. Filtro de Aceite" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Marca</label>
                            <input type="text" name="brand" class="form-control" placeholder="Ej. Yamaha" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Descripcion (Opcional)</label>
                            <textarea name="description" class="form-control" rows="2" placeholder="Detalles del producto..."></textarea>
                        </div>
                        <div class="row g-2 mb-3">
                            <div class="col-6">
                                <label class="form-label">Precio ($)</label>
                                <input type="number" step="0.01" name="price" class="form-control" placeholder="0.00" required>
                            </div>
                            <div class="col-6">
                                <label class="form-label">Stock Inicial</label>
                                <input type="number" name="stock" class="form-control" placeholder="0" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Codigo de Barras</label>
                            <input type="text" name="barcode" class="form-control" placeholder="Vacio para autogenerar">
                        </div>
                        <div class="mb-4">
                            <label class="form-label">Imagen del Repuesto</label>
                            <input type="file" name="image" class="form-control" accept=".jpg,.jpeg">
                            <small class="text-muted mt-1 d-block fw-bold" style="font-size: 0.8rem;">Solo formatos: JPG, JPEG.</small>
                        </div>
                        <button type="submit" class="btn btn-accent w-100 rounded-pill fw-bold py-2 fs-6">
                            <i class="bi bi-plus-circle me-1"></i> Guardar Producto
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <div class="col-lg-9 col-md-8">
            <div class="action-card h-100 d-flex flex-column">
                <div class="card-header border-bottom border-secondary pb-3 mb-2 px-4 pt-4 d-flex justify-content-between align-items-center">
                    <h5 class="fw-bold mb-0 text-accent"><i class="bi bi-card-list me-2"></i>Inventario Disponible</h5>
                    <span class="badge bg-secondary bg-opacity-25 text-light px-3 py-2 rounded-pill fw-bold border border-secondary border-opacity-25">
                        Total: <%= request.getAttribute("products") != null ? ((List<Product>)request.getAttribute("products")).size() : 0 %>
                    </span>
                </div>
                
                <div class="table-responsive flex-grow-1 px-3" style="max-height: 65vh; overflow-y: auto;">
                    <table class="table table-hover align-middle table-borderless">
                        <thead class="sticky-top" style="background: var(--card-bg); z-index: 10;">
                            <tr>
                                <th class="text-secondary text-uppercase pb-3">Foto</th>
                                <th class="text-secondary text-uppercase pb-3">ID</th>
                                <th class="text-secondary text-uppercase pb-3">Repuesto</th>
                                <th class="text-secondary text-uppercase pb-3">Marca</th>
                                <th class="text-secondary text-uppercase pb-3 text-center">Stock</th>
                                <th class="text-secondary text-uppercase pb-3 text-end">Precio</th>
                                <th class="text-secondary text-uppercase pb-3 text-center">Codigo</th>
                                <th class="text-secondary text-uppercase pb-3 text-center">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                List<Product> list = (List<Product>) request.getAttribute("products");
                                if(list != null && !list.isEmpty()) {
                                    for(Product p : list) {
                                        String img = (p.getImageUrl() != null && !p.getImageUrl().isEmpty()) ? p.getImageUrl() : "https://via.placeholder.com/50x50?text=No+Img";
                            %>
                            <tr style="border-bottom: 1px solid var(--card-border);">
                                <td>
                                    <img src="<%= img %>" width="45" height="45" class="rounded-3 shadow-sm" style="object-fit:cover; border: 1px solid var(--card-border);">
                                </td>
                                <td class="text-muted">#<%= p.getId() %></td>
                                <td class="fw-bold fs-6"><%= p.getName() %></td>
                                <td><span class="badge bg-secondary bg-opacity-25 text-light border border-secondary border-opacity-25 py-1 px-2"><%= p.getBrand() %></span></td>
                                <td class="text-center">
                                    <% if(p.getStock() <= 5) { %>
                                        <span class="badge bg-danger bg-opacity-25 text-danger border border-danger border-opacity-25 px-2 py-1 fs-6"><%= p.getStock() %></span>
                                    <% } else { %>
                                        <span class="badge bg-success bg-opacity-25 text-success border border-success border-opacity-25 px-2 py-1 fs-6"><%= p.getStock() %></span>
                                    <% } %>
                                </td>
                                <td class="fw-bold text-end text-accent fs-6">$<%= String.format("%.2f", p.getPrice()) %></td>
                                <td class="text-center">
                                    <div class="inventory-barcode-container shadow-sm">
                                        <svg id="barcode-<%= p.getId() %>"></svg>
                                        <script>
                                            JsBarcode("#barcode-<%= p.getId() %>", "<%= p.getBarcode() %>", {
                                                format: "CODE128",
                                                displayValue: true,
                                                height: 25,
                                                fontSize: 12,
                                                margin: 0,
                                                background: "#ffffff",
                                                lineColor: "#000000"
                                            });
                                        </script>
                                    </div>
                                </td>
                                <td class="text-center">
                                    <div class="d-flex justify-content-center gap-2">
                                        <button class="btn btn-sm btn-outline-warning rounded-pill px-3 fw-bold" onclick="openEditModal(<%= p.getId() %>, '<%= p.getName().replace("'", "\\'") %>', '<%= p.getBrand().replace("'", "\\'") %>', '<%= (p.getDescription() != null ? p.getDescription().replace("'", "\\'") : "") %>', <%= p.getPrice() %>, <%= p.getStock() %>)">
                                            <i class="bi bi-pencil"></i>
                                        </button>
                                        <form action="inventory" method="POST" class="d-inline" onsubmit="return confirm('Seguro que desea eliminar el producto <%= p.getName().replace("'", "\\'") %>?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="<%= p.getId() %>">
                                            <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill px-3 fw-bold"><i class="bi bi-trash"></i></button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                            <%      }
                                } else {
                                    out.print("<tr><td colspan='8' class='text-center text-secondary py-5'><i class='bi bi-inbox fs-1 d-block mb-3'></i>El inventario esta vacio.</td></tr>");
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="editModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-secondary shadow-lg">
      <div class="modal-header border-secondary">
        <h5 class="modal-title text-accent fw-bold"><i class="bi bi-pencil-square me-2"></i>Editar Producto</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="filter: var(--close-btn-filter);"></button>
      </div>
      <form action="inventory" method="POST" enctype="multipart/form-data">
          <div class="modal-body p-4">
              <input type="hidden" name="action" value="edit">
              <input type="hidden" name="id" id="editId">
              <div class="mb-3">
                  <label class="form-label">Nombre del Repuesto</label>
                  <input type="text" name="name" id="editName" class="form-control" required>
              </div>
              <div class="mb-3">
                  <label class="form-label">Marca</label>
                  <input type="text" name="brand" id="editBrand" class="form-control" required>
              </div>
              <div class="mb-3">
                  <label class="form-label">Descripcion</label>
                  <textarea name="description" id="editDesc" class="form-control" rows="2"></textarea>
              </div>
              <div class="row g-2 mb-3">
                  <div class="col-6">
                      <label class="form-label">Precio ($)</label>
                      <input type="number" step="0.01" name="price" id="editPrice" class="form-control" required>
                  </div>
                  <div class="col-6">
                      <label class="form-label">Stock Actual</label>
                      <input type="number" name="stock" id="editStock" class="form-control" required>
                  </div>
              </div>
              <div class="mb-3">
                  <label class="form-label">Actualizar Imagen (Opcional)</label>
                  <input type="file" name="image" class="form-control" accept=".jpg,.jpeg">
              </div>
          </div>
          <div class="modal-footer border-secondary">
            <button type="button" class="btn btn-outline-secondary rounded-pill fw-bold" data-bs-dismiss="modal">Cancelar</button>
            <button type="submit" class="btn btn-accent rounded-pill fw-bold">Guardar Cambios</button>
          </div>
      </form>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function openEditModal(id, name, brand, desc, price, stock) {
        document.getElementById('editId').value = id;
        document.getElementById('editName').value = name;
        document.getElementById('editBrand').value = brand;
        document.getElementById('editDesc').value = (desc === 'null' || !desc) ? '' : desc;
        document.getElementById('editPrice').value = price;
        document.getElementById('editStock').value = stock;
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