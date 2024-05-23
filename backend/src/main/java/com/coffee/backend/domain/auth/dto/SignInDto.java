package com.coffee.backend.domain.auth.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SignInDto {
    private String loginId;
    private String password;
    private String deviceToken;
}
