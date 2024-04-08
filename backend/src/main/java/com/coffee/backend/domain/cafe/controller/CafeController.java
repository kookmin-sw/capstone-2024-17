package com.coffee.backend.domain.cafe.controller;


import com.coffee.backend.domain.auth.controller.AuthenticationPrincipal;
import com.coffee.backend.domain.cafe.dto.CafeDto;
import com.coffee.backend.domain.cafe.service.CafePublisher;
import com.coffee.backend.domain.user.entity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Controller;

@RequiredArgsConstructor
@Controller
@Slf4j
public class CafeController {
    private final CafePublisher cafePublisher;

    /*
    클라이언트에서 서버로 메시지 전송
    /pub/cafe/update로 메시지 발행
    */
    @MessageMapping("/cafe/update")
    public void sendMatchRequest(@AuthenticationPrincipal User user, @Payload CafeDto dto) {
        log.info("Message Catch!!");
        cafePublisher.updateCafeChoice(dto);
    }
}
