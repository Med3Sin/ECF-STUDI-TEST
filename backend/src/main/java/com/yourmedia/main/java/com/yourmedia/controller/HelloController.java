package com.yourmedia.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @GetMapping("/")
    public String hello() {
        return "Hello World from YourMedia!";
    }

    @GetMapping("/health")
    public String health() {
        return "Application is healthy!";
    }
} 