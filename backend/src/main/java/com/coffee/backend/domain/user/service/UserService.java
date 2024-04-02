package com.coffee.backend.domain.user.service;

import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.domain.user.repository.UserRepository;
import com.coffee.backend.exception.CustomException;
import com.coffee.backend.domain.auth.exception.ErrorCode;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {
    private final UserRepository userRepository;

    public User getByUserId(Long userId) {
        Optional<User> user = userRepository.findById(userId);

        return user.orElseThrow(() -> {
            log.info("id = {} 인 사용자가 존재하지 않습니다", userId);
            return new CustomException(ErrorCode.USER_NOT_FOUND);
        });
    }
}
