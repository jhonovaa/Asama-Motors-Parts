<%@ page contentType="text/plain;charset=UTF-8" language="java" %>
<%
    String realPath = request.getServletContext().getRealPath("/");
    String userDir = System.getProperty("user.dir");
    String classPath = application.getClass().getResource("/").getPath();
    
    out.println("realPath: " + realPath);
    out.println("user.dir: " + userDir);
    out.println("classPath: " + classPath);
%>
