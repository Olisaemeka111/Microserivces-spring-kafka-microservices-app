package com.minejava.orderservice;

import com.minejava.orderservice.config.TestConfig;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT, 
	properties = {"spring.config.name=application-test"})
@Import(TestConfig.class)
class OrderServiceApplicationTests {

	@Test
	void contextLoads() {
		// Simple test to verify context loads
	}

}
