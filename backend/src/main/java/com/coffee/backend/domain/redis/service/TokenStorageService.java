package com.coffee.backend.domain.redis.service;

import java.util.concurrent.TimeUnit;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class TokenStorageService {

    private static final long TOKEN_EXPIRATION_TIME = 3L; // 토큰 만료 시간 - 3시간
    private static final TimeUnit TOKEN_EXPIRATION_TIME_UNIT = TimeUnit.HOURS;

    private final RedisTemplate<String, String> redisTemplate;

    public void storeToken(String userUUID, String token) {
        log.trace("storeToken()");
        redisTemplate.opsForValue().set(userUUID, token, TOKEN_EXPIRATION_TIME, TOKEN_EXPIRATION_TIME_UNIT);
    }
}
