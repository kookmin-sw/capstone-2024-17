package com.coffee.backend.domain.cafe.service;

import com.coffee.backend.domain.cafe.dto.CafeUserDto;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.domain.user.repository.UserRepository;
import com.coffee.backend.domain.user.service.UserService;
import com.coffee.backend.exception.CustomException;
import com.coffee.backend.exception.ErrorCode;
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
    private final UserRepository userRepository;

    //redis에 add 하는 메소드
    public void addCafeChoice(String cafeId, Long userId, String sessionId) {
        System.out.println("addCafeChoice() 진입");
        /*
        Redis에 아래 형식으로 저장됨
            namespace = cafe
            key = starbucks
            value = set(user1, user2, user3)
         */
        String cafeChoiceKey = "cafe:" + cafeId;

        // 이미 해당 카페에 존재하는 사용자인지 확인
        String userIdStr = String.valueOf(userId); // Long 타입을 String으로 변환
        Boolean isMember = redisTemplate.opsForSet().isMember(cafeChoiceKey, userIdStr);
        if (Boolean.TRUE.equals(isMember)) {
            throw new IllegalArgumentException(
                    "Add Exception: " + "'" + userId + "'" + " 는 " + cafeId + "' 카페에 이미 속해 있습니다.");
        }

        // 카페 ID에 해당하는 세트에 사용자 추가
        redisTemplate.opsForSet().add(cafeChoiceKey, userIdStr);

        // UserDB에 cafeId, sessionId 저장
        userRepository.findByUserId(userId).ifPresent(user -> {
            user.setCafeId(cafeId);
            user.setSessionId(sessionId);
            userRepository.save(user);
        });
    }

    // redis 카페선택 삭제, UserDB에 cafeId, sessionId null 로 초기화
    public void deleteCafeChoice(String cafeId, Long userId) {
        System.out.println("deleteCafeChoice() 진입");
        final String cafeChoiceKey = "cafe:" + cafeId;

        // 카페 ID에 해당하는 세트에서 사용자 ID 찾기
        String userIdStr = String.valueOf(userId); // Long 타입을 String으로 변환
        Boolean isMember = redisTemplate.opsForSet().isMember(cafeChoiceKey, userIdStr);
        if (Boolean.TRUE.equals(isMember)) {
            redisTemplate.opsForSet().remove(cafeChoiceKey, userIdStr);
        } else {
            throw new IllegalArgumentException("User ID '" + userId + "' 는 '" + cafeId + "' 카페에 속해 있지 않습니다.");
        }
        // 해당 User cafeId, sessionId null 로 초기화
        userRepository.findByUserId(userId).ifPresent(user -> {
            user.setCafeId(null);
            user.setSessionId(null);
            userRepository.save(user);
        });
    }

    public List<CafeUserDto> getUserProfilesFromRedisAndDB(String cafeId) {
        // cafeId 를 가진 유저를 redis 에서 싹 조회
        Set<Object> userSet = getUserListFromRedis(cafeId);

        // 각 userId로 DB에서 User entity, (Company entity, position entity) 를 조회
        return Optional.ofNullable(userSet).orElse(Collections.emptySet()).stream()
                .filter(Objects::nonNull) // null 값 제거
                .map(user -> getUserInfoFromDB(Long.parseLong(user.toString()))) // String ID를 Long으로 안전하게 변환
                .collect(Collectors.toList());
    }

    public Set<Object> getUserListFromRedis(String cafeId) {
        System.out.println("getUserListFromRedis() 진입");
        String cafeChoiceKey = "cafe:" + cafeId;
        return redisTemplate.opsForSet().members(cafeChoiceKey);
    }

    public CafeUserDto getUserInfoFromDB(Long userId) {
        return userService.getCafeUserInfoByUserId(userId); // userId로 User entity 조회
    }

    public void clearSessionAndCafeIdBySessionId(String sessionId) {
        User user = userRepository.findBySessionId(sessionId).orElseThrow(() -> {
            log.info("sessionId = {} 를 갖는 사용자가 존재하지 않습니다.", sessionId);
            return new CustomException(ErrorCode.USER_NOT_FOUND);
        });
        // redis 에서 cafeId 유저 삭제 및 cafeId, sessionId null 로 초기화
        deleteCafeChoice(user.getCafeId(), user.getUserId());
    }
}
