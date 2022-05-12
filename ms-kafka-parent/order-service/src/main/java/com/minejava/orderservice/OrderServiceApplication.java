package com.minejava.orderservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;


@SpringBootApplication
@EnableEurekaClient
public class OrderServiceApplication {
	// checking for initial runs for the new account
	public static void main(String[] args) {
		SpringApplication.run(OrderServiceApplication.class, args);
	}

}
