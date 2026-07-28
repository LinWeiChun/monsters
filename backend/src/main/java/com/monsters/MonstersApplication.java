package com.monsters;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class MonstersApplication {

    public static void main(String[] args) {
        SpringApplication.run(MonstersApplication.class, args);
    }
}
