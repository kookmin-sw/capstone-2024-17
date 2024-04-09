package com.coffee.backend.domain.message.service;

import com.coffee.backend.domain.chatroom.entity.Chatroom;
import com.coffee.backend.domain.message.dto.MessageDto;
import com.coffee.backend.domain.message.dto.MessageResponse;
import com.coffee.backend.domain.message.dto.MessageResponses;
import com.coffee.backend.domain.message.entity.Message;
import com.coffee.backend.domain.message.repository.MessageRepository;
import com.coffee.backend.domain.user.service.UserService;
import java.time.format.DateTimeFormatter;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MessageService {
    private final MessageRepository messageRepository;
    private final UserService userService;
    private DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy년 MM월 dd일/HH:mm");

    public List<Message> getMessages(Chatroom chatRoom) {
        return messageRepository.findAllByChatroom(chatRoom).stream().toList();
    }

    public MessageResponse convertMessageResponse(Message message, Long userId) {
        return new MessageResponse(userId,
                message.getContent(),
                message.getCreatedAt().format(formatter),
                userService.getByUserId(userId).getNickname());
    }

    public MessageResponses convertMessageResponses(List<Message> messages) {
        return new MessageResponses(messages.stream().map(m -> new MessageResponse(
                m.getSenderId(),
                m.getContent(),
                m.getCreatedAt().format(formatter),
                userService.getByUserId(m.getSenderId()).getNickname()
        )).toList());
    }

    public Message saveMessage(Chatroom chatroom, MessageDto messageDto) {
        Message message = new Message();
        message.setSenderId(messageDto.getSenderId());
        message.setContent(messageDto.getContent());
        message.setChatroom(chatroom);
        return messageRepository.save(message);
    }
}
