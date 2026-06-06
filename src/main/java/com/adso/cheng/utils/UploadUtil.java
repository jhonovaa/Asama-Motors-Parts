package com.adso.cheng.utils;

import jakarta.servlet.http.HttpServletRequest;
import java.io.File;

public class UploadUtil {
    
    public static String getSourceWebappPath(HttpServletRequest request) {
        // 1. Try to read project absolute path from Maven filtered properties
        try {
            java.io.InputStream is = UploadUtil.class.getClassLoader().getResourceAsStream("path.properties");
            if (is != null) {
                java.util.Properties props = new java.util.Properties();
                props.load(is);
                String basedir = props.getProperty("project.basedir");
                if (basedir != null && !basedir.contains("${")) {
                    File srcWebapp = new File(basedir, "src" + File.separator + "main" + File.separator + "webapp");
                    if (srcWebapp.exists()) {
                        return srcWebapp.getAbsolutePath();
                    }
                }
            }
        } catch (Exception ignored) {
            // Fallback to next methods
        }

        String realPath = request.getServletContext().getRealPath("/");
        if (realPath != null) {
            // 2. If it already points to src/main/webapp
            if (realPath.replace('\\', '/').contains("/src/main/webapp")) {
                return realPath;
            }

            // 3. Try walking up from realPath to find project root (pom.xml)
            String projectRoot = findProjectRoot(new File(realPath));
            if (projectRoot != null) {
                File srcWebapp = new File(projectRoot, "src" + File.separator + "main" + File.separator + "webapp");
                if (srcWebapp.exists()) {
                    return srcWebapp.getAbsolutePath();
                }
            }
        }

        // 4. Fallback: check if we are running via Maven (user.dir is project root)
        File userDirSrc = new File(System.getProperty("user.dir"), "src" + File.separator + "main" + File.separator + "webapp");
        if (userDirSrc.exists()) {
            return userDirSrc.getAbsolutePath();
        }

        // 5. Common paths heuristic for teammates
        String userHome = System.getProperty("user.home");
        String[] commonRoots = {"Desktop", "Documents", "Downloads"};
        for (String root : commonRoots) {
            File possibleSrc = new File(userHome, root + File.separator + "asama" + File.separator + "src" + File.separator + "main" + File.separator + "webapp");
            if (possibleSrc.exists()) {
                return possibleSrc.getAbsolutePath();
            }
        }

        // 6. Final Fallback: use the deployment folder
        return realPath;
    }

    private static String findProjectRoot(File currentDir) {
        if (currentDir == null || !currentDir.exists()) return null;
        File pom = new File(currentDir, "pom.xml");
        if (pom.exists()) {
            return currentDir.getAbsolutePath();
        }
        return findProjectRoot(currentDir.getParentFile());
    }
}
