package com.coffee.backend.domain.cafe.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CafeUserProfileDto {
    private String loginId;
    private String nickname;
    private String introduction;
    private String companyName;
    private String positionName;

    public CafeUserProfileDto(CafeUserDto cafeUserDto, String companyName, String positionName) {
        this.loginId = cafeUserDto.getLoginId();
        this.nickname = cafeUserDto.getNickname();
        this.introduction = cafeUserDto.getIntroduction();
        this.companyName = companyName;
        this.positionName = positionName;
    }
}
