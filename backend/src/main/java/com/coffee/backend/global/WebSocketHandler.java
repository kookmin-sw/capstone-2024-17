package com.coffee.backend.global;

import com.coffee.backend.domain.redis.service.RedisService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

@Component // @Bean 따로 등록 없이 사용 가능
@RequiredArgsConstructor
public class WebSocketHandler extends TextWebSocketHandler {
    private final RedisService redisService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        // 메시지 Json으로 파싱
        JsonNode jsonNode = objectMapper.readTree(message.getPayload());
        String type = jsonNode.get("type").asText();

        switch (type) {
            case "cafeChoice" -> redisService.handleCafeChoice(jsonNode);
            case "matchRequest" -> redisService.handleMatchRequest(jsonNode);
            default -> throw new IllegalArgumentException("웹소켓 message type을 알 수 없습니다." + type);
        }
    }
}