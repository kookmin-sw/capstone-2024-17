package com.coffee.backend.domain.match.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MatchDto {
    private String requestId;
    private String senderId;
    private String receiverId;
    private String targetToken; // 푸시 알림 위해 필요
    private String status;
}