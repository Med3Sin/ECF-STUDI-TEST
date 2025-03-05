package com.yourmedia.services;

import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.multipart.MultipartFile;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.PutObjectRequest;
import java.util.UUID;

@Service
public class S3Service {
    
    @Autowired
    private AmazonS3 s3Client;

    private final String bucketName = "yourmedia-storage";

    public String uploadFile(MultipartFile file) {
        String fileName = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
        
        try {
            PutObjectRequest request = new PutObjectRequest(bucketName, fileName, file.getInputStream(), file.getSize());
            s3Client.putObject(request);
            return s3Client.getUrl(bucketName, fileName).toString();
        } catch (Exception e) {
            throw new RuntimeException("Failed to upload file to S3", e);
        }
    }

    public void deleteFile(String fileUrl) {
        String fileName = fileUrl.substring(fileUrl.lastIndexOf("/") + 1);
        s3Client.deleteObject(bucketName, fileName);
    }
} 