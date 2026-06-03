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
        String sql = "SELECT mj.id, mj.description, mj.status, mj.cost, mj.created_at, " +
                     "m.plate, m.brand AS moto_brand, m.model AS moto_model, m.year AS moto_year, " +
                     "c.full_name AS customer_name, mec.full_name AS mechanic_name " +
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
                job.put("plate", rs.getString("plate"));
                job.put("motoBrand", rs.getString("moto_brand"));
                job.put("motoModel", rs.getString("moto_model"));
                job.put("motoYear", rs.getInt("moto_year"));
                job.put("customerName", rs.getString("customer_name"));
                job.put("mechanicName", rs.getString("mechanic_name"));
                jobs.add(job);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return jobs;
    }

    public List<Map<String, Object>> getJobsByMechanic(int mechanicId) {
        List<Map<String, Object>> jobs = new ArrayList<>();
        String sql = "SELECT mj.id, mj.description, mj.status, mj.cost, mj.created_at, " +
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

    public void addMotorcycle(int customerId, String plate, String brand, String model, int year) {
        String sql = "INSERT INTO motorcycles (customer_id, plate, brand, model, year) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);
            stmt.setString(2, plate);
            stmt.setString(3, brand);
            stmt.setString(4, model);
            stmt.setInt(5, year);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
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
}
