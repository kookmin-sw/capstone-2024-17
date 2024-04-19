package com.coffee.backend.domain.storage.service;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.coffee.backend.domain.storage.repository.UploadFileRepository;
import com.coffee.backend.domain.storage.entity.UploadFile;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

@Slf4j
@Component
@RequiredArgsConstructor
public class StorageService {

    @Value("${cloud.aws.s3.bucket}")
    private String bucket;

    private final AmazonS3 s3Client;
    private final UploadFileRepository uploadFileRepository;

    // MultipartFile 을 S3에 업로드하고 UploadFile 레코드 save 한 뒤 반환
    public UploadFile uploadFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return null; // TODO exception handling
        }
        File fileObj = convertMultiPartFileToFile(file);
        String originalFilename = file.getOriginalFilename();
        String extension = getFileExtension(originalFilename);
        String fileName = UUID.randomUUID() + originalFilename + "." + extension;

        log.info("uploadFile fileName: {}", fileName);
        s3Client.putObject(new PutObjectRequest(bucket, fileName, fileObj));
        fileObj.delete();

        UploadFile uploadFile = UploadFile.builder()
                .originFilename(originalFilename)
                .storedFilename(fileName)
                .build();
        uploadFileRepository.save(uploadFile);
        return uploadFile;
    }

    public String getFileUrl(String fileName) {
        return s3Client.getUrl(bucket, fileName).toString();
    }

    public String deleteFile(String fileName) {
        s3Client.deleteObject(bucket, fileName);
        return fileName + " removed ...";
    }


    private File convertMultiPartFileToFile(MultipartFile file) {
        File convertedFile = new File(file.getOriginalFilename());
        try (FileOutputStream fos = new FileOutputStream(convertedFile)) {
            fos.write(file.getBytes());
        } catch (IOException e) {
            log.error("Error converting multipartFile to file", e);
        }
        return convertedFile;
    }

    private static String getFileExtension(String originalFileName) {
        return originalFileName.substring(originalFileName.lastIndexOf(".") + 1);
    }

}

