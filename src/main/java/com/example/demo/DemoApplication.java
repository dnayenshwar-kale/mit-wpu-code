package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }

    @org.springframework.context.annotation.Bean
    public org.springframework.boot.CommandLineRunner dataLoader(com.example.demo.repository.PersonRepository repo) {
        return args -> {
            repo.save(new com.example.demo.model.Person("Alice"));
            repo.save(new com.example.demo.model.Person("Bob"));
        };
    }
}
