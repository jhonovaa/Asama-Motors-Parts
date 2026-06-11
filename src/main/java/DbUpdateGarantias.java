import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class DbUpdateGarantias {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://aws-1-us-west-2.pooler.supabase.com:5432/postgres";
        String user = "postgres.xqnicdbrknpvqgnzquuz";
        String password = "asamaadso2026";
        
        try {
            Class.forName("org.postgresql.Driver");
            Connection conn = DriverManager.getConnection(url, user, password);
            Statement stmt = conn.createStatement();
            
            try {
                stmt.execute("CREATE TABLE IF NOT EXISTS post_sale_requests (" +
                             "id SERIAL PRIMARY KEY, " +
                             "sale_id INT NOT NULL REFERENCES sales(id), " +
                             "request_type VARCHAR(50) NOT NULL, " +
                             "damage VARCHAR(255) NOT NULL, " +
                             "description TEXT NOT NULL, " +
                             "image_path VARCHAR(255), " +
                             "status VARCHAR(50) DEFAULT 'PENDIENTE', " +
                             "admin_reply TEXT, " +
                             "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                             ")");
                System.out.println("Created post_sale_requests table.");
            } catch(Exception e) {
                System.out.println("Failed to create post_sale_requests: " + e.getMessage());
            }

            try {
                stmt.execute("CREATE TABLE IF NOT EXISTS accountant_reports (" +
                             "id SERIAL PRIMARY KEY, " +
                             "request_id INT NOT NULL REFERENCES post_sale_requests(id), " +
                             "pdf_path VARCHAR(255) NOT NULL, " +
                             "is_read BOOLEAN DEFAULT FALSE, " +
                             "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                             ")");
                System.out.println("Created accountant_reports table.");
            } catch(Exception e) {
                System.out.println("Failed to create accountant_reports: " + e.getMessage());
            }

            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
