package com.adso.cheng;

import com.adso.cheng.utils.DbConnection;
import java.sql.Connection;
import java.sql.Statement;

public class UpdateSchema {
    public static void main(String[] args) {
        try (Connection conn = DbConnection.getConnection();
             Statement stmt = conn.createStatement()) {
             
            System.out.println("Executing schema update...");
            stmt.executeUpdate("ALTER TABLE products ADD COLUMN weight DECIMAL(10,2) DEFAULT 0.0;");
            System.out.println("Success!");
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
