public class TestUploadUtil {
    public static void main(String[] args) {
        String userDir = System.getProperty("user.dir");
        String userHome = System.getProperty("user.home");
        System.out.println("user.dir: " + userDir);
        System.out.println("user.home: " + userHome);
        
        java.io.File desktopSrc = new java.io.File(userHome, "Desktop\\asama\\src\\main\\webapp");
        System.out.println("Desktop Src exists: " + desktopSrc.exists());
        System.out.println("Desktop Src path: " + desktopSrc.getAbsolutePath());
    }
}
