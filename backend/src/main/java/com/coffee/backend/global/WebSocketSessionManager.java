package com.coffee.backend.global;

import java.io.IOException;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

// 3. 웹소켓 서버를 통해 사용자에게 실시간으로 메시지 전송
@Component
public class WebSocketSessionManager {
    private final Map<String, WebSocketSession> sessions = new ConcurrentHashMap<>();

    public void registerSession(String userId, WebSocketSession session) {
        sessions.put(userId, session);
    }

    // websocket 서버의 사용자에게 최종 response 메시지 전송
    public void sendResponseMessage(String userId, String message) {
        WebSocketSession session = sessions.get(userId);
        if (session != null && session.isOpen()) {
            try {
                session.sendMessage(new TextMessage(message));
            } catch (IOException e) {
                throw new RuntimeException("Response 전송 실패 to 사용자: " + userId, e);
            }
        }
    }
}
