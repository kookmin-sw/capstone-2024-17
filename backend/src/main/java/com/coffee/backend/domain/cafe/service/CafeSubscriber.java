package com.coffee.backend.domain.cafe.service;

import com.coffee.backend.domain.cafe.dto.CafeDto;
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
public class CafeSubscriber implements MessageListener {
    private final ObjectMapper objectMapper;
    private final SimpMessagingTemplate messagingTemplate;

    // redis에서 수신한 메시지를 websocket 구독자에게 전달
    @Override
    public void onMessage(Message message, byte[] pattern) {
        try {
            log.info(message.toString());
            CafeDto cafeDto = objectMapper.readValue(message.getBody(),
                    CafeDto.class); // 이 로직 굳이 필요한지 다시 확인 - 같은 CafeDto 객체 아닌가

            // sub/user/{userId}/cafe/update
            // 여기서 userId는 cafeId로 사용
            messagingTemplate.convertAndSendToUser(cafeDto.getCafeId(), "/cafe/update", cafeDto);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
