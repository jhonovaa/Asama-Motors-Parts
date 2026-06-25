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
                + "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"max-width: 550px; background-color: #14171c; border-radius: 16px; border-top: 6px solid #0052ff; box-shadow: 0 12px 32px rgba(0,0,0,0.5);\">"
                + "<tr><td align=\"center\" style=\"padding: 45px 30px 15px 30px;\">"
                + "<h1 style=\"color: #ffffff; margin: 0; font-size: 26px; font-weight: 800; letter-spacing: 2px; text-transform: uppercase;\">ASAMA <span style=\"color: #0052ff;\">MOTO PARTS</span></h1>"
                + "</td></tr>"
                + "<tr><td style=\"padding: 20px 40px 40px 40px;\">"
                + "<h2 style=\"color: #ffffff; margin: 0 0 15px 0; font-size: 18px; font-weight: 600;\">Hola,</h2>"
                + "<p style=\"color: #98a2b3; font-size: 15px; line-height: 1.6; margin: 0 0 30px 0;\">Hemos recibido una solicitud para acceder a tu cuenta. Utiliza el siguiente codigo de seguridad para completar tu inicio de sesion de forma segura:</p>"
                + "<div style=\"background-color: #0a0b0d; border: 1px solid rgba(0, 82, 255, 0.4); border-radius: 12px; padding: 25px; text-align: center; margin-bottom: 30px; box-shadow: inset 0 2px 8px rgba(0,0,0,0.6);\">"
                + "<span style=\"font-family: 'Courier New', Courier, monospace; font-size: 48px; font-weight: 900; letter-spacing: 14px; color: #0052ff; margin-left: 14px;\">" + otp + "</span>"
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
}