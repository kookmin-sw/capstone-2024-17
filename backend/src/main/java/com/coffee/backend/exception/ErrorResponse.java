package com.coffee.backend.exception;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;
import org.springframework.http.HttpStatus;

@Getter
@ToString
@NoArgsConstructor
public class ErrorResponse<T> {

    private boolean success;
    private String code;
    private String message;
    private T data;

    @Builder
    public ErrorResponse(HttpStatus status, String code, String message) {
        this.success = false;
        this.code = code;
        this.message = message;
        this.data = null;
    }
}