package com.coffee.backend.domain.cafe.service;

import com.coffee.backend.domain.cafe.dto.CafeDto;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class CafePublisher {
    private final RedisTemplate<String, Object> redisTemplate;
    private final CafeService cafeService;

    public void updateCafeChoice(CafeDto dto) {
        String loginId = dto.getLoginId();
        String cafeId = dto.getCafeId();

        /*
        redis update (Redis에 아래 형식으로 저장됨)
            namespace = cafe
            key = starbucks
            value = set(user1, user2, user3)
         */
        String cafeChoiceKey = "cafe:" + cafeId;
        redisTemplate.opsForSet().add(cafeChoiceKey, loginId); // 카페 ID에 해당하는 세트에 사용자 ID 추가

        cafeService.getCafeByUserId(loginId); // 테스트!
        redisTemplate.convertAndSend("ch02", dto); // ch02 채널로 dto 발행
    }

}
