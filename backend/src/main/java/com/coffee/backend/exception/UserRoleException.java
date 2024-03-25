package com.coffee.backend.exception;

public class UserRoleException extends RuntimeException {
    public UserRoleException() {
        super("사용자의 권한이 잘못되었습니다.");
    }

    public UserRoleException(String s) {
        super(s);
    }
}
