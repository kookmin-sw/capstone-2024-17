package com.coffee.backend.domain.message.dto;

import lombok.Getter;

@Getter
public class MessageDto {
    private Long senderId;
    private Long chatroomId;
    private String content;
}
