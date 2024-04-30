package com.coffee.backend.domain.company.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class CompanyRequestDto {
    private Long id;
    private String name;
    private String domain;
    private String bno;
    private String user;
}
