package com.example.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class HelloController {

    private final com.example.demo.repository.PersonRepository personRepository;

    public HelloController(com.example.demo.repository.PersonRepository personRepository) {
        this.personRepository = personRepository;
    }

    @GetMapping("/hello")
    public String sayHello() {
        return "Hello, world!";
    }

    @GetMapping("/persons")
    public java.util.List<com.example.demo.model.Person> listPersons() {
        return personRepository.findAll();
    }

    @PostMapping("/persons")
    public com.example.demo.model.Person addPerson(@RequestBody com.example.demo.model.Person person) {
        return personRepository.save(person);
    }
}

