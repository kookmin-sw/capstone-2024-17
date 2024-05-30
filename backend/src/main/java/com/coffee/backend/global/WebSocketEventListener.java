package com.coffee.backend.global;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionSubscribeEvent;

@Component
public class WebSocketEventListener {
    private final SubscriptionRegistry subscriptionRegistry;

    @Autowired
    public WebSocketEventListener(SubscriptionRegistry subscriptionRegistry) {
        this.subscriptionRegistry = subscriptionRegistry;
    }

    @EventListener
    public void handleSubscribeEvent(SessionSubscribeEvent event) {
        // 구독 이벤트 발생 시, 구독 처리
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String sessionId = headerAccessor.getSessionId();
        String destination = headerAccessor.getDestination();

        // 이미 구독된 경우, 추가 처리 없이 반환
        if (destination != null && subscriptionRegistry.hasSubscription(sessionId, destination)) {
            return;
        }
        // 중복이 아닌 경우만 구독 추가
        subscriptionRegistry.addSubscription(sessionId, destination);

        // 구독 정보 출력
        subscriptionRegistry.printSubscriptions();
    }
}

