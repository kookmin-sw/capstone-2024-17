package com.coffee.backend.domain.match.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MatchDto {
    private String requestId;
    private String senderId;
    private String receiverId;
    private String status;
}