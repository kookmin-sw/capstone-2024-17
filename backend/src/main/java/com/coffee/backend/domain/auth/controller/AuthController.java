package com.coffee.backend.domain.auth.controller;

import com.coffee.backend.domain.auth.dto.AuthDto;
import com.coffee.backend.domain.auth.dto.LoginIdDto;
import com.coffee.backend.domain.auth.dto.SignInDto;
import com.coffee.backend.domain.auth.dto.SignUpDto;
import com.coffee.backend.domain.auth.service.AuthService;
import com.coffee.backend.domain.user.dto.UserDto;
import com.coffee.backend.domain.user.service.UserService;
import com.coffee.backend.utils.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Slf4j
public class AuthController {
    private final AuthService authService;
    private final UserService userService;

    @PostMapping("/checkDuplicate")
    public ResponseEntity<ApiResponse<Boolean>> checkLoginId(@RequestBody LoginIdDto dto) {
        Boolean isDuplicatedLoginId = userService.checkDuplicatedLoginId(dto.getLoginId());
        return ResponseEntity.ok(ApiResponse.success(isDuplicatedLoginId));
    }

    @PostMapping("/signUp")
    public ResponseEntity<ApiResponse<UserDto>> signUp(
            @Valid @RequestBody SignUpDto dto
    ) {
        UserDto userDto = authService.signUp(dto);
        return ResponseEntity.ok(ApiResponse.success(userDto));
    }

    @PostMapping("/signIn")
    public ResponseEntity<ApiResponse<AuthDto>> signIn(
            @Valid @RequestBody SignInDto dto
    ) {
        AuthDto authDto = authService.signIn(dto);
        return ResponseEntity.ok(ApiResponse.success(authDto));
    }
}