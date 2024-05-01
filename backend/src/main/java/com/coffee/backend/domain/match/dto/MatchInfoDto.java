package com.coffee.backend.domain.match.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MatchInfoDto {
    private String matchId;
    private Long senderId;
    private Long receiverId;
}
