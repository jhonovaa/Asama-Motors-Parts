package com.adso.cheng.utils;

import java.sql.Connection;
import java.sql.Statement;

public class AlterTable {
    public static void main(String[] args) {
        try (Connection conn = DbConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            try {
                stmt.execute("ALTER TABLE products ADD COLUMN estante VARCHAR(50)");
                System.out.println("Added estante");
            } catch (Exception e) { System.out.println(e.getMessage()); }
            
            try {
                stmt.execute("ALTER TABLE products ADD COLUMN fila VARCHAR(50)");
                System.out.println("Added fila");
            } catch (Exception e) { System.out.println(e.getMessage()); }

            try {
                stmt.execute("ALTER TABLE products ADD COLUMN minimo_programado INT DEFAULT 5");
                System.out.println("Added minimo_programado");
            } catch (Exception e) { System.out.println(e.getMessage()); }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
