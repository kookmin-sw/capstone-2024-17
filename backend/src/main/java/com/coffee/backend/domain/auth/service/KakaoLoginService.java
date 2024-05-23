package com.coffee.backend.domain.auth.service;

import com.coffee.backend.domain.auth.dto.AuthDto;
import com.coffee.backend.domain.auth.dto.KakaoUserInfoDto;
import com.coffee.backend.domain.user.entity.Position;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.domain.user.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

@Slf4j
@RequiredArgsConstructor
@Service
public class KakaoLoginService {
    private final ObjectMapper objectMapper;
    private final UserRepository userRepository;
    private final JwtService jwtService;

    public KakaoUserInfoDto getUserInfo(String accessToken) {
        log.trace("getUserInfo()");
        try {
            RestTemplate restTemplate = new RestTemplate();
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(accessToken);

            HttpEntity<String> request = new HttpEntity<>(headers);
            String userInfoURI = "https://kapi.kakao.com/v2/user/me";
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
        log.trace("signIn()");
        User user = userRepository.findByKakaoId(dto.getId())
                .orElseGet(User::new);

        // DB에 정보 없으면 회원가입 처리
        if (user.getKakaoId() == null) {
            user.setKakaoId(dto.getId());
            user.setNickname("user@" + dto.getId());
            user.setPosition(Position.P00);
            user.setCoffeeBean(46);
            user.setUserUUID(UUID.randomUUID().toString());
        }
        // update deviceToken
        user.setDeviceToken(dto.getDeviceToken());
        userRepository.save(user);

        String token = jwtService.createAccessToken(user.getUserId());

        return new AuthDto(user.getUserUUID(), token);
    }
}
