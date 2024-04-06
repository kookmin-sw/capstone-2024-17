package com.coffee.backend.domain.redis.service;

import com.coffee.backend.domain.match.service.MatchService;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.connection.Message;
import org.springframework.data.redis.connection.MessageListener;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

// 2. Redis Pub/Sub으로 메시지 발행/수신
@RequiredArgsConstructor
@Service
public class RedisService implements MessageListener {
    private final MatchService matchService;
    private final StringRedisTemplate stringRedisTemplate;
    private final ObjectMapper objectMapper = new ObjectMapper();

    // Redis에 메시지 도착할 때마다 호출
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
        updateCafeChoice(userId, cafeId);
    }

    public void handleMatchRequest(JsonNode jsonNode) {
        String fromUserId = jsonNode.get("fromUserId").asText();
        String toUserId = jsonNode.get("toUserId").asText();
        matchService.sendAndSaveMatchRequest(fromUserId, toUserId);
    }

    public void updateCafeChoice(String userId, String cafeId) {
        // 카페 정보 변동 시 Redis에 업데이트
        stringRedisTemplate.opsForValue().set(userId, cafeId);

        String message = String.format("{\"userId\":\"%s\", \"cafeId\":\"%s\"}", userId, cafeId);
        stringRedisTemplate.convertAndSend("cafeChoice", message);
    }
}
