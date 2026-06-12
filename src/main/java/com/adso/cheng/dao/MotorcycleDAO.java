package com.adso.cheng.dao;

import com.adso.cheng.models.Motorcycle;
import com.adso.cheng.utils.DbConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class MotorcycleDAO {

    public List<Motorcycle> getMotorcyclesByCustomer(int customerId) {
        List<Motorcycle> list = new ArrayList<>();
        String sql = "SELECT * FROM motorcycles WHERE customer_id = ? ORDER BY id DESC";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Motorcycle m = new Motorcycle();
                    m.setId(rs.getInt("id"));
                    m.setCustomerId(rs.getInt("customer_id"));
                    m.setPlate(rs.getString("plate"));
                    m.setBrand(rs.getString("brand"));
                    m.setModel(rs.getString("model"));
                    m.setYear(rs.getInt("year"));
                    list.add(m);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addMotorcycle(Motorcycle m) {
        String sql = "INSERT INTO motorcycles (customer_id, plate, brand, model, year) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, m.getCustomerId());
            stmt.setString(2, m.getPlate());
            stmt.setString(3, m.getBrand());
            stmt.setString(4, m.getModel());
            stmt.setInt(5, m.getYear());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteMotorcycle(int id, int customerId) {
        String sql = "DELETE FROM motorcycles WHERE id = ? AND customer_id = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            stmt.setInt(2, customerId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
