package com.coffee.backend.domain.chatroom.repository;

import com.coffee.backend.domain.chatroom.entity.Chatroom;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ChatroomRepository extends JpaRepository<Chatroom, Long> {
}
