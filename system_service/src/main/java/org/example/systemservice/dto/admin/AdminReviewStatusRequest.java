package org.example.systemservice.dto.admin;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class AdminReviewStatusRequest {

    @NotBlank(message = "状态不能为空")
    private String status;

    @Size(max = 255, message = "备注不能超过255字符")
    private String note;

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
}
