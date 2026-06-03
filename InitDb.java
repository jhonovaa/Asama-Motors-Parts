import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.nio.file.Files;
import java.nio.file.Paths;

public class InitDb {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://aws-1-us-west-2.pooler.supabase.com:5432/postgres";
        String user = "postgres.xqnicdbrknpvqgnzquuz";
        String password = "asamaadso2026";
        
        try {
            Class.forName("org.postgresql.Driver");
            Connection conn = DriverManager.getConnection(url, user, password);
            Statement stmt = conn.createStatement();
            
            String sql = new String(Files.readAllBytes(Paths.get("schema.sql")));
            String[] statements = sql.split(";");
            for (String s : statements) {
                if (s.trim().length() > 0) {
                    try {
                        stmt.execute(s);
                        System.out.println("Executed: " + s.trim().substring(0, Math.min(50, s.trim().length())));
                    } catch(Exception e) {
                        System.out.println("Error executing: " + e.getMessage());
                    }
                }
            }

            stmt.close();
            conn.close();
            System.out.println("Schema initialization complete.");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
