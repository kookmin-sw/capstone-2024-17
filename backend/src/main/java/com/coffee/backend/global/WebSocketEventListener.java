package com.coffee.backend.global;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;
import org.springframework.web.socket.messaging.SessionSubscribeEvent;
import org.springframework.web.socket.messaging.SessionUnsubscribeEvent;

@Component
public class WebSocketEventListener {
    private final SubscriptionRegistry subscriptionRegistry;

    @Autowired
    public WebSocketEventListener(SubscriptionRegistry subscriptionRegistry) {
        this.subscriptionRegistry = subscriptionRegistry;
    }

    // 구독 이벤트 발생 시, 구독 처리
    @EventListener
    public void handleSubscribeEvent(SessionSubscribeEvent event) {
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String sessionId = headerAccessor.getSessionId();
        String destination = headerAccessor.getDestination();

        // 이미 구독된 경우 pass
        if (destination != null && subscriptionRegistry.hasSubscription(sessionId, destination)) {
            return;
        }
        // 중복이 아닌 경우만 구독 추가
        subscriptionRegistry.addSubscription(sessionId, destination);
        subscriptionRegistry.printSubscriptions(); // 구독 정보 출력
    }

    // 구독 취소 이벤트 발생 시, 구독 취소 처리
    @EventListener
    public void handleUnsubscribeEvent(SessionUnsubscribeEvent event) {
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String sessionId = headerAccessor.getSessionId();
        String subscriptionId = headerAccessor.getSubscriptionId();

        System.out.println(
                "구독 취소 이벤트 sessionId: " + sessionId + ", subscriptionId: " + subscriptionId);
        // 구독 취소 시 구독 정보 삭제
        subscriptionRegistry.removeSubscription(sessionId, subscriptionId);
        subscriptionRegistry.printSubscriptions(); // 구독 정보 출력
    }

    // 웹소켓 disconnect 이벤트 발생 시, 해당 세션의 모든 구독 취소 처리
    @EventListener
    public void handleDisconnectEvent(SessionDisconnectEvent event) {
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String sessionId = headerAccessor.getSessionId();

        System.out.println("웹소켓 disconnect 이벤트 sessionId: " + sessionId);

        // 연결 종료 시 모든 구독 정보 삭제
        subscriptionRegistry.removeSubscriptionsBySessionId(sessionId);
        subscriptionRegistry.printSubscriptions(); // 구독 정보 출력
    }
}
