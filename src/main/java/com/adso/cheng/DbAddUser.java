package com.adso.cheng;

import com.adso.cheng.utils.DbConnection;
import com.adso.cheng.utils.HashUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class DbAddUser {
    public static void main(String[] args) {
        try (Connection conn = DbConnection.getConnection()) {
            String sql = "INSERT INTO users (full_name, document_id, email, password, role_id, barcode) VALUES (?, ?, ?, ?, ?, ?) ON CONFLICT DO NOTHING";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, "Admin Asama");
                stmt.setString(2, "999999999");
                stmt.setString(3, "asamaadmim@gmail.com");
                stmt.setString(4, HashUtil.sha256("Sa31478."));
                stmt.setInt(5, 1);
                stmt.setString(6, "ASAMA-ADM-99");
                int rows = stmt.executeUpdate();
                System.out.println("User inserted: " + rows);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
