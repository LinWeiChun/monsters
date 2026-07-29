package com.monsters.notification.email;

import com.monsters.config.registration.RegistrationSmtpProperties;
import java.util.Map;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

@Component
@ConditionalOnProperty(
        prefix = "app.registration.email.smtp",
        name = "enabled",
        havingValue = "true"
)
public class SmtpEmailDeliveryAdapter implements EmailDeliveryPort {

    private static final String VERIFICATION_TEMPLATE = "verify-email";

    private final JavaMailSender mailSender;
    private final RegistrationSmtpProperties properties;

    public SmtpEmailDeliveryAdapter(
            JavaMailSender mailSender,
            RegistrationSmtpProperties properties
    ) {
        this.mailSender = mailSender;
        this.properties = properties;
    }

    @Override
    public void deliver(EmailDeliveryRequest request) {
        if (!VERIFICATION_TEMPLATE.equals(request.templateId())) {
            throw new IllegalArgumentException("Unsupported email template");
        }
        String verificationUrl = requiredVariable(request.variables(), "verificationUrl");
        if (!StringUtils.hasText(properties.getFrom())
                || !StringUtils.hasText(properties.getSubject())) {
            throw new IllegalStateException("Registration SMTP sender is unavailable");
        }

        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(properties.getFrom());
        message.setTo(request.recipient());
        message.setSubject(properties.getSubject());
        message.setText("""
                請使用以下連結完成 Email 驗證。連結將於 24 小時後失效：

                %s

                若您未提出此要求，請忽略這封信。
                """.formatted(verificationUrl));
        mailSender.send(message);
    }

    private String requiredVariable(Map<String, String> variables, String name) {
        String value = variables.get(name);
        if (!StringUtils.hasText(value)) {
            throw new IllegalArgumentException("Email template variable is missing");
        }
        return value;
    }
}
