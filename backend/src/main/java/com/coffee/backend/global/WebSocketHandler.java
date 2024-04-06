package com.coffee.backend.global;

import com.coffee.backend.domain.redis.service.RedisService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

// 1. 카페 선택 / 매칭 요청 웹소켓 서버로 전송
@Component // @Bean 따로 등록 없이 사용 가능
@RequiredArgsConstructor
public class WebSocketHandler extends TextWebSocketHandler {
    private final WebSocketSessionManager webSocketSessionManager;
    private final RedisService redisService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    // 연결된 websocket session 등록
    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        String userId = String.valueOf(session.getAttributes().get("userId"));
        webSocketSessionManager.registerSession(userId, session);
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {

        /*
        [ message 형태 ]

        1. 카페 선택 정보

        {
          "type": "cafeChoice",
          "userId": "user123",
          "cafeId": "cafe456"
        }

        2. 매칭 요청 정보
        {
          "type": "matchRequest",
          "fromUserId": "user123",
          "toUserId": "user456"
        }
        */

        JsonNode jsonNode = objectMapper.readTree(message.getPayload());
        String type = jsonNode.get("type").asText();

        switch (type) {
            case "cafeChoice" -> redisService.handleCafeChoice(jsonNode);
            case "matchRequest" -> redisService.handleMatchRequest(jsonNode);
            default -> throw new IllegalArgumentException("웹소켓 message type을 알 수 없습니다." + type);
        }
    }

    // 연결 해제 한 websocket session 삭제
    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        String userId = String.valueOf(session.getAttributes().get("userId"));
        webSocketSessionManager.removeSession(userId);
    }
}