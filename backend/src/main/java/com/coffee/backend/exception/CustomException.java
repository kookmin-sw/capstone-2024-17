package com.coffee.backend.exception;

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