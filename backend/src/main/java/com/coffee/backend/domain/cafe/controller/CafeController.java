package com.coffee.backend.domain.cafe.controller;


import com.coffee.backend.domain.auth.controller.AuthenticationPrincipal;
import com.coffee.backend.domain.cafe.dto.CafeDto;
import com.coffee.backend.domain.cafe.dto.CafeListDto;
import com.coffee.backend.domain.cafe.dto.CafeUserProfileDto;
import com.coffee.backend.domain.cafe.service.CafePublisher;
import com.coffee.backend.domain.cafe.service.CafeService;
import com.coffee.backend.domain.user.entity.User;
import com.fasterxml.jackson.core.JsonProcessingException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@RequiredArgsConstructor
@Controller
@Slf4j
public class CafeController {
    private final CafePublisher cafePublisher;
    private final CafeService cafeService;
    private final RedisTemplate<String, Object> redisTemplate;

    /*
    클라이언트에서 서버로 메시지 전송
    /pub/cafe/update로 메시지 발행
    */
    @MessageMapping("/cafe/update") // pub/cafe/update
    public void publishCafeUpdate(@AuthenticationPrincipal User user, @Payload CafeDto dto)
            throws JsonProcessingException {
        log.info("Message Catch!!");
        cafePublisher.updateCafeChoice(dto);
    }

    // (지도 페이지) 특정 카페에 속한 모든 유저들을 redis에서 찾아 각 유저 정보를 조회해 프론트로 보낸다.
    @PostMapping("/cafe/get-users")
    public ResponseEntity<Map<String, List<CafeUserProfileDto>>> getCafeUsers(@AuthenticationPrincipal User user,
                                                                              @RequestBody CafeListDto dto) {
        List<String> cafeList = dto.getCafeList();
        Map<String, List<CafeUserProfileDto>> cafeUsersMap = new HashMap<>(); //반환값

        for (String cafeId : cafeList) {
            List<CafeUserProfileDto> userProfileDtoList = cafeService.getUserProfilesFromRedisAndDB(cafeId);
            cafeUsersMap.put(cafeId, userProfileDtoList);
        }
        return ResponseEntity.ok(cafeUsersMap);
    }

    //EC2 redis 연결 오류 테스트용 (add, delete) 잘 되는지 확인
    @PostMapping("/redis-test")
    public ResponseEntity<String> redisTest(@RequestBody String key) {
        String cafeId = "starbucks";
        // add Test
        cafeService.addCafeChoice(cafeId, key);
        System.out.println("!!! 저장 시도 : " + cafeService.getUserListFromRedis(cafeId));
        // delete Test
        cafeService.deleteCafeChoice(cafeId, key);
        System.out.println("!!! 삭제 시도 : " + cafeService.getUserListFromRedis(cafeId));
        return ResponseEntity.ok("출력을 확인");
    }

//    @PostMapping("/redis-test")
//    public ResponseEntity<String> redisTest(@RequestBody String key) {
//        System.out.println("테스트 !!! : 저장 시도");
//        ValueOperations<String, Object> ops = redisTemplate.opsForValue();
//        ops.set("testKey", key); // 값 저장
//        System.out.println("테스트 !!! : 조회 시도");
//        String value = (String) ops.get("testKey"); // 값 조회
//        return ResponseEntity.ok("조회된 값: " + key);
//    }
}
