package com.adso.cheng.dao;

import com.adso.cheng.models.User;
import com.adso.cheng.utils.DbConnection;
import com.adso.cheng.utils.HashUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {

    public User authenticate(String email, String password) {
        String hashedPassword = HashUtil.sha256(password);
        String sql = "SELECT * FROM users WHERE email = ? AND password = ?";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            stmt.setString(2, hashedPassword);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractUserFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean registerCustomer(User user) {
        String sql = "INSERT INTO users (full_name, document_id, email, password, role_id) VALUES (?, ?, ?, ?, 5)";
        try (Connection conn = DbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, user.getFullName());
            stmt.setString(2, user.getDocumentId());
            stmt.setString(3, user.getEmail());
            stmt.setString(4, HashUtil.sha256(user.getPassword()));
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private User extractUserFromResultSet(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setFullName(rs.getString("full_name"));
        user.setDocumentId(rs.getString("document_id"));
        user.setEmail(rs.getString("email"));
        user.setPassword(rs.getString("password"));
        user.setRoleId(rs.getInt("role_id"));
        user.setBarcode(rs.getString("barcode"));
        try { user.setPhotoPath(rs.getString("photo_path")); } catch(SQLException e) {}
        return user;
    }
}
