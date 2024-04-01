package com.coffee.backend.domain.fcm.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Builder
@AllArgsConstructor
@Getter
public class FcmMessageDto {
    private boolean validateOnly;
    private Message message;

    @Builder
    @AllArgsConstructor
    @Getter
    public static class Message {
        private Notification notification;
        private String targetToken;
    }

    @Builder
    @AllArgsConstructor
    @Getter
    public static class Notification {
        private String title;
        private String body;
        private String image;
    }
}
