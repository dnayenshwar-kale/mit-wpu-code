package com.example.demo.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("OK");
    }

    @GetMapping("/ready")
    public ResponseEntity<String> ready() {
        // Add custom readiness checks here (database connectivity, etc.)
        return ResponseEntity.ok("READY");
    }

    @GetMapping("/live")
    public ResponseEntity<String> live() {
        // Basic liveness check
        return ResponseEntity.ok("LIVE");
    }
}