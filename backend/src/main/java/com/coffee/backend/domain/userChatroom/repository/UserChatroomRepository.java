package com.coffee.backend.domain.userChatroom.repository;

import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.domain.userChatroom.entity.UserChatroom;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserChatroomRepository extends JpaRepository<UserChatroom, Long> {
    Optional<UserChatroom> findAllByUser(User user);
}
