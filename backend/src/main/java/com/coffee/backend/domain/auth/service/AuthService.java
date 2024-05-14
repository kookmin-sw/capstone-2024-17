package com.coffee.backend.domain.auth.service;

import com.coffee.backend.domain.auth.dto.AuthDto;
import com.coffee.backend.domain.auth.dto.SignInDto;
import com.coffee.backend.domain.auth.dto.SignUpDto;
import com.coffee.backend.domain.redis.exception.RedisOperationException;
import com.coffee.backend.domain.redis.service.TokenStorageService;
import com.coffee.backend.domain.user.dto.UserDto;
import com.coffee.backend.domain.user.entity.Position;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.domain.user.repository.UserRepository;
import com.coffee.backend.exception.CustomException;
import com.coffee.backend.exception.ErrorCode;
import com.coffee.backend.utils.CustomMapper;
import io.lettuce.core.RedisException;
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
    private final CustomMapper customMapper;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    private final TokenStorageService tokenStorageService;

    public UserDto detail(User user) {
        log.trace("detail()");
        return customMapper.toUserDto(user);
    }

    public UserDto signUp(SignUpDto dto) {
        log.trace("signUp()");
        validateLoginIdNotDuplicated(dto.getLoginId());

        User user = mapper.map(dto, User.class);
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setUserUUID(UUID.randomUUID().toString());
        user.setPosition(Position.P00);

        User savedUser = userRepository.save(user);
        return customMapper.toUserDto(savedUser);
    }

    public AuthDto signIn(SignInDto dto) {
        log.trace("signIn()");
        User user = userRepository.findByLoginId(dto.getLoginId())
                .orElseThrow(() -> new CustomException(ErrorCode.LOGIN_FAILED));

        validatePassword(dto.getPassword(), user.getPassword());

        String token = jwtService.createAccessToken(user.getUserId());

        // redis에 토큰 저장
        try {
            tokenStorageService.storeToken(user.getUserUUID(), token);
        } catch (RedisException e) {
            throw new RedisOperationException(e.getMessage(), e);
        }

        return new AuthDto(user.getUserUUID(), token);
    }

    public boolean deleteUserByUserUUID(String userUUID) {
        log.trace("deleteUserByUserUUID()");
        userRepository.findByUserUUID(userUUID)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        userRepository.deleteByUserUUID(userUUID);
        return true;
    }

    private void validateLoginIdNotDuplicated(String loginId) {
        log.trace("validateLoginIdNotDuplicated()");
        userRepository.findByLoginId(loginId).ifPresent(u -> {
            throw new CustomException(ErrorCode.LOGIN_ID_DUPLICATED);
        });
    }

    private void validatePassword(String inputPassword, String storedPassword) {
        log.trace("validatePassword()");
        if (!passwordEncoder.matches(inputPassword, storedPassword)) {
            throw new CustomException(ErrorCode.LOGIN_FAILED);
        }
    }
}
