import java.util.Properties;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public class TestEmail {
    public static void main(String[] args) {
        String SENDER_EMAIL = "asamaadmim@gmail.com";
        String SENDER_PASSWORD = "Sa31478.";
        try {
            Properties properties = new Properties();
            properties.put("mail.smtp.auth", "true");
            properties.put("mail.smtp.starttls.enable", "true");
            properties.put("mail.smtp.host", "smtp.gmail.com");
            properties.put("mail.smtp.port", "587");
            // Sometimes this is needed
            properties.put("mail.smtp.ssl.protocols", "TLSv1.2");

            Session session = Session.getInstance(properties, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
                }
            });
            session.setDebug(true);

            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SENDER_EMAIL));
            message.addRecipient(Message.RecipientType.TO, new InternetAddress("test@test.com"));
            message.setSubject("Test");
            message.setText("Test");

            Transport.send(message);
            System.out.println("Success!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
