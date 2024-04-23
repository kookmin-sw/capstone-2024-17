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

    //redis에 add 하는 메소드
    public void addCafeChoice(String cafeId, String loginId) {
        System.out.println("addCafeChoice() 진입");
        /*
        Redis에 아래 형식으로 저장됨
            namespace = cafe
            key = starbucks
            value = set(user1, user2, user3)
         */
        String cafeChoiceKey = "cafe:" + cafeId;
        redisTemplate.opsForSet().add(cafeChoiceKey, loginId); // 카페 ID에 해당하는 세트에 사용자 ID 추가
    }

    //redis에서 delete 하는 메소드
    public void deleteCafeChoice(String cafeId, String loginId) {
        System.out.println("deleteCafeChoice() 진입");
        final String cafeChoiceKey = "cafe:" + cafeId;

        // 카페 ID에 해당하는 세트에서 사용자 ID 찾기
        Boolean isMember = redisTemplate.opsForSet().isMember(cafeChoiceKey, loginId);
        if (Boolean.TRUE.equals(isMember)) {
            redisTemplate.opsForSet().remove(cafeChoiceKey, loginId);
        } else {
            throw new IllegalArgumentException("User ID '" + loginId + "' 는 '" + cafeId + "' 카페에 속해 있지 않습니다.");
        }
    }


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
        System.out.println("getUserListFromRedis() 진입");
        String cafeChoiceKey = "cafe:" + cafeId;
        return redisTemplate.opsForSet().members(cafeChoiceKey);
    }

    public CafeUserProfileDto getUserInfoFromDB(String userId) {
        CafeUserDto cafeUserDto = userService.getCafeUserInfoByLoginId(userId); // userId로 User entity 조회
        // TODO : Company entity, Position entity 조회해서 cafeUserDto에 추가
        return new CafeUserProfileDto(cafeUserDto, "임시 company", "임시 position");
    }
}
