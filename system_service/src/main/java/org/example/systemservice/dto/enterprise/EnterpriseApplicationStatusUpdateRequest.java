package org.example.systemservice.dto.enterprise;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class EnterpriseApplicationStatusUpdateRequest {

    @NotNull(message = "目标状态不能为空")
    private Integer toStatus;

    @Size(max = 255, message = "淘汰原因过长")
    private String rejectReason;

    @Size(max = 255, message = "操作备注过长")
    private String note;

    public Integer getToStatus() {
        return toStatus;
    }

    public void setToStatus(Integer toStatus) {
        this.toStatus = toStatus;
    }

    public String getRejectReason() {
        return rejectReason;
    }

    public void setRejectReason(String rejectReason) {
        this.rejectReason = rejectReason;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
}
