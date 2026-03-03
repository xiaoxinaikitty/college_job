package org.example.systemservice.controller;

import jakarta.validation.Valid;
import org.example.systemservice.common.ApiResponse;
import org.example.systemservice.dto.AuthResponse;
import org.example.systemservice.dto.LoginRequest;
import org.example.systemservice.dto.RegisterEnterpriseRequest;
import org.example.systemservice.dto.RegisterStudentRequest;
import org.example.systemservice.service.AuthService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register/student")
    public ApiResponse<AuthResponse> registerStudent(@Valid @RequestBody RegisterStudentRequest request) {
        return ApiResponse.success("学生注册成功", authService.registerStudent(request));
    }

    @PostMapping("/register/enterprise")
    public ApiResponse<AuthResponse> registerEnterprise(@Valid @RequestBody RegisterEnterpriseRequest request) {
        return ApiResponse.success("企业注册成功", authService.registerEnterprise(request));
    }

    @PostMapping("/login")
    public ApiResponse<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ApiResponse.success("登录成功", authService.login(request));
    }
}
