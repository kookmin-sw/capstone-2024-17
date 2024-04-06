package com.coffee.backend.domain.match.service;

import com.coffee.backend.global.WebSocketSessionManager;
import java.time.Duration;
import java.util.Map;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class MatchService {
    private final StringRedisTemplate stringRedisTemplate;
    private final WebSocketSessionManager webSocketSessionManager;

    // 매칭 요청 및 저장
    public void sendAndSaveMatchRequest(String fromUserId, String toUserId) {
        String matchRequestId = UUID.randomUUID().toString();
        Map<String, String> matchInfo = Map.of(
                "fromUserId", fromUserId,
                "toUserId", toUserId,
                "status", "pending"
        );

        // 요청 정보 저장
        stringRedisTemplate.opsForHash().putAll("matchRequest:" + matchRequestId, matchInfo);
        stringRedisTemplate.expire("matchRequest:" + matchRequestId, Duration.ofMinutes(10));

        // toUserId한테 매칭 요청 알림 전송
        // 따라서 convertAndSend 대신 sendResponseMessage 사용
        webSocketSessionManager.sendResponseMessage(toUserId, "매칭 요청이 왔습니다. From: " + fromUserId);
    }

    // 매칭 요청 수락
    public void acceptMatchRequest(String matchRequestId) {
        Map<Object, Object> matchInfo = stringRedisTemplate.opsForHash().entries("matchRequest:" + matchRequestId);
        if ("pending".equals(matchInfo.get("status"))) {
            stringRedisTemplate.opsForHash().put("matchRequest:" + matchRequestId, "status", "accepted");

            String fromUserId = (String) matchInfo.get("fromUserId");

            // fromUserId에게 매칭 수락 알림 전송
            webSocketSessionManager.sendResponseMessage(fromUserId, "매칭이 수락되었습니다.");
        }
    }
}