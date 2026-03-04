package org.example.systemservice.dto.admin;

import jakarta.validation.constraints.Size;

public class AdminReportAcceptRequest {

    @Size(max = 255, message = "受理备注不能超过255字符")
    private String note;

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
}
