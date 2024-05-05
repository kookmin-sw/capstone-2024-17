package com.coffee.backend.domain.user.controller;

import com.coffee.backend.domain.auth.controller.AuthenticationPrincipal;
import com.coffee.backend.domain.user.dto.IntroductionUpdateRequest;
import com.coffee.backend.domain.user.dto.PositionUpdateRequest;
import com.coffee.backend.domain.user.dto.UserDto;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.domain.user.service.UserService;
import com.coffee.backend.utils.ApiResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequestMapping("/user")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;

    @PostMapping("/position/update")
    public ResponseEntity<ApiResponse<UserDto>> position(@AuthenticationPrincipal User user,
                                                         @RequestBody PositionUpdateRequest dto) {

        return ResponseEntity.ok(ApiResponse.success(userService.updateUserPosition(user, dto.getPosition())));
    }

    @PostMapping("/introduction/update")
    public ResponseEntity<ApiResponse<UserDto>> position(@AuthenticationPrincipal User user,
                                                         @RequestBody IntroductionUpdateRequest dto) {

        return ResponseEntity.ok(ApiResponse.success(userService.updateUserIntroduction(user, dto.getIntroduction())));
    }


}
