package com.coffee.backend.domain.auth.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class KakaoUserInfoDto {
    private Long id;
    private String deviceToken;
}
