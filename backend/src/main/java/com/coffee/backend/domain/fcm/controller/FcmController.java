package com.coffee.backend.domain.fcm.controller;

import com.coffee.backend.domain.fcm.dto.FcmMessageDto;
import com.coffee.backend.domain.fcm.service.FcmService;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/fcm")
@RequiredArgsConstructor
public class FcmController {

    private final FcmService fcmService;

    @PostMapping()
    public ResponseEntity<String> sendNotification(@RequestBody FcmMessageDto dto) {
        try {
            fcmService.sendMessageTo(dto);
            return ResponseEntity.ok().body("알림 전송 성공");
        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("알림 전송 실패");
        }
    }
}
