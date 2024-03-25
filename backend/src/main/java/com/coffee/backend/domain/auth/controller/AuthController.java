package com.coffee.backend.domain.auth.controller;

import com.coffee.backend.domain.auth.dto.AuthDto;
import com.coffee.backend.domain.auth.dto.CheckLoginIdDto;
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
import org.springframework.web.bind.annotation.GetMapping;
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

    @GetMapping("/healthCheck")
    public String healthCheck() {
        return "Connect !";
    }

    @PostMapping("/check-duplicate")
    public ResponseEntity<ApiResponse<Boolean>> checkLoginId(@RequestBody CheckLoginIdDto checkLoginIdDto) {
        Boolean duplicatedLoginId = userService.isDuplicatedLoginId(checkLoginIdDto.getLoginId());
        return ResponseEntity.ok(ApiResponse.success(duplicatedLoginId));
    }

    @PostMapping("/signUp")
    public ResponseEntity<ApiResponse<UserDto>> signUp(
            @Valid @RequestBody SignUpDto signUpDto
    ) {
        UserDto userDto = authService.signUp(signUpDto);
        return ResponseEntity.ok(ApiResponse.success(userDto));
    }

    @PostMapping("/signIn")
    public ResponseEntity<ApiResponse<AuthDto>> signIn(
            @Valid @RequestBody SignInDto signInDto
    ) {
        AuthDto authDto = authService.signIn(signInDto);
        return ResponseEntity.ok(ApiResponse.success(authDto));
    }
}
