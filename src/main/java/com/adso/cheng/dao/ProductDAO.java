package com.adso.cheng.dao;

import com.adso.cheng.models.Product;
import com.adso.cheng.utils.DbConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products ORDER BY id DESC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                products.add(extractProductFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return products;
    }

    public Product getProductByBarcode(String barcode) {
        String sql = "SELECT * FROM products WHERE barcode = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, barcode);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractProductFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public int addProduct(Product p) {
        String sql = "INSERT INTO products (name, description, brand, price, stock, barcode, image_url, estante, fila, minimo_programado, motorcycle_brand, motorcycle_model, part_category, weight) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING id";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, p.getName());
            stmt.setString(2, p.getDescription());
            stmt.setString(3, p.getBrand());
            stmt.setDouble(4, p.getPrice());
            stmt.setInt(5, p.getStock());
            stmt.setString(6, p.getBarcode()); // Auto-generated in UI usually
            stmt.setString(7, p.getImageUrl());
            stmt.setString(8, p.getEstante());
            stmt.setString(9, p.getFila());
            stmt.setInt(10, p.getMinimoProgramado());
            stmt.setString(11, p.getMotorcycleBrand());
            stmt.setString(12, p.getMotorcycleModel());
            stmt.setString(13, p.getPartCategory());
            stmt.setDouble(14, p.getWeight());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public boolean logInventory(int productId, int userId, int quantityAdded) {
        String sql = "INSERT INTO inventory_logs (product_id, user_id, quantity_added) VALUES (?, ?, ?)";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, productId);
            stmt.setInt(2, userId);
            stmt.setInt(3, quantityAdded);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateProduct(Product p) {
        String sql = "UPDATE products SET name=?, description=?, brand=?, price=?, stock=?, estante=?, fila=?, minimo_programado=?, motorcycle_brand=?, motorcycle_model=?, part_category=?, weight=?, barcode=? WHERE id=?";
        if (p.getImageUrl() != null && !p.getImageUrl().isEmpty()) {
            sql = "UPDATE products SET name=?, description=?, brand=?, price=?, stock=?, estante=?, fila=?, minimo_programado=?, motorcycle_brand=?, motorcycle_model=?, part_category=?, weight=?, barcode=?, image_url=? WHERE id=?";
        }
        
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, p.getName());
            stmt.setString(2, p.getDescription());
            stmt.setString(3, p.getBrand());
            stmt.setDouble(4, p.getPrice());
            stmt.setInt(5, p.getStock());
            stmt.setString(6, p.getEstante());
            stmt.setString(7, p.getFila());
            stmt.setInt(8, p.getMinimoProgramado());
            stmt.setString(9, p.getMotorcycleBrand());
            stmt.setString(10, p.getMotorcycleModel());
            stmt.setString(11, p.getPartCategory());
            stmt.setDouble(12, p.getWeight());
            stmt.setString(13, p.getBarcode());
            
            if (p.getImageUrl() != null && !p.getImageUrl().isEmpty()) {
                stmt.setString(14, p.getImageUrl());
                stmt.setInt(15, p.getId());
            } else {
                stmt.setInt(14, p.getId());
            }
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteProduct(int id) {
        String deleteLogsSql = "DELETE FROM inventory_logs WHERE product_id=?";
        String deleteSalesSql = "DELETE FROM sales WHERE product_id=?";
        String deleteProductSql = "DELETE FROM products WHERE id=?";
        try (Connection conn = DbConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement logStmt = conn.prepareStatement(deleteLogsSql)) {
                logStmt.setInt(1, id);
                logStmt.executeUpdate();
            }
            try (PreparedStatement salesStmt = conn.prepareStatement(deleteSalesSql)) {
                salesStmt.setInt(1, id);
                salesStmt.executeUpdate();
            }
            try (PreparedStatement prodStmt = conn.prepareStatement(deleteProductSql)) {
                prodStmt.setInt(1, id);
                int result = prodStmt.executeUpdate();
                conn.commit();
                return result > 0;
            } catch (SQLException ex) {
                conn.rollback();
                ex.printStackTrace();
                return false;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Product extractProductFromResultSet(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setId(rs.getInt("id"));
        p.setName(rs.getString("name"));
        p.setDescription(rs.getString("description"));
        p.setBrand(rs.getString("brand"));
        p.setPrice(rs.getDouble("price"));
        p.setStock(rs.getInt("stock"));
        p.setBarcode(rs.getString("barcode"));
        p.setImageUrl(rs.getString("image_url"));
        p.setEstante(rs.getString("estante"));
        p.setFila(rs.getString("fila"));
        p.setMinimoProgramado(rs.getInt("minimo_programado"));
        p.setMotorcycleBrand(rs.getString("motorcycle_brand"));
        p.setMotorcycleModel(rs.getString("motorcycle_model"));
        p.setPartCategory(rs.getString("part_category"));
        p.setWeight(rs.getDouble("weight"));
        return p;
    }
}
