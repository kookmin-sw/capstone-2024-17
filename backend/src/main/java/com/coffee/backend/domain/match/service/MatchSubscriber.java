package com.coffee.backend.domain.match.service;

import com.coffee.backend.domain.match.dto.MatchDto;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.connection.Message;
import org.springframework.data.redis.connection.MessageListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
@Slf4j
public class MatchSubscriber implements MessageListener {
    private final ObjectMapper objectMapper;
    private final SimpMessagingTemplate messagingTemplate;

    // redis에서 수신한 메시지를 websocket 구독자에게 전달
    @Override
    public void onMessage(Message message, byte[] pattern) {
        try {
            log.info(message.toString());
            MatchDto matchDto = objectMapper.readValue(message.getBody(), MatchDto.class);

            // sub/user/{userId}/match/request
            // 여기서 userId는 loginId로 사용
            messagingTemplate.convertAndSendToUser(matchDto.getToLoginId(), "/match/request", matchDto);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
