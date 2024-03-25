package com.coffee.backend.exception;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum ErrorCode {
    TOKEN_EXPIRED(HttpStatus.UNAUTHORIZED, "1401", "JWT 토큰이 만료되었습니다."),
    LOGIN_ID_DUPLICATED(HttpStatus.CONFLICT, "1409", "로그인 ID가 중복됩니다"),
    LOGIN_FAILED(HttpStatus.NOT_FOUND, "1404", "로그인 또는 패스워드가 일치하지 않습니다."),

    WORKSPACE_NOT_FOUND(HttpStatus.NOT_FOUND, "2404", "해당 워크 스페이스를 찾을 수 없습니다."),
    USER_WORKSPACE_NOT_FOUND(HttpStatus.NOT_FOUND, "3404", "해당 유저 워크 스페이스를 찾을 수 없습니다."),
    USER_NOT_FOUND(HttpStatus.NOT_FOUND, "4404", "해당 사용자를 찾을 수 없습니다."),
    CHAT_ROOM_NOT_FOUND(HttpStatus.NOT_FOUND, "5404", "해당 채팅방을 찾을 수 없습니다."),
    TODO_NOT_FOUND(HttpStatus.NOT_FOUND, "6404", "해당 TO-DO 항목을 찾을 수 없습니다."),
    TODO_COMPLETE_UNAUTHORIZED(HttpStatus.UNAUTHORIZED, "6401", "투두를 생성한 회원이 아닙니다"),
    CHAT_ROOM_USER_NOT_FOUND(HttpStatus.NOT_FOUND, "7404", "사용자 채팅방을 찾을 수 없습니다.");

    private final HttpStatus status;
    private final String code;
    private final String message;
}
