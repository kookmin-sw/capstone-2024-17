package com.coffee.backend.domain.match.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MatchDto {
    private String fromLoginId;
    private String toLoginId;
    private String status;
}
