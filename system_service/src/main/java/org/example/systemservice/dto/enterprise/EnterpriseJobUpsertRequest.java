package org.example.systemservice.dto.enterprise;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

public class EnterpriseJobUpsertRequest {

    @NotBlank(message = "岗位标题不能为空")
    @Size(max = 200, message = "岗位标题过长")
    private String title;

    @Size(max = 64, message = "岗位分类过长")
    private String category;

    @Size(max = 64, message = "城市信息过长")
    private String city;

    private BigDecimal salaryMin;

    private BigDecimal salaryMax;

    private Integer internshipMonths;

    @Size(max = 64, message = "学历要求过长")
    private String educationRequirement;

    @NotBlank(message = "岗位描述不能为空")
    @Size(max = 5000, message = "岗位描述过长")
    private String description;

    @Size(max = 5000, message = "岗位要求过长")
    private String requirementText;

    @NotNull(message = "是否提交审核不能为空")
    private Boolean submitForReview;

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public BigDecimal getSalaryMin() {
        return salaryMin;
    }

    public void setSalaryMin(BigDecimal salaryMin) {
        this.salaryMin = salaryMin;
    }

    public BigDecimal getSalaryMax() {
        return salaryMax;
    }

    public void setSalaryMax(BigDecimal salaryMax) {
        this.salaryMax = salaryMax;
    }

    public Integer getInternshipMonths() {
        return internshipMonths;
    }

    public void setInternshipMonths(Integer internshipMonths) {
        this.internshipMonths = internshipMonths;
    }

    public String getEducationRequirement() {
        return educationRequirement;
    }

    public void setEducationRequirement(String educationRequirement) {
        this.educationRequirement = educationRequirement;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getRequirementText() {
        return requirementText;
    }

    public void setRequirementText(String requirementText) {
        this.requirementText = requirementText;
    }

    public Boolean getSubmitForReview() {
        return submitForReview;
    }

    public void setSubmitForReview(Boolean submitForReview) {
        this.submitForReview = submitForReview;
    }
}
