package com.example.demo.config;

import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        OpenAPI oas = new OpenAPI()
            .info(new Info().title("Demo API").version("1.0").description("Demo project API documentation"));
        // Use a relative server URL so Swagger UI uses the current host/proxy (avoids localhost in 'servers')
        oas.setServers(java.util.List.of(new Server().url("/")));
        return oas;
    }
}
