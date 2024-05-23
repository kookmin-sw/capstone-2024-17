package com.coffee.backend.domain.auth.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class KakaoRequestDto {
    private String accessToken;
    private String deviceToken;
}
