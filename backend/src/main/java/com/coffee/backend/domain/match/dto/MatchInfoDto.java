package com.coffee.backend.domain.match.dto;

import lombok.AccessLevel;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter(AccessLevel.PROTECTED)
public class MatchInfoDto {
    private String matchId;
    private Long senderId;
    private Long receiverId;
}
