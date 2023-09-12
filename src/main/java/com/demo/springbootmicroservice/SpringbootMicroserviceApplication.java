package com.demo.springbootmicroservice;

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
            "{\"message\": \"Hello, World!\", \"environment\": \"%s\", \"host\": \"%s\", \"ipAddress\": \"%s\"}",
            environment, hostname, ipAddress
        );
    }
}