package com.coffee.backend.domain.fcm.service;

import com.coffee.backend.domain.fcm.dto.FcmPushMessageDto;
import com.coffee.backend.exception.CustomException;
import com.coffee.backend.exception.ErrorCode;
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
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

@Service
@RequiredArgsConstructor
public class FcmService {
    private final ObjectMapper objectMapper;
    private static final String FIREBASE_CONFIG_PATH = "firebase/firebase-secret-key.json";
    private static final String API_URL = "https://fcm.googleapis.com/v1/projects/capstone-coffeechat/messages:send";
    private static final List<String> SCOPES = List.of("https://www.googleapis.com/auth/cloud-platform");

    public void sendPushMessageTo(String targetToken, String title, String body) {
        try {
            String pushMessage = makePushMessage(targetToken, title, body);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(getAccessToken());

            HttpEntity<String> entity = new HttpEntity<>(pushMessage, headers);
            RestTemplate restTemplate = new RestTemplate();
            ResponseEntity<String> response = restTemplate.exchange(API_URL, HttpMethod.POST, entity, String.class);

            System.out.println(response.getStatusCode());
        } catch (JsonProcessingException e) {
            throw new CustomException(ErrorCode.FCM_MESSAGE_FORMAT_ERROR);
        } catch (IOException e) {
            throw new CustomException(ErrorCode.FCM_ACCESS_TOKEN_ERROR);
        } catch (RestClientException e) {
            throw new CustomException(ErrorCode.FCM_SEND_ERROR);
        }
    }

    private String getAccessToken() throws IOException {
        GoogleCredentials googleCredentials = GoogleCredentials
                .fromStream(new ClassPathResource(FIREBASE_CONFIG_PATH).getInputStream())
                .createScoped(SCOPES);

        googleCredentials.refreshIfExpired();
        return googleCredentials.getAccessToken().getTokenValue();
    }

    private String makePushMessage(String targetToken, String title, String body) throws JsonProcessingException {
        FcmPushMessageDto fcmPushMessageDto = FcmPushMessageDto.builder()
                .message(FcmPushMessageDto.Message.builder()
                        .targetToken(targetToken)
                        .notification(FcmPushMessageDto.Notification.builder()
                                .title(title)
                                .body(body)
                                .build())
                        .build())
                .build();
        return objectMapper.writeValueAsString(fcmPushMessageDto);
    }
}