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

    // pub/match/request
    @MessageMapping("/match/request")
    public void sendMatchRequest(@AuthenticationPrincipal User user, @Payload MatchDto dto) {
        log.info("Request Message Catch!!");
        matchPublisher.sendMatchRequest(dto);
        matchPublisher.saveMatchRequest(dto);
    }

    // pub/match/accept -> 채팅방 개설
    @MessageMapping("/match/accept")
    public void acceptMatchRequest(@AuthenticationPrincipal User user, @Payload MatchDto dto) {
        log.info("Accept Message Catch!!");
        matchPublisher.acceptMatchRequest(dto);
    }
}
