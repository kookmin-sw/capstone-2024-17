package com.coffee.backend.domain.match.service;

import com.coffee.backend.domain.match.dto.MatchDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
@Slf4j
public class MatchPublisher {
    private final RedisTemplate<String, Object> redisTemplate;

    // 매칭 요청
    public void sendMatchRequest(MatchDto dto) {
        dto.setStatus("pending");
        redisTemplate.convertAndSend("matchRequest", dto);
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

    // 매칭 동시 요청 제한
}