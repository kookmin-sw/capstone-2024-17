package com.coffee.backend.domain.fcm.service;

import com.coffee.backend.domain.fcm.dto.FcmPushMessageDto;
import com.coffee.backend.domain.fcm.dto.FcmRequestDto;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.auth.oauth2.GoogleCredentials;
import java.io.IOException;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
@RequiredArgsConstructor
public class FcmService {
    public void sendPushMessageTo(FcmRequestDto dto) throws IOException {
        String pushMessage = makePushMessage(dto);
        RestTemplate restTemplate = new RestTemplate();

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Authorization", "Bearer " + getAccessToken());

        HttpEntity<String> entity = new HttpEntity<>(pushMessage, headers);

        String API_URL = "<https://fcm.googleapis.com/v1/projects/capstone-coffeechat/messages:send>";
        ResponseEntity<String> response = restTemplate.exchange(API_URL, HttpMethod.POST, entity, String.class);

        System.out.println(response.getStatusCode());
    }

        private String getAccessToken() throws IOException {
        String firebaseConfigPath = "firebase/firebase-secret-key.json";

        GoogleCredentials googleCredentials = GoogleCredentials
                .fromStream(new ClassPathResource(firebaseConfigPath).getInputStream())
                .createScoped(List.of("<https://www.googleapis.com/auth/cloud-platform>"));

        googleCredentials.refreshIfExpired();
        return googleCredentials.getAccessToken().getTokenValue();
    }

    private String makePushMessage(FcmRequestDto dto) throws JsonProcessingException {
        ObjectMapper om = new ObjectMapper();
        FcmPushMessageDto fcmPushMessageDto = FcmPushMessageDto.builder()
                .message(FcmPushMessageDto.Message.builder()
                        .token(dto.getToken())
                        .notification(FcmPushMessageDto.Notification.builder()
                                .title(dto.getTitle())
                                .body(dto.getBody())
                                .image(null)
                                .build()
                        )
                        .build())
                .build();
        return om.writeValueAsString(fcmPushMessageDto);
    }
}