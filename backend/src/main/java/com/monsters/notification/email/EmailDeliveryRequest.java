package com.monsters.notification.email;

import java.util.Map;

public record EmailDeliveryRequest(
        String recipient,
        String templateId,
        Map<String, String> variables
) {

    public EmailDeliveryRequest {
        variables = Map.copyOf(variables);
    }
}
