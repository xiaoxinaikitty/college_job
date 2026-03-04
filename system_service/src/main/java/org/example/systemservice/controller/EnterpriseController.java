package org.example.systemservice.controller;

import jakarta.validation.Valid;
import org.example.systemservice.common.ApiResponse;
import org.example.systemservice.dto.enterprise.*;
import org.example.systemservice.dto.student.SendMessageRequest;
import org.example.systemservice.entity.JobApplication;
import org.example.systemservice.entity.JobPosting;
import org.example.systemservice.entity.Message;
import org.example.systemservice.entity.Offer;
import org.example.systemservice.service.EnterpriseService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/enterprise")
public class EnterpriseController {

    private final EnterpriseService enterpriseService;

    public EnterpriseController(EnterpriseService enterpriseService) {
        this.enterpriseService = enterpriseService;
    }

    @GetMapping("/profile")
    public ApiResponse<Map<String, Object>> profileDetail(
            @RequestHeader("X-User-Id") Long enterpriseUserId
    ) {
        return ApiResponse.success(enterpriseService.profileDetail(enterpriseUserId));
    }

    @PutMapping("/profile")
    public ApiResponse<Map<String, Object>> updateProfile(
            @RequestHeader("X-User-Id") Long enterpriseUserId,
            @Valid @RequestBody EnterpriseProfileUpdateRequest request
    ) {
        return ApiResponse.success("企业资料更新成功", enterpriseService.updateProfile(enterpriseUserId, request));
    }

    @PostMapping("/certifications/submit")
    public ApiResponse<Map<String, Object>> submitCertification(
            @RequestHeader("X-User-Id") Long enterpriseUserId,
            @Valid @RequestBody EnterpriseCertificationSubmitRequest request
    ) {
        return ApiResponse.success("企业认证提交成功", enterpriseService.submitCertification(enterpriseUserId, request));
    }

    @PostMapping("/jobs")
    public ApiResponse<JobPosting> createJob(
            @RequestHeader("X-User-Id") Long enterpriseUserId,
            @Valid @RequestBody EnterpriseJobUpsertRequest request
    ) {
        return ApiResponse.success("岗位创建成功", enterpriseService.createJob(enterpriseUserId, request));
    }

    @PutMapping("/jobs/{jobId}")
    public ApiResponse<JobPosting> updateJob(
            @RequestHeader("X-User-Id") Long enterpriseUserId,
            @PathVariable Long jobId,
            @Valid @RequestBody EnterpriseJobUpsertRequest request
    ) {
        return ApiResponse.success("岗位更新成功", enterpriseService.updateJob(enterpriseUserId, jobId, request));
    }

    @PutMapping("/jobs/{jobId}/offline")
    public ApiResponse<JobPosting> offlineJob(
            @RequestHeader("X-User-Id") Long enterpriseUserId,
            @PathVariable Long jobId
    ) {
        return ApiResponse.success("岗位下线成功", enterpriseService.offlineJob(enterpriseUserId, jobId));
    }

    @GetMapping("/jobs")
    public ApiResponse<List<Map<String, Object>>> listJobs(
            @RequestHeader("X-User-Id") Long enterpriseUserId
    ) {
        return ApiResponse.success(enterpriseService.listJobs(enterpriseUserId));
    }

    @GetMapping("/jobs/{jobId}")
    public ApiResponse<Map<String, Object>> jobDetail(
            @RequestHeader("X-User-Id") Long enterpriseUserId,
            @PathVariable Long jobId
    ) {
        return ApiResponse.success(enterpriseService.jobDetail(enterpriseUserId, jobId));
    }

    @GetMapping("/applications")
    public ApiResponse<List<Map<String, Object>>> listApplications(
            @RequestHeader("X-User-Id") Long enterpriseUserId,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) Long jobId
    ) {
        return ApiResponse.success(enterpriseService.listApplications(enterpriseUserId, status, jobId));
    }

    @GetMapping("/applications/{applicationId}")
    public ApiResponse<Map<String, Object>> applicationDetail(
            @RequestHeader("X-User-Id") Long enterpriseUserId,
            @PathVariable Long applicationId
    ) {
        return ApiResponse.success(enterpriseService.applicationDetail(enterpriseUserId, applicationId));
    }

    @PostMapping("/applications/{applicationId}/status")
    public ApiResponse<JobApplication> updateApplicationStatus(
            @RequestHeader("X-User-Id") Long enterpriseUserId,
            @PathVariable Long applicationId,
            @Valid @RequestBody EnterpriseApplicationStatusUpdateRequest request
    ) {
        return ApiResponse.success(
                "投递状态更新成功",
                enterpriseService.updateApplicationStatus(enterpriseUserId, applicationId, request)
        );
    }

    @GetMapping("/chats")
    public ApiResponse<List<Map<String, Object>>> listConversations(
            @RequestHeader("X-User-Id") Long enterpriseUserId
    ) {
        return ApiResponse.success(enterpriseService.listConversations(enterpriseUserId));
    }

    @GetMapping("/chats/{conversationId}/messages")
    public ApiResponse<List<Message>> listMessages(
            @RequestHeader("X-User-Id") Long enterpriseUserId,
            @PathVariable Long conversationId
    ) {
        return ApiResponse.success(enterpriseService.listMessages(enterpriseUserId, conversationId));
    }

    @PostMapping("/chats/{conversationId}/messages")
    public ApiResponse<Message> sendMessage(
            @RequestHeader("X-User-Id") Long enterpriseUserId,
            @PathVariable Long conversationId,
            @Valid @RequestBody SendMessageRequest request
    ) {
        return ApiResponse.success("发送成功", enterpriseService.sendMessage(enterpriseUserId, conversationId, request));
    }

    @PostMapping("/interviews")
    public ApiResponse<Map<String, Object>> createInterview(
            @RequestHeader("X-User-Id") Long enterpriseUserId,
            @Valid @RequestBody EnterpriseInterviewCreateRequest request
    ) {
        return ApiResponse.success("面试安排成功", enterpriseService.createInterview(enterpriseUserId, request));
    }

    @GetMapping("/interviews")
    public ApiResponse<List<Map<String, Object>>> listInterviews(
            @RequestHeader("X-User-Id") Long enterpriseUserId,
            @RequestParam(required = false) Long applicationId
    ) {
        return ApiResponse.success(enterpriseService.listInterviews(enterpriseUserId, applicationId));
    }

    @PostMapping("/interviews/{interviewId}/result")
    public ApiResponse<Map<String, Object>> submitInterviewResult(
            @RequestHeader("X-User-Id") Long enterpriseUserId,
            @PathVariable Long interviewId,
            @Valid @RequestBody EnterpriseInterviewResultRequest request
    ) {
        return ApiResponse.success(
                "面试结果提交成功",
                enterpriseService.submitInterviewResult(enterpriseUserId, interviewId, request)
        );
    }

    @PostMapping("/offers")
    public ApiResponse<Offer> createOffer(
            @RequestHeader("X-User-Id") Long enterpriseUserId,
            @Valid @RequestBody EnterpriseOfferCreateRequest request
    ) {
        return ApiResponse.success("Offer发放成功", enterpriseService.createOffer(enterpriseUserId, request));
    }

    @GetMapping("/offers")
    public ApiResponse<List<Map<String, Object>>> listOffers(
            @RequestHeader("X-User-Id") Long enterpriseUserId
    ) {
        return ApiResponse.success(enterpriseService.listOffers(enterpriseUserId));
    }
}
