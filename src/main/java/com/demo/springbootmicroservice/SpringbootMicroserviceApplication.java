package com.demo.springbootmicroservice;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.File;
import java.net.InetAddress;
import java.net.UnknownHostException;

@SpringBootApplication
public class SpringbootMicroserviceApplication {
    public static void main(String[] args) {
        SpringApplication.run(SpringbootMicroserviceApplication.class, args);
    }
}

@RestController
class HelloWorldController {

    @Value("${app.greeting:Default Greeting from Spring Boot!}")
    private String greeting;

    @Value("${app.api.key:DefaultAPIKey}")
    private String apiKey;

    @GetMapping(value = "/helloworld", produces = MediaType.APPLICATION_JSON_VALUE)
    public String helloWorld() {
        String hostname = System.getenv("HOSTNAME");
        String ipAddress = "Unknown";
        String environment = "unknown";

        try {
            ipAddress = InetAddress.getLocalHost().getHostAddress();
        } catch (UnknownHostException e) {
            e.printStackTrace();
        }

        // Check if running in Docker
        File dockerFile = new File("/.dockerenv");
        if (dockerFile.exists()) {
            environment = "Docker";
        }

        // Check if running in Kubernetes
        if (System.getenv("KUBERNETES_PORT") != null) {
            environment = "Kubernetes";
        }

        return String.format(
            "{\"message\": \"%s\", \"apiKey\": \"%s\", \"environment\": \"%s\", \"host\": \"%s\", \"ipAddress\": \"%s\"}",
            greeting, apiKey, environment, hostname, ipAddress
        );
    }
}