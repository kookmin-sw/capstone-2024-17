package com.coffee.backend.domain.cafe.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CafeUserDto {
    // userId, nickname, introduction
    // TODO : email을 introduction으로 교체
    private Long userId;
    private String nickname;
    private String email;

    public CafeUserDto(Long userId, String nickname, String email) {
        this.userId = userId;
        this.nickname = nickname;
        this.email = email;
    }
}
