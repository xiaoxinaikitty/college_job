package org.example.systemservice.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class RegisterEnterpriseRequest {

    @NotBlank(message = "手机号不能为空")
    @Pattern(regexp = "^[0-9]{6,20}$", message = "手机号格式不正确")
    private String phone;

    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 32, message = "密码长度需在6-32位")
    private String password;

    @NotBlank(message = "企业名称不能为空")
    @Size(max = 200, message = "企业名称长度不能超过200")
    private String enterpriseName;

    @Size(max = 64, message = "统一社会信用代码长度不能超过64")
    private String unifiedCreditCode;

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEnterpriseName() {
        return enterpriseName;
    }

    public void setEnterpriseName(String enterpriseName) {
        this.enterpriseName = enterpriseName;
    }

    public String getUnifiedCreditCode() {
        return unifiedCreditCode;
    }

    public void setUnifiedCreditCode(String unifiedCreditCode) {
        this.unifiedCreditCode = unifiedCreditCode;
    }
}
