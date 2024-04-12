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

    @Override
    public void onMessage(Message message, byte[] pattern) {
        try {
            log.info("onMessage");

            MatchDto matchDto = objectMapper.readValue(message.getBody(), MatchDto.class); // 이 로직 필요한지 확인 필요
            String channel = new String(message.getChannel());

            // 매칭 요청
            if (channel.equals("matchRequest")) {
                messagingTemplate.convertAndSend("/user/" + matchDto.getReceiverId(), matchDto);
            }
            // 매칭 수락 -> 채팅방 개설
            else if (channel.equals("matchAccept")) {
                messagingTemplate.convertAndSend("/user/" + matchDto.getReceiverId(), matchDto);
            }
            // 매칭 취소
            else if (channel.equals("matchCancel")) {
                messagingTemplate.convertAndSend("/user/" + matchDto.getReceiverId(), matchDto);
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
