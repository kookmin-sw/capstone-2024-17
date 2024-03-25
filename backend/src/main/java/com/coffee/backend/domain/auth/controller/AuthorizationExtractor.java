package com.coffee.backend.domain.auth.controller;

import com.teamkrews.auth.exception.InvalidTokenException;
import com.teamkrews.global.exception.CustomException;
import com.teamkrews.global.exception.ErrorCode;
import jakarta.servlet.http.HttpServletRequest;
import java.util.Objects;
import org.springframework.http.HttpHeaders;

public class AuthorizationExtractor {

    private static final String BEARER_TYPE = "Bearer ";

    public static String extract(final HttpServletRequest request) {
        String authorizationHeader = request.getHeader(HttpHeaders.AUTHORIZATION);

        if (Objects.isNull(authorizationHeader)) {
            throw new CustomException(ErrorCode.TOKEN_EXPIRED);
        }

        validateAuthorizationFormat(authorizationHeader);
        return authorizationHeader.substring(BEARER_TYPE.length()).trim();
    }

    private static void validateAuthorizationFormat(final String authorizationHeader) {
        if (!authorizationHeader.toLowerCase().startsWith(BEARER_TYPE.toLowerCase())) {
            throw new InvalidTokenException("token 형식이 잘못 되었습니다.");
        }
    }
}
