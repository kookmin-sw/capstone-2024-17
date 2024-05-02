package com.coffee.backend.domain.company.dto;

import jakarta.validation.constraints.NotEmpty;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CompanyRequestRequest {
    @NotEmpty
    private String name;
    @NotEmpty
    private String domain;
    @NotEmpty
    private String bno;
}
