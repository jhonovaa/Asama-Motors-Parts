import java.nio.file.*;
import java.util.regex.*;
import java.io.IOException;

public class Refactor {
    public static void main(String[] args) throws IOException {
        Path dir = Paths.get("c:\\Users\\salaz\\Desktop\\asama\\src\\main\\webapp");
        // Regex to match :root { ... } including newlines
        Pattern p = Pattern.compile("(?s)\\s*:root\\s*\\{[^}]*\\}");
        Files.walk(dir).filter(path -> path.toString().endsWith(".jsp")).forEach(path -> {
            try {
                String content = new String(Files.readAllBytes(path), "UTF-8");
                String newContent = p.matcher(content).replaceAll("");
                if (!content.equals(newContent)) {
                    Files.write(path, newContent.getBytes("UTF-8"));
                    System.out.println("Modified " + path.getFileName());
                }
            } catch(Exception e) {
                e.printStackTrace();
            }
        });
        System.out.println("Refactoring complete.");
    }
}
