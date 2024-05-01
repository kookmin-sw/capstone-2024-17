package com.coffee.backend.domain.user.dto;

import com.coffee.backend.domain.company.entity.Company;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReceiverInfoDto {
    private String nickname;
    private Company company;
    //    private String position;
    private String introduction;
    private String rating;
}