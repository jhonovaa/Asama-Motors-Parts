package com.adso.cheng.dao;

import com.adso.cheng.utils.DbConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MaintenanceDAO {

    public List<Map<String, Object>> getAllJobs() {
        List<Map<String, Object>> jobs = new ArrayList<>();
        String sql = "SELECT mj.id, mj.description, mj.status, mj.cost, mj.created_at, mj.is_paid, " +
                     "m.plate, m.brand AS moto_brand, m.model AS moto_model, m.year AS moto_year, " +
                     "c.full_name AS customer_name, c.email AS customer_email, c.document_id AS customer_document, mec.full_name AS mechanic_name " +
                     "FROM maintenance_jobs mj " +
                     "JOIN motorcycles m ON mj.motorcycle_id = m.id " +
                     "JOIN users c ON m.customer_id = c.id " +
                     "LEFT JOIN users mec ON mj.mechanic_id = mec.id " +
                     "ORDER BY mj.created_at DESC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> job = new HashMap<>();
                job.put("id", rs.getInt("id"));
                job.put("description", rs.getString("description"));
                job.put("status", rs.getString("status"));
                job.put("cost", rs.getDouble("cost"));
                job.put("createdAt", rs.getTimestamp("created_at"));
                job.put("isPaid", rs.getBoolean("is_paid"));
                job.put("plate", rs.getString("plate"));
                job.put("motoBrand", rs.getString("moto_brand"));
                job.put("motoModel", rs.getString("moto_model"));
                job.put("motoYear", rs.getInt("moto_year"));
                job.put("customerName", rs.getString("customer_name"));
                job.put("customerEmail", rs.getString("customer_email"));
                job.put("customerDocument", rs.getString("customer_document"));
                job.put("mechanicName", rs.getString("mechanic_name"));
                jobs.add(job);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return jobs;
    }

    public Map<String, Object> getJobById(int jobId) {
        String sql = "SELECT mj.id, mj.description, mj.status, mj.cost, mj.created_at, mj.is_paid, " +
                     "m.plate, m.brand AS moto_brand, m.model AS moto_model, m.year AS moto_year, " +
                     "c.full_name AS customer_name, c.email AS customer_email, c.document_id AS customer_document, mec.full_name AS mechanic_name " +
                     "FROM maintenance_jobs mj " +
                     "JOIN motorcycles m ON mj.motorcycle_id = m.id " +
                     "JOIN users c ON m.customer_id = c.id " +
                     "LEFT JOIN users mec ON mj.mechanic_id = mec.id " +
                     "WHERE mj.id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, jobId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> job = new HashMap<>();
                    job.put("id", rs.getInt("id"));
                    job.put("description", rs.getString("description"));
                    job.put("status", rs.getString("status"));
                    job.put("cost", rs.getDouble("cost"));
                    job.put("createdAt", rs.getTimestamp("created_at"));
                    job.put("isPaid", rs.getBoolean("is_paid"));
                    job.put("plate", rs.getString("plate"));
                    job.put("motoBrand", rs.getString("moto_brand"));
                    job.put("motoModel", rs.getString("moto_model"));
                    job.put("motoYear", rs.getInt("moto_year"));
                    job.put("customerName", rs.getString("customer_name"));
                    job.put("customerEmail", rs.getString("customer_email"));
                    job.put("customerDocument", rs.getString("customer_document"));
                    job.put("mechanicName", rs.getString("mechanic_name"));
                    return job;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Map<String, Object>> getJobsByMechanic(int mechanicId) {
        List<Map<String, Object>> jobs = new ArrayList<>();
        String sql = "SELECT mj.id, mj.description, mj.status, mj.cost, mj.created_at, mj.is_paid, " +
                     "m.plate, m.brand AS moto_brand, m.model AS moto_model, m.year AS moto_year, " +
                     "c.full_name AS customer_name, mec.full_name AS mechanic_name " +
                     "FROM maintenance_jobs mj " +
                     "JOIN motorcycles m ON mj.motorcycle_id = m.id " +
                     "JOIN users c ON m.customer_id = c.id " +
                     "LEFT JOIN users mec ON mj.mechanic_id = mec.id " +
                     "WHERE mj.mechanic_id = ? " +
                     "ORDER BY mj.created_at DESC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, mechanicId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> job = new HashMap<>();
                    job.put("id", rs.getInt("id"));
                    job.put("description", rs.getString("description"));
                    job.put("status", rs.getString("status"));
                    job.put("cost", rs.getDouble("cost"));
                    job.put("createdAt", rs.getTimestamp("created_at"));
                    job.put("isPaid", rs.getBoolean("is_paid"));
                    job.put("plate", rs.getString("plate"));
                    job.put("motoBrand", rs.getString("moto_brand"));
                    job.put("motoModel", rs.getString("moto_model"));
                    job.put("motoYear", rs.getInt("moto_year"));
                    job.put("customerName", rs.getString("customer_name"));
                    job.put("mechanicName", rs.getString("mechanic_name"));
                    jobs.add(job);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return jobs;
    }

    public int addMotorcycle(int customerId, String plate, String brand, String model, int year) {
        String sql = "INSERT INTO motorcycles (customer_id, plate, brand, model, year) VALUES (?, ?, ?, ?, ?) RETURNING id";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);
            stmt.setString(2, plate);
            stmt.setString(3, brand);
            stmt.setString(4, model);
            stmt.setInt(5, year);
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

    public List<Map<String, Object>> getMotorcyclesByCustomer(int customerId) {
        List<Map<String, Object>> motos = new ArrayList<>();
        String sql = "SELECT id, plate, brand, model, year FROM motorcycles WHERE customer_id = ? ORDER BY id DESC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> moto = new HashMap<>();
                    moto.put("id", rs.getInt("id"));
                    moto.put("plate", rs.getString("plate"));
                    moto.put("brand", rs.getString("brand"));
                    moto.put("model", rs.getString("model"));
                    moto.put("year", rs.getInt("year"));
                    motos.add(moto);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return motos;
    }

    public List<Map<String, Object>> getAllMotorcycles() {
        List<Map<String, Object>> motos = new ArrayList<>();
        String sql = "SELECT m.id, m.plate, m.brand, m.model, m.year, u.full_name AS customer_name " +
                     "FROM motorcycles m " +
                     "JOIN users u ON m.customer_id = u.id " +
                     "ORDER BY m.id DESC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> moto = new HashMap<>();
                moto.put("id", rs.getInt("id"));
                moto.put("plate", rs.getString("plate"));
                moto.put("brand", rs.getString("brand"));
                moto.put("model", rs.getString("model"));
                moto.put("year", rs.getInt("year"));
                moto.put("customerName", rs.getString("customer_name"));
                motos.add(moto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return motos;
    }

    public void addJob(int motorcycleId, int mechanicId, String description) {
        String sql = "INSERT INTO maintenance_jobs (motorcycle_id, mechanic_id, description) VALUES (?, ?, ?)";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, motorcycleId);
            stmt.setInt(2, mechanicId);
            stmt.setString(3, description);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void updateJobStatus(int jobId, String status, double cost) {
        String sql = "UPDATE maintenance_jobs SET status = ?, cost = ? WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setDouble(2, cost);
            stmt.setInt(3, jobId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void addJobPart(int jobId, int productId, int quantity, String reason, double laborCost, double productPrice) {
        Connection conn = null;
        try {
            conn = DbConnection.getConnection();
            conn.setAutoCommit(false);

            // Insert part
            String sqlInsert = "INSERT INTO maintenance_job_parts (job_id, product_id, quantity, reason, labor_cost) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sqlInsert)) {
                stmt.setInt(1, jobId);
                stmt.setInt(2, productId);
                stmt.setInt(3, quantity);
                stmt.setString(4, reason);
                stmt.setDouble(5, laborCost);
                stmt.executeUpdate();
            }

            // Update inventory
            String sqlUpdateInv = "UPDATE products SET stock = stock - ? WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sqlUpdateInv)) {
                stmt.setInt(1, quantity);
                stmt.setInt(2, productId);
                stmt.executeUpdate();
            }

            // Update job cost
            double totalAddedCost = (productPrice * quantity) + laborCost;
            String sqlUpdateCost = "UPDATE maintenance_jobs SET cost = cost + ? WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sqlUpdateCost)) {
                stmt.setDouble(1, totalAddedCost);
                stmt.setInt(2, jobId);
                stmt.executeUpdate();
            }

            conn.commit();
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
    }

    public List<Map<String, Object>> getJobParts(int jobId) {
        List<Map<String, Object>> parts = new ArrayList<>();
        String sql = "SELECT mjp.*, p.name, p.price " +
                     "FROM maintenance_job_parts mjp " +
                     "JOIN products p ON mjp.product_id = p.id " +
                     "WHERE mjp.job_id = ? " +
                     "ORDER BY mjp.created_at ASC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, jobId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> part = new HashMap<>();
                    part.put("productId", rs.getInt("product_id"));
                    part.put("name", rs.getString("name"));
                    part.put("price", rs.getDouble("price"));
                    part.put("quantity", rs.getInt("quantity"));
                    part.put("reason", rs.getString("reason"));
                    part.put("laborCost", rs.getDouble("labor_cost"));
                    java.sql.Timestamp ts = rs.getTimestamp("created_at");
                    part.put("createdAt", ts != null ? ts.toString() : "");
                    parts.add(part);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return parts;
    }

    public List<Map<String, Object>> getCompletedUnpaidJobs() {
        List<Map<String, Object>> jobs = new ArrayList<>();
        String sql = "SELECT mj.id, mj.description, mj.status, mj.cost, mj.created_at, " +
                     "m.plate, m.brand AS moto_brand, m.model AS moto_model, " +
                     "c.id AS customer_id, c.full_name AS customer_name, c.document_id AS customer_document, c.email AS customer_email " +
                     "FROM maintenance_jobs mj " +
                     "JOIN motorcycles m ON mj.motorcycle_id = m.id " +
                     "JOIN users c ON m.customer_id = c.id " +
                     "WHERE mj.status = 'COMPLETADO' AND mj.is_paid = FALSE " +
                     "ORDER BY mj.created_at ASC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> job = new HashMap<>();
                job.put("id", rs.getInt("id"));
                job.put("description", rs.getString("description"));
                job.put("status", rs.getString("status"));
                job.put("cost", rs.getDouble("cost"));
                job.put("createdAt", rs.getTimestamp("created_at"));
                job.put("plate", rs.getString("plate"));
                job.put("motoBrand", rs.getString("moto_brand"));
                job.put("motoModel", rs.getString("moto_model"));
                job.put("customerId", rs.getInt("customer_id"));
                job.put("customerName", rs.getString("customer_name"));
                job.put("customerDocument", rs.getString("customer_document"));
                job.put("customerEmail", rs.getString("customer_email"));
                jobs.add(job);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return jobs;
    }

    public void markJobAsPaid(int jobId) {
        String sql = "UPDATE maintenance_jobs SET is_paid = TRUE WHERE id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, jobId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
