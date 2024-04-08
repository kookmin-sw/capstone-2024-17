package com.coffee.backend.domain.match.service;

import com.coffee.backend.domain.match.dto.MatchDto;

import java.time.Duration;
import java.util.Map;
import java.util.UUID;

import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@RequiredArgsConstructor
@Service
public class MatchPublisher {
    private final RedisTemplate<String, Object> redisTemplate;

    // ch01 채널로 매칭 요청
    public void sendMatchRequest(MatchDto dto) {
        redisTemplate.convertAndSend("ch01", dto); // dto를 통해 fromLoginId & toLoginId 전달
    }

    // 매칭 요청 저장
    @Transactional
    public void saveMatchRequest(MatchDto dto) {
        String matchRequestId = UUID.randomUUID().toString();
        Map<String, String> response = Map.of(
                "fromUserId", dto.getFromLoginId(),
                "toUserId", dto.getToLoginId(),
                "status", "pending"
        );

        // 요청 정보 저장
        redisTemplate.opsForHash().putAll("matchRequest:" + matchRequestId, response);
        redisTemplate.expire("matchRequest:" + matchRequestId, Duration.ofMinutes(10));
    }

//    // 매칭 요청 수락
//    public void acceptMatchRequest(String matchRequestId) {
//        Map<Object, Object> matchInfo = redisTemplate.opsForHash().entries("matchRequest:" + matchRequestId);
//        if ("pending".equals(matchInfo.get("status"))) {
//            redisTemplate.opsForHash().put("matchRequest:" + matchRequestId, "status", "accepted");
//
//            String fromUserId = (String) matchInfo.get("fromUserId");
//
//            // fromUserId에게 매칭 수락 알림 전송
////            messagingMapping.sendResponseMessage(fromUserId, "매칭이 수락되었습니다.");
//        }
//    }
}