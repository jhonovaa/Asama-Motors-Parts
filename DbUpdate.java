import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class DbUpdate {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://aws-1-us-west-2.pooler.supabase.com:5432/postgres";
        String user = "postgres.ofoqkykudgtpoqbhbghy";
        String password = "holacomo3stas";
        
        try {
            Class.forName("org.postgresql.Driver");
            Connection conn = DriverManager.getConnection(url, user, password);
            Statement stmt = conn.createStatement();
            
            // Alter cashier_id to be nullable
            try {
                stmt.execute("ALTER TABLE sales ALTER COLUMN cashier_id DROP NOT NULL");
                System.out.println("Made cashier_id nullable.");
            } catch(Exception e) {
                System.out.println("Failed to make cashier_id nullable: " + e.getMessage());
            }

            // Rename sale_time to sale_date
            try {
                stmt.execute("ALTER TABLE sales RENAME COLUMN sale_time TO sale_date");
                System.out.println("Renamed sale_time to sale_date.");
            } catch(Exception e) {
                System.out.println("Column might already be sale_date: " + e.getMessage());
            }

            // Add sale_type
            try {
                stmt.execute("ALTER TABLE sales ADD COLUMN sale_type VARCHAR(50) DEFAULT 'IN_STORE'");
                System.out.println("Added sale_type to sales.");
            } catch(Exception e) {
                System.out.println("Column sale_type might already exist: " + e.getMessage());
            }
            
            // Update past sales to be ONLINE if customer_id is not null and cashier_id is null
            try {
                stmt.execute("UPDATE sales SET sale_type = 'ONLINE' WHERE cashier_id IS NULL");
                System.out.println("Updated past online sales.");
            } catch(Exception e) {
                System.out.println("Failed to update past sales: " + e.getMessage());
            }

            // Create inventory_logs table
            try {
                stmt.execute("CREATE TABLE IF NOT EXISTS inventory_logs (" +
                             "id SERIAL PRIMARY KEY, " +
                             "product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE, " +
                             "user_id INT NOT NULL REFERENCES users(id), " +
                             "quantity_added INT NOT NULL, " +
                             "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                             ")");
                System.out.println("Created inventory_logs table.");
            } catch(Exception e) {
                System.out.println("Failed to create inventory_logs: " + e.getMessage());
            }

            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
