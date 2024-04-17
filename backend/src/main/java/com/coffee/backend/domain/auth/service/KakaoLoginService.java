package com.coffee.backend.domain.auth.service;

import com.coffee.backend.domain.auth.dto.AuthDto;
import com.coffee.backend.domain.auth.dto.KakaoUserInfoDto;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.domain.user.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

@RequiredArgsConstructor
@Service
public class KakaoLoginService {
    private final ObjectMapper objectMapper;
    private final UserRepository userRepository;
    private final JwtService jwtService;

    @Value("${kakao.user_info_uri}")
    private String userInfoURI;

    public KakaoUserInfoDto getUserInfo(String accessToken) {
        try {
            RestTemplate restTemplate = new RestTemplate();
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(accessToken);

            HttpEntity<String> request = new HttpEntity<>(headers);
            ResponseEntity<String> response = restTemplate.exchange(
                    userInfoURI, HttpMethod.GET, request, String.class);

            if (response.getStatusCode() == HttpStatus.OK) {
                return objectMapper.readValue(response.getBody(), KakaoUserInfoDto.class);
            } else {
                throw new RuntimeException("Failed to retrieve user info from Kakao API");
            }
        } catch (Exception e) {
            throw new RuntimeException("유저 정보를 받아올 수 없습니다.");
        }
    }

    @Transactional
    public AuthDto signIn(KakaoUserInfoDto dto) {
        User user = userRepository.findById(dto.getUserId())
                .orElseGet(User::new);

        // DB에 정보 없으면 회원가입 처리
        if (user.getUserId() == null) {
            user.setUserId(dto.getUserId());
            userRepository.save(user);
        }

        String token = jwtService.createAccessToken(user.getUserId());

        return new AuthDto(user.getUserUUID(), token);
    }
}
