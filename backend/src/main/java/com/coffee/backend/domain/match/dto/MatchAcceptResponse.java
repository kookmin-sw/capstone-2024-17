package com.coffee.backend.domain.match.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@Getter
@Setter
public class MatchAcceptResponse {
    private String matchId;
    private Long senderId;
    private Long receiverId;
    private long expirationTime;
    private String status;
    private Long chatroomId;
}
