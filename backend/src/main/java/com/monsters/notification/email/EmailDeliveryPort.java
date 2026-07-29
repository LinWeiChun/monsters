package com.monsters.notification.email;

public interface EmailDeliveryPort {

    void deliver(EmailDeliveryRequest request);
}
