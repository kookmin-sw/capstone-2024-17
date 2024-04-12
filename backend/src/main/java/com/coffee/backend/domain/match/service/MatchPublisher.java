package com.coffee.backend.domain.match.service;

import com.coffee.backend.domain.match.dto.MatchDto;
import java.time.Duration;
import java.util.Map;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@RequiredArgsConstructor
@Service
@Slf4j
public class MatchPublisher {
    private final RedisTemplate<String, Object> redisTemplate;

    // 매칭 요청
    public void sendMatchRequest(MatchDto dto) {
        dto.setRequestId(UUID.randomUUID().toString());
        log.info("send match request with requestId: {}", dto.getRequestId());
        redisTemplate.convertAndSend("matchRequest", dto);
    }

    // 매칭 요청 저장
    @Transactional
    public void saveMatchRequest(MatchDto dto) {
        String requestId = UUID.randomUUID().toString();
        Map<String, String> response = Map.of(
                "senderId", dto.getSenderId(),
                "receiverId", dto.getReceiverId(),
                "status", "pending"
        );

        redisTemplate.opsForHash().putAll("matchRequest:" + requestId, response);
        redisTemplate.expire("matchRequest:" + requestId, Duration.ofMinutes(10));
        log.info("match request saved with requestId: {}", requestId);
    }

    // 매칭 요청 수락
    public void acceptMatchRequest(MatchDto dto) {
        dto.setStatus("accepted");
        redisTemplate.convertAndSend("matchAccept", dto);
    }

    // 매칭 요청 수동 취소
    public void cancelMatchRequest(MatchDto dto) {
        dto.setStatus("canceled");
        redisTemplate.convertAndSend("matchCancel", dto);
    }

    // 매칭 요청 자동 취소

    // 매칭 동시 요청 제한
}