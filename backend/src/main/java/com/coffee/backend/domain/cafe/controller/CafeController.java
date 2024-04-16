package com.coffee.backend.domain.cafe.controller;


import com.coffee.backend.domain.auth.controller.AuthenticationPrincipal;
import com.coffee.backend.domain.cafe.dto.CafeDto;
import com.coffee.backend.domain.cafe.dto.CafeUserProfileDto;
import com.coffee.backend.domain.cafe.service.CafePublisher;
import com.coffee.backend.domain.cafe.service.CafeService;
import com.coffee.backend.domain.user.entity.User;
import com.fasterxml.jackson.core.JsonProcessingException;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@RequiredArgsConstructor
@Controller
@Slf4j
public class CafeController {
    private final CafePublisher cafePublisher;
    private final CafeService cafeService;

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

    // 특정 카페에 속한 모든 유저들을 redis에서 찾아 각 유저 정보를 조회해 프론트로 보낸다.
    @GetMapping("/cafe/{cafeId}") //http://localhost:8080/cafe/starbucks
    public ResponseEntity<List<CafeUserProfileDto>> getCafeUsers(@AuthenticationPrincipal User user,
                                                                 @PathVariable String cafeId) {
        return ResponseEntity.ok(cafeService.getUserProfilesFromRedisAndDB(cafeId));
    }
}
