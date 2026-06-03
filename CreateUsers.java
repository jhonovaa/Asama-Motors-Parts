import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.Statement;

public class CreateUsers {
    static String sha256(String input) throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] hash = digest.digest(input.getBytes(StandardCharsets.UTF_8));
        StringBuilder hex = new StringBuilder();
        for (byte b : hash) { String h = Integer.toHexString(0xff & b); if(h.length()==1) hex.append('0'); hex.append(h); }
        return hex.toString();
    }
    
    public static void main(String[] args) {
        String url = "jdbc:postgresql://aws-1-us-west-2.pooler.supabase.com:5432/postgres";
        String user = "postgres.xqnicdbrknpvqgnzquuz";
        String password = "asamaadso2026";
        
        try {
            Class.forName("org.postgresql.Driver");
            Connection conn = DriverManager.getConnection(url, user, password);
            
            Statement stmt = conn.createStatement();
            stmt.execute("DELETE FROM users WHERE email != 'admin@asama.com'");
            stmt.close();
            
            String sql = "INSERT INTO users (full_name, document_id, email, password, role_id, barcode) VALUES (?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            
            // Contador (2)
            ps.setString(1, "Carlos Contador"); ps.setString(2, "200000000");
            ps.setString(3, "contador@asama.com"); ps.setString(4, sha256("12345"));
            ps.setInt(5, 2); ps.setString(6, "ASAMA-CON-200"); ps.executeUpdate();
            
            // Bodeguero (3)
            ps.setString(1, "Bruno Bodeguero"); ps.setString(2, "300000000");
            ps.setString(3, "bodeguero@asama.com"); ps.setString(4, sha256("12345"));
            ps.setInt(5, 3); ps.setString(6, "ASAMA-BOD-300"); ps.executeUpdate();
            
            // Cajero (4)
            ps.setString(1, "Camila Cajera"); ps.setString(2, "400000000");
            ps.setString(3, "cajero@asama.com"); ps.setString(4, sha256("12345"));
            ps.setInt(5, 4); ps.setString(6, "ASAMA-CAJ-400"); ps.executeUpdate();
            
            // Cliente (5)
            ps.setString(1, "Diego Cliente"); ps.setString(2, "500000000");
            ps.setString(3, "cliente@asama.com"); ps.setString(4, sha256("12345"));
            ps.setInt(5, 5); ps.setString(6, null); ps.executeUpdate();
            
            // Mecánico (6)
            ps.setString(1, "Miguel Mecánico"); ps.setString(2, "600000000");
            ps.setString(3, "mecanico@asama.com"); ps.setString(4, sha256("12345"));
            ps.setInt(5, 6); ps.setString(6, "ASAMA-MEC-600"); ps.executeUpdate();

            ps.close(); conn.close();
            System.out.println("Users created with SHA-256 passwords.");
        } catch (Exception e) { e.printStackTrace(); }
    }
}
