package com.coffee.backend.domain.auth.service;

import com.coffee.backend.domain.auth.dto.AuthDto;
import com.coffee.backend.domain.auth.dto.SignInDto;
import com.coffee.backend.domain.auth.dto.SignUpDto;
import com.coffee.backend.domain.redis.service.TokenStorageService;
import com.coffee.backend.domain.user.dto.UserDto;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.domain.user.repository.UserRepository;
import com.coffee.backend.exception.CustomException;
import com.coffee.backend.exception.ErrorCode;
import jakarta.transaction.Transactional;
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
    private final JwtService jwtService;
    private final UserRepository userRepository;
    private final ModelMapper mapper;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    private final TokenStorageService tokenStorageService;

    public UserDto signUp(SignUpDto dto) {
        validateLoginIdNotDuplicated(dto.getLoginId());

        User user = mapper.map(dto, User.class);
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setUserUUID(UUID.randomUUID().toString());

        User savedUser = userRepository.save(user);
        return mapper.map(savedUser, UserDto.class);
    }

    public AuthDto signIn(SignInDto dto) {
        User user = userRepository.findByLoginId(dto.getLoginId())
                .orElseThrow(() -> new CustomException(ErrorCode.LOGIN_FAILED));

        validatePassword(dto.getPassword(), user.getPassword());

        String token = jwtService.createAccessToken(user.getUserId());

        // redis에 토큰 저장
        tokenStorageService.storeToken(user.getUserUUID(), token);

        return new AuthDto(user.getUserUUID(), token);
    }

    public boolean deleteUserByUserUUID(String userUUID) {
        if (!userRepository.existsByUserUUID(userUUID)) {
            throw new CustomException(ErrorCode.USER_NOT_FOUND);
        }
        userRepository.deleteByUserUUID(userUUID);
        return true;
    }

    private void validateLoginIdNotDuplicated(String loginId) {
        userRepository.findByLoginId(loginId).ifPresent(u -> {
            throw new CustomException(ErrorCode.LOGIN_ID_DUPLICATED);
        });
    }

    private void validatePassword(String inputPassword, String storedPassword) {
        if (!passwordEncoder.matches(inputPassword, storedPassword)) {
            throw new CustomException(ErrorCode.LOGIN_FAILED);
        }
    }
}
