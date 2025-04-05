package com.minejava.apigateway.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/fallback")
public class FallbackController {

    @GetMapping("/product")
    public Mono<ResponseEntity<String>> productServiceFallback() {
        return Mono.just(ResponseEntity.serviceUnavailable()
                .body("Product Service is currently unavailable. Please try again later."));
    }

    @GetMapping("/order")
    public Mono<ResponseEntity<String>> orderServiceFallback() {
        return Mono.just(ResponseEntity.serviceUnavailable()
                .body("Order Service is currently unavailable. Please try again later."));
    }

    @GetMapping("/default")
    public Mono<ResponseEntity<String>> defaultFallback() {
        return Mono.just(ResponseEntity.serviceUnavailable()
                .body("The requested service is currently unavailable. Please try again later."));
    }
}
