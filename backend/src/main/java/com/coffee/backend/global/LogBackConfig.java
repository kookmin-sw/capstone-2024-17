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
    private final static String pattern = "%green(%d{yyyy-MM-dd HH:mm:ss, Asia/Seoul}) %cyan(%5level) %magenta(%method) %replace(%logger){'com.coffee.', ''} - %blue(%msg%n)";
//    private final static String pattern = "%green(%d{yyyy-MM-dd HH:mm:ss}) %cyan(%5level) %magenta(%method) %logger{50} - %blue(%msg%n)";


    private void createLoggers(ConsoleAppender<ILoggingEvent> appender) {
        createLogger("com.coffee.backend", TRACE, false, appender);  // backend 패키지 TRACE 레벨로 로깅
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
        logger.setAdditive(false); //로그 이벤트가 루트 로거까지 전파되지 않도록
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
