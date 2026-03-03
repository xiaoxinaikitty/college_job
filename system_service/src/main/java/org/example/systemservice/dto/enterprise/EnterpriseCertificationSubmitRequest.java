package org.example.systemservice.dto.enterprise;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class EnterpriseCertificationSubmitRequest {

    @NotBlank(message = "营业执照文件地址不能为空")
    @Size(max = 512, message = "营业执照文件地址过长")
    private String licenseFileUrl;

    @Size(max = 255, message = "提交说明过长")
    private String submitRemark;

    public String getLicenseFileUrl() {
        return licenseFileUrl;
    }

    public void setLicenseFileUrl(String licenseFileUrl) {
        this.licenseFileUrl = licenseFileUrl;
    }

    public String getSubmitRemark() {
        return submitRemark;
    }

    public void setSubmitRemark(String submitRemark) {
        this.submitRemark = submitRemark;
    }
}
