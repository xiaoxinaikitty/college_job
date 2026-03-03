package org.example.systemservice.dto.enterprise;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class EnterpriseInterviewResultRequest {

    @NotBlank(message = "面试结果不能为空")
    private String result;

    @Size(max = 255, message = "结果说明过长")
    private String note;

    public String getResult() {
        return result;
    }

    public void setResult(String result) {
        this.result = result;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
}
