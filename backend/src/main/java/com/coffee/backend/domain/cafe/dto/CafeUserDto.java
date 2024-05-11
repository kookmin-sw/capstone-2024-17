package com.coffee.backend.domain.cafe.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CafeUserDto {
    private Long userId;
    private String nickname;
    private String company;
    private String position;
    private String introduction;
    private String coffeeBean;
}
