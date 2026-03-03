package org.example.systemservice.dto.student;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;

public class InterviewConfirmRequest {

    @NotBlank(message = "操作类型不能为空")
    private String action;

    @Size(max = 255, message = "说明内容过长")
    private String note;

    private LocalDateTime expectedRescheduleAt;

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public LocalDateTime getExpectedRescheduleAt() {
        return expectedRescheduleAt;
    }

    public void setExpectedRescheduleAt(LocalDateTime expectedRescheduleAt) {
        this.expectedRescheduleAt = expectedRescheduleAt;
    }
}
