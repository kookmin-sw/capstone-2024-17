package com.coffee.backend.domain.storage.repository;

import com.coffee.backend.domain.storage.entity.UploadFile;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UploadFileRepository extends JpaRepository<UploadFile, Long> {
}
