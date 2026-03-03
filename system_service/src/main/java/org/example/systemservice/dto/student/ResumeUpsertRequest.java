package org.example.systemservice.dto.student;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

public class ResumeUpsertRequest {

    @NotBlank(message = "简历标题不能为空")
    @Size(max = 128, message = "简历标题长度不能超过128")
    private String title;

    @NotBlank(message = "简历内容不能为空")
    private String resumeContentJson;

    @DecimalMin(value = "0.00", message = "完整度不能小于0")
    @DecimalMax(value = "100.00", message = "完整度不能大于100")
    private BigDecimal completionScore;

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getResumeContentJson() {
        return resumeContentJson;
    }

    public void setResumeContentJson(String resumeContentJson) {
        this.resumeContentJson = resumeContentJson;
    }

    public BigDecimal getCompletionScore() {
        return completionScore;
    }

    public void setCompletionScore(BigDecimal completionScore) {
        this.completionScore = completionScore;
    }
}
