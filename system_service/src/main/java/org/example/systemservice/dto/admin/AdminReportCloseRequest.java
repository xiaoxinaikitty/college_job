package org.example.systemservice.dto.admin;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class AdminReportCloseRequest {

    @NotBlank(message = "结案结果不能为空")
    @Size(max = 255, message = "结案结果不能超过255字符")
    private String result;

    private Boolean withPenalty;

    public String getResult() {
        return result;
    }

    public void setResult(String result) {
        this.result = result;
    }

    public Boolean getWithPenalty() {
        return withPenalty;
    }

    public void setWithPenalty(Boolean withPenalty) {
        this.withPenalty = withPenalty;
    }
}
