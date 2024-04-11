package com.coffee.backend.utils;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public class ApiResponse<T> {
    private final boolean success;
    private final String statusCode;
    private final String message;
    private final T data;

    public static class Builder<T> {
        private boolean success;
        private String statusCode;
        private String message;
        private T data;

        public Builder<T> success(boolean success) {
            this.success = success;
            return this;
        }

        public Builder<T> statusCode(String statusCode) {
            this.statusCode = statusCode;
            return this;
        }

        public Builder<T> message(String message) {
            this.message = message;
            return this;
        }

        public Builder<T> data(T data) {
            this.data = data;
            return this;
        }

        public ApiResponse<T> build() {
            return new ApiResponse<>(this);
        }
    }

    private ApiResponse(Builder<T> builder) {
        this.success = builder.success;
        this.statusCode = builder.statusCode;
        this.message = builder.message;
        this.data = builder.data;
    }

    // 성공 응답 생성
    public static <T> ApiResponse<T> success(T data) {
        return new Builder<T>()
                .success(true)
                .statusCode(String.valueOf(HttpStatus.OK.value()))
                .message("Success")
                .data(data)
                .build();
    }

}
