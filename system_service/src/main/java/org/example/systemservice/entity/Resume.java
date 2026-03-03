package org.example.systemservice.entity;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "cjs_resume")
public class Resume {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "student_user_id", nullable = false)
    private Long studentUserId;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "is_default", nullable = false)
    private Integer isDefault;

    @Column(name = "resume_status", nullable = false)
    private Integer resumeStatus;

    @Column(name = "resume_content_json", nullable = false, columnDefinition = "json")
    private String resumeContentJson;

    @Column(name = "completion_score", nullable = false)
    private BigDecimal completionScore;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        LocalDateTime now = LocalDateTime.now();
        this.createdAt = now;
        this.updatedAt = now;
        if (this.isDefault == null) {
            this.isDefault = 0;
        }
        if (this.resumeStatus == null) {
            this.resumeStatus = 1;
        }
        if (this.completionScore == null) {
            this.completionScore = BigDecimal.ZERO;
        }
    }

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getStudentUserId() {
        return studentUserId;
    }

    public void setStudentUserId(Long studentUserId) {
        this.studentUserId = studentUserId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public Integer getIsDefault() {
        return isDefault;
    }

    public void setIsDefault(Integer isDefault) {
        this.isDefault = isDefault;
    }

    public Integer getResumeStatus() {
        return resumeStatus;
    }

    public void setResumeStatus(Integer resumeStatus) {
        this.resumeStatus = resumeStatus;
    }

    public String getResumeContentJson() {
        return resumeContentJson;
    }

    public void setResumeContentJson(String resumeContentJson) {
        this.resumeContentJson = resumeContentJson;
    }

    public BigDecimal getCompletionScore() {
        return completionScore;
    }

    public void setCompletionScore(BigDecimal completionScore) {
        this.completionScore = completionScore;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
