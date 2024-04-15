package com.coffee.backend.domain.message.dto;

import com.coffee.backend.domain.user.dto.UserDto;
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
    private UserDto userInfo;
}
