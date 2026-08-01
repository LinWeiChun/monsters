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
    private static final String GUARDIAN_GRANT_TEMPLATE = "guardian-consent-grant";
    private static final String GUARDIAN_WITHDRAW_TEMPLATE = "guardian-consent-withdraw";

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
        if (!VERIFICATION_TEMPLATE.equals(request.templateId())
                && !GUARDIAN_GRANT_TEMPLATE.equals(request.templateId())
                && !GUARDIAN_WITHDRAW_TEMPLATE.equals(request.templateId())) {
            throw new IllegalArgumentException("Unsupported email template");
        }
        String actionUrl = requiredVariable(request.variables(),
                VERIFICATION_TEMPLATE.equals(request.templateId()) ? "verificationUrl" : "actionUrl");
        if (!StringUtils.hasText(properties.getFrom())
                || !StringUtils.hasText(properties.getSubject())) {
            throw new IllegalStateException("Registration SMTP sender is unavailable");
        }

        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(properties.getFrom());
        message.setTo(request.recipient());
        message.setSubject(subject(request.templateId()));
        message.setText(body(request.templateId(), actionUrl, request.variables().get("consentReference")));
        mailSender.send(message);
    }

    private String subject(String template) {
        return switch (template) {
            case GUARDIAN_GRANT_TEMPLATE -> properties.getGuardianGrantSubject();
            case GUARDIAN_WITHDRAW_TEMPLATE -> properties.getGuardianWithdrawSubject();
            default -> properties.getSubject();
        };
    }

    private String body(String template, String url, String consentReference) {
        return switch (template) {
            case GUARDIAN_GRANT_TEMPLATE -> """
                    請閱讀監護人同意文件，並使用以下單次連結確認。連結將於 24 小時後失效：

                    %s

                    此同意不會讓您查看會員的私人內容。日後如需撤回，請保留同意編號：%s
                    若您未收到同意請求，請忽略這封信。
                    """.formatted(url, consentReference);
            case GUARDIAN_WITHDRAW_TEMPLATE -> """
                    請使用以下單次連結確認撤回監護人同意。連結將於 15 分鐘後失效：

                    %s

                    完成撤回後，會員將立即無法使用一般功能。
                    """.formatted(url);
            default -> """
                    請使用以下連結完成 Email 驗證。連結將於 24 小時後失效：

                    %s

                    若您未提出此要求，請忽略這封信。
                    """.formatted(url);
        };
    }

    private String requiredVariable(Map<String, String> variables, String name) {
        String value = variables.get(name);
        if (!StringUtils.hasText(value)) {
            throw new IllegalArgumentException("Email template variable is missing");
        }
        return value;
    }
}
