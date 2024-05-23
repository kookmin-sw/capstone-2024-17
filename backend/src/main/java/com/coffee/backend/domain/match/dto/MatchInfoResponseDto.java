package com.coffee.backend.domain.match.dto;

import com.coffee.backend.domain.user.dto.ReceiverInfoDto;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MatchInfoResponseDto {
    private String matchId;
    private String requestTypeId;
    private ReceiverInfoDto receiverInfo;
    private String expirationTime;
}