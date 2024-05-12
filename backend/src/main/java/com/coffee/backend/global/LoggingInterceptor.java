package com.coffee.backend.global;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class LoggingInterceptor implements HandlerInterceptor {
    private static final Logger logger = LoggerFactory.getLogger(LoggingInterceptor.class);

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws IOException {
        // Endpoint URL 로깅
        logger.trace("---------------------------------------------");
        logger.trace("URL : {}", request.getRequestURI());

        // User Authentication 로깅
        if (request.getHeader("authorization") != null) {
            logger.trace("Authorization Token : {User}");
        }
        return true;
    }
}
