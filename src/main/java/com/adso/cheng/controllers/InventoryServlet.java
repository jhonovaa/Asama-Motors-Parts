package com.adso.cheng.controllers;

import com.adso.cheng.dao.ProductDAO;
import com.adso.cheng.models.Product;
import com.adso.cheng.models.User;
import com.adso.cheng.utils.AuditLogger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

@WebServlet("/inventory")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
    maxFileSize = 1024 * 1024 * 5,       // 5 MB
    maxRequestSize = 1024 * 1024 * 10    // 10 MB
)
public class InventoryServlet extends HttpServlet {
    private ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        // Security Check: Only Admin (1) or Bodeguero (3)
        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 3)) {
            response.sendRedirect("login");
            return;
        }

        List<Product> products = productDAO.getAllProducts();
        request.setAttribute("products", products);
        request.getRequestDispatcher("inventory.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 3)) {
            response.sendRedirect("login");
            return;
        }

        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            productDAO.deleteProduct(id);
            AuditLogger.logAction(user.getId(), "INVENTARIO", "Producto Eliminado", "Eliminó el producto ID: " + id);
        } else if ("edit".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            Product oldProduct = productDAO.getAllProducts().stream().filter(pr -> pr.getId() == id).findFirst().orElse(null);
            
            Product p = new Product();
            p.setId(id);
            p.setName(request.getParameter("name"));
            p.setDescription(request.getParameter("description"));
            p.setBrand(request.getParameter("brand"));
            p.setPrice(Double.parseDouble(request.getParameter("price")));
            int newStock = Integer.parseInt(request.getParameter("stock"));
            p.setStock(newStock);
            p.setEstante(request.getParameter("estante"));
            p.setFila(request.getParameter("fila"));
            p.setMinimoProgramado(Integer.parseInt(request.getParameter("minimo_programado")));
            p.setMotorcycleBrand(request.getParameter("motorcycle_brand"));
            p.setMotorcycleModel(request.getParameter("motorcycle_model"));
            p.setPartCategory(request.getParameter("part_category"));
            
            String editedBarcode = request.getParameter("barcode");
            if (editedBarcode != null && !editedBarcode.trim().isEmpty()) {
                p.setBarcode(editedBarcode.trim());
            } else if (oldProduct != null) {
                p.setBarcode(oldProduct.getBarcode());
            }
            
            Part filePart = request.getPart("image");
            if (filePart != null && filePart.getSize() > 0) {
                p.setImageUrl(saveFile(filePart, request));
            }
            
            if (productDAO.updateProduct(p)) {
                AuditLogger.logAction(user.getId(), "INVENTARIO", "Producto Actualizado", "Editó el producto ID: " + id + " (" + p.getName() + ")");
                if (oldProduct != null && newStock > oldProduct.getStock()) {
                    productDAO.logInventory(p.getId(), user.getId(), newStock - oldProduct.getStock());
                }
            }
        } else {
            // Add Product
            Product p = new Product();
            p.setName(request.getParameter("name"));
            p.setDescription(request.getParameter("description"));
            p.setBrand(request.getParameter("brand"));
            p.setPrice(Double.parseDouble(request.getParameter("price")));
            int stock = Integer.parseInt(request.getParameter("stock"));
            p.setStock(stock);
            p.setEstante(request.getParameter("estante"));
            p.setFila(request.getParameter("fila"));
            p.setMinimoProgramado(Integer.parseInt(request.getParameter("minimo_programado")));
            p.setMotorcycleBrand(request.getParameter("motorcycle_brand"));
            p.setMotorcycleModel(request.getParameter("motorcycle_model"));
            p.setPartCategory(request.getParameter("part_category"));
            
            Part filePart = request.getPart("image");
            if (filePart != null && filePart.getSize() > 0) {
                p.setImageUrl(saveFile(filePart, request));
            }
            
            String barcode = request.getParameter("barcode");
            if (barcode == null || barcode.isEmpty()) {
                barcode = "ASAMA-" + System.currentTimeMillis();
            }
            p.setBarcode(barcode);
            int newId = productDAO.addProduct(p);
            if (newId > 0) {
                AuditLogger.logAction(user.getId(), "INVENTARIO", "Producto Agregado", "Añadió nuevo producto: " + p.getName() + " con stock inicial: " + stock);
                if (stock > 0) {
                    productDAO.logInventory(newId, user.getId(), stock);
                }
            }
        }
        
        response.sendRedirect("inventory");
    }
    
    private String saveFile(Part part, HttpServletRequest request) throws IOException {
        String baseWebapp = com.adso.cheng.utils.UploadUtil.getSourceWebappPath(request);
        String baseUploadPath = baseWebapp + File.separator + "resources" + File.separator + "fotos" + File.separator + "productos";
        
        File uploadDir = new File(baseUploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        String fileName = UUID.randomUUID().toString() + ".jpg";
        part.write(baseUploadPath + File.separator + fileName);
        
        // Also write to deployed directory for immediate UI access
        String deployUploadPath = request.getServletContext().getRealPath("/resources/fotos/productos");
        if (deployUploadPath != null) {
            File deployDir = new File(deployUploadPath);
            if (!deployDir.exists()) deployDir.mkdirs();
            java.nio.file.Files.copy(
                new java.io.File(baseUploadPath + File.separator + fileName).toPath(),
                new java.io.File(deployUploadPath + File.separator + fileName).toPath(),
                java.nio.file.StandardCopyOption.REPLACE_EXISTING
            );
        }

        return "resources/fotos/productos/" + fileName;
    }
}
