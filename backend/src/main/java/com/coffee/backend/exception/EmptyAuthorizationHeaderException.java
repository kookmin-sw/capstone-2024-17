package com.coffee.backend.exception;

public class EmptyAuthorizationHeaderException extends RuntimeException {
    public EmptyAuthorizationHeaderException() {
        super("Authorization Header가 비어있습니다");
    }
}
