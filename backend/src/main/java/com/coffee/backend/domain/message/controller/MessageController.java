package com.coffee.backend.domain.message.controller;

import com.coffee.backend.domain.auth.controller.AuthenticationPrincipal;
import com.coffee.backend.domain.chatroom.entity.Chatroom;
import com.coffee.backend.domain.chatroom.repository.ChatroomRepository;
import com.coffee.backend.domain.message.dto.MessageDto;
import com.coffee.backend.domain.message.dto.MessageResponses;
import com.coffee.backend.domain.message.entity.Message;
import com.coffee.backend.domain.message.service.MessageService;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.domain.userChatroom.repository.UserChatroomRepository;
import com.coffee.backend.utils.ApiResponse;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/message")
public class MessageController {
    private final ChatroomRepository chatroomRepository;
    private final UserChatroomRepository userChatroomRepository;
    private final MessageService messageService;
    private final SimpMessageSendingOperations sendingOperations;

    // 특정 채팅방 메시지 불러오기
    @GetMapping("/list")
    public ResponseEntity<ApiResponse<MessageResponses>> getMessageList(@AuthenticationPrincipal User user,
                                                                        @RequestParam(name = "chatroom_id") Long chatroomId) {
        // 채팅방 존재, 접근권한 확인
        Chatroom chatroom = chatroomRepository.findById(chatroomId).orElseThrow();
        userChatroomRepository.findByChatroomAndUser(chatroom, user).orElseThrow();

        List<Message> messages = messageService.getMessages(chatroom);
        MessageResponses messageResponses = messageService.convertMessageResponses(messages);

        return ResponseEntity.ok(ApiResponse.success(messageResponses));
    }

    // 메시지 전송 및 저장
    @MessageMapping("/chatroom/{chatroomId}") // /pub/chatroom/{chatroomId}
    public void sendAndSaveMessage(@DestinationVariable Long chatroomId, @RequestBody MessageDto dto) {
        System.out.println("message!");
        // 메시지 저장
        Chatroom chatroom = chatroomRepository.findById(chatroomId).orElseThrow();
        Message message = messageService.saveMessage(chatroom, dto);

        sendingOperations.convertAndSend("/sub/chatroom/" + chatroomId,
                messageService.convertMessageResponse(message, dto.getSenderId()));
    }
}
