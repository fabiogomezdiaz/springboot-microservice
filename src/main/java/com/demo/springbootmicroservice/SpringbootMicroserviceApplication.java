package com.demo.springbootmicroservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
public class SpringbootMicroserviceApplication {

    public static void main(String[] args) {
        SpringApplication.run(SpringbootMicroserviceApplication.class, args);
    }
}

@RestController
class HelloWorldController {

    @GetMapping("/helloworld")
    public String helloWorld() {
        return "Hello, World!";
    }
}