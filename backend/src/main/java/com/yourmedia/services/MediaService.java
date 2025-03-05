package com.yourmedia.services;

import com.yourmedia.models.Media;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.multipart.MultipartFile;
import java.time.LocalDateTime;

@Service
public class MediaService {
    
    @Autowired
    private S3Service s3Service;

    public Media uploadMedia(MultipartFile file, String type) {
        Media media = new Media();
        media.setFileName(file.getOriginalFilename());
        media.setFileType(type);
        media.setFileSize(file.getSize());
        media.setUploadDate(LocalDateTime.now());
        media.setStatus("PENDING");

        // Upload to S3
        String fileUrl = s3Service.uploadFile(file);
        media.setFileUrl(fileUrl);
        media.setStatus("COMPLETED");

        return media;
    }

    public void deleteMedia(Long id) {
        // Delete from S3 and database
    }

    public Media getMedia(Long id) {
        // Retrieve from database
        return null;
    }
} 