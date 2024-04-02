package com.coffee.backend.domain.auth.exception;

public class LoginIdAlreadyExistsException extends RuntimeException {
    public LoginIdAlreadyExistsException(String message) {
        super(message);
    }
}
