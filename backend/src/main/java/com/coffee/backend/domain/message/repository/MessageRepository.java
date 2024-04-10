package com.coffee.backend.domain.message.repository;

import com.coffee.backend.domain.chatroom.entity.Chatroom;
import com.coffee.backend.domain.message.entity.Message;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {
    List<Message> findAllByChatroom(Chatroom chatroom);
}
