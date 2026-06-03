import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class CheckRole {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://aws-1-us-west-2.pooler.supabase.com:5432/postgres";
        String user = "postgres.ofoqkykudgtpoqbhbghy";
        String password = "holacomo3stas";
        
        try {
            Class.forName("org.postgresql.Driver");
            Connection conn = DriverManager.getConnection(url, user, password);
            Statement stmt = conn.createStatement();
            
            ResultSet rs = stmt.executeQuery("SELECT full_name, role_id FROM users");
            while (rs.next()) {
                System.out.println("User: " + rs.getString("full_name") + ", Role: " + rs.getInt("role_id"));
            }
            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
