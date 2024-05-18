package com.coffee.backend.domain.chatroom.dto;

import com.coffee.backend.domain.user.dto.UserDto;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class ChatroomResponse {
    private Long chatroomId;
    private UserDto userInfo;
    private String recentMessage;
}
