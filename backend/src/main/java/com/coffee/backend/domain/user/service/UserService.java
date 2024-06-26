package com.coffee.backend.domain.user.service;

import com.coffee.backend.domain.cafe.dto.CafeUserDto;
import com.coffee.backend.domain.company.entity.Company;
import com.coffee.backend.domain.user.dto.UserDto;
import com.coffee.backend.domain.user.entity.Position;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.domain.user.repository.UserRepository;
import com.coffee.backend.exception.CustomException;
import com.coffee.backend.exception.ErrorCode;
import com.coffee.backend.utils.CustomMapper;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class UserService {
    private final UserRepository userRepository;
    private final CustomMapper customMapper;

    public User getByUserId(Long userId) {
        log.trace("getByUserId()");
        Optional<User> user = userRepository.findById(userId);

        return user.orElseThrow(() -> {
            log.info("id = {} 인 사용자가 존재하지 않습니다", userId);
            return new CustomException(ErrorCode.USER_NOT_FOUND);
        });
    }

    // 특정 카페에 접속한 사용자 list에 보일 User 데이터 조회
    public CafeUserDto getCafeUserInfoByUserId(Long userId) {
        log.trace("getCafeUserInfoByUserId()");
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> {
                    log.info("id = {} 인 사용자가 존재하지 않습니다", userId);
                    return new CustomException(ErrorCode.USER_NOT_FOUND);
                });

        return CafeUserDto.builder()
                .userId(user.getUserId())
                .nickname(user.getNickname())
                .company(Optional.ofNullable(user.getCompany()).map(Company::getName).orElse("무소속"))
                .position(user.getPosition().getName())
                .introduction(Optional.ofNullable(user.getIntroduction()).orElse("기본소개"))
                .coffeeBean(String.format("%.1f", user.getCoffeeBean()))
                .build();
    }


    public void checkDuplicatedEmail(String loginId, String email) {
        log.trace("checkDuplicatedEmail()");
        Optional<User> _user = userRepository.findByEmail(email);
        if (_user.isPresent()) {
            if (_user.get().getLoginId().equals(loginId)) {
                return; // 자기 자신 email이면 duplication 아님
            }
            log.debug("userService.checkDuplicatedEmail exception occur email: {}", email);
            throw new CustomException(ErrorCode.EMAIL_DUPLICATED);
        }
    }

    public void setUserEmail(User user, String email) {
        log.trace("setUserEmail()");
//        this.checkDuplicatedEmail(email);
        user.setEmail(email);
        userRepository.save(user);
    }

    public void setUserCompany(User user, Company company) {
        log.trace("setUserCompany()");
        user.setCompany(company);
        userRepository.save(user);
    }

    public UserDto updateUserNickname(User user, String nickname) {
        log.trace("updateUserNickname()");
        user.setNickname(nickname);
        return customMapper.toUserDto(userRepository.save(user));
    }

    public UserDto updateUserPosition(User user, String position) {
        log.trace("updateUserPosition()");
        user.setPosition(Position.of(position));
        return customMapper.toUserDto(userRepository.save(user));
    }

    public UserDto updateUserIntroduction(User user, String introduction) {
        log.trace("updateUserIntroduction()");
        user.setIntroduction(introduction);
        return customMapper.toUserDto(userRepository.save(user));
    }

    public void updateUserSessionId(Long userId, String sessionId) {
        log.trace("updateUserSessionId()");
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> {
                    log.info("id = {} 인 사용자가 존재하지 않습니다", userId);
                    return new CustomException(ErrorCode.USER_NOT_FOUND);
                });
        user.setSessionId(sessionId);
        userRepository.save(user);
    }

    public UserDto resetCompany(User user) {
        log.trace("resetCompany()");
        user.setCompany(null);
        return customMapper.toUserDto(userRepository.save(user));
    }
}
