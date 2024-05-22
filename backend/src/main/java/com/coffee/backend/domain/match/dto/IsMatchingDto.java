package com.coffee.backend.domain.match.dto;

import com.coffee.backend.domain.user.dto.ReceiverInfoDto;
import com.coffee.backend.domain.user.dto.SenderInfoDto;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class IsMatchingDto {
    private String matchId;
    private String isMatching;
    private Long partner;
    private SenderInfoDto senderInfo;
    private ReceiverInfoDto receiverInfo;
}