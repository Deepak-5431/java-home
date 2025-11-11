package com.commander.industryhub.server;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class IndustryChatApplication {

    public static void main(String[] args) {
        SpringApplication.run(IndustryChatApplication.class, args);
    }

}
