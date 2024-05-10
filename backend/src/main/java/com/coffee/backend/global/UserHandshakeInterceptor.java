package com.coffee.backend.global;

import com.coffee.backend.domain.user.service.UserService;
import java.util.Map;
import lombok.AllArgsConstructor;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;

@Component
@AllArgsConstructor
public class UserHandshakeInterceptor implements HandshakeInterceptor {
    private final UserService userService;

//    @Autowired
//    public UserHandshakeInterceptor(UserService userService) {
//        this.userService = userService;
//    }

    //connection URL 에서 loginId 추출
    @Override
    public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse response, WebSocketHandler wsHandler,
                                   Map<String, Object> attributes) throws Exception {
        String query = request.getURI().getQuery();
        if (query != null) {
            String[] params = query.split("&");
            for (String param : params) {
                String[] keyValue = param.split("=");
                String key = keyValue[0];
                if (key.equals("loginId")) {
                    String value = keyValue[1];
                    attributes.put("loginId", value); // 세션 속성에 사용자 ID 저장
                }
            }
        }
        return true;
    }

    // handshake 이후 User DB에 sessionId 저장
    @Override
    public void afterHandshake(ServerHttpRequest request, ServerHttpResponse response, WebSocketHandler wsHandler,
                               Exception exception) {
//        System.out.println("여기 도달?");
        String sessionId = request.getHeaders().getFirst("sec-websocket-key"); // 세션 ID 추출
        String loginId = request.getHeaders().getFirst("loginId"); // loginId 추출
//        System.out.println("?" + loginId + " " + sessionId + "여기 도달?");
        userService.updateUserSessionId(loginId, sessionId); // user DB에 sessionId 저장
    }
}
