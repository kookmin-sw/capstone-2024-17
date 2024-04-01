package com.coffee.backend.domain.fcm.service;

import com.coffee.backend.domain.fcm.dto.FcmMessageDto;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.auth.oauth2.GoogleCredentials;
import java.io.IOException;
import java.util.List;
import lombok.RequiredArgsConstructor;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class FcmService {
    private static final String FIREBASE_CONFIG_PATH = "firebase/firebase_service_key.json";
    private static final MediaType JSON = MediaType.get("application/json; charset=utf-8");

    private final OkHttpClient httpClient = new OkHttpClient();
    private final ObjectMapper objectMapper;

    public void sendMessageTo(FcmMessageDto dto) throws IOException {
        String messagePayload = createMessagePayload(
                dto.getMessage().getTargetToken(),
                dto.getMessage().getNotification().getTitle(),
                dto.getMessage().getNotification().getBody(),
                dto.getMessage().getNotification().getImage());
        Request request = createPostRequest(messagePayload);
        executeRequest(request);
    }

    private String createMessagePayload(String targetToken, String title, String body, String image) throws IOException {
        FcmMessageDto fcmMessageDto = FcmMessageDto.builder()
                .validateOnly(false)
                .message(FcmMessageDto.Message.builder()
                        .targetToken(targetToken)
                        .notification(FcmMessageDto.Notification.builder()
                                .title(title)
                                .body(body)
                                .image(image)
                                .build())
                        .build())
                .build();

        return objectMapper.writeValueAsString(fcmMessageDto);
    }

    private Request createPostRequest(String messagePayload) throws IOException {
        RequestBody requestBody = RequestBody.Companion.create(messagePayload, JSON);
        String API_URL = "https://fcm.googleapis.com/v1/projects/capstone-coffeechat/messages:send";
        return new Request.Builder()
                .url(API_URL)
                .post(requestBody)
                .addHeader("Authorization", "Bearer " + getAccessToken())
                .build();
    }

    private void executeRequest(Request request) throws IOException {
        try (Response response = httpClient.newCall(request).execute()) {
            if (response.isSuccessful() && response.body() != null) {
                System.out.println("Response: " + response.body().string());
            } else {
                throw new IOException("executeRequest 에러 " + response.code());
            }
        }
    }

    private String getAccessToken() throws IOException {
        GoogleCredentials googleCredentials = GoogleCredentials
                .fromStream(new ClassPathResource(FIREBASE_CONFIG_PATH).getInputStream())
                .createScoped(List.of("https://www.googleapis.com/auth/cloud-platform"));

        googleCredentials.refreshIfExpired();
        return googleCredentials.getAccessToken().getTokenValue();
    }
}
