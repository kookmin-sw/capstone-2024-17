package com.coffee.backend.domain.company.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class EmailVerificationResponse {
    private Boolean result;

    public EmailVerificationResponse(Boolean result) {
        this.result = result;
    }
}
