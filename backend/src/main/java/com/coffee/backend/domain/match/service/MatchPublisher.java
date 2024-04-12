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
    @Transactional
    public void sendMatchRequest(MatchDto dto) {
        String requestId = UUID.randomUUID().toString();
        dto.setRequestId(requestId);
        dto.setStatus("pending");

        Map<String, String> matchDetails = Map.of(
                "senderId", dto.getSenderId(),
                "receiverId", dto.getReceiverId(),
                "status", dto.getStatus()
        );

        redisTemplate.opsForHash().putAll("requestId:" + requestId, matchDetails);
        redisTemplate.expire("requestId" + requestId, Duration.ofMinutes(10));

        redisTemplate.convertAndSend("matchRequest", dto);
    }

    // 매칭 요청 수락
    public void acceptMatchRequest(MatchDto dto) {
        if (verifyMatchRequest(dto)) {
            dto.setStatus("accepted");
        } else {
            dto.setStatus("failed");
        }
        redisTemplate.convertAndSend("matchAccept", dto);
    }

    // 매칭 요청 수동 취소
    public void cancelMatchRequest(MatchDto dto) {
        dto.setStatus("canceled");
        redisTemplate.convertAndSend("matchCancel", dto);
    }

    // 매칭 요청 검증
    private boolean verifyMatchRequest(MatchDto dto) {
        String requestId = dto.getRequestId();
        Long ttl = redisTemplate.getExpire("requestId:" + requestId);
        return ttl != null && ttl > 0;
    }

    // 매칭 동시 요청 제한
}