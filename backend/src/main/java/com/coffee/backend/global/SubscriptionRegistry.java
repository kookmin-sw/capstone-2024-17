package com.coffee.backend.global;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import org.springframework.stereotype.Component;

@Component
public class SubscriptionRegistry {
    private final Map<String, Set<String>> subscriptions = new HashMap<>();

    // subscribe
    public synchronized void addSubscription(String sessionId, String destination) {
        subscriptions.computeIfAbsent(sessionId, k -> new HashSet<>()).add(destination);
    }

    // 특정 세션이 특정 destination 을 구독 중인지 확인
    public synchronized boolean hasSubscription(String sessionId, String destination) {
        return subscriptions.containsKey(sessionId) && subscriptions.get(sessionId).contains(destination);
    }

    // 구독 취소
    public synchronized void removeSubscription(String sessionId, String destination) {
        if (subscriptions.containsKey(sessionId)) {
            Set<String> destinations = subscriptions.get(sessionId);
            destinations.remove(destination);
            if (destinations.isEmpty()) {
                subscriptions.remove(sessionId);
            }
        }
    }

    // 특정 세션의 모든 구독 취소
    public synchronized void removeSubscriptionsBySessionId(String sessionId) {
        subscriptions.remove(sessionId);
    }

    // 전체 구독 정보를 출력
    public synchronized void printSubscriptions() {
        System.out.println("웹소켓 구독 정보: " + subscriptions);
    }
}
