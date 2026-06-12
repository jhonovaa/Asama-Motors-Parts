import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class DbUpdateAudit {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://aws-1-us-west-2.pooler.supabase.com:5432/postgres";
        String user = "postgres.xqnicdbrknpvqgnzquuz";
        String password = "asamaadso2026";
        
        try {
            Class.forName("org.postgresql.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, password);
                 Statement stmt = conn.createStatement()) {
                
                String sql = "CREATE TABLE IF NOT EXISTS audit_logs (" +
                             "id SERIAL PRIMARY KEY, " +
                             "user_id INT NOT NULL REFERENCES users(id), " +
                             "module VARCHAR(50) NOT NULL, " +
                             "action VARCHAR(100) NOT NULL, " +
                             "details TEXT, " +
                             "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                             ");";
                
                stmt.execute(sql);
                System.out.println("Created audit_logs table.");
                
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
