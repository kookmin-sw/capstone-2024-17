package com.coffee.backend.domain.cafe.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CafeDto {
    private String type; // add, delete
    private String loginId;
    private String cafeId;
}
