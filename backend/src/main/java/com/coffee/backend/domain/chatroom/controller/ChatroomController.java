package com.coffee.backend.domain.chatroom.controller;

import com.coffee.backend.domain.auth.controller.AuthenticationPrincipal;
import com.coffee.backend.domain.chatroom.dto.ChatroomCreationDto;
import com.coffee.backend.domain.chatroom.dto.ChatroomResponse;
import com.coffee.backend.domain.chatroom.dto.ChatroomResponses;
import com.coffee.backend.domain.chatroom.service.ChatroomService;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.global.DtoLogger;
import com.coffee.backend.utils.ApiResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("chatroom")
public class ChatroomController {
    private final ChatroomService chatroomService;

    //    채팅방 생성 FIXME 체팅방 생성은 api가 아니라 매칭 성공시 서버에 의해 이뤄져야한다
    @PostMapping("/create")
    public ResponseEntity<ApiResponse<ChatroomResponse>> createChatroom(@AuthenticationPrincipal User user,
                                                                        @RequestParam("senderId") Long senderId) {
        DtoLogger.requestParam("senderId", senderId); // SenderId: 매칭요청을 보낸 사람 Id

        ChatroomCreationDto dto = new ChatroomCreationDto(senderId, user.getUserId());
        ChatroomResponse response = chatroomService.createChatroom(dto);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    //    내가 속한 채팅방 리스트
    @GetMapping("/list")
    public ResponseEntity<ApiResponse<ChatroomResponses>> getChatrooms(@AuthenticationPrincipal User user) {

        ChatroomResponses chatroomResponses = chatroomService.getChatrooms(user);
        return ResponseEntity.ok(ApiResponse.success(chatroomResponses));
    }
}
