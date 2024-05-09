package com.coffee.backend.domain.company.entity;

import com.coffee.backend.domain.storage.entity.UploadFile;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Company {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "company_id")
    private Long companyId;
    private String name;
    private String domain;
    private String bno;
    @ManyToOne
    @JoinColumn(name = "logo_file_id")
    private UploadFile logo;

    // TODO : flyaway 설정 이후 default company로 설정 (company DB에 무소속 회사 정보가 있어야 함)
//    public static Company getDefault() {
//        return Company.builder().companyId(0L).name("무소속").domain("coffee.com").bno("0").build();
//    }
}
