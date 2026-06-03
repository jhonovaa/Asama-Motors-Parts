package com.adso.cheng.utils;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DbConnection {
    private static String URL;
    private static String USER;
    private static String PASS;

    static {
        try {
            Class.forName("org.postgresql.Driver");
            Properties props = new Properties();
            InputStream is = DbConnection.class.getClassLoader().getResourceAsStream("db.properties");
            if (is != null) {
                props.load(is);
                URL = props.getProperty("db.url");
                USER = props.getProperty("db.user");
                PASS = props.getProperty("db.password");
            } else {
                // Fallback
                URL = "jdbc:postgresql://aws-1-us-west-2.pooler.supabase.com:5432/postgres";
                USER = "postgres.xqnicdbrknpvqgnzquuz";
                PASS = "asamaadso2026";
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to initialize DB connection.", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }
}
