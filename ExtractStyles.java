import java.io.*;
import java.nio.file.*;
import java.util.regex.*;
import java.util.stream.*;

public class ExtractStyles {
    public static void main(String[] args) throws Exception {
        Path webappDir = Paths.get("src/main/webapp");
        Path outFile = Paths.get("styles_dump.txt");
        StringBuilder dump = new StringBuilder();
        Pattern stylePattern = Pattern.compile("(?s)<style>(.*?)</style>");

        try (Stream<Path> paths = Files.walk(webappDir)) {
            paths.filter(Files::isRegularFile)
                 .filter(p -> p.toString().endsWith(".jsp"))
                 .forEach(path -> {
                     try {
                         String content = new String(Files.readAllBytes(path));
                         Matcher m = stylePattern.matcher(content);
                         if (m.find()) {
                             dump.append("=== ").append(path.getFileName()).append(" ===\n");
                             dump.append(m.group(1)).append("\n\n");
                         }
                     } catch (Exception e) {}
                 });
        }
        Files.write(outFile, dump.toString().getBytes());
        System.out.println("Extracted styles to styles_dump.txt");
    }
}
