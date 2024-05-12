package com.coffee.backend.global;

import java.lang.reflect.Field;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

// Dto 객체의 필드와 값을 로깅 (for request logging)
public class DtoLogger {
    private static final Logger logger = LoggerFactory.getLogger(DtoLogger.class);

    public static void logDto(Object dto) {
        Class<?> clazz = dto.getClass();
        Field[] fields = clazz.getDeclaredFields(); // 모든 필드를 가져옴
        StringBuilder logMessage = new StringBuilder();

        // log 커스텀
        String dtoName = dto.getClass().getSimpleName();
        logMessage.append(dtoName).append(" {");
        for (Field field : fields) {
            field.setAccessible(true); // private 필드 접근 허용

            // log
            String key = field.getName();
            String valueType = field.getType().getSimpleName();
            logMessage.append(key).append(": ").append(valueType).append(", ");
        }

        if (logMessage.length() > 2) {
            logMessage.setLength(logMessage.length() - 2); // 마지막 콤마 제거
        }
        logMessage.append("}");
        logger.trace(logMessage.toString());
    }
}
