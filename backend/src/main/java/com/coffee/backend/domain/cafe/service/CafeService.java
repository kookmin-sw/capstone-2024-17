package com.coffee.backend.domain.cafe.service;

import com.coffee.backend.domain.cafe.dto.CafeUserDto;
import com.coffee.backend.domain.user.service.UserService;
import java.util.Objects;
import java.util.Set;
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
    public Set<Object> getUsersByCafeId(String cafeId) {
        String cafeChoiceKey = "cafe:" + cafeId;
        Set<Object> userSet = redisTemplate.opsForSet().members(cafeChoiceKey); // 카페 ID에 해당하는 세트의 모든 사용자 ID 조회
//        System.out.println("cafeId = " + cafeId + " userSet = " + userSet); // 출력
        for (Object userId : Objects.requireNonNull(userSet)) {
            getUserInfoFromDB((String) userId);
        }
        return userSet;
    }

    // userId로 User entity, Company entity, Position entity 조회
    public void getUserInfoFromDB(String userId) {
        CafeUserDto cafeUserDto = userService.getCafeUserInfoByLoginId(userId); // userId로 User entity 조회
        // TODO : Company entity, Position entity 조회해서 cafeUserDto에 추가
    }
}
