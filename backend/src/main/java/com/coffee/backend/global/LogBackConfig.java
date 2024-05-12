package com.coffee.backend.global;

import static ch.qos.logback.classic.Level.TRACE;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.LoggerContext;
import ch.qos.logback.classic.encoder.PatternLayoutEncoder;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.ConsoleAppender;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class LogBackConfig {
    private final LoggerContext logCtx = (LoggerContext) LoggerFactory.getILoggerFactory();
    // 커스텀 영역
    private final static String pattern = "%green(%d{yyyy-MM-dd HH:mm:ss}) %cyan(%5level) %magenta(%method) %logger{35} - %yellow(%msg%n)";

    private void createLoggers(ConsoleAppender<ILoggingEvent> appender) {
//        createLogger("root", INFO, true, appender);
        createLogger("com.coffee.backend", TRACE, true, appender);  // 이제 backend 패키지 로그를 자세히 기록
        createLogger("com.coffee.backend.*.controller", TRACE, false, appender); // 컨트롤러에서 HTTP 요청과 응답 로깅
        createLogger("com.coffee.backend.*.service", TRACE, false, appender);    // 서비스 메소드 진입 로깅
    }

    @Bean
    public ConsoleAppender<ILoggingEvent> logConfig() {
        ConsoleAppender<ILoggingEvent> consoleAppender = getLogConsoleAppender();
        createLoggers(consoleAppender);
        return consoleAppender;
    }

    private void createLogger(String loggerName, Level logLevel, Boolean additive,
                              ConsoleAppender<ILoggingEvent> appender) {
        Logger logger = logCtx.getLogger(loggerName);
        logger.setAdditive(additive);
        logger.setLevel(logLevel);
        logger.addAppender(appender);
    }

    private ConsoleAppender<ILoggingEvent> getLogConsoleAppender() {
        final String appenderName = "STDOUT";
        PatternLayoutEncoder consoleLogEncoder = createLogEncoder(pattern);
        return createLogConsoleAppender(appenderName, consoleLogEncoder);
    }

    private PatternLayoutEncoder createLogEncoder(String pattern) {
        PatternLayoutEncoder encoder = new PatternLayoutEncoder();
        encoder.setContext(logCtx);
        encoder.setPattern(pattern);
        encoder.start();
        return encoder;
    }

    private ConsoleAppender<ILoggingEvent> createLogConsoleAppender(String appenderName,
                                                                    PatternLayoutEncoder consoleLogEncoder) {
        ConsoleAppender<ILoggingEvent> logConsoleAppender = new ConsoleAppender<>();
        logConsoleAppender.setName(appenderName);
        logConsoleAppender.setContext(logCtx);
        logConsoleAppender.setEncoder(consoleLogEncoder);
        logConsoleAppender.start();
        return logConsoleAppender;
    }
}
