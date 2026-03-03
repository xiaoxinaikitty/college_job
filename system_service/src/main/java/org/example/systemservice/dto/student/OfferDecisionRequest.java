package org.example.systemservice.dto.student;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class OfferDecisionRequest {

    @NotBlank(message = "处理动作不能为空")
    private String action;

    @Size(max = 255, message = "拒绝原因过长")
    private String rejectReason;

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getRejectReason() {
        return rejectReason;
    }

    public void setRejectReason(String rejectReason) {
        this.rejectReason = rejectReason;
    }
}
