package com.coffee.backend.domain.match.dto;

import lombok.Getter;
import org.springframework.messaging.handler.annotation.SendTo;

@Getter
@SendTo
public class MatchIdDto {
    private String matchId;
}