package com.coffee.backend.domain.match.controller;

import com.coffee.backend.domain.auth.controller.AuthenticationPrincipal;
import com.coffee.backend.domain.match.dto.MatchDto;
import com.coffee.backend.domain.match.service.MatchService;
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
    private final MatchService matchService;

    // pub/match/request
    @MessageMapping("/match/request")
    public void sendMatchRequest(@AuthenticationPrincipal User user, @Payload MatchDto dto) {
        log.info("Request Message Catch!!");
        matchService.sendMatchRequest(dto);
    }

    // pub/match/accept -> 채팅방 개설
    @MessageMapping("/match/accept")
    public void acceptMatchRequest(@AuthenticationPrincipal User user, @Payload MatchDto dto) {
        log.info("Accept Message Catch!!");
        matchService.acceptMatchRequest(dto);
    }

    // pub/match/cancel
    @MessageMapping("/match/cancel")
    public void cancelMatchRequest(@AuthenticationPrincipal User user, @Payload MatchDto dto) {
        log.info("Cancel Message Catch!!");
        matchService.cancelMatchRequest(dto);
    }
}
