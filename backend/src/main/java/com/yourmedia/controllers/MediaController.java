package com.yourmedia.controllers;

import org.springframework.web.bind.annotation.*;
import org.springframework.beans.factory.annotation.Autowired;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Counter;

@RestController
@RequestMapping("/api/media")
public class MediaController {
    private final MeterRegistry registry;
    private final Counter imageUploads;
    private final Counter videoUploads;
    private final Counter compressionSuccess;

    @Autowired
    public MediaController(MeterRegistry registry) {
        this.registry = registry;
        this.imageUploads = Counter.builder("media.uploads.total")
            .tag("type", "image")
            .register(registry);
        this.videoUploads = Counter.builder("media.uploads.total")
            .tag("type", "video")
            .register(registry);
        this.compressionSuccess = Counter.builder("media.compression.success")
            .tag("type", "image")
            .register(registry);
    }

    @PostMapping("/upload")
    public void uploadMedia(@RequestParam String type) {
        if ("image".equals(type)) {
            imageUploads.increment();
        } else if ("video".equals(type)) {
            videoUploads.increment();
        }
    }

    @GetMapping("/health")
    public String healthCheck() {
        return "healthy";
    }
} 