package com.coffee.backend.domain.fcm.service;

import com.coffee.backend.domain.fcm.dto.FcmPushMessageDto;
import com.coffee.backend.domain.fcm.dto.FcmPushMessageDto.Data;
import com.coffee.backend.domain.fcm.dto.FcmPushMessageDto.Message;
import com.coffee.backend.domain.fcm.dto.FcmPushMessageDto.Notification;
import com.coffee.backend.exception.CustomException;
import com.coffee.backend.exception.ErrorCode;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.auth.oauth2.GoogleCredentials;
import java.io.IOException;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

@Slf4j
@Service
@RequiredArgsConstructor
public class FcmService {
    private final ObjectMapper objectMapper;
    private static final String FIREBASE_CONFIG_PATH = "firebase/firebase-secret-key.json";
    private static final String API_URL = "https://fcm.googleapis.com/v1/projects/career-cup-d9082/messages:send";

    public void sendPushMessageTo(String targetToken, String title, String body) {
        log.trace("sendPushMessageTo()");
        try {
            String pushMessage = makePushMessage(targetToken, title, body);

            final HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(getAccessToken());

            log.trace("pushMessage: {}", pushMessage);
            log.trace("headers: {}", headers);

            HttpEntity<String> entity = new HttpEntity<>(pushMessage, headers);
            RestTemplate restTemplate = new RestTemplate();
            ResponseEntity<String> response = restTemplate.exchange(API_URL, HttpMethod.POST, entity, String.class);

            log.trace("status code: {}", response.getStatusCode());
        } catch (JsonProcessingException e) {
            throw new CustomException(ErrorCode.FCM_MESSAGE_FORMAT_ERROR);
        } catch (IOException e) {
            log.error("구글 토큰 요청 에러", e);
            throw new CustomException(ErrorCode.FCM_ACCESS_TOKEN_ERROR);
        } catch (RestClientException e) {
            throw new CustomException(ErrorCode.FCM_SEND_ERROR);
        }
    }

    private String getAccessToken() throws IOException {
        log.trace("getAccessToken()");
        final GoogleCredentials googleCredentials = GoogleCredentials
                .fromStream(new ClassPathResource(FIREBASE_CONFIG_PATH).getInputStream())
                .createScoped(List.of("https://www.googleapis.com/auth/cloud-platform"));

        googleCredentials.refreshIfExpired();
        return googleCredentials.getAccessToken().getTokenValue();
    }

    private String makePushMessage(String targetToken, String title, String body) throws JsonProcessingException {
        log.trace("makePushMessage()");
        Data data = new Data();
        data.setTitle(title);
        data.setBody(body);

        Notification notification = new Notification();
        notification.setTitle(title);
        notification.setBody(body);

        Message message = new Message();
        message.setData(data);
        message.setNotification(notification);
        message.setToken(targetToken);

        FcmPushMessageDto fcmPushMessageDto = new FcmPushMessageDto(false, message);
        return objectMapper.writeValueAsString(fcmPushMessageDto);
    }
}
