package com.coffee.backend.domain.cafe.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CafeUserDto {
    private String loginId;
    private String nickname;
    private String introduction;

    public CafeUserDto(String loginId, String nickname, String introduction) {
        this.loginId = loginId;
        this.nickname = nickname;
        this.introduction = introduction;
    }
}
