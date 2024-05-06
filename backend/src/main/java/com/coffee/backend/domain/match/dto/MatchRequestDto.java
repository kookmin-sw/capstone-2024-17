package com.coffee.backend.domain.match.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MatchRequestDto {
    private Long senderId;
    private Long receiverId;
    private String requestTypeId;
}