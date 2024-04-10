package com.coffee.backend.domain.chatroom.dto;


import java.util.ArrayList;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ChatroomResponses {
    private List<ChatroomResponse> chatrooms = new ArrayList<>();

    public ChatroomResponses(List<ChatroomResponse> chatrooms) {
        this.chatrooms = chatrooms;
    }
}
