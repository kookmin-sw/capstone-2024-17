package com.coffee.backend.domain.user.service;

import com.coffee.backend.domain.cafe.dto.CafeUserDto;
import com.coffee.backend.domain.company.entity.Company;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.domain.user.repository.UserRepository;
import com.coffee.backend.exception.CustomException;
import com.coffee.backend.exception.ErrorCode;
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

    public User getByUserId(Long userId) {
        Optional<User> user = userRepository.findById(userId);

        return user.orElseThrow(() -> {
            log.info("id = {} 인 사용자가 존재하지 않습니다", userId);
            return new CustomException(ErrorCode.USER_NOT_FOUND);
        });
    }

    // 특정 카페에 접속한 사용자 list에 보일 User 데이터 조회
    public CafeUserDto getCafeUserInfoByLoginId(String loginId) {
        return userRepository.findByLoginId(loginId)
                .map(user -> new CafeUserDto(user.getLoginId(), user.getNickname(),
                        user.getEmail())) // TODO : email을 introduction으로 교체
                .orElseThrow(() -> {
                    log.info("id = {} 인 사용자가 존재하지 않습니다", loginId);
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

    public void setUserCompany(User user, Company company) {
        user.setCompany(company);
        userRepository.save(user);
    }
}
