package com.coffee.backend.domain.match.service;

import com.coffee.backend.domain.match.dto.MatchDto;

import java.time.Duration;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@RequiredArgsConstructor
@Service
public class MatchPublisher {
    private final RedisTemplate<String, Object> redisTemplate;

    // matchRequest 채널로 매칭 요청
    public void sendMatchRequest(MatchDto dto) {
        redisTemplate.convertAndSend("matchRequest", dto); // dto를 통해 fromLoginId & toLoginId 전달
    }

    // 매칭 요청 저장
    @Transactional
    public void saveMatchRequest(MatchDto dto) {
        String matchRequestId = UUID.randomUUID().toString();
        Map<String, String> response = Map.of(
                "fromLoginId", dto.getFromLoginId(),
                "toLoginId", dto.getToLoginId(),
                "status", "pending"
        );

        redisTemplate.opsForHash().putAll("matchRequest:" + matchRequestId, response);
        redisTemplate.expire("matchRequest:" + matchRequestId, Duration.ofMinutes(10));
    }

    // 매칭 요청 수락
    public void acceptMatchRequest(String matchRequestId) {
        Map<Object, Object> request = redisTemplate.opsForHash().entries("matchRequest:" + matchRequestId);
        if ("pending".equals(request.get("status"))) {
            redisTemplate.opsForHash().put("matchRequest:" + matchRequestId, "status", "accepted");

            Map<String, String> response = new HashMap<>();
            response.put("matchRequestId", matchRequestId);
            response.put("status", "accepted");

            redisTemplate.convertAndSend("matchAccept", response);
        }
    }

    // 매칭 요청 취소

    // 매칭 동시 요청 제한
}