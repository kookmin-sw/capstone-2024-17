package com.coffee.backend.domain.user.dto;

import com.coffee.backend.domain.company.dto.CompanyDto;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserDto {
    private Long userId;
    private String loginId;
    private Long kakaoId;
    private CompanyDto company;
    private String position;
    private String nickname;
    private String email;
    private String phone;
    private String userUUID;
    private String introduction;
    private String deviceToken;
    private double coffeeBean;
}
