package com.coffee.backend.domain.user.repository;

import com.coffee.backend.domain.user.entity.User;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByLoginId(final String loginId);

    boolean existsByUserUUID(String userUUID);

    void deleteByUserUUID(String userUUID);
}
