package com.coffee.backend.domain.company.entity;

import com.coffee.backend.domain.user.entity.User;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToOne;
import lombok.Builder;
import lombok.Getter;

@Entity
@Getter
@Builder
public class CompanyRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long CompanyRequestId;
    @OneToOne
    private User user;
    private String name;
    private String domain;
    private String bno;
}
