package com.coffee.backend.domain.auth.controller;

import com.coffee.backend.domain.auth.dto.AuthDto;
import com.coffee.backend.domain.auth.dto.DeleteUserDto;
import com.coffee.backend.domain.auth.dto.LoginIdDto;
import com.coffee.backend.domain.auth.dto.SignInDto;
import com.coffee.backend.domain.auth.dto.SignUpDto;
import com.coffee.backend.domain.auth.service.AuthService;
import com.coffee.backend.domain.user.dto.UserDto;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.domain.user.service.UserService;
import com.coffee.backend.exception.CustomException;
import com.coffee.backend.domain.auth.exception.ErrorCode;
import com.coffee.backend.utils.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
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

    @DeleteMapping("/delete")
    public ResponseEntity<ApiResponse<Boolean>> deleteAccount(
            @AuthenticationPrincipal User user,
            @RequestBody DeleteUserDto dto
    ) {
        boolean isDeleted = authService.deleteUserByUserUUID(dto.getUserUUID());
        if (isDeleted) {
            return ResponseEntity.ok(ApiResponse.success(true));
        } else {
            throw new CustomException(ErrorCode.DELETE_USER_FAILED);
        }
    }
}
