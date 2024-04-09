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

    //TODO : CafeController.java 의 sendMatchRequest() 에서 호출됨 테스트용 데이터가 잘 조회되는지? 어떻게 조회되는지?
    public String getCafeByUserId(String userId) {
        // redis 에서 userId로 cafeId 조회
        Object cafeId = redisTemplate.opsForValue().get(userId.toString());
        System.out.println("userId= " + userId + " cafeId = " + cafeId); // userId = user1, cafeId = 1
        return (String) cafeId;
    }

//    public void getUsersByCafeId(Long cafeId) {
//        // TODO : 그 cafeId 를 가진 유저를 redis 에서 싹 조회하고
//        Set<String> userSet = getUserListFromRedis(cafeId);
//        // TODO : userSet에서 각 userId 꺼내서 그 userId로 DB에서 User entity, (Company entity, position entity) 를 조회
//        아래 형식처럼 list에 담아 리턴
//        /*
//        리턴 형식 (companyName, positionName은 일단 NULL로 보낸다.)
//            {
//                "userList" : [
//                {
//                "userId" : Long
//                "nickname" : String
//                "introduction" : String
//                "companyName" : String
//                "positionName" : String
//                },
//                {
//                    동일하게
//                },
//                ]
//            }
//         */
//    }
//

    // redis 에서 cafeId로 조회해서 userList 리턴
    public List<CafeUserProfileDto> getUsersByCafeId(String cafeId) {
        String cafeChoiceKey = "cafe:" + cafeId;
        Set<Object> userSet = redisTemplate.opsForSet().members(cafeChoiceKey);

        return Optional.ofNullable(userSet).orElse(Collections.emptySet()).stream() //null일땐 빈 Set 반환
                .filter(Objects::nonNull) // null 값 제거
                .map(userId -> getUserInfoFromDB((String) userId))
                .collect(Collectors.toList()); // 결과를 List로 수집
    }

    // userId로 User entity, Company entity, Position entity 조회
    public CafeUserProfileDto getUserInfoFromDB(String userId) {
        CafeUserDto cafeUserDto = userService.getCafeUserInfoByLoginId(userId); // userId로 User entity 조회
        // TODO : Company entity, Position entity 조회해서 cafeUserDto에 추가
        return new CafeUserProfileDto(cafeUserDto, "임시값", "임시값");
    }
}
