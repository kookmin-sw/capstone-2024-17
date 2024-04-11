package com.coffee.backend.domain.cafe.service;

import com.coffee.backend.domain.cafe.dto.CafeDto;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class CafePublisher {
    private final RedisTemplate<String, Object> redisTemplate;
    private final CafeService cafeService;

    public void updateCafeChoice(CafeDto dto) throws JsonProcessingException {
        String loginId = dto.getLoginId();
        String cafeId = dto.getCafeId();

        /*
        Redis에 아래 형식으로 저장됨
            namespace = cafe
            key = starbucks
            value = set(user1, user2, user3)
         */
        String cafeChoiceKey = "cafe:" + cafeId;
        redisTemplate.opsForSet().add(cafeChoiceKey, loginId); // 카페 ID에 해당하는 세트에 사용자 ID 추가

        // dto를 json으로 변환 (redisTemplate 직렬화 문제)
        ObjectMapper objectMapper = new ObjectMapper();
        String cafeDtoJson = objectMapper.writeValueAsString(dto);
        redisTemplate.convertAndSend("ch02", cafeDtoJson); // ch02 채널로 dto 발행

    }
}
