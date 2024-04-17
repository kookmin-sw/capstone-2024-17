package com.coffee.backend.domain.user.service;

import com.coffee.backend.domain.cafe.dto.CafeUserDto;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.domain.user.repository.UserRepository;
import com.coffee.backend.exception.CustomException;
import com.coffee.backend.exception.ErrorCode;
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

    // 특정 카페에 접속한 사용자 list에 보일 User 데이터 조회
    public CafeUserDto getCafeUserInfoByLoginId(String userId) {
        return userRepository.findByLoginId(userId)
                .map(user -> new CafeUserDto(user.getUserId(), user.getNickname(),
                        user.getEmail())) // TODO : email을 introduction으로 교체
                .orElseThrow(() -> {
                    log.info("id = {} 인 사용자가 존재하지 않습니다", userId);
                    return new CustomException(ErrorCode.USER_NOT_FOUND);
                });
    }

    public void checkDuplicatedEmail(String email) {
        Optional<User> user = userRepository.findByEmail(email);
        if (user.isPresent()) {
            log.debug("userService.checkDuplicatedEmail exception occur email: {}", email);
            throw new CustomException(ErrorCode.EMAIL_DUPLICATED);
        }
    }

    public void setUserEmail(User user, String email) {
//        this.checkDuplicatedEmail(email);
        user.setEmail(email);
        userRepository.save(user);
    }
}
