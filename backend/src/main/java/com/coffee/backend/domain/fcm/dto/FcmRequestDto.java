package com.coffee.backend.domain.fcm.dto;

import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class FcmRequestDto {
        private String token;
        private String title;
        private String body;
}