package com.coffee.backend.domain.Storage.Repository;

import com.coffee.backend.domain.Storage.entity.UploadFile;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UploadFileRepository extends JpaRepository<UploadFile, Long> {
}
