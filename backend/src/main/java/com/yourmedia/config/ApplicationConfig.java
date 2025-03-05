package com.yourmedia.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Bean;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import org.springframework.beans.factory.annotation.Value;

@Configuration
public class ApplicationConfig {

    @Value("${aws.region}")
    private String awsRegion;

    @Bean
    public AmazonS3 s3Client() {
        return AmazonS3ClientBuilder.standard()
                .withRegion(awsRegion)
                .build();
    }
} 