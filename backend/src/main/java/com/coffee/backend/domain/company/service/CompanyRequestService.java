package com.coffee.backend.domain.company.service;

import com.coffee.backend.domain.company.dto.CompanyRequestDto;
import com.coffee.backend.domain.company.dto.CompanyRequestRequest;
import com.coffee.backend.domain.company.entity.CompanyRequest;
import com.coffee.backend.domain.company.repository.CompanyRequestRepository;
import com.coffee.backend.domain.user.entity.User;
import com.coffee.backend.exception.CustomException;
import com.coffee.backend.exception.ErrorCode;
import com.coffee.backend.utils.CustomMapper;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@Transactional
@RequiredArgsConstructor
public class CompanyRequestService {

    private final CompanyRequestRepository companyRequestRepository;
    private final CustomMapper customMapper;
    private final int PAGE_SIZE = 10;

    public CompanyRequestRequest saveRequest(User user, CompanyRequestRequest dto) {
        companyRequestRepository.save(CompanyRequest.builder()
                .name(dto.getName())
                .domain(dto.getDomain())
                .bno(dto.getBno())
                .user(user).build()
        );
        return dto;
    }

    public void deleteRequest(Long companyRequestId) {
        companyRequestRepository.delete(companyRequestRepository.findById(companyRequestId).orElseThrow(() -> {
                    log.info("id = {} 인 company_request 가 존재하지 않습니다", companyRequestId);
                    return new CustomException(ErrorCode.COMPANY_REQUEST_NOT_FOUND);
                }
        ));
    }

    public Page<CompanyRequestDto> findAllRequests(int page) {
        Pageable pageRequest = PageRequest.of(page, PAGE_SIZE);
        return companyRequestRepository.findAll(pageRequest)
                .map(cr -> CompanyRequestDto.builder().id(cr.getCompanyRequestId())
                        .name(cr.getName())
                        .domain(cr.getDomain())
                        .bno(cr.getBno())
                        .user(customMapper.toUserDto(cr.getUser())).build());
    }
}
