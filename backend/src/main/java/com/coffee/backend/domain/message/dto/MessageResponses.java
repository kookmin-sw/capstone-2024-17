package com.coffee.backend.domain.message.dto;

import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MessageResponses {
    List<MessageResponse> messageResponses;

    public MessageResponses(List<MessageResponse> messageResponses) {
        this.messageResponses = messageResponses;
    }
}
