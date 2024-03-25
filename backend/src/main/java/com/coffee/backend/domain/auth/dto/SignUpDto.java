package com.coffee.backend.domain.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SignUpDto {
    @NotNull
    private String loginId;

    @Pattern(regexp = "^(?=.*[0-9])(?=.*[a-z])(?=.*[!@#$%^&*()]).{8,20}$",
            message = "비밀번호는 숫자, 소문자, 특수문자를 최소 1개 이상 포함한 8자 이상 20자 이하의 문자열이어야 합니다.")
    private String password;

    @NotNull
    private String nickname;

    @Email
    private String email;

    @NotNull
    private String phone;
}
