package com.minejava.apigateway.health;

import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.ReactiveHealthIndicator;
import org.springframework.cloud.client.discovery.DiscoveryClient;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

@Component
public class GatewayHealthIndicator implements ReactiveHealthIndicator {

    private final DiscoveryClient discoveryClient;

    public GatewayHealthIndicator(DiscoveryClient discoveryClient) {
        this.discoveryClient = discoveryClient;
    }

    @Override
    public Mono<Health> health() {
        return checkDiscoveryServiceHealth()
                .onErrorResume(ex -> Mono.just(Health.down(ex).build()));
    }

    private Mono<Health> checkDiscoveryServiceHealth() {
        return Mono.fromCallable(() -> {
            // Check if discovery service is available
            boolean discoveryServiceAvailable = !discoveryClient.getServices().isEmpty();
            
            if (discoveryServiceAvailable) {
                return Health.up()
                        .withDetail("discoveryService", "available")
                        .withDetail("registeredServices", discoveryClient.getServices())
                        .build();
            } else {
                return Health.down()
                        .withDetail("discoveryService", "unavailable")
                        .withDetail("reason", "No services registered with discovery server")
                        .build();
            }
        });
    }
}
