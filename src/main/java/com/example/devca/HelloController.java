package com.example.devca;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.time.LocalDateTime;

@RestController
public class HelloController {

    @GetMapping("/")
    public String hello() {
        return "Hello time is: " + LocalDateTime.now();
    }
}
