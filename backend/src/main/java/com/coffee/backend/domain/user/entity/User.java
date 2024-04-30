package com.coffee.backend.domain.user.entity;

import com.coffee.backend.domain.company.entity.Company;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "user")
@Setter
@Getter
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long userId;
    private Long kakaoId;
    private String loginId;
    private String password;
    private String nickname;
    private String email;
    private String phone;
    private String userUUID;
    private String deviceToken;
    @ManyToOne
    @JoinColumn(name = "company_id")
    private Company companyId;
}