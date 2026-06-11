<%@ page import="com.adso.cheng.models.User" %>
<%@ page import="com.adso.cheng.utils.DbConnection" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRoleId() != 5) { // Solo clientes pueden solicitar esto
        response.sendRedirect("login.jsp");
        return;
    }

    String saleIdStr = request.getParameter("sale_id");
    if (saleIdStr == null || saleIdStr.isEmpty()) {
        response.sendRedirect("dashboard.jsp?msg=Error:%20No%20se%20ha%20proporcionado%20una%20venta%20valida.");
        return;
    }

    int saleId = Integer.parseInt(saleIdStr);
    String productName = "";
    String saleDate = "";
    double totalPrice = 0.0;
    
    try (Connection conn = DbConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(
             "SELECT s.sale_date, p.name, s.total_price " +
             "FROM sales s JOIN products p ON s.product_id = p.id " +
             "WHERE s.id = ? AND s.customer_id = ?")) {
        stmt.setInt(1, saleId);
        stmt.setInt(2, user.getId());
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            productName = rs.getString("name");
            saleDate = rs.getTimestamp("sale_date").toString().substring(0, 16);
            totalPrice = rs.getDouble("total_price");
        } else {
            response.sendRedirect("dashboard.jsp?msg=Error:%20No%20se%20encontro%20la%20venta.");
            return;
        }
    } catch (Exception e) {
        response.sendRedirect("dashboard.jsp?msg=Error%20interno%20del%20sistema.");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Solicitud de Garantía / Devolución - Asama Moto Parts</title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="resources/theme.css?v=6">
</head>
<body>
<script src="resources/theme.js"></script>

<%@ include file="navbar.jsp" %>

<div class="container pb-5" style="margin-top: 100px;">
    <div class="row justify-content-center">
        <div class="col-lg-8 col-md-10">
            <div class="card-custom p-4 p-md-5">
                <div class="d-flex align-items-center mb-4">
                    <i class="bi bi-shield-exclamation fs-1 text-accent me-3"></i>
                    <div>
                        <h3 class="fw-bold mb-1">Solicitar Garantía o Devolución</h3>
                        <p class="text-secondary mb-0">Rellena el formulario con los detalles del inconveniente.</p>
                    </div>
                </div>

                <div class="alert alert-secondary bg-opacity-10 border-0 rounded-3 mb-4">
                    <h6 class="fw-bold mb-2">Detalles de la Compra</h6>
                    <ul class="list-unstyled mb-0 small">
                        <li><strong>Repuesto:</strong> <%= productName %></li>
                        <li><strong>Fecha:</strong> <%= saleDate %></li>
                        <li><strong>Valor:</strong> $<%= String.format("%.2f", totalPrice) %></li>
                    </ul>
                </div>

                <form action="postSaleRequest" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="sale_id" value="<%= saleId %>">
                    
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Tipo de Solicitud</label>
                            <select name="request_type" class="form-select form-control" required>
                                <option value="GARANTIA">Reclamar Garantía</option>
                                <option value="DEVOLUCION">Solicitar Devolución / Reembolso</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Tipo de Daño o Motivo</label>
                            <input type="text" name="damage" class="form-control" placeholder="Ej. Pieza rota, no encaja, defecto de fábrica..." required>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Descripción Detallada</label>
                            <textarea name="description" class="form-control" rows="4" placeholder="Describe claramente el problema con el repuesto..." required></textarea>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Adjuntar Fotografía</label>
                            <p class="text-muted small mb-2">Solo se permiten imágenes en formato .jpg, .jpeg o .png (Máx. 5MB)</p>
                            <input type="file" name="image" class="form-control" accept=".jpg,.jpeg,.png" required>
                        </div>
                    </div>

                    <div class="d-flex justify-content-end gap-3 mt-5">
                        <a href="dashboard.jsp" class="btn btn-outline-secondary rounded-pill px-4">Cancelar</a>
                        <button type="submit" class="btn btn-accent rounded-pill px-5 fw-bold">
                            <i class="bi bi-send me-2"></i>Enviar Solicitud
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
