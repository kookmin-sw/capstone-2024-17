package com.coffee.backend.domain.company.repository;

import com.coffee.backend.domain.company.entity.CompanyRequest;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CompanyRequestRepository extends JpaRepository<CompanyRequest, Long> {
}
