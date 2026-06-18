import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class CreateExpensesTable {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://aws-1-us-west-2.pooler.supabase.com:5432/postgres";
        String user = "postgres.xqnicdbrknpvqgnzquuz";
        String password = "asamaadso2026";
        
        try {
            Class.forName("org.postgresql.Driver");
            Connection conn = DriverManager.getConnection(url, user, password);
            Statement stmt = conn.createStatement();
            
            String sql = "CREATE TABLE IF NOT EXISTS expenses (" +
                         "id SERIAL PRIMARY KEY," +
                         "user_id INT NOT NULL REFERENCES users(id)," +
                         "expense_type VARCHAR(50) NOT NULL," +
                         "description TEXT NOT NULL," +
                         "amount DECIMAL(10, 2) NOT NULL," +
                         "expense_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                         ")";
            stmt.execute(sql);
            System.out.println("Expenses table created successfully.");
            
            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
