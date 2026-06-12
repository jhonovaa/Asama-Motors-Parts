package com.adso.cheng.utils;

import java.sql.Connection;
import java.sql.Statement;

public class DbUpdateSchema {
    public static void main(String[] args) {
        try (Connection conn = DbConnection.getConnection();
             Statement stmt = conn.createStatement()) {
             
            System.out.println("Adding motorcycle_brand...");
            try { stmt.execute("ALTER TABLE products ADD COLUMN motorcycle_brand VARCHAR(100)"); } catch(Exception e) { System.out.println(e.getMessage()); }
            
            System.out.println("Adding motorcycle_model...");
            try { stmt.execute("ALTER TABLE products ADD COLUMN motorcycle_model VARCHAR(100)"); } catch(Exception e) { System.out.println(e.getMessage()); }
            
            System.out.println("Adding part_category...");
            try { stmt.execute("ALTER TABLE products ADD COLUMN part_category VARCHAR(100)"); } catch(Exception e) { System.out.println(e.getMessage()); }
            
            System.out.println("Ensuring motorcycles table exists...");
            try {
                stmt.execute("CREATE TABLE IF NOT EXISTS motorcycles (" +
                             "id SERIAL PRIMARY KEY, " +
                             "customer_id INT NOT NULL REFERENCES users(id), " +
                             "plate VARCHAR(20) NOT NULL UNIQUE, " +
                             "brand VARCHAR(100), " +
                             "model VARCHAR(100), " +
                             "year INT" +
                             ")");
            } catch(Exception e) { System.out.println(e.getMessage()); }
            
            System.out.println("Schema update complete.");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
