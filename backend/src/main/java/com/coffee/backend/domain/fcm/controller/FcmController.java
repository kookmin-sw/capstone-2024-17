package com.coffee.backend.domain.fcm.controller;

import com.coffee.backend.domain.fcm.dto.FcmRequestDto;
import com.coffee.backend.domain.fcm.service.FcmService;
import com.coffee.backend.utils.ApiResponse;
import jakarta.validation.Valid;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/fcm")
public class FcmController {

    private final FcmService fcmService;

    @PostMapping()
    public ResponseEntity<ApiResponse<String>> sendPushMessage(@Valid @RequestBody FcmRequestDto dto) {
        fcmService.sendPushMessageTo(dto);
        return ResponseEntity.ok(ApiResponse.success("알림 전송 성공"));
    }
}
