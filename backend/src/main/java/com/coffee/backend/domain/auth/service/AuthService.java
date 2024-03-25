package com.coffee.backend.domain.auth.service;

import com.coffee.backend.domain.auth.dto.SignUpDto;
import com.coffee.backend.domain.user.dto.UserDto;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.domain.user.repository.UserRepository;
import com.coffee.backend.exception.CustomException;
import com.coffee.backend.exception.ErrorCode;
import jakarta.transaction.Transactional;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class AuthService {
    private final UserRepository userRepository;
    private final ModelMapper mapper;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public UserDto signUp(SignUpDto dto) {
        Optional<User> userWrapper = userRepository.findByLoginId(dto.getLoginId());

        if (userWrapper.isPresent()) {
            throw new CustomException(ErrorCode.LOGIN_ID_DUPLICATED);
        }

        User user = mapper.map(dto, User.class);
        user.setPassword(passwordEncoder.encode(dto.getPassword()));

        user.setUserUUID(UUID.randomUUID().toString());

        User saved = userRepository.save(user);

        return mapper.map(saved, UserDto.class);
    }
}
