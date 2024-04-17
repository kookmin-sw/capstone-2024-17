package com.coffee.backend.domain.auth.controller;

import com.coffee.backend.domain.auth.dto.AuthDto;
import com.coffee.backend.domain.auth.dto.KakaoRequestDto;
import com.coffee.backend.domain.auth.dto.KakaoUserInfoDto;
import com.coffee.backend.domain.auth.service.KakaoLoginService;
import com.coffee.backend.utils.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RestController
@RequestMapping("/auth/kakao")
public class KakaoLoginController {
    private final KakaoLoginService kakaoLoginService;

    @PostMapping("/signIn")
    public ResponseEntity<ApiResponse<AuthDto>> kakaoLogin(@RequestBody KakaoRequestDto dto) {
        KakaoUserInfoDto userInfoDto = kakaoLoginService.getUserInfo(dto.getAccessToken());
        AuthDto authDto = kakaoLoginService.signIn(userInfoDto);
        return ResponseEntity.ok(ApiResponse.success(authDto));
    }
}
