package com.coffee.backend.domain.auth.service;

import com.coffee.backend.domain.auth.dto.AuthDto;
import com.coffee.backend.domain.auth.dto.SignInDto;
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
    private final JwtService jwtService;
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

    public AuthDto signIn(SignInDto dto) {
        final String loginId = dto.getLoginId();
        final String password = dto.getPassword();

        Optional<User> userWrapper = userRepository.findByLoginId(loginId);

        if (userWrapper.isEmpty()) {
            log.info("{} 에 해당하는 사용자가 없습니다.", loginId);
            throw new CustomException(ErrorCode.LOGIN_FAILED);
        }

        User user = userWrapper.get();

        if (!passwordEncoder.matches(password, user.getPassword())) {
            log.info("패스워드 또는 아이디 정보가 일치하지 않습니다. loginId = {}, pwd = {}", loginId, password);
            throw new CustomException(ErrorCode.LOGIN_FAILED);
        }

        return new AuthDto(user.getUserUUID(), jwtService.createAccessToken(user.getUserId()));
    }
}
