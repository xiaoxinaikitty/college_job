package org.example.systemservice.dto.admin;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class AdminFreezeRequest {

    @NotNull(message = "冻结天数不能为空")
    @Min(value = 1, message = "冻结天数必须大于0")
    private Integer durationDays;

    @Size(max = 255, message = "冻结原因不能超过255字符")
    private String reason;

    public Integer getDurationDays() {
        return durationDays;
    }

    public void setDurationDays(Integer durationDays) {
        this.durationDays = durationDays;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }
}
