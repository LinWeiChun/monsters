package com.monsters.notification.email;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import com.monsters.config.registration.RegistrationSmtpProperties;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;

class SmtpEmailDeliveryAdapterTest {

    @Test
    void shouldRenderVerificationUrlWithoutLoggingOrProviderSpecificCode() {
        JavaMailSender mailSender = mock(JavaMailSender.class);
        RegistrationSmtpProperties properties = new RegistrationSmtpProperties();
        properties.setFrom("no-reply@example.test");
        properties.setSubject("Verify your Monsters email");
        SmtpEmailDeliveryAdapter adapter = new SmtpEmailDeliveryAdapter(mailSender, properties);

        adapter.deliver(new EmailDeliveryRequest(
                "member@example.test",
                "verify-email",
                Map.of("verificationUrl", "https://example.test/verify-email?token=synthetic")
        ));

        ArgumentCaptor<SimpleMailMessage> captor =
                ArgumentCaptor.forClass(SimpleMailMessage.class);
        verify(mailSender).send(captor.capture());
        assertThat(captor.getValue().getFrom()).isEqualTo("no-reply@example.test");
        assertThat(captor.getValue().getTo()).containsExactly("member@example.test");
        assertThat(captor.getValue().getSubject()).isEqualTo("Verify your Monsters email");
        assertThat(captor.getValue().getText())
                .contains("https://example.test/verify-email?token=synthetic")
                .doesNotContain("member@example.test");
    }
}
