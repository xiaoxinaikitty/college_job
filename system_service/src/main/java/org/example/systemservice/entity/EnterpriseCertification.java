package org.example.systemservice.entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "cjs_enterprise_certification")
public class EnterpriseCertification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "enterprise_id", nullable = false)
    private Long enterpriseId;

    @Column(name = "license_file_url", nullable = false)
    private String licenseFileUrl;

    @Column(name = "submitter_user_id", nullable = false)
    private Long submitterUserId;

    @Column(name = "audit_status", nullable = false)
    private Integer auditStatus;

    @Column(name = "audit_remark")
    private String auditRemark;

    @Column(name = "audited_by")
    private Long auditedBy;

    @Column(name = "submitted_at", nullable = false)
    private LocalDateTime submittedAt;

    @Column(name = "audited_at")
    private LocalDateTime auditedAt;

    @PrePersist
    public void prePersist() {
        if (this.auditStatus == null) {
            this.auditStatus = 1;
        }
        if (this.submittedAt == null) {
            this.submittedAt = LocalDateTime.now();
        }
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getEnterpriseId() {
        return enterpriseId;
    }

    public void setEnterpriseId(Long enterpriseId) {
        this.enterpriseId = enterpriseId;
    }

    public String getLicenseFileUrl() {
        return licenseFileUrl;
    }

    public void setLicenseFileUrl(String licenseFileUrl) {
        this.licenseFileUrl = licenseFileUrl;
    }

    public Long getSubmitterUserId() {
        return submitterUserId;
    }

    public void setSubmitterUserId(Long submitterUserId) {
        this.submitterUserId = submitterUserId;
    }

    public Integer getAuditStatus() {
        return auditStatus;
    }

    public void setAuditStatus(Integer auditStatus) {
        this.auditStatus = auditStatus;
    }

    public String getAuditRemark() {
        return auditRemark;
    }

    public void setAuditRemark(String auditRemark) {
        this.auditRemark = auditRemark;
    }

    public Long getAuditedBy() {
        return auditedBy;
    }

    public void setAuditedBy(Long auditedBy) {
        this.auditedBy = auditedBy;
    }

    public LocalDateTime getSubmittedAt() {
        return submittedAt;
    }

    public void setSubmittedAt(LocalDateTime submittedAt) {
        this.submittedAt = submittedAt;
    }

    public LocalDateTime getAuditedAt() {
        return auditedAt;
    }

    public void setAuditedAt(LocalDateTime auditedAt) {
        this.auditedAt = auditedAt;
    }
}
