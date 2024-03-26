package com.coffee.backend.exception;

public class LoginIdAlreadyExistsException extends RuntimeException {
    public LoginIdAlreadyExistsException(String message) {
        super(message);
    }
}
