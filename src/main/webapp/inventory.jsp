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
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/jsbarcode@3.11.5/dist/JsBarcode.all.min.js"></script>
    <style>
        :root {
            --bg-color: #0f1013;
            --text-color: #f1f2f6;
            --nav-bg: rgba(15, 16, 19, 0.85);
            --metallic-gunmetal: #1a1d24;
            --card-bg: #2a2e35;
            --accent-orange: #FF6B35;
        }
        body { font-family: 'Inter', sans-serif; background-color: var(--bg-color); color: var(--text-color); }
        .navbar-custom { background-color: var(--nav-bg); backdrop-filter: blur(20px); border-bottom: 1px solid rgba(255,255,255,0.08); }
        .navbar-brand { color: #E5E4E2 !important; font-weight: 700; }
        
        .card { background: var(--metallic-gunmetal); border-radius: 15px; border: 1px solid rgba(255,255,255,0.05); color: #fff; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        .card-header { background: transparent !important; border-bottom: 1px solid rgba(255,255,255,0.1); font-weight: 600; padding: 15px 20px; }
        .form-control { background: var(--card-bg); border: 1px solid rgba(255,255,255,0.1); color: #fff; border-radius: 10px; }
        .form-control:focus { background: var(--card-bg); color: #fff; border-color: var(--accent-red); box-shadow: none; }
        
        .table-dark { background-color: transparent !important; }
        .table { color: #ccc; }
        .table th, .table td { border-color: rgba(255,255,255,0.1); vertical-align: middle; }
        .barcode-svg { background: white; padding: 5px; border-radius: 8px; }
        
        .btn-primary { background-color: var(--accent-red); color: #fff; border: none; border-radius: 20px; transition: 0.3s; }
        .btn-primary:hover { background-color: #E55A2B; }
        
        .modal-content { background: var(--metallic-gunmetal); border: 1px solid rgba(255,255,255,0.1); color: white; border-radius: 15px; }
        .modal-header { border-bottom: 1px solid rgba(255,255,255,0.1); }
        .modal-footer { border-top: 1px solid rgba(255,255,255,0.1); }
    </style>
</head>
<body>

<%@ include file="navbar.jsp" %>

<div class="container mt-4">
    <div class="row">
        <!-- Add Product Form -->
        <div class="col-md-4">
            <div class="card shadow-sm">
                <div class="card-header text-danger"><i class="bi bi-plus-circle"></i> Nuevo Producto</div>
                <div class="card-body">
                    <form action="inventory" method="POST" enctype="multipart/form-data">
                        <div class="mb-2"><input type="text" name="name" class="form-control" placeholder="Nombre" required></div>
                        <div class="mb-2"><input type="text" name="brand" class="form-control" placeholder="Marca" required></div>
                        <div class="mb-2"><textarea name="description" class="form-control" placeholder="Descripción"></textarea></div>
                        <div class="row">
                            <div class="col"><input type="number" step="0.01" name="price" class="form-control" placeholder="Precio $" required></div>
                            <div class="col"><input type="number" name="stock" class="form-control" placeholder="Stock" required></div>
                        </div>
                        <div class="mb-2 mt-2">
                            <input type="text" name="barcode" class="form-control" placeholder="Código Barras (Opcional)">
                            <small class="text-muted">Si se deja vacío, el sistema generará uno automáticamente.</small>
                        </div>
                        <div class="mb-2 mt-2">
                            <label class="form-label small">Imagen del repuesto (Solo JPG)</label>
                            <input type="file" name="image" class="form-control" accept=".jpg,.jpeg">
                        </div>
                        <button type="submit" class="btn btn-primary w-100 mt-2">Guardar Producto</button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Product List -->
        <div class="col-md-8">
            <div class="card shadow-sm">
                <div class="card-header bg-dark text-white">Productos en Stock</div>
                <div class="card-body p-0">
                    <table class="table table-striped table-hover m-0">
                        <thead class="table-dark">
                            <tr>
                                <th>Foto</th>
                                <th>ID</th>
                                <th>Nombre</th>
                                <th>Marca</th>
                                <th>Stock</th>
                                <th>Precio</th>
                                <th>Código de Barras</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                List<Product> list = (List<Product>) request.getAttribute("products");
                                if(list != null) {
                                    for(Product p : list) {
                                        String img = p.getImageUrl() != null ? p.getImageUrl() : "https://via.placeholder.com/50";
                            %>
                            <tr>
                                <td><img src="<%= img %>" width="50" height="50" style="object-fit:cover; border-radius:5px;"></td>
                                <td><%= p.getId() %></td>
                                <td><%= p.getName() %></td>
                                <td><%= p.getBrand() %></td>
                                <td><%= p.getStock() %></td>
                                <td>$<%= p.getPrice() %></td>
                                <td>
                                    <svg class="barcode-svg" id="barcode-<%= p.getId() %>"></svg>
                                    <script>
                                        JsBarcode("#barcode-<%= p.getId() %>", "<%= p.getBarcode() %>", {
                                            format: "CODE128",
                                            displayValue: true,
                                            height: 40,
                                            fontSize: 14
                                        });
                                    </script>
                                </td>
                                <td>
                                    <button class="btn btn-sm btn-warning" onclick="openEditModal(<%= p.getId() %>, '<%= p.getName() %>', '<%= p.getBrand() %>', '<%= p.getDescription() %>', <%= p.getPrice() %>, <%= p.getStock() %>)">Editar</button>
                                    <form action="inventory" method="POST" class="d-inline" onsubmit="return confirm('¿Seguro que desea eliminar este producto?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%= p.getId() %>">
                                        <button type="submit" class="btn btn-sm btn-moto">Eliminar</button>
                                    </form>
                                </td>
                            </tr>
                            <%      }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Edit Modal -->
<div class="modal fade" id="editModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title text-danger">Editar Producto</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <form action="inventory" method="POST" enctype="multipart/form-data">
          <div class="modal-body">
              <input type="hidden" name="action" value="edit">
              <input type="hidden" name="id" id="editId">
              <div class="mb-2"><input type="text" name="name" id="editName" class="form-control" placeholder="Nombre" required></div>
              <div class="mb-2"><input type="text" name="brand" id="editBrand" class="form-control" placeholder="Marca" required></div>
              <div class="mb-2"><textarea name="description" id="editDesc" class="form-control" placeholder="Descripción"></textarea></div>
              <div class="row">
                  <div class="col"><input type="number" step="0.01" name="price" id="editPrice" class="form-control" placeholder="Precio $" required></div>
                  <div class="col"><input type="number" name="stock" id="editStock" class="form-control" placeholder="Stock" required></div>
              </div>
              <div class="mb-2 mt-2">
                  <label class="form-label small">Nueva Imagen (Opcional, solo JPG)</label>
                  <input type="file" name="image" class="form-control" accept=".jpg,.jpeg">
              </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
            <button type="submit" class="btn btn-primary">Guardar Cambios</button>
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
        document.getElementById('editDesc').value = desc === 'null' ? '' : desc;
        document.getElementById('editPrice').value = price;
        document.getElementById('editStock').value = stock;
        new bootstrap.Modal(document.getElementById('editModal')).show();
    }
</script>

</body>
</html>
