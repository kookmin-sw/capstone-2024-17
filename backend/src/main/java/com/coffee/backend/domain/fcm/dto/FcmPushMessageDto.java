package com.coffee.backend.domain.fcm.dto;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@RequiredArgsConstructor
public class FcmPushMessageDto {
    private final boolean validateOnly;
    private final Message message;

    @Getter
    @Setter
    @RequiredArgsConstructor
    public static class Message {
        private Data data;
        private Notification notification;
        private String token;
    }

    @Getter
    @Setter
    @RequiredArgsConstructor
    public static class Data {
        private String title;
        private String body;
    }

    @Getter
    @Setter
    @RequiredArgsConstructor
    public static class Notification {
        private String title;
        private String body;
    }
}