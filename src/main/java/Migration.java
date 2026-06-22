import com.adso.cheng.utils.DbConnection;
import java.sql.Connection;
import java.sql.Statement;

public class Migration {
    public static void main(String[] args) {
        try (Connection conn = DbConnection.getConnection();
             Statement stmt = conn.createStatement()) {
             
             String sql = "CREATE TABLE IF NOT EXISTS online_orders (" +
                          "id SERIAL PRIMARY KEY, " +
                          "customer_id INT NOT NULL REFERENCES users(id), " +
                          "total_amount DECIMAL(10, 2) NOT NULL, " +
                          "shipping_cost DECIMAL(10, 2) DEFAULT 0.00, " +
                          "items_json TEXT NOT NULL, " +
                          "status VARCHAR(50) DEFAULT 'PENDIENTE', " +
                          "is_read_admin BOOLEAN DEFAULT FALSE, " +
                          "is_read_cashier BOOLEAN DEFAULT FALSE, " +
                          "is_read_storekeeper BOOLEAN DEFAULT FALSE, " +
                          "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                          ");";
             
             stmt.executeUpdate(sql);
             stmt.executeUpdate("ALTER TABLE online_orders ADD COLUMN IF NOT EXISTS is_read_storekeeper BOOLEAN DEFAULT FALSE;");
             System.out.println("MIGRATION_SUCCESS: online_orders table created and altered.");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
