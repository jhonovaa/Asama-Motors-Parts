package com.adso.cheng.utils;

import java.sql.Connection;
import java.sql.Statement;

public class DbUpdateInvoices {
    public static void main(String[] args) {
        try (Connection conn = DbConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            System.out.println("Creating dian_invoices table...");
            
            String sql = "CREATE TABLE IF NOT EXISTS dian_invoices (" +
                         "id SERIAL PRIMARY KEY," +
                         "invoice_number VARCHAR(50) NOT NULL UNIQUE," +
                         "cufe VARCHAR(100) NOT NULL," +
                         "issue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                         "customer_document VARCHAR(50)," +
                         "customer_name VARCHAR(150)," +
                         "customer_email VARCHAR(150)," +
                         "subtotal DECIMAL(10, 2) NOT NULL," +
                         "tax_amount DECIMAL(10, 2) NOT NULL," +
                         "total_amount DECIMAL(10, 2) NOT NULL," +
                         "order_id INT NULL," +
                         "items_json TEXT NOT NULL" +
                         ")";
            stmt.execute(sql);
            System.out.println("Created dian_invoices table successfully.");
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
