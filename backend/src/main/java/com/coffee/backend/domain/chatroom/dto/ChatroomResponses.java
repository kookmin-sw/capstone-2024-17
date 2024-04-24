package com.coffee.backend.domain.chatroom.dto;


import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ChatroomResponses {
    private List<ChatroomResponse> chatrooms;

    public ChatroomResponses(List<ChatroomResponse> chatrooms) {
        this.chatrooms = chatrooms;
    }
}
