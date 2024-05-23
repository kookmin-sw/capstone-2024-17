package com.coffee.backend.domain.match.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MatchFinishRequestDto {
    private String matchId;
    private Long enderId; // 종료를 누른 유저 아이디
}