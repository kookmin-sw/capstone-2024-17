package com.coffee.backend.domain.userChatroom.entity;

import com.coffee.backend.domain.chatroom.entity.Chatroom;
import com.coffee.backend.domain.user.entity.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "user_chatroom")
@Getter
@Setter
public class UserChatroom {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_chatroom_id")
    private Long userChatroomId;

    @ManyToOne
    @JoinColumn(name = "chatroom_id")
    private Chatroom chatroom;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
}
