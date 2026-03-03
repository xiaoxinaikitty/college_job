package org.example.systemservice.dto.enterprise;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;

public class EnterpriseInterviewCreateRequest {

    @NotNull(message = "投递ID不能为空")
    private Long applicationId;

    @NotNull(message = "面试类型不能为空")
    private Integer interviewType;

    @NotNull(message = "面试时间不能为空")
    private LocalDateTime scheduledAt;

    @NotNull(message = "面试时长不能为空")
    private Integer durationMinutes;

    @Size(max = 512, message = "会议链接过长")
    private String meetingLink;

    @Size(max = 255, message = "面试地点过长")
    private String location;

    @Size(max = 255, message = "备注过长")
    private String remark;

    public Long getApplicationId() {
        return applicationId;
    }

    public void setApplicationId(Long applicationId) {
        this.applicationId = applicationId;
    }

    public Integer getInterviewType() {
        return interviewType;
    }

    public void setInterviewType(Integer interviewType) {
        this.interviewType = interviewType;
    }

    public LocalDateTime getScheduledAt() {
        return scheduledAt;
    }

    public void setScheduledAt(LocalDateTime scheduledAt) {
        this.scheduledAt = scheduledAt;
    }

    public Integer getDurationMinutes() {
        return durationMinutes;
    }

    public void setDurationMinutes(Integer durationMinutes) {
        this.durationMinutes = durationMinutes;
    }

    public String getMeetingLink() {
        return meetingLink;
    }

    public void setMeetingLink(String meetingLink) {
        this.meetingLink = meetingLink;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }
}
