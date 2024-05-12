package com.coffee.backend.domain.company.controller;

import com.coffee.backend.domain.auth.controller.AuthenticationPrincipal;
import com.coffee.backend.domain.company.dto.CompanyDto;
import com.coffee.backend.domain.company.dto.EmailRequest;
import com.coffee.backend.domain.company.dto.EmailVerificationRequest;
import com.coffee.backend.domain.company.dto.EmailVerificationResponse;
import com.coffee.backend.domain.company.service.CompanyService;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.global.DtoLogger;
import com.coffee.backend.utils.ApiResponse;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;


@Slf4j
@RequiredArgsConstructor
@RestController
public class CompanyController {
    private final CompanyService companyService;

    /**
     * 회사 이름을 키워드로 검색하는 api
     */
    @GetMapping("/company/search")
    public ResponseEntity<ApiResponse<List<CompanyDto>>> searchCompany(@RequestParam String keyword) {
        DtoLogger.requestParam("keyword", keyword);

        List<CompanyDto> companyList = companyService.searchCompany(keyword);
        return ResponseEntity.ok(ApiResponse.success(companyList));
    }

    /**
     * 회사 인증 코드를 요청하는 api
     */
    @PostMapping("/email/verification-request")
    public ResponseEntity<ApiResponse<String>> sendMessage(@AuthenticationPrincipal User user,
                                                           @RequestBody @Valid EmailRequest dto) {
        DtoLogger.user(user);
        DtoLogger.requestBody(dto);

        companyService.sendCodeToEmail(user.getLoginId(), dto.getEmail());
        return ResponseEntity.ok(ApiResponse.success("Email sent"));
    }

    /**
     * 회사 인증 코드가 유효한지 확인하는 api
     */
    @PostMapping("/email/verification")
    public ResponseEntity<ApiResponse<EmailVerificationResponse>> verificationEmail(@AuthenticationPrincipal User user,
                                                                                    @RequestBody EmailVerificationRequest dto) {
        DtoLogger.user(user);
        DtoLogger.requestBody(dto);

        EmailVerificationResponse response = companyService.verifiedCode(
                user,
                dto.getEmail(),
                dto.getAuthCode());
        return ResponseEntity.ok(ApiResponse.success(response));
    }
}
