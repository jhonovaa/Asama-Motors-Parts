import java.io.*;
import java.nio.file.*;
import java.util.stream.*;

public class ReplaceLink {
    public static void main(String[] args) throws Exception {
        Path webappDir = Paths.get("src/main/webapp");
        try (Stream<Path> paths = Files.walk(webappDir)) {
            paths.filter(Files::isRegularFile)
                 .filter(p -> p.toString().endsWith(".jsp"))
                 .forEach(path -> {
                     try {
                         String content = new String(Files.readAllBytes(path));
                         if (content.contains("resources/theme.css")) {
                             content = content.replaceAll("resources/theme\\.css(\\?v=[0-9]+)?", "resources/theme.css?v=6");
                             Files.write(path, content.getBytes());
                         }
                     } catch (Exception e) {}
                 });
        }
        System.out.println("Cache busting complete");
    }
}
