package com.coffee.backend.domain.auth.service;

import com.coffee.backend.exception.CustomException;
import com.coffee.backend.exception.ErrorCode;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class JwtService {
    @Value("${jwt.secretKey}")
    private String secretKey;

    @Value("${jwt.access.expiration}")
    private Long accessTokenExpirationPeriod;

    @Value("${jwt.refresh.expiration}")
    private Long refreshTokenExpirationPeriod;

    private SecretKey key;

    private static final String ACCESS_TOKEN_SUBJECT = "AccessToken";
    private static final String REFRESH_TOKEN_SUBJECT = "RefreshToken";
    private static final String ID_CLAIM = "id";

    @PostConstruct
    void init() {
        key = Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8));
    }

    public String createAccessToken(final Long userId) {
        Date now = new Date();
        Map<String, Object> userClaim = new HashMap<>();
        userClaim.put(ID_CLAIM, userId);

        return Jwts.builder()
                .setSubject(ACCESS_TOKEN_SUBJECT)
                .setExpiration(new Date(now.getTime() + accessTokenExpirationPeriod))
                .addClaims(userClaim)
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

    public String createRefreshToken() {
        Date now = new Date();

        return Jwts.builder()
                .setSubject(REFRESH_TOKEN_SUBJECT)
                .setExpiration(new Date(now.getTime() + refreshTokenExpirationPeriod))
                .signWith(key, SignatureAlgorithm.HS512)
                .compact();
    }

    public boolean validateToken(String token) {
        try {
            Jws<Claims> claims = Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token);

            claims.getBody()
                    .getExpiration()
                    .before(new Date());

            return true;
        } catch (Exception e) {
            log.info("토큰 인증 실패");
            throw new CustomException(ErrorCode.TOKEN_EXPIRED);
        }
    }

    public Optional<Long> extractId(String accessToken) {
        validateToken(accessToken);

        try {
            Claims claims = Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(accessToken)
                    .getBody();

            Long id = claims.get(ID_CLAIM, Long.class);
            return id != null ? Optional.of(id) : Optional.empty();
        } catch (Exception e) {
            throw new IllegalArgumentException("유효하지 엑세스 토큰입니다.");
        }
    }
}
