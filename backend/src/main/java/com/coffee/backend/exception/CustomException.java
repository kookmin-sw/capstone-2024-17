package com.coffee.backend.exception;

import com.coffee.backend.domain.auth.exception.ErrorCode;

public class CustomException extends RuntimeException {

    private final ErrorCode code;

    public CustomException(ErrorCode code) {
        super(code.getMessage());
        this.code = code;
    }

    @Override
    public String getMessage() {
        return super.getMessage();
    }

    public ErrorCode getCode() {
        return this.code;
    }
}