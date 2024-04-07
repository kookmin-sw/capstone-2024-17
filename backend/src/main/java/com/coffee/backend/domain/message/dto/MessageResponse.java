package com.coffee.backend.domain.message.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class MessageResponse {
    private Long senderId;
    private String content;
    private String datetime;
    private String nickname;
}
