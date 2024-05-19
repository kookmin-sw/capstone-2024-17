package com.coffee.backend.domain.chatroom.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ChatroomCreationDto {
    private Long senderId;
    private Long receiverId;

    public ChatroomCreationDto(Long senderId, Long receiverId) {
        this.senderId = senderId;
        this.receiverId = receiverId;
    }
}
