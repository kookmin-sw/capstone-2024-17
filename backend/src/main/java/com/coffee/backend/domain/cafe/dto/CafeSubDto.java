package com.coffee.backend.domain.cafe.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CafeSubDto {
    private String type; // add, delete
    private String loginId;
    private String cafeId;
    private CafeUserDto cafeUserDto;
}
