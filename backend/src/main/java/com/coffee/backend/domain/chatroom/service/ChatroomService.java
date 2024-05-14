package com.coffee.backend.domain.chatroom.service;

import com.coffee.backend.domain.chatroom.dto.ChatroomCreationDto;
import com.coffee.backend.domain.chatroom.dto.ChatroomResponse;
import com.coffee.backend.domain.chatroom.dto.ChatroomResponses;
import com.coffee.backend.domain.chatroom.entity.Chatroom;
import com.coffee.backend.domain.chatroom.repository.ChatroomRepository;
import com.coffee.backend.domain.message.service.MessageService;
import com.coffee.backend.domain.user.dto.UserDto;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.domain.user.repository.UserRepository;
import com.coffee.backend.domain.userChatroom.entity.UserChatroom;
import com.coffee.backend.domain.userChatroom.repository.UserChatroomRepository;
import com.coffee.backend.utils.CustomMapper;
import jakarta.transaction.Transactional;
import java.util.List;
import java.util.NoSuchElementException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class ChatroomService {
    private final UserRepository userRepository;
    private final ChatroomRepository chatroomRepository;
    private final UserChatroomRepository userChatroomRepository;
    private final MessageService messageService;
    private final CustomMapper customMapper;

    @Transactional
    public ChatroomResponse createChatroom(ChatroomCreationDto dto) {
        log.trace("createChatroom()");
//      TODO?  채팅방 이미 있는지 확인
//      TODO Exception 수정
        User sender = userRepository.findByUserUUID(dto.getSenderUUID())
                .orElseThrow(NoSuchElementException::new);
        User receiver = userRepository.findById(dto.getReceiverId())
                .orElseThrow(NoSuchElementException::new);

        Chatroom room = new Chatroom();
        chatroomRepository.save(room);
        UserChatroom uc1 = new UserChatroom();
        uc1.setChatroom(room);
        uc1.setUser(sender);
        userChatroomRepository.save(uc1);
        UserChatroom uc2 = new UserChatroom();
        uc2.setChatroom(room);
        uc2.setUser(receiver);
        userChatroomRepository.save(uc2);

        UserDto userInfo = customMapper.toUserDto(sender);
        return new ChatroomResponse(room.getChatroomId(), userInfo, "");
    }

    @Transactional
    public ChatroomResponses getChatrooms(User user) {
        log.trace("getChatrooms()");
        List<ChatroomResponse> responses = (userChatroomRepository.findAllByUser(user)).stream()
                .filter(o -> o.getUser().equals(user))
                .map(UserChatroom::getChatroom)
                .map(cr -> {
                    User other = userChatroomRepository.findOtherUserChatroomByChatroomAndUser(cr, user).orElseThrow()
                            .getUser();
                    UserDto otherInfo = customMapper.toUserDto(other);

                    return new ChatroomResponse(cr.getChatroomId(), otherInfo,
                            messageService.getRecentMessageContent(cr));
                })
                .toList();

        return new ChatroomResponses(responses);
    }
}
