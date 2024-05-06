package com.coffee.backend.domain.company.entity;

import com.coffee.backend.domain.user.entity.User;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import lombok.Builder;
import lombok.Getter;

@Entity
@Getter
@Builder
public class CompanyRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long CompanyRequestId;
    @ManyToOne // 유저 한 명이 여러 회사 request 가능
    @JoinColumn(name = "user_id")
    private User user;
    private String name;
    private String domain;
    private String bno;
}
