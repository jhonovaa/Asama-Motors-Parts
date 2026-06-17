package com.adso.cheng.filters;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import jakarta.servlet.jsp.jstl.core.Config;
import java.io.IOException;
import java.util.Locale;

@WebFilter("/*")
public class LanguageFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpSession session = req.getSession();

        String lang = req.getParameter("lang");
        if (lang != null && !lang.isEmpty()) {
            session.setAttribute("lang", lang);
        } else {
            lang = (String) session.getAttribute("lang");
            if (lang == null || lang.isEmpty()) {
                lang = "es"; // Idioma por defecto
                session.setAttribute("lang", lang);
            }
        }

        // Establecer el Locale globalmente utilizando la clase Config de JSTL
        Config.set(req, Config.FMT_LOCALE, new Locale(lang));
        
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
