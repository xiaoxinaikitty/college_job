package org.example.systemservice.service;

import org.example.systemservice.common.ErrorCode;
import org.example.systemservice.dto.AuthResponse;
import org.example.systemservice.dto.LoginRequest;
import org.example.systemservice.dto.RegisterEnterpriseRequest;
import org.example.systemservice.dto.RegisterStudentRequest;
import org.example.systemservice.entity.Enterprise;
import org.example.systemservice.entity.User;
import org.example.systemservice.exception.BizException;
import org.example.systemservice.repository.EnterpriseRepository;
import org.example.systemservice.repository.UserRepository;
import org.example.systemservice.security.JwtTokenProvider;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final EnterpriseRepository enterpriseRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    public AuthService(
            UserRepository userRepository,
            EnterpriseRepository enterpriseRepository,
            PasswordEncoder passwordEncoder,
            JwtTokenProvider jwtTokenProvider
    ) {
        this.userRepository = userRepository;
        this.enterpriseRepository = enterpriseRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    @Transactional
    public AuthResponse registerStudent(RegisterStudentRequest request) {
        validatePhoneNotExists(request.getPhone());

        User user = new User();
        user.setUserType(1);
        user.setAccountStatus(1);
        user.setPhone(request.getPhone());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setNickname(request.getNickname());
        User saved = userRepository.save(user);

        return buildAuthResponse(saved, null);
    }

    @Transactional
    public AuthResponse registerEnterprise(RegisterEnterpriseRequest request) {
        validatePhoneNotExists(request.getPhone());

        User user = new User();
        user.setUserType(2);
        user.setAccountStatus(1);
        user.setPhone(request.getPhone());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setNickname(request.getEnterpriseName());
        User savedUser = userRepository.save(user);

        Enterprise enterprise = new Enterprise();
        enterprise.setOwnerUserId(savedUser.getId());
        enterprise.setEnterpriseName(request.getEnterpriseName());
        enterprise.setUnifiedCreditCode(request.getUnifiedCreditCode());
        enterprise.setCertifiedStatus(1);
        enterprise.setEnterpriseStatus(1);
        Enterprise savedEnterprise = enterpriseRepository.save(enterprise);

        return buildAuthResponse(savedUser, savedEnterprise.getId());
    }

    @Transactional
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByPhoneAndIsDeleted(request.getPhone(), 0)
                .orElseThrow(() -> new BizException(ErrorCode.USER_NOT_FOUND, "账号不存在"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new BizException(ErrorCode.PASSWORD_ERROR, "密码错误");
        }
        if (user.getAccountStatus() == null || user.getAccountStatus() != 1) {
            throw new BizException(ErrorCode.ACCOUNT_DISABLED, "账号不可用");
        }
        if (request.getUserType() != null && !request.getUserType().equals(user.getUserType())) {
            throw new BizException(ErrorCode.USER_TYPE_MISMATCH, "账号角色不匹配");
        }

        user.setLastLoginAt(LocalDateTime.now());
        userRepository.save(user);

        Long enterpriseId = null;
        if (user.getUserType() == 2) {
            enterpriseId = enterpriseRepository.findByOwnerUserId(user.getId())
                    .map(Enterprise::getId)
                    .orElse(null);
        }

        return buildAuthResponse(user, enterpriseId);
    }

    private void validatePhoneNotExists(String phone) {
        if (userRepository.existsByPhoneAndIsDeleted(phone, 0)) {
            throw new BizException(ErrorCode.PHONE_ALREADY_EXISTS, "手机号已注册");
        }
    }

    private AuthResponse buildAuthResponse(User user, Long enterpriseId) {
        String token = jwtTokenProvider.createToken(user.getId(), user.getUserType());
        AuthResponse response = new AuthResponse();
        response.setUserId(user.getId());
        response.setUserType(user.getUserType());
        response.setEnterpriseId(enterpriseId);
        response.setNickname(user.getNickname());
        response.setTokenType("Bearer");
        response.setAccessToken(token);
        response.setExpiresIn(jwtTokenProvider.getExpireSeconds());
        return response;
    }
}

