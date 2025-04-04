package com.minejava.orderservice.config;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Bean;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.web.reactive.function.client.WebClient;

/**
 * Test configuration to mock external dependencies for unit tests
 */
@TestConfiguration
public class TestConfig {

    @MockBean
    private KafkaTemplate<String, Object> kafkaTemplate;

    @Bean
    public WebClient.Builder webClientBuilder() {
        return WebClient.builder();
    }
}
