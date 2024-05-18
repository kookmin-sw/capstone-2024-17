package com.coffee.backend.domain.user.dto;

import com.coffee.backend.domain.company.dto.CompanyDto;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReceiverInfoDto {
    private String nickname;
    private CompanyDto company;
    private String position;
    private String introduction;
    private double coffeeBean;
}
