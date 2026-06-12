package com.adso.cheng.utils;

import java.sql.Connection;
import java.sql.Statement;

public class UpdateOnlineStatus {
    public static void main(String[] args) {
        try (Connection conn = DbConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            stmt.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS is_online BOOLEAN DEFAULT FALSE");
            System.out.println("Columna is_online añadida.");
            
            stmt.execute("UPDATE users SET is_online = FALSE");
            System.out.println("Usuarios reiniciados a offline.");
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
