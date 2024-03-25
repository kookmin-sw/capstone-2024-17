package com.coffee.backend.domain.user.service;

import com.coffee.backend.domain.user.dto.UserDto;
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

    public User getById(Long id) {
        Optional<User> user = userRepository.findById(id);

        return user.orElseThrow(() -> {
            log.info("id = {} 인 사용자가 존재하지 않습니다", id);
            return new CustomException(ErrorCode.USER_NOT_FOUND);
        });
    }

    public Boolean isDuplicatedLoginId(String loginId) {
        Optional<User> userOptional = userRepository.findByLoginId(loginId);

        if (userOptional.isEmpty()) {
            return Boolean.FALSE;
        }

        return Boolean.TRUE;
    }

    public UserDto convertToInfo(User user) {
        UserDto userDto = new UserDto();
        userDto.setNickname(user.getNickname());

        return userDto;
    }
}
