package com.coffee.backend.domain.company.controller;

import com.coffee.backend.domain.auth.controller.AuthenticationPrincipal;
import com.coffee.backend.domain.company.dto.CompanyRequestRequest;
import com.coffee.backend.domain.company.entity.CompanyRequest;
import com.coffee.backend.domain.company.service.CompanyRequestService;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.utils.ApiResponse;
import io.swagger.v3.oas.annotations.Hidden;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequiredArgsConstructor
public class CompanyRequestController {
    private final CompanyRequestService companyRequestService;

    @PostMapping("/company/request")
    public ResponseEntity<ApiResponse<CompanyRequest>> createCompanyRequest(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody CompanyRequestRequest dto) {
        return ResponseEntity.ok(ApiResponse.success(companyRequestService.saveRequest(user, dto)));
    }

    @Hidden
    @DeleteMapping("/company/request")
    public ResponseEntity<ApiResponse<String>> deleteCompanyRequest(@RequestParam Long companyRequestId) {
        companyRequestService.deleteRequest(companyRequestId);
        return ResponseEntity.ok(ApiResponse.success("company request deleted"));
    }
}
