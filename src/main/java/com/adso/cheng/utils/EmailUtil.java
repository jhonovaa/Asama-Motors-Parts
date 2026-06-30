package com.adso.cheng.utils;

import java.util.Properties;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public class EmailUtil {

    private static final String SENDER_EMAIL = "asamaadmim@gmail.com";
    private static final String SENDER_PASSWORD = "xjewgactfzzyfkis";

    public static void sendOtpEmail(String recipientEmail, String otp) throws Exception {
        Properties properties = new Properties();
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.host", "smtp.gmail.com");
        properties.put("mail.smtp.port", "587");
        properties.put("mail.smtp.ssl.protocols", "TLSv1.2");
        
        // Configuraciones recomendadas para servidores Linux
        properties.put("mail.smtp.ssl.trust", "smtp.gmail.com"); // Previene errores de certificados (PKIX) comunes en Linux
        properties.put("mail.smtp.connectiontimeout", "10000");  // Timeout de 10 segundos
        properties.put("mail.smtp.timeout", "10000");
        
        System.out.println("\n==================================");
        System.out.println("INTENTANDO ENVIAR OTP: " + otp);
        System.out.println("A CORREO: " + recipientEmail);
        System.out.println("==================================\n");

        Session session = Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
            }
        });

        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(SENDER_EMAIL, "Asama Moto Parts"));
        message.addRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));
        message.setSubject("Codigo de Verificacion OTP - Asama Moto Parts");

        // Diseno de alta fidelidad en Gris Carbon y Azul Electrico
        String htmlContent = "<!DOCTYPE html><html><head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"></head>"
                + "<body style=\"margin: 0; padding: 0; background-color: #0a0b0d; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;\">"
                + "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"padding: 40px 20px;\">"
                + "<tr><td align=\"center\">"
                + "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"max-width: 550px; background-color: #14171c; border-radius: 16px; border-top: 6px solid #ED1C24; box-shadow: 0 12px 32px rgba(0,0,0,0.5);\">"
                + "<tr><td align=\"center\" style=\"padding: 45px 30px 15px 30px;\">"
                + "<h1 style=\"color: #ffffff; margin: 0; font-size: 26px; font-weight: 800; letter-spacing: 2px; text-transform: uppercase;\">ASAMA <span style=\"color: #ED1C24;\">MOTO PARTS</span></h1>"
                + "</td></tr>"
                + "<tr><td style=\"padding: 20px 40px 40px 40px;\">"
                + "<h2 style=\"color: #ffffff; margin: 0 0 15px 0; font-size: 18px; font-weight: 600;\">Hola,</h2>"
                + "<p style=\"color: #98a2b3; font-size: 15px; line-height: 1.6; margin: 0 0 30px 0;\">Hemos recibido una solicitud para acceder a tu cuenta. Utiliza el siguiente codigo de seguridad para completar tu inicio de sesion de forma segura:</p>"
                + "<div style=\"background-color: #0a0b0d; border: 1px solid rgba(237, 28, 36, 0.4); border-radius: 12px; padding: 25px; text-align: center; margin-bottom: 30px; box-shadow: inset 0 2px 8px rgba(0,0,0,0.6);\">"
                + "<span style=\"font-family: 'Courier New', Courier, monospace; font-size: 48px; font-weight: 900; letter-spacing: 14px; color: #ED1C24; margin-left: 14px;\">" + otp + "</span>"
                + "</div>"
                + "<p style=\"color: #667085; font-size: 13px; line-height: 1.5; margin: 0;\">Este codigo es de un solo uso y tiene un tiempo limite de expiracion. Si no solicitaste este movimiento, puedes ignorar este mensaje.</p>"
                + "</td></tr>"
                + "<tr><td align=\"center\" style=\"padding: 24px; background-color: #0a0b0d; border-bottom-left-radius: 16px; border-bottom-right-radius: 16px;\">"
                + "<p style=\"color: #475467; font-size: 11px; margin: 0; text-transform: uppercase; letter-spacing: 1px;\">&copy; 2026 Asama Moto Parts. Todos los derechos reservados.</p>"
                + "</td></tr>"
                + "</table></td></tr></table></body></html>";

        message.setContent(htmlContent, "text/html; charset=utf-8");

        Transport.send(message);
    }

    public static void sendPasswordResetEmail(String recipientEmail, String resetLink) throws Exception {
        Properties properties = new Properties();
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.host", "smtp.gmail.com");
        properties.put("mail.smtp.port", "587");
        properties.put("mail.smtp.ssl.protocols", "TLSv1.2");
        properties.put("mail.smtp.ssl.trust", "smtp.gmail.com");
        properties.put("mail.smtp.connectiontimeout", "10000");
        properties.put("mail.smtp.timeout", "10000");
        
        System.out.println("\n==================================");
        System.out.println("INTENTANDO ENVIAR LINK DE RESET: " + resetLink);
        System.out.println("A CORREO: " + recipientEmail);
        System.out.println("==================================\n");

        Session session = Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
            }
        });

        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(SENDER_EMAIL, "Asama Moto Parts"));
        message.addRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));
        message.setSubject("Recuperación de Contraseña - Asama Moto Parts");

        String htmlContent = "<!DOCTYPE html><html><head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"></head>"
                + "<body style=\"margin: 0; padding: 0; background-color: #0a0b0d; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;\">"
                + "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"padding: 40px 20px;\">"
                + "<tr><td align=\"center\">"
                + "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"max-width: 550px; background-color: #14171c; border-radius: 16px; border-top: 6px solid #ED1C24; box-shadow: 0 12px 32px rgba(0,0,0,0.5);\">"
                + "<tr><td align=\"center\" style=\"padding: 45px 30px 15px 30px;\">"
                + "<h1 style=\"color: #ffffff; margin: 0; font-size: 26px; font-weight: 800; letter-spacing: 2px; text-transform: uppercase;\">ASAMA <span style=\"color: #ED1C24;\">MOTO PARTS</span></h1>"
                + "</td></tr>"
                + "<tr><td style=\"padding: 20px 40px 40px 40px;\">"
                + "<h2 style=\"color: #ffffff; margin: 0 0 15px 0; font-size: 18px; font-weight: 600;\">Recuperar Acceso,</h2>"
                + "<p style=\"color: #98a2b3; font-size: 15px; line-height: 1.6; margin: 0 0 30px 0;\">Hemos recibido una solicitud para cambiar tu contraseña. Haz clic en el botón de abajo para establecer una nueva contraseña de forma segura:</p>"
                + "<div style=\"text-align: center; margin-bottom: 30px;\">"
                + "<a href=\"" + resetLink + "\" style=\"display: inline-block; background-color: #ED1C24; color: #ffffff; font-size: 16px; font-weight: bold; text-decoration: none; padding: 16px 32px; border-radius: 50px; box-shadow: 0 4px 15px rgba(237, 28, 36, 0.4);\">Cambiar Mi Contraseña</a>"
                + "</div>"
                + "<p style=\"color: #667085; font-size: 13px; line-height: 1.5; margin: 0;\">Este enlace es de un solo uso y expirará en 15 minutos. Si no solicitaste este cambio, puedes ignorar este mensaje; tu cuenta sigue segura.</p>"
                + "</td></tr>"
                + "<tr><td align=\"center\" style=\"padding: 24px; background-color: #0a0b0d; border-bottom-left-radius: 16px; border-bottom-right-radius: 16px;\">"
                + "<p style=\"color: #475467; font-size: 11px; margin: 0; text-transform: uppercase; letter-spacing: 1px;\">&copy; 2026 Asama Moto Parts. Todos los derechos reservados.</p>"
                + "</td></tr>"
                + "</table></td></tr></table></body></html>";

        message.setContent(htmlContent, "text/html; charset=utf-8");

        Transport.send(message);
    }

    public static void sendMaintenanceFinishedEmail(String recipientEmail, java.util.Map<String, Object> job, java.util.List<java.util.Map<String, Object>> parts) throws Exception {
        Properties properties = new Properties();
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.host", "smtp.gmail.com");
        properties.put("mail.smtp.port", "587");
        properties.put("mail.smtp.ssl.protocols", "TLSv1.2");
        properties.put("mail.smtp.ssl.trust", "smtp.gmail.com");
        properties.put("mail.smtp.connectiontimeout", "10000");
        properties.put("mail.smtp.timeout", "10000");
        
        Session session = Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
            }
        });

        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(SENDER_EMAIL, "Asama Moto Parts"));
        message.addRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));
        message.setSubject("Mantenimiento Terminado - Asama Moto Parts");

        String motoDesc = job.get("motoBrand") + " " + job.get("motoModel") + " (" + job.get("plate") + ")";
        String totalCost = String.format("%,.2f", ((Number)job.get("cost")).doubleValue());

        StringBuilder partsHtml = new StringBuilder();
        if (parts != null && !parts.isEmpty()) {
            partsHtml.append("<table width=\"100%\" style=\"color:#98a2b3; font-size: 14px; border-collapse: collapse; margin-bottom: 20px;\">")
                     .append("<tr style=\"border-bottom: 1px solid rgba(255,255,255,0.1);\">")
                     .append("<th align=\"left\" style=\"padding:8px 0;\">Repuesto</th>")
                     .append("<th align=\"center\" style=\"padding:8px 0;\">Cant.</th>")
                     .append("<th align=\"right\" style=\"padding:8px 0;\">Costo</th>")
                     .append("</tr>");
            
            for (java.util.Map<String, Object> part : parts) {
                double partTotal = (((Number)part.get("price")).doubleValue() * ((Number)part.get("quantity")).intValue()) + ((Number)part.get("laborCost")).doubleValue();
                partsHtml.append("<tr style=\"border-bottom: 1px solid rgba(255,255,255,0.05);\">")
                         .append("<td style=\"padding:8px 0;\">").append(part.get("name")).append("</td>")
                         .append("<td align=\"center\" style=\"padding:8px 0;\">").append(part.get("quantity")).append("</td>")
                         .append("<td align=\"right\" style=\"padding:8px 0;\">$").append(String.format("%,.2f", partTotal)).append("</td>")
                         .append("</tr>");
            }
            partsHtml.append("</table>");
        } else {
            partsHtml.append("<p style=\"color: #98a2b3; font-size: 14px; font-style: italic;\">No se registraron repuestos (solo diagnóstico o mano de obra general).</p>");
        }

        String htmlContent = "<!DOCTYPE html><html><head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"></head>"
                + "<body style=\"margin: 0; padding: 0; background-color: #0a0b0d; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;\">"
                + "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"padding: 40px 20px;\">"
                + "<tr><td align=\"center\">"
                + "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"max-width: 550px; background-color: #14171c; border-radius: 16px; border-top: 6px solid #ED1C24; box-shadow: 0 12px 32px rgba(0,0,0,0.5);\">"
                + "<tr><td align=\"center\" style=\"padding: 45px 30px 15px 30px;\">"
                + "<h1 style=\"color: #ffffff; margin: 0; font-size: 26px; font-weight: 800; letter-spacing: 2px; text-transform: uppercase;\">ASAMA <span style=\"color: #ED1C24;\">MOTO PARTS</span></h1>"
                + "</td></tr>"
                + "<tr><td style=\"padding: 20px 40px 40px 40px;\">"
                + "<h2 style=\"color: #ffffff; margin: 0 0 15px 0; font-size: 18px; font-weight: 600;\">¡Tu moto está lista!</h2>"
                + "<p style=\"color: #98a2b3; font-size: 15px; line-height: 1.6; margin: 0 0 20px 0;\">Hola <b>" + job.get("customerName") + "</b>, el mantenimiento de tu <b>" + motoDesc + "</b> ha sido completado y ya puedes pasar a recogerla.</p>"
                + "<div style=\"background-color: #0a0b0d; border: 1px solid rgba(237, 28, 36, 0.4); border-radius: 12px; padding: 25px; margin-bottom: 25px; box-shadow: inset 0 2px 8px rgba(0,0,0,0.6);\">"
                + "<h3 style=\"color: #ffffff; margin-top: 0; font-size: 16px; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 10px;\">Detalle del Servicio</h3>"
                + partsHtml.toString()
                + "<div style=\"text-align: right; color: #ED1C24; font-size: 18px; font-weight: bold; margin-top: 15px;\">Total: $" + totalCost + " COP</div>"
                + "</div>"
                + "<p style=\"color: #667085; font-size: 13px; line-height: 1.5; margin: 0;\">Por favor acércate a nuestra sede para realizar el pago y retirar tu vehículo. ¡Gracias por confiar en Asama Moto Parts!</p>"
                + "</td></tr>"
                + "<tr><td align=\"center\" style=\"padding: 24px; background-color: #0a0b0d; border-bottom-left-radius: 16px; border-bottom-right-radius: 16px;\">"
                + "<p style=\"color: #475467; font-size: 11px; margin: 0; text-transform: uppercase; letter-spacing: 1px;\">&copy; 2026 Asama Moto Parts. Todos los derechos reservados.</p>"
                + "</td></tr>"
                + "</table></td></tr></table></body></html>";

        message.setContent(htmlContent, "text/html; charset=utf-8");
        Transport.send(message);
    }

    public static void sendPurchaseInvoiceEmail(String recipientEmail, String customerName, java.util.List<java.util.Map<String, Object>> cart, double totalCost, boolean isRegistered, boolean isOnline, String storeUrl) throws Exception {
        Properties properties = new Properties();
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.host", "smtp.gmail.com");
        properties.put("mail.smtp.port", "587");
        properties.put("mail.smtp.ssl.protocols", "TLSv1.2");
        properties.put("mail.smtp.ssl.trust", "smtp.gmail.com");
        properties.put("mail.smtp.connectiontimeout", "10000");
        properties.put("mail.smtp.timeout", "10000");
        
        Session session = Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
            }
        });

        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(SENDER_EMAIL, "Asama Moto Parts"));
        message.addRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));
        message.setSubject("Factura de Compra - Asama Moto Parts");

        StringBuilder partsHtml = new StringBuilder();
        if (cart != null && !cart.isEmpty()) {
            partsHtml.append("<table width=\"100%\" style=\"color:#98a2b3; font-size: 14px; border-collapse: collapse; margin-bottom: 20px;\">")
                     .append("<tr style=\"border-bottom: 1px solid rgba(255,255,255,0.1);\">")
                     .append("<th align=\"left\" style=\"padding:8px 0;\">Producto</th>")
                     .append("<th align=\"center\" style=\"padding:8px 0;\">Cant.</th>")
                     .append("<th align=\"right\" style=\"padding:8px 0;\">Subtotal</th>")
                     .append("</tr>");
            
            for (java.util.Map<String, Object> part : cart) {
                String name = (String) part.get("name");
                int qty = ((Number) part.get("qty")).intValue();
                double price = ((Number) part.get("price")).doubleValue();
                double partTotal = price * qty;
                partsHtml.append("<tr style=\"border-bottom: 1px solid rgba(255,255,255,0.05);\">")
                         .append("<td style=\"padding:8px 0;\">").append(name).append("</td>")
                         .append("<td align=\"center\" style=\"padding:8px 0;\">").append(qty).append("</td>")
                         .append("<td align=\"right\" style=\"padding:8px 0;\">$").append(String.format("%,.2f", partTotal)).append("</td>")
                         .append("</tr>");
            }
            partsHtml.append("</table>");
        }

        String greeting = isOnline ? "Gracias por tu compra. Tu pedido está en proceso de preparación." : "Gracias por tu compra presencial.";
        
        String registerHtml = "";
        if (!isRegistered) {
            registerHtml = "<div style=\"background-color: #241416; border-left: 4px solid #ED1C24; padding: 15px; margin-bottom: 25px;\">"
                         + "<h3 style=\"color: #ED1C24; margin-top: 0; font-size: 15px;\">¡Únete a nuestra comunidad!</h3>"
                         + "<p style=\"color: #98a2b3; font-size: 13px; line-height: 1.5; margin: 0 0 10px 0;\">Regístrate para estar al pendiente de nuestros servicios, ver el historial de tus compras y agilizar tus garantías.</p>"
                         + "<a href=\"" + storeUrl + "\" style=\"display: inline-block; background-color: #ED1C24; color: #ffffff; font-size: 13px; font-weight: bold; text-decoration: none; padding: 8px 16px; border-radius: 4px;\">Regístrate Aquí</a>"
                         + "</div>";
        }

        String htmlContent = "<!DOCTYPE html><html><head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"></head>"
                + "<body style=\"margin: 0; padding: 0; background-color: #0a0b0d; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;\">"
                + "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"padding: 40px 20px;\">"
                + "<tr><td align=\"center\">"
                + "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"max-width: 550px; background-color: #14171c; border-radius: 16px; border-top: 6px solid #ED1C24; box-shadow: 0 12px 32px rgba(0,0,0,0.5);\">"
                + "<tr><td align=\"center\" style=\"padding: 45px 30px 15px 30px;\">"
                + "<h1 style=\"color: #ffffff; margin: 0; font-size: 26px; font-weight: 800; letter-spacing: 2px; text-transform: uppercase;\">ASAMA <span style=\"color: #ED1C24;\">MOTO PARTS</span></h1>"
                + "</td></tr>"
                + "<tr><td style=\"padding: 20px 40px 40px 40px;\">"
                + "<h2 style=\"color: #ffffff; margin: 0 0 15px 0; font-size: 18px; font-weight: 600;\">" + greeting + "</h2>"
                + "<p style=\"color: #98a2b3; font-size: 15px; line-height: 1.6; margin: 0 0 20px 0;\">Hola <b>" + customerName + "</b>, aquí tienes el resumen de tu compra:</p>"
                + "<div style=\"background-color: #0a0b0d; border: 1px solid rgba(237, 28, 36, 0.4); border-radius: 12px; padding: 25px; margin-bottom: 25px; box-shadow: inset 0 2px 8px rgba(0,0,0,0.6);\">"
                + "<h3 style=\"color: #ffffff; margin-top: 0; font-size: 16px; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 10px;\">Detalle de Factura</h3>"
                + partsHtml.toString()
                + "<div style=\"text-align: right; color: #ED1C24; font-size: 18px; font-weight: bold; margin-top: 15px;\">Total a Pagar: $" + String.format("%,.2f", totalCost) + "</div>"
                + "</div>"
                + registerHtml
                + "<p style=\"color: #667085; font-size: 13px; line-height: 1.5; margin: 0;\">Gracias por confiar en Asama Moto Parts.</p>"
                + "</td></tr>"
                + "<tr><td align=\"center\" style=\"padding: 24px; background-color: #0a0b0d; border-bottom-left-radius: 16px; border-bottom-right-radius: 16px;\">"
                + "<p style=\"color: #475467; font-size: 11px; margin: 0; text-transform: uppercase; letter-spacing: 1px;\">&copy; 2026 Asama Moto Parts. Todos los derechos reservados.</p>"
                + "</td></tr>"
                + "</table></td></tr></table></body></html>";

        message.setContent(htmlContent, "text/html; charset=utf-8");
        Transport.send(message);
    }
}