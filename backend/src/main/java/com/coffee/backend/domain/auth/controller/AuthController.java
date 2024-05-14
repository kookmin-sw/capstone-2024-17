package com.coffee.backend.domain.auth.controller;

import com.coffee.backend.domain.auth.dto.AuthDto;
import com.coffee.backend.domain.auth.dto.DeleteUserDto;
import com.coffee.backend.domain.auth.dto.KakaoRequestDto;
import com.coffee.backend.domain.auth.dto.KakaoUserInfoDto;
import com.coffee.backend.domain.auth.dto.SignInDto;
import com.coffee.backend.domain.auth.dto.SignUpDto;
import com.coffee.backend.domain.auth.service.AuthService;
import com.coffee.backend.domain.auth.service.KakaoLoginService;
import com.coffee.backend.domain.user.dto.UserDto;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.exception.CustomException;
import com.coffee.backend.exception.ErrorCode;
import com.coffee.backend.global.DtoLogger;
import com.coffee.backend.utils.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Slf4j
public class AuthController {
    private final AuthService authService;
    private final KakaoLoginService kakaoLoginService;
    static Logger logger = LoggerFactory.getLogger(AuthController.class);

    @PostMapping("/signUp")
    public ResponseEntity<ApiResponse<UserDto>> signUp(
            @Valid @RequestBody SignUpDto dto
    ) {
        DtoLogger.requestBody(dto);

        UserDto userDto = authService.signUp(dto);
        return ResponseEntity.ok(ApiResponse.success(userDto));
    }

    @PostMapping("/signIn")
    public ResponseEntity<ApiResponse<AuthDto>> signIn(
            @Valid @RequestBody SignInDto dto
    ) {
        DtoLogger.requestBody(dto);

        AuthDto authDto = authService.signIn(dto);
        return ResponseEntity.ok(ApiResponse.success(authDto));
    }

    @DeleteMapping("/delete")
    public ResponseEntity<ApiResponse<Boolean>> deleteAccount(
            @AuthenticationPrincipal User user,
            @RequestBody DeleteUserDto dto
    ) {
        DtoLogger.requestBody(dto);

        boolean isDeleted = authService.deleteUserByUserUUID(dto.getUserUUID());
        if (isDeleted) {
            return ResponseEntity.ok(ApiResponse.success(true));
        } else {
            throw new CustomException(ErrorCode.DELETE_USER_FAILED);
        }
    }

    @PostMapping("/kakaoSignIn")
    public ResponseEntity<ApiResponse<AuthDto>> kakaoLogin(@RequestBody KakaoRequestDto dto) {
        DtoLogger.requestBody(dto);

        KakaoUserInfoDto userInfoDto = kakaoLoginService.getUserInfo(dto.getAccessToken());
        AuthDto authDto = kakaoLoginService.signIn(userInfoDto);
        return ResponseEntity.ok(ApiResponse.success(authDto));
    }

    @GetMapping("/detail")
    public ResponseEntity<ApiResponse<UserDto>> detail(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(ApiResponse.success(authService.detail(user)));
    }
}
