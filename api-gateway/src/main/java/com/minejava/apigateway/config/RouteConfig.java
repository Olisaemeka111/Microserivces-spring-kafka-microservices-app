package com.minejava.apigateway.config;

import org.springframework.cloud.gateway.filter.factory.RetryGatewayFilterFactory;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.http.HttpMethod;

@Configuration
@Profile("programmatic-routes")
public class RouteConfig {

    @Bean
    public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
        RetryGatewayFilterFactory.RetryConfig retryConfig = new RetryGatewayFilterFactory.RetryConfig();
        retryConfig.setRetries(3);
        retryConfig.setMethods(HttpMethod.GET, HttpMethod.POST);
        
        return builder.routes()
                .route("product-service", r -> r
                        .path("/api/product/**")
                        .filters(f -> f
                                .retry(c -> c.setRetries(3)
                                        .setMethods(HttpMethod.GET, HttpMethod.POST))
                                .circuitBreaker(c -> c
                                        .setName("productServiceCircuitBreaker")
                                        .setFallbackUri("forward:/fallback/product")))
                        .uri("lb://product-service"))
                .route("order-service", r -> r
                        .path("/api/order/**")
                        .filters(f -> f
                                .retry(c -> c.setRetries(3)
                                        .setMethods(HttpMethod.GET, HttpMethod.POST))
                                .circuitBreaker(c -> c
                                        .setName("orderServiceCircuitBreaker")
                                        .setFallbackUri("forward:/fallback/order")))
                        .uri("lb://order-service"))
                .route("discovery-server", r -> r
                        .path("/eureka/web")
                        .filters(f -> f.setPath("/"))
                        .uri("http://discovery-server:8761"))
                .route("discovery-server-static", r -> r
                        .path("/eureka/**")
                        .uri("http://discovery-server:8761"))
                .build();
    }
}
