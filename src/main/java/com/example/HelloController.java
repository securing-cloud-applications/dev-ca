package com.example;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.Enumeration;

@RestController
public class HelloController {

    @GetMapping("/")
    public String hello(HttpServletRequest request) {
        boolean isSecure = request.isSecure();
        StringBuilder headers = new StringBuilder();
        Enumeration<String> headerNames = request.getHeaderNames();

        while (headerNames.hasMoreElements()) {
            String headerName = headerNames.nextElement();
            String headerValue = request.getHeader(headerName);
            headers.append(headerName).append(": ").append(headerValue).append("\n");
        }

        return "Hello time is: " + LocalDateTime.now() + "\n" +
                "Connection is secure: " + isSecure + "\n" +
                "HTTP Headers:\n" + headers.toString();
    }
}