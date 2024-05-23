package com.coffee.backend.domain.company.service;

import com.coffee.backend.domain.company.dto.CompanyDto;
import com.coffee.backend.domain.company.dto.EmailVerificationResponse;
import com.coffee.backend.domain.company.entity.Company;
import com.coffee.backend.domain.company.repository.CompanyRepository;
import com.coffee.backend.domain.mail.service.MailService;
import com.coffee.backend.domain.storage.service.StorageService;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.domain.user.service.UserService;
import com.coffee.backend.exception.CustomException;
import com.coffee.backend.exception.ErrorCode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.transaction.Transactional;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Duration;
import java.util.List;
import java.util.Random;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@Transactional
@RequiredArgsConstructor
public class CompanyService {
    private final UserService userService;
    private final CompanyRepository companyRepository;
    private final StorageService storageService;
    @Value("${spring.mail.auth-code-expiration-millis}")
    private long authCodeExpirationMillis;
    private static final String AUTH_CODE_PREFIX = "EmailAuthCode:";
    private final MailService mailService;
    private final RedisTemplate<String, String> redisTemplate;
    private final ObjectMapper objectMapper;

    public Company findCompanyByDomain(String domain) {
        log.trace("findCompanyByDomain()");
        return companyRepository.findByDomain(domain).orElseThrow(() -> {
            log.info("domain {} not found", domain);
            throw new CustomException(ErrorCode.COMPANY_NOT_FOUND);
        });
    }


    public void sendCodeToEmail(String loginId, String toEmail) {
        log.trace("sendCodeToEmail()");
        userService.checkDuplicatedEmail(loginId, toEmail);
        String domain = toEmail.split("@")[1];
        this.findCompanyByDomain(domain);

        String title = "커리어 한잔 이메일 인증 코드";
        String authCode = this.createCode();
        String content = "<h1>회원님의 커리어 한잔 이메일 인증 코드</h1>" +
                loginId + " 님, 안녕하세요." +
                "커리어 한잔을 사용해주셔서 감사합니다." +
                "<br><br>" +
                "<div>" +
                "인증 번호는 " + "<b>" + authCode + "</b>" + " 입니다." +
                "</div>" +
                "<br>";
        mailService.sendEmail(toEmail, title, content);
        // 이메일 인증 요청 시 인증 번호 Redis에 저장 ( key = "AuthCode " + Email / value = AuthCode )
        redisTemplate.opsForValue().set(AUTH_CODE_PREFIX + toEmail, authCode,
                Duration.ofMillis(this.authCodeExpirationMillis));
    }


    private String createCode() {
        log.trace("createCode()");
        int lenth = 6;
        try {
            Random random = SecureRandom.getInstanceStrong();
            StringBuilder builder = new StringBuilder();
            for (int i = 0; i < lenth; i++) {
                builder.append(random.nextInt(10));
            }
            return builder.toString();
        } catch (NoSuchAlgorithmException e) {
            log.debug("CompanyService.createCode() exception occur");
            throw new CustomException(ErrorCode.NO_SUCH_ALGORITHM);
        }
    }

    public EmailVerificationResponse verifiedCode(User user, String email, String authCode) {
        log.trace("verifiedCode()");
        userService.checkDuplicatedEmail(user.getLoginId(), email);

        String redisAuthCode = redisTemplate.opsForValue().get(AUTH_CODE_PREFIX + email);
        boolean authResult = authCode.equals(redisAuthCode); // true : 인증 성공
        if (authResult) {
            redisTemplate.delete(AUTH_CODE_PREFIX + email);
            userService.setUserEmail(user, email); // 인증 성공 시 이메일 변경
            String domain = email.split("@")[1];
            Company company = this.findCompanyByDomain(domain);
            userService.setUserCompany(user, company); // 인증 성공 시 회사 연결
        }
        return new EmailVerificationResponse(authResult);
    }

    public List<CompanyDto> searchCompany(String searchKeyword) {
        log.trace("searchCompany()");
        List<Company> companyList = companyRepository.findAllByNameContaining(searchKeyword);
        return companyList.stream().map(company -> {
            CompanyDto companyDto = new CompanyDto();
            companyDto.setName(company.getName());
            companyDto.setDomain(company.getDomain());
            companyDto.setLogoUrl(storageService.getFileUrl(company.getLogo().getStoredFilename()));
            return companyDto;
        }).toList();
    }
}
