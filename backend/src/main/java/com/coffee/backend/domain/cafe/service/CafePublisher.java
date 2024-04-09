package com.coffee.backend.domain.cafe.service;

import com.coffee.backend.domain.cafe.dto.CafeDto;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class CafePublisher {
    private final RedisTemplate<String, Object> redisTemplate;

    public void updateCafeChoice(CafeDto dto) {
        String loginId = dto.getLoginId();
        String cafeId = dto.getCafeId();

        // redis update
        redisTemplate.opsForValue().set(loginId, cafeId);
        redisTemplate.convertAndSend("cafeChoice", dto);
    }
}