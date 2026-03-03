package org.example.systemservice.dto.student;

import jakarta.validation.constraints.NotNull;

public class ApplyJobRequest {

    @NotNull(message = "岗位ID不能为空")
    private Long jobId;

    @NotNull(message = "简历ID不能为空")
    private Long resumeId;

    public Long getJobId() {
        return jobId;
    }

    public void setJobId(Long jobId) {
        this.jobId = jobId;
    }

    public Long getResumeId() {
        return resumeId;
    }

    public void setResumeId(Long resumeId) {
        this.resumeId = resumeId;
    }
}
