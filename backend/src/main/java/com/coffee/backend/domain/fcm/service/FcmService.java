package com.coffee.backend.domain.fcm.service;

import com.coffee.backend.domain.fcm.dto.FcmRequestDto;
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
    private static final String API_URL = "https://fcm.googleapis.com/v1/projects/capstone-coffeechat/messages:send"; //fcm 엔드포인트
    private static final String FIREBASE_CONFIG_PATH = "firebase/firebase_service_key.json";
    private static final MediaType JSON = MediaType.get("application/json; charset=utf-8");

    private final OkHttpClient httpClient = new OkHttpClient();
    private final ObjectMapper objectMapper;

    // fcm으로 알림 전송
    public void sendNotificationTo(FcmRequestDto dto) throws IOException {
        String messagePayload = objectMapper.writeValueAsString(dto);
        Request request = createPostRequest(messagePayload);
        executeRequest(request);
    }

    private Request createPostRequest(String messagePayload) throws IOException {
        RequestBody requestBody = RequestBody.create(messagePayload, JSON);
        return new Request.Builder()
                .url(API_URL)
                .post(requestBody)
                .addHeader("Authorization", "Bearer " + getAccessToken())
                .build();
    }

    private String getAccessToken() throws IOException {
        GoogleCredentials googleCredentials = GoogleCredentials
                .fromStream(new ClassPathResource(FIREBASE_CONFIG_PATH).getInputStream())
                .createScoped(List.of("https://www.googleapis.com/auth/cloud-platform"));

        googleCredentials.refreshIfExpired();
        return googleCredentials.getAccessToken().getTokenValue();
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
}
