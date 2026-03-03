package org.example.systemservice.dto.student;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class CreateReportRequest {

    @NotNull(message = "举报目标类型不能为空")
    private Integer targetType;

    @NotNull(message = "举报目标ID不能为空")
    private Long targetId;

    @Size(max = 255, message = "举报原因过长")
    private String reason;

    @Size(max = 512, message = "证据链接过长")
    private String evidenceUrl;

    public Integer getTargetType() {
        return targetType;
    }

    public void setTargetType(Integer targetType) {
        this.targetType = targetType;
    }

    public Long getTargetId() {
        return targetId;
    }

    public void setTargetId(Long targetId) {
        this.targetId = targetId;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getEvidenceUrl() {
        return evidenceUrl;
    }

    public void setEvidenceUrl(String evidenceUrl) {
        this.evidenceUrl = evidenceUrl;
    }
}
