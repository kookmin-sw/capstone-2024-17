package com.coffee.backend.domain.redis.service;

import com.coffee.backend.global.WebSocketSessionManager;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Duration;
import java.util.Map;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.connection.Message;
import org.springframework.data.redis.connection.MessageListener;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

// 2. Redis Pub/Sub으로 메시지 발행/수신
@RequiredArgsConstructor
@Service
public class RedisService implements MessageListener {
    private final WebSocketSessionManager webSocketSessionManager;
    private final StringRedisTemplate stringRedisTemplate;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void onMessage(Message message, byte[] pattern) {
        String channel = new String(message.getChannel());
        String messageBody = new String(message.getBody());

        try {
            JsonNode jsonNode = objectMapper.readTree(messageBody);
            if ("cafeChoice".equals(channel)) {
                handleCafeChoice(jsonNode);
            } else if ("matchRequest".equals(channel)) {
                handleMatchRequest(jsonNode);
            }
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
    }

    public void handleCafeChoice(JsonNode jsonNode) {
        String userId = jsonNode.get("userId").asText();
        String cafeId = jsonNode.get("cafeId").asText();
        publishCafeChoice(userId, cafeId);
    }

    public void handleMatchRequest(JsonNode jsonNode) {
        String fromUserId = jsonNode.get("fromUserId").asText();
        String toUserId = jsonNode.get("toUserId").asText();
        String matchRequestId = createMatchRequestId(fromUserId, toUserId);
        saveMatchRequest(matchRequestId, fromUserId, toUserId);
        publishMatchRequest(fromUserId, toUserId);
    }

    public void publishCafeChoice(String userId, String cafeId) {
        String message = String.format("{\"userId\":\"%s\", \"cafeId\":\"%s\"}", userId, cafeId);
        stringRedisTemplate.convertAndSend("cafeChoice", message);
    }

    public void publishMatchRequest(String fromUserId, String toUserId) {
        String message = String.format("{\"fromUserId\":\"%s\", \"toUserId\":\"%s\"}", fromUserId, toUserId);
        stringRedisTemplate.convertAndSend("matchRequest", message);
    }

    // 매칭 요청 ID 생성
    private String createMatchRequestId(String fromUserId, String toUserId) {
        String baseId = fromUserId + "-" + toUserId;
        String uniqueSuffix = UUID.randomUUID().toString().substring(0, 8); // 충돌 감소
        return baseId + "-" + uniqueSuffix;
    }

    // 매칭 요청 저장
    private void saveMatchRequest(String matchRequestId, String fromUserId, String toUserId) {
        Map<String, String> matchRequestDetails = Map.of(
                "matchRequestId", matchRequestId,
                "fromUserId", fromUserId,
                "toUserId", toUserId,
                "status", "pending" // 초기 상태는 pending
        );
        stringRedisTemplate.opsForHash()
                .putAll("matchRequest:" + matchRequestId, matchRequestDetails); // 이거 repository로 리팩토링 필요!
        stringRedisTemplate.expire("matchRequest:" + matchRequestId, Duration.ofMinutes(10)); // 10분 후 만료
    }

    // 매칭 요청 수락 - 웹소켓 서버로 실시간으로 전송
    public void acceptMatchRequest(String matchRequestId) {
        stringRedisTemplate.opsForHash().put("matchRequest:" + matchRequestId, "status", "accepted");

        // 매칭 요청에 해당하는 사용자 정보 조회
        String fromUserId = stringRedisTemplate.opsForHash().get("matchRequest:" + matchRequestId, "fromUserId")
                .toString();

        // WebSocketSessionManager를 사용하여 사용자 A에게 매칭 수락 알림 전송
        webSocketSessionManager.sendResponseMessage(fromUserId, "Your match request has been accepted.");
    }
}
