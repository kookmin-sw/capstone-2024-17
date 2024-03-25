package com.coffee.backend.domain.auth.controller;


import com.coffee.backend.domain.auth.service.JwtService;
import com.coffee.backend.domain.user.service.UserService;
import com.coffee.backend.exception.InvalidTokenException;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.core.MethodParameter;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;

@Component
@RequiredArgsConstructor
public class AuthenticationPrincipalArgumentResolver implements HandlerMethodArgumentResolver {

    private final JwtService jwtService;
    private final UserService userService;

    @Override
    public boolean supportsParameter(final MethodParameter parameter) {
        return parameter.hasParameterAnnotation(AuthenticationPrincipal.class);
    }

    @Override
    public Object resolveArgument(final MethodParameter parameter, final ModelAndViewContainer mavContainer,
                                  final NativeWebRequest webRequest, final WebDataBinderFactory binderFactory) {
        HttpServletRequest request = webRequest.getNativeRequest(HttpServletRequest.class);

        String accessToken = AuthorizationExtractor.extract(request);

        jwtService.validateToken(accessToken);
        Long userId = jwtService.extractId(accessToken).orElseThrow(
                () -> {
                    throw new InvalidTokenException("토큰에 ID가 없습니다");
                }
        );

        return userService.getByUserId(userId);
    }
}
