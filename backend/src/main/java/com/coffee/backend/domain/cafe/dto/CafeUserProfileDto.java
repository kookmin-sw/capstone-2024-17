package com.coffee.backend.domain.cafe.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CafeUserProfileDto {
    private Long userId;
    private String nickname;
    private String introduction;
    private String companyName;
    private String positionName;

    public CafeUserProfileDto(CafeUserDto cafeUserDto, String companyName, String positionName) {
        this.userId = cafeUserDto.getUserId();
        this.nickname = cafeUserDto.getNickname();
        this.introduction = cafeUserDto.getIntroduction();
        this.companyName = companyName;
        this.positionName = positionName;
    }
}
