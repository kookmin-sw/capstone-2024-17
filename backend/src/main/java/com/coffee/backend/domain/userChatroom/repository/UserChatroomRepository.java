package com.coffee.backend.domain.userChatroom.repository;

import com.coffee.backend.domain.chatroom.entity.Chatroom;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.domain.userChatroom.entity.UserChatroom;
import io.lettuce.core.dynamic.annotation.Param;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface UserChatroomRepository extends JpaRepository<UserChatroom, Long> {
    List<UserChatroom> findAllByUser(User user);

    Optional<UserChatroom> findByChatroomAndUser(Chatroom chatroom, User user);

    /**
     * 주어진 chatroom과 연결된 UserChatroom을 찾고, 그 중에서도 user와 다른 사용자(u2)와 연결된 UserChatroom을 반환
     */
    @Query("SELECT uc2 " +
            "FROM UserChatroom uc1 " +
            "JOIN uc1.chatroom c " +
            "JOIN uc1.user u1 " +
            "JOIN UserChatroom uc2 ON uc2.chatroom = c " +
            "JOIN uc2.user u2 " +
            "WHERE uc1.chatroom = :chatroom AND u2 != :user")
    Optional<UserChatroom> findOtherUserChatroomByChatroomAndUser(@Param("chatroom") Chatroom chatroom,
                                                                  @Param("user") User user);

    @Query("SELECT uc1.chatroom " +
            "FROM UserChatroom uc1 " +
            "JOIN UserChatroom uc2 ON uc1.chatroom = uc2.chatroom " +
            "WHERE uc1.user = :user AND uc2.user = :user2")
    Optional<Chatroom> findByUserAndOtherUser(@Param("user") User user, @Param("user2") User user2);

}
