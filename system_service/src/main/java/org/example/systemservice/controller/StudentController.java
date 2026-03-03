package org.example.systemservice.controller;

import jakarta.validation.Valid;
import org.example.systemservice.common.ApiResponse;
import org.example.systemservice.common.PageResponse;
import org.example.systemservice.dto.student.*;
import org.example.systemservice.entity.*;
import org.example.systemservice.service.StudentService;
import org.springframework.core.io.FileSystemResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.util.UriUtils;

import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/student")
public class StudentController {

    private final StudentService studentService;

    public StudentController(StudentService studentService) {
        this.studentService = studentService;
    }

    @PostMapping("/resumes")
    public ApiResponse<Resume> createResume(
            @RequestHeader("X-User-Id") Long studentUserId,
            @Valid @RequestBody ResumeUpsertRequest request
    ) {
        return ApiResponse.success("简历创建成功", studentService.createResume(studentUserId, request));
    }

    @PutMapping("/resumes/{resumeId}")
    public ApiResponse<Resume> updateResume(
            @RequestHeader("X-User-Id") Long studentUserId,
            @PathVariable Long resumeId,
            @Valid @RequestBody ResumeUpsertRequest request
    ) {
        return ApiResponse.success("简历更新成功", studentService.updateResume(studentUserId, resumeId, request));
    }

    @GetMapping("/resumes")
    public ApiResponse<List<Resume>> listResumes(@RequestHeader("X-User-Id") Long studentUserId) {
        return ApiResponse.success(studentService.listResumes(studentUserId));
    }

    @PutMapping("/resumes/{resumeId}/default")
    public ApiResponse<Void> setDefaultResume(
            @RequestHeader("X-User-Id") Long studentUserId,
            @PathVariable Long resumeId
    ) {
        studentService.setDefaultResume(studentUserId, resumeId);
        return ApiResponse.success("设置默认简历成功", null);
    }

    @PostMapping(value = "/resumes/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<Map<String, Object>> uploadResumeFile(
            @RequestHeader("X-User-Id") Long studentUserId,
            @RequestPart("file") MultipartFile file,
            @RequestParam(required = false) String title
    ) {
        return ApiResponse.success("简历上传成功", studentService.uploadResumeFile(studentUserId, file, title));
    }

    @GetMapping("/resumes/{resumeId}/file")
    public ResponseEntity<FileSystemResource> downloadResumeFile(
            @RequestHeader("X-User-Id") Long studentUserId,
            @PathVariable Long resumeId
    ) {
        StudentService.ResumeFileInfo fileInfo = studentService.resolveResumeFile(studentUserId, resumeId);
        String encodedFileName = UriUtils.encode(fileInfo.getFileName(), StandardCharsets.UTF_8);
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(fileInfo.getContentType()))
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename*=UTF-8''" + encodedFileName)
                .body(new FileSystemResource(fileInfo.getFilePath().toFile()));
    }

    @GetMapping("/jobs")
    public ApiResponse<PageResponse<Map<String, Object>>> listJobs(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String city,
            @RequestParam(required = false) String category,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        return ApiResponse.success(studentService.listJobs(keyword, city, category, page, size));
    }

    @GetMapping("/jobs/{jobId}")
    public ApiResponse<Map<String, Object>> jobDetail(@PathVariable Long jobId) {
        return ApiResponse.success(studentService.jobDetail(jobId));
    }

    @PostMapping("/applications")
    public ApiResponse<JobApplication> applyJob(
            @RequestHeader("X-User-Id") Long studentUserId,
            @Valid @RequestBody ApplyJobRequest request
    ) {
        return ApiResponse.success("投递成功", studentService.applyJob(studentUserId, request));
    }

    @GetMapping("/applications")
    public ApiResponse<List<Map<String, Object>>> listMyApplications(
            @RequestHeader("X-User-Id") Long studentUserId
    ) {
        return ApiResponse.success(studentService.listMyApplications(studentUserId));
    }

    @GetMapping("/applications/{applicationId}")
    public ApiResponse<Map<String, Object>> applicationDetail(
            @RequestHeader("X-User-Id") Long studentUserId,
            @PathVariable Long applicationId
    ) {
        return ApiResponse.success(studentService.applicationDetail(studentUserId, applicationId));
    }

    @GetMapping("/chats")
    public ApiResponse<List<Conversation>> listConversations(
            @RequestHeader("X-User-Id") Long studentUserId
    ) {
        return ApiResponse.success(studentService.listConversations(studentUserId));
    }

    @GetMapping("/chats/{conversationId}/messages")
    public ApiResponse<List<Message>> listMessages(
            @RequestHeader("X-User-Id") Long studentUserId,
            @PathVariable Long conversationId
    ) {
        return ApiResponse.success(studentService.listMessages(studentUserId, conversationId));
    }

    @PostMapping("/chats/{conversationId}/messages")
    public ApiResponse<Message> sendMessage(
            @RequestHeader("X-User-Id") Long studentUserId,
            @PathVariable Long conversationId,
            @Valid @RequestBody SendMessageRequest request
    ) {
        return ApiResponse.success("发送成功", studentService.sendMessage(studentUserId, conversationId, request));
    }

    @GetMapping("/interviews")
    public ApiResponse<List<InterviewSchedule>> listInterviews(
            @RequestHeader("X-User-Id") Long studentUserId
    ) {
        return ApiResponse.success(studentService.listInterviews(studentUserId));
    }

    @GetMapping("/offers")
    public ApiResponse<List<Offer>> listOffers(
            @RequestHeader("X-User-Id") Long studentUserId
    ) {
        return ApiResponse.success(studentService.listOffers(studentUserId));
    }

    @PostMapping("/offers/{offerId}/decision")
    public ApiResponse<Offer> offerDecision(
            @RequestHeader("X-User-Id") Long studentUserId,
            @PathVariable Long offerId,
            @Valid @RequestBody OfferDecisionRequest request
    ) {
        return ApiResponse.success("Offer处理成功", studentService.handleOfferDecision(studentUserId, offerId, request));
    }

    @PostMapping("/reviews")
    public ApiResponse<EnterpriseReview> createReview(
            @RequestHeader("X-User-Id") Long studentUserId,
            @Valid @RequestBody CreateReviewRequest request
    ) {
        return ApiResponse.success("评价成功", studentService.createReview(studentUserId, request));
    }

    @GetMapping("/reviews")
    public ApiResponse<List<EnterpriseReview>> listReviews(
            @RequestHeader("X-User-Id") Long studentUserId
    ) {
        return ApiResponse.success(studentService.listMyReviews(studentUserId));
    }

    @PostMapping("/reports")
    public ApiResponse<Report> createReport(
            @RequestHeader("X-User-Id") Long studentUserId,
            @Valid @RequestBody CreateReportRequest request
    ) {
        return ApiResponse.success("举报提交成功", studentService.createReport(studentUserId, request));
    }

    @GetMapping("/reports")
    public ApiResponse<List<Report>> listReports(
            @RequestHeader("X-User-Id") Long studentUserId
    ) {
        return ApiResponse.success(studentService.listMyReports(studentUserId));
    }
}


