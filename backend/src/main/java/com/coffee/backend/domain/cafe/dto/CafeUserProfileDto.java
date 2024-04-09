package com.coffee.backend.domain.cafe.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CafeUserProfileDto {
    private final CafeUserDto cafeUserDto;
    private String companyName;
    private String positionName;

    public CafeUserProfileDto(CafeUserDto cafeUserDto, String companyName, String positionName) {
        this.cafeUserDto = cafeUserDto;
        this.companyName = companyName;
        this.positionName = positionName;
    }
}
