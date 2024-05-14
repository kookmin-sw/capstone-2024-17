package com.coffee.backend.domain.cafe.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CafeDto {
    private final String msg = "\n???? Request Validation Error ";

    @NotBlank(message = msg)
    private String type; // add, delete

    @NotNull(message = msg)
    private Long userId;

    @NotBlank(message = msg)
    private String cafeId;
}
