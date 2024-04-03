package com.coffee.backend.domain.chatroom.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ChatroomCreationDto {
    private String senderUUID;
    private Long receiverId;

    public ChatroomCreationDto(String senderUUID, Long receiverId) {
        this.senderUUID = senderUUID;
        this.receiverId = receiverId;
    }
}
