package com.coffee.backend.domain.company.dto;

import com.coffee.backend.domain.user.dto.UserDto;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class CompanyRequestDto {
    private Long id;
    private String name;
    private String domain;
    private String bno;
    private UserDto user;
}
