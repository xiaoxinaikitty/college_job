package org.example.systemservice.security;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;

@Component
public class JwtTokenProvider {

    private final SecretKey secretKey;
    private final long expireSeconds;

    public JwtTokenProvider(
            @Value("${auth.jwt-secret}") String secret,
            @Value("${auth.jwt-expire-seconds:7200}") long expireSeconds
    ) {
        this.secretKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.expireSeconds = expireSeconds;
    }

    public String createToken(Long userId, Integer userType) {
        Instant now = Instant.now();
        Instant expireAt = now.plusSeconds(expireSeconds);
        return Jwts.builder()
                .subject(String.valueOf(userId))
                .claim("userType", userType)
                .issuedAt(Date.from(now))
                .expiration(Date.from(expireAt))
                .signWith(secretKey, SignatureAlgorithm.HS256)
                .compact();
    }

    public long getExpireSeconds() {
        return expireSeconds;
    }
}
