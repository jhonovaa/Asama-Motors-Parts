package com.adso.cheng.utils;

import java.sql.Connection;
import java.sql.Statement;

public class DbUpdater {
    public static void main(String[] args) {
        System.out.println("Starting Database Update...");
        try (Connection conn = DbConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            // 1. Create maintenance_job_parts table
            String createTableSql = "CREATE TABLE IF NOT EXISTS maintenance_job_parts (" +
                    "id SERIAL PRIMARY KEY, " +
                    "job_id INT NOT NULL REFERENCES maintenance_jobs(id) ON DELETE CASCADE, " +
                    "product_id INT NOT NULL REFERENCES products(id), " +
                    "quantity INT NOT NULL, " +
                    "reason TEXT, " +
                    "labor_cost DECIMAL(10, 2) DEFAULT 0.00, " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                    ")";
            stmt.executeUpdate(createTableSql);
            System.out.println("Table maintenance_job_parts created or already exists.");
            
            // 2. Add is_paid column to maintenance_jobs
            String alterTableSql = "ALTER TABLE maintenance_jobs ADD COLUMN IF NOT EXISTS is_paid BOOLEAN DEFAULT FALSE";
            stmt.executeUpdate(alterTableSql);
            System.out.println("Column is_paid added to maintenance_jobs or already exists.");
            
            System.out.println("Database Update Completed Successfully!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
