package com.coffee.backend.domain.cafe.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CafeSubDto {
    private String type; // add, delete
    private String loginId;
    private String cafeId;
    private CafeUserProfileDto cafeUserProfileDto;

    public CafeSubDto(CafeDto cafeDto, CafeUserProfileDto cafeUserProfileDto) {
        this.type = cafeDto.getType();
        this.loginId = cafeDto.getLoginId();
        this.cafeId = cafeDto.getCafeId();
        this.cafeUserProfileDto = cafeUserProfileDto;
    }
}
