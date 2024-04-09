package com.coffee.backend.domain.match.controller;

import com.coffee.backend.domain.auth.controller.AuthenticationPrincipal;
import com.coffee.backend.domain.match.dto.MatchDto;
import com.coffee.backend.domain.match.service.MatchPublisher;
import com.coffee.backend.domain.user.entity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Controller;

@RequiredArgsConstructor
@Controller
@Slf4j
public class MatchController {
    private final MatchPublisher matchPublisher;

    /*
    클라이언트에서 서버로 메시지 전송
    /pub/match/request로 메시지 발행
    */
    @MessageMapping("/match/request")
    public void sendMatchRequest(@AuthenticationPrincipal User user, @Payload MatchDto dto) {
        log.info("Message Catch!!");
        matchPublisher.sendMatchRequest(dto);
        matchPublisher.saveMatchRequest(dto);
    }
}
