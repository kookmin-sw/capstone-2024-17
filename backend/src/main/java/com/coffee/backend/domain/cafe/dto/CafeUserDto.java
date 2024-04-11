package com.coffee.backend.domain.cafe.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CafeUserDto {
    private Long userId;
    private String nickname;
    private String introduction;

    public CafeUserDto(Long userId, String nickname, String introduction) {
        this.userId = userId;
        this.nickname = nickname;
        this.introduction = introduction;
    }
}
