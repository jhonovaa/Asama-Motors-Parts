import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;

public class ListTables {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://aws-1-us-west-2.pooler.supabase.com:5432/postgres";
        String user = "postgres.ofoqkykudgtpoqbhbghy";
        String password = "holacomo3stas";
        try {
            Class.forName("org.postgresql.Driver");
            Connection conn = DriverManager.getConnection(url, user, password);
            ResultSet rs = conn.getMetaData().getTables(null, null, "%", new String[] {"TABLE"});
            while (rs.next()) {
                System.out.println(rs.getString("TABLE_NAME"));
            }
            rs.close();
            conn.close();
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
}
