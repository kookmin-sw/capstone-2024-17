package com.coffee.backend.domain.match.dto;

import com.coffee.backend.domain.user.dto.ReceiverInfoDto;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MatchInfoResponseDto {
    private Long requestTypeId;
    private Long senderId;
    private Long receiverId;
    private ReceiverInfoDto receiverInfo;
}