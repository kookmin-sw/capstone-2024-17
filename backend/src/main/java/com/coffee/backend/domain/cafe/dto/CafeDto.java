package com.coffee.backend.domain.cafe.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CafeDto {
    private String type; // add, delete
    private Long userId;
    private String cafeId;
}
