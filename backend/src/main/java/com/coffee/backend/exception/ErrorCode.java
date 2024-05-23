package com.coffee.backend.exception;

import com.google.api.Http;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum ErrorCode {
    TOKEN_EXPIRED(HttpStatus.UNAUTHORIZED, "1401", "JWT 토큰이 만료되었습니다."),
    LOGIN_FAILED(HttpStatus.NOT_FOUND, "1404", "로그인 또는 패스워드가 일치하지 않습니다."),
    USER_NOT_FOUND(HttpStatus.NOT_FOUND, "1404", "해당 사용자를 찾을 수 없습니다."),
    LOGIN_ID_DUPLICATED(HttpStatus.CONFLICT, "1409", "로그인 ID가 중복됩니다"),
    DELETE_USER_FAILED(HttpStatus.INTERNAL_SERVER_ERROR, "1500", "사용자 탈퇴 처리 중 오류가 발생했습니다."),

    ILLEGAL_ARGUMENT_POSITION(HttpStatus.NOT_FOUND, "2404", "잘못 된 직무를 입력했습니다."),

    REDIS_ACCESS_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "3500", "Redis 접근 중 오류가 발생했습니다."),

    REVIEW_NOT_FOUND(HttpStatus.NOT_FOUND, "4404", "해당 리뷰를 찾을 수 없습니다."),

    FCM_ACCESS_TOKEN_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "5500", "FCM 액세스 토큰을 가져오는 중 오류가 발생했습니다."),
    FCM_MESSAGE_FORMAT_ERROR(HttpStatus.BAD_REQUEST, "5400", "FCM 메시지 포맷이 잘못되었습니다."),
    FCM_SEND_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "5501", "FCM 메시지 전송 중 오류가 발생했습니다."),

    UNABLE_TO_SEND_EMAIL_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "6500", "이메일 발송 중 에러가 발생했습니다."),
    EMAIL_DUPLICATED(HttpStatus.CONFLICT, "6409", "EMAIL이 중복됩니다"),
    NO_SUCH_ALGORITHM(HttpStatus.INTERNAL_SERVER_ERROR, "6501", "인증코드 생성 중 오류가 발생했습니다."),
    COMPANY_REQUEST_NOT_FOUND(HttpStatus.NOT_FOUND, "6404", "해당 COMPANY_REQUEST를 찾을 수 없습니다."),

    REQUEST_DUPLICATED(HttpStatus.CONFLICT, "7409", "요청이 중복됩니다."),
    REQUEST_SAME_USER(HttpStatus.CONFLICT, "7409", "본인에게 요청을 보낼 수 없습니다."),
    REQUEST_NOT_FOUND(HttpStatus.NOT_FOUND, "7404", "해당 요청 정보를 찾을 수 없습니다."),
    REQUEST_ALREADY_ACCEPTED(HttpStatus.CONFLICT, "7409", "이미 수락한 요청입니다."),
    REQUEST_NOT_ACCEPTED(HttpStatus.NOT_FOUND, "7404", "해당 요청은 수락되지 않았습니다."),
    REQUEST_DECLINED(HttpStatus.CONFLICT, "7409", "이미 거절된 요청입니다."),
    REQUEST_CANCELED(HttpStatus.CONFLICT, "7409", "이미 취소된 요청입니다."),
    REQUEST_FINISHED(HttpStatus.CONFLICT, "7409", "이미 종료된 요청입니다."),
    REQUEST_EXPIRED(HttpStatus.UNAUTHORIZED, "7401", "요청이 만료되었습니다."),

    COMPANY_NOT_FOUND(HttpStatus.NOT_FOUND, "8404", "해당 COMPANY를 찾을 수 없습니다."),

    VALUE_ERROR(HttpStatus.BAD_REQUEST, "9400", "잘못된 값이 입력되었습니다."),
    MAPPING_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "9500", "매핑 중 오류가 발생했습니다.");

    private final HttpStatus status;
    private final String code;
    private final String message;
}
