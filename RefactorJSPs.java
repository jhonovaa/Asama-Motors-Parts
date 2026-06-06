import java.io.*;
import java.nio.file.*;
import java.util.regex.*;
import java.util.stream.*;

public class RefactorJSPs {
    public static void main(String[] args) throws Exception {
        Path webappDir = Paths.get("src/main/webapp");
        Pattern stylePattern = Pattern.compile("(?s)\\s*<style>.*?</style>\\s*");

        try (Stream<Path> paths = Files.walk(webappDir)) {
            paths.filter(Files::isRegularFile)
                 .filter(p -> p.toString().endsWith(".jsp"))
                 .forEach(path -> {
                     try {
                         String content = new String(Files.readAllBytes(path));
                         boolean changed = false;

                         // Remove <style> blocks
                         Matcher m = stylePattern.matcher(content);
                         if (m.find()) {
                             content = m.replaceAll("\n");
                             changed = true;
                         }

                         // Add specific body classes
                         String fileName = path.getFileName().toString();
                         if (fileName.equals("login.jsp") || fileName.equals("register.jsp") || 
                             fileName.equals("otp.jsp") || fileName.equals("time_tracking.jsp")) {
                             if (!content.contains("<body class=\"body-center\">")) {
                                 content = content.replace("<body>", "<body class=\"body-center\">");
                                 changed = true;
                             }
                         } else if (fileName.equals("index.jsp")) {
                             if (!content.contains("<body class=\"no-pad\">")) {
                                 content = content.replace("<body>", "<body class=\"no-pad\">");
                                 changed = true;
                             }
                         }

                         if (changed) {
                             Files.write(path, content.getBytes());
                             System.out.println("Cleaned up: " + fileName);
                         }
                     } catch (Exception e) {
                         System.err.println("Error on " + path.getFileName() + ": " + e.getMessage());
                     }
                 });
        }
        System.out.println("Global JSP Refactoring Complete!");
    }
}
