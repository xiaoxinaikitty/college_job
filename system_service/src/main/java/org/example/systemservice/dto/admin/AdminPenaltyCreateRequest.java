package org.example.systemservice.dto.admin;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class AdminPenaltyCreateRequest {

    @NotBlank(message = "处罚目标不能为空")
    @Size(max = 200, message = "处罚目标不能超过200字符")
    private String target;

    @NotBlank(message = "目标类型不能为空")
    private String targetType;

    @NotBlank(message = "处罚动作不能为空")
    @Size(max = 120, message = "处罚动作不能超过120字符")
    private String action;

    @NotBlank(message = "处罚等级不能为空")
    private String severity;

    @NotBlank(message = "处罚原因不能为空")
    @Size(max = 255, message = "处罚原因不能超过255字符")
    private String reason;

    private Long targetId;

    public String getTarget() {
        return target;
    }

    public void setTarget(String target) {
        this.target = target;
    }

    public String getTargetType() {
        return targetType;
    }

    public void setTargetType(String targetType) {
        this.targetType = targetType;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getSeverity() {
        return severity;
    }

    public void setSeverity(String severity) {
        this.severity = severity;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public Long getTargetId() {
        return targetId;
    }

    public void setTargetId(Long targetId) {
        this.targetId = targetId;
    }
}
