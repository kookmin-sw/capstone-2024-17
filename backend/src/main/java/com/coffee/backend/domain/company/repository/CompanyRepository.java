package com.coffee.backend.domain.company.repository;

import com.coffee.backend.domain.company.entity.Company;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CompanyRepository extends JpaRepository<Company, Long> {
    List<Company> findAllByNameContaining(String companyName);

    Optional<Company> findByDomain(String domain);
}
