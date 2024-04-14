package com.coffee.backend.domain.cafe.service;

import com.coffee.backend.domain.cafe.dto.CafeUserDto;
import com.coffee.backend.domain.cafe.dto.CafeUserProfileDto;
import com.coffee.backend.domain.user.service.UserService;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class CafeService {
    private final RedisTemplate<String, Object> redisTemplate;
    private final UserService userService;

    public List<CafeUserProfileDto> getUserProfilesFromRedisAndDB(String cafeId) {
        // cafeId 를 가진 유저를 redis 에서 싹 조회
        Set<Object> userSet = getUserListFromRedis(cafeId);

        // 각 userId로 DB에서 User entity, (Company entity, position entity) 를 조회
        return Optional.ofNullable(userSet).orElse(Collections.emptySet()).stream()
                .filter(Objects::nonNull) // null 값 제거
                .map(userId -> getUserInfoFromDB((String) userId))
                .collect(Collectors.toList());
    }

    public Set<Object> getUserListFromRedis(String cafeId) {
        String cafeChoiceKey = "cafe:" + cafeId;
        return redisTemplate.opsForSet().members(cafeChoiceKey);
    }

    public CafeUserProfileDto getUserInfoFromDB(String userId) {
        CafeUserDto cafeUserDto = userService.getCafeUserInfoByLoginId(userId); // userId로 User entity 조회
        // TODO : Company entity, Position entity 조회해서 cafeUserDto에 추가
        return new CafeUserProfileDto(cafeUserDto, "임시 company", "임시 position");
    }
}
