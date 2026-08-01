package com.monsters.config.registration;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "app.registration.email.smtp")
public class RegistrationSmtpProperties {

    private String from;
    private String subject = "Verify your Monsters email";
    private String guardianGrantSubject = "貘nsters 監護人同意確認";
    private String guardianWithdrawSubject = "貘nsters 監護人同意撤回確認";

    public String getFrom() {
        return from;
    }

    public void setFrom(String from) {
        this.from = from;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }
    public String getGuardianGrantSubject() { return guardianGrantSubject; }
    public void setGuardianGrantSubject(String value) { guardianGrantSubject = value; }
    public String getGuardianWithdrawSubject() { return guardianWithdrawSubject; }
    public void setGuardianWithdrawSubject(String value) { guardianWithdrawSubject = value; }
}
