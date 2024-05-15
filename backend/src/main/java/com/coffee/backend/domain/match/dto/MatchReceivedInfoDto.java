package com.coffee.backend.domain.match.dto;

import com.coffee.backend.domain.user.dto.SenderInfoDto;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MatchReceivedInfoDto {
    private String matchId;
    private String requestTypeId;
    private SenderInfoDto senderInfo;
}