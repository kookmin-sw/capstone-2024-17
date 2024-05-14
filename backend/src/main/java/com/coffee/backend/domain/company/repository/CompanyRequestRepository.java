package com.coffee.backend.domain.company.repository;

import com.coffee.backend.domain.company.entity.CompanyRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CompanyRequestRepository extends JpaRepository<CompanyRequest, Long> {
    Page<CompanyRequest> findAll(Pageable pageable);
}
