package org.example.systemservice.dto.enterprise;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class EnterpriseProfileUpdateRequest {

    @NotBlank(message = "企业名称不能为空")
    @Size(max = 200, message = "企业名称过长")
    private String enterpriseName;

    @Size(max = 64, message = "统一社会信用代码过长")
    private String unifiedCreditCode;

    @Size(max = 128, message = "行业信息过长")
    private String industry;

    @Size(max = 64, message = "城市信息过长")
    private String city;

    @Size(max = 255, message = "地址信息过长")
    private String address;

    @Size(max = 255, message = "官网地址过长")
    private String website;

    @Size(max = 512, message = "Logo地址过长")
    private String logoUrl;

    @Size(max = 2000, message = "企业简介过长")
    private String intro;

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

    public String getIndustry() {
        return industry;
    }

    public void setIndustry(String industry) {
        this.industry = industry;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getWebsite() {
        return website;
    }

    public void setWebsite(String website) {
        this.website = website;
    }

    public String getLogoUrl() {
        return logoUrl;
    }

    public void setLogoUrl(String logoUrl) {
        this.logoUrl = logoUrl;
    }

    public String getIntro() {
        return intro;
    }

    public void setIntro(String intro) {
        this.intro = intro;
    }
}
