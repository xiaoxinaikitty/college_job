package org.example.systemservice.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.systemservice.common.ErrorCode;
import org.example.systemservice.common.PageResponse;
import org.example.systemservice.dto.student.*;
import org.example.systemservice.entity.*;
import org.example.systemservice.exception.BizException;
import org.example.systemservice.repository.*;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.ThreadLocalRandom;
import java.util.stream.Collectors;

@Service
public class StudentService {

    private final UserRepository userRepository;
    private final ResumeRepository resumeRepository;
    private final JobPostingRepository jobPostingRepository;
    private final JobApplicationRepository jobApplicationRepository;
    private final ApplicationStatusLogRepository applicationStatusLogRepository;
    private final ConversationRepository conversationRepository;
    private final MessageRepository messageRepository;
    private final InterviewScheduleRepository interviewScheduleRepository;
    private final OfferRepository offerRepository;
    private final OfferStatusLogRepository offerStatusLogRepository;
    private final EnterpriseReviewRepository enterpriseReviewRepository;
    private final ReportRepository reportRepository;
    private final EnterpriseRepository enterpriseRepository;
    private final ObjectMapper objectMapper;

    private static final long MAX_RESUME_FILE_SIZE = 10L * 1024 * 1024;
    private static final Set<String> ALLOWED_RESUME_EXTENSIONS = Set.of("pdf", "doc", "docx");

    public StudentService(
            UserRepository userRepository,
            ResumeRepository resumeRepository,
            JobPostingRepository jobPostingRepository,
            JobApplicationRepository jobApplicationRepository,
            ApplicationStatusLogRepository applicationStatusLogRepository,
            ConversationRepository conversationRepository,
            MessageRepository messageRepository,
            InterviewScheduleRepository interviewScheduleRepository,
            OfferRepository offerRepository,
            OfferStatusLogRepository offerStatusLogRepository,
            EnterpriseReviewRepository enterpriseReviewRepository,
            ReportRepository reportRepository,
            EnterpriseRepository enterpriseRepository,
            ObjectMapper objectMapper
    ) {
        this.userRepository = userRepository;
        this.resumeRepository = resumeRepository;
        this.jobPostingRepository = jobPostingRepository;
        this.jobApplicationRepository = jobApplicationRepository;
        this.applicationStatusLogRepository = applicationStatusLogRepository;
        this.conversationRepository = conversationRepository;
        this.messageRepository = messageRepository;
        this.interviewScheduleRepository = interviewScheduleRepository;
        this.offerRepository = offerRepository;
        this.offerStatusLogRepository = offerStatusLogRepository;
        this.enterpriseReviewRepository = enterpriseReviewRepository;
        this.reportRepository = reportRepository;
        this.enterpriseRepository = enterpriseRepository;
        this.objectMapper = objectMapper;
    }

    private void validateStudent(Long studentUserId) {
        boolean valid = userRepository.existsByIdAndUserTypeAndIsDeleted(studentUserId, 1, 0);
        if (!valid) {
            throw new BizException(ErrorCode.USER_TYPE_MISMATCH, "学生身份无效");
        }
    }

    @Transactional
    public Resume createResume(Long studentUserId, ResumeUpsertRequest request) {
        validateStudent(studentUserId);
        Resume resume = new Resume();
        resume.setStudentUserId(studentUserId);
        resume.setTitle(request.getTitle().trim());
        resume.setResumeContentJson(request.getResumeContentJson().trim());
        resume.setCompletionScore(
                request.getCompletionScore() == null ? BigDecimal.ZERO : request.getCompletionScore()
        );
        resume.setResumeStatus(1);
        resume.setIsDefault(0);
        return resumeRepository.save(resume);
    }

    @Transactional
    public Resume updateResume(Long studentUserId, Long resumeId, ResumeUpsertRequest request) {
        validateStudent(studentUserId);
        Resume resume = resumeRepository.findByIdAndStudentUserId(resumeId, studentUserId)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "简历不存在"));
        resume.setTitle(request.getTitle().trim());
        resume.setResumeContentJson(request.getResumeContentJson().trim());
        resume.setCompletionScore(
                request.getCompletionScore() == null ? BigDecimal.ZERO : request.getCompletionScore()
        );
        return resumeRepository.save(resume);
    }

    @Transactional
    public void setDefaultResume(Long studentUserId, Long resumeId) {
        validateStudent(studentUserId);
        Resume resume = resumeRepository.findByIdAndStudentUserId(resumeId, studentUserId)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "简历不存在"));
        resumeRepository.clearDefaultByStudentUserId(studentUserId);
        resume.setIsDefault(1);
        resumeRepository.save(resume);
    }

    public List<Resume> listResumes(Long studentUserId) {
        validateStudent(studentUserId);
        return resumeRepository.findByStudentUserIdOrderByUpdatedAtDesc(studentUserId);
    }

    @Transactional
    public Map<String, Object> uploadResumeFile(Long studentUserId, MultipartFile file, String title) {
        validateStudent(studentUserId);
        if (file == null || file.isEmpty()) {
            throw new BizException(ErrorCode.PARAM_ERROR, "请上传简历文件");
        }

        String originalFilename = Optional.ofNullable(file.getOriginalFilename()).orElse("resume");
        String extension = getFileExtension(originalFilename);
        if (!ALLOWED_RESUME_EXTENSIONS.contains(extension)) {
            throw new BizException(ErrorCode.PARAM_ERROR, "仅支持 pdf/doc/docx 文件");
        }
        if (file.getSize() > MAX_RESUME_FILE_SIZE) {
            throw new BizException(ErrorCode.PARAM_ERROR, "文件大小不能超过10MB");
        }

        Path uploadDir = Paths.get(System.getProperty("user.dir"), "uploads", "resumes", String.valueOf(studentUserId));
        try {
            Files.createDirectories(uploadDir);
        } catch (IOException e) {
            throw new BizException(ErrorCode.SYSTEM_ERROR, "创建上传目录失败");
        }

        String storageFileName = buildStorageFileName(extension);
        Path targetPath = uploadDir.resolve(storageFileName);
        try {
            file.transferTo(targetPath.toFile());
        } catch (IOException e) {
            throw new BizException(ErrorCode.SYSTEM_ERROR, "保存文件失败");
        }

        String resumeTitle = (title != null && !title.trim().isEmpty())
                ? title.trim()
                : extractBaseName(originalFilename);

        boolean hasResume = !resumeRepository.findByStudentUserIdOrderByUpdatedAtDesc(studentUserId).isEmpty();

        Map<String, Object> contentJsonMap = new LinkedHashMap<>();
        contentJsonMap.put("source", "file_upload");
        contentJsonMap.put("originalFileName", originalFilename);
        contentJsonMap.put("storedFileName", storageFileName);
        contentJsonMap.put("fileSize", file.getSize());
        contentJsonMap.put("fileExtension", extension);
        contentJsonMap.put("storagePath", targetPath.toString());

        Resume resume = new Resume();
        resume.setStudentUserId(studentUserId);
        resume.setTitle(resumeTitle);
        resume.setIsDefault(hasResume ? 0 : 1);
        resume.setResumeStatus(1);
        resume.setCompletionScore(BigDecimal.valueOf(20));

        try {
            resume.setResumeContentJson(objectMapper.writeValueAsString(contentJsonMap));
        } catch (Exception e) {
            throw new BizException(ErrorCode.SYSTEM_ERROR, "构建简历内容失败");
        }

        resume = resumeRepository.save(resume);

        String downloadUrl = "/api/student/resumes/" + resume.getId() + "/file";
        contentJsonMap.put("downloadUrl", downloadUrl);
        try {
            resume.setResumeContentJson(objectMapper.writeValueAsString(contentJsonMap));
        } catch (Exception e) {
            throw new BizException(ErrorCode.SYSTEM_ERROR, "更新简历内容失败");
        }
        resume = resumeRepository.save(resume);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("resume", resume);
        result.put("resumeId", resume.getId());
        result.put("downloadUrl", downloadUrl);
        result.put("fileName", originalFilename);
        result.put("fileSize", file.getSize());
        return result;
    }

    public ResumeFileInfo resolveResumeFile(Long studentUserId, Long resumeId) {
        validateStudent(studentUserId);
        Resume resume = resumeRepository.findByIdAndStudentUserId(resumeId, studentUserId)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "简历不存在"));

        Map<String, Object> content = parseResumeContent(resume.getResumeContentJson());
        String storagePath = valueToString(content.get("storagePath"));
        if (storagePath == null || storagePath.isBlank()) {
            throw new BizException(ErrorCode.DATA_NOT_FOUND, "简历文件不存在");
        }

        Path filePath = Paths.get(storagePath);
        if (!Files.exists(filePath) || !Files.isRegularFile(filePath)) {
            throw new BizException(ErrorCode.DATA_NOT_FOUND, "简历文件不存在");
        }

        String fileName = valueToString(content.get("originalFileName"));
        if (fileName == null || fileName.isBlank()) {
            fileName = resume.getTitle() + "." + Optional.ofNullable(valueToString(content.get("fileExtension"))).orElse("pdf");
        }

        String contentType;
        try {
            contentType = Files.probeContentType(filePath);
        } catch (IOException ignored) {
            contentType = null;
        }
        if (contentType == null || contentType.isBlank()) {
            contentType = guessContentTypeByExtension(fileName);
        }

        return new ResumeFileInfo(filePath, fileName, contentType);
    }

    public PageResponse<Map<String, Object>> listJobs(String keyword, String city, String category, int page, int size) {
        PageRequest pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "publishAt", "id"));
        Page<JobPosting> result = jobPostingRepository.searchOnlineJobs(
                normalize(keyword), normalize(city), normalize(category), pageable
        );
        List<Map<String, Object>> records = result.getContent().stream().map(job -> {
            Map<String, Object> map = new LinkedHashMap<>();
            map.put("jobId", job.getId());
            map.put("title", job.getTitle());
            map.put("category", job.getCategory());
            map.put("city", job.getCity());
            map.put("salaryMin", job.getSalaryMin());
            map.put("salaryMax", job.getSalaryMax());
            map.put("internshipMonths", job.getInternshipMonths());
            map.put("educationRequirement", job.getEducationRequirement());
            map.put("status", job.getStatus());
            map.put("publishAt", job.getPublishAt());
            map.put("enterpriseId", job.getEnterpriseId());
            map.put("enterpriseName", enterpriseRepository.findById(job.getEnterpriseId())
                    .map(Enterprise::getEnterpriseName).orElse("-"));
            return map;
        }).collect(Collectors.toList());
        return new PageResponse<>(records, result.getTotalElements(), page, size);
    }

    public Map<String, Object> jobDetail(Long jobId) {
        JobPosting job = jobPostingRepository.findByIdAndStatus(jobId, 3)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "岗位不存在或未上线"));
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("jobId", job.getId());
        map.put("title", job.getTitle());
        map.put("category", job.getCategory());
        map.put("city", job.getCity());
        map.put("salaryMin", job.getSalaryMin());
        map.put("salaryMax", job.getSalaryMax());
        map.put("internshipMonths", job.getInternshipMonths());
        map.put("educationRequirement", job.getEducationRequirement());
        map.put("description", job.getDescription());
        map.put("requirementText", job.getRequirementText());
        map.put("enterpriseId", job.getEnterpriseId());
        map.put("enterpriseName", enterpriseRepository.findById(job.getEnterpriseId())
                .map(Enterprise::getEnterpriseName).orElse("-"));
        map.put("publishAt", job.getPublishAt());
        return map;
    }

    @Transactional
    public JobApplication applyJob(Long studentUserId, ApplyJobRequest request) {
        validateStudent(studentUserId);
        JobPosting job = jobPostingRepository.findByIdAndStatus(request.getJobId(), 3)
                .orElseThrow(() -> new BizException(ErrorCode.JOB_NOT_ONLINE, "岗位不存在或未上线"));
        resumeRepository.findByIdAndStudentUserId(request.getResumeId(), studentUserId)
                .orElseThrow(() -> new BizException(ErrorCode.RESUME_NOT_FOUND, "简历不存在"));

        if (jobApplicationRepository.existsByJobIdAndStudentUserId(job.getId(), studentUserId)) {
            throw new BizException(ErrorCode.ALREADY_APPLIED, "该岗位已投递");
        }

        JobApplication app = new JobApplication();
        app.setApplicationNo(generateApplicationNo());
        app.setJobId(job.getId());
        app.setEnterpriseId(job.getEnterpriseId());
        app.setStudentUserId(studentUserId);
        app.setResumeId(request.getResumeId());
        app.setStatus(1);

        try {
            app = jobApplicationRepository.save(app);
        } catch (DataIntegrityViolationException e) {
            throw new BizException(ErrorCode.ALREADY_APPLIED, "该岗位已投递");
        }

        saveApplicationLog(app.getId(), null, 1, studentUserId, 1, "学生投递");

        Conversation conversation = new Conversation();
        conversation.setApplicationId(app.getId());
        conversation.setEnterpriseId(app.getEnterpriseId());
        conversation.setStudentUserId(studentUserId);
        conversation.setStatus(1);
        conversationRepository.save(conversation);

        return app;
    }

    public List<Map<String, Object>> listMyApplications(Long studentUserId) {
        validateStudent(studentUserId);
        return jobApplicationRepository.findByStudentUserIdOrderByCreatedAtDesc(studentUserId)
                .stream()
                .map(app -> {
                    Map<String, Object> map = new LinkedHashMap<>();
                    map.put("applicationId", app.getId());
                    map.put("applicationNo", app.getApplicationNo());
                    map.put("jobId", app.getJobId());
                    map.put("resumeId", app.getResumeId());
                    map.put("enterpriseId", app.getEnterpriseId());
                    map.put("status", app.getStatus());
                    map.put("rejectReason", app.getRejectReason());
                    map.put("submittedAt", app.getSubmittedAt());
                    map.put("lastActionAt", app.getLastActionAt());
                    return map;
                })
                .collect(Collectors.toList());
    }

    public Map<String, Object> applicationDetail(Long studentUserId, Long applicationId) {
        validateStudent(studentUserId);
        JobApplication app = jobApplicationRepository.findByIdAndStudentUserId(applicationId, studentUserId)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "投递记录不存在"));
        List<ApplicationStatusLog> logs = applicationStatusLogRepository.findByApplicationIdOrderByCreatedAtAsc(applicationId);

        Map<String, Object> map = new LinkedHashMap<>();
        map.put("application", app);
        map.put("statusLogs", logs);
        return map;
    }

    public List<Conversation> listConversations(Long studentUserId) {
        validateStudent(studentUserId);
        return conversationRepository.findByStudentUserIdOrderByUpdatedAtDesc(studentUserId);
    }

    public List<Message> listMessages(Long studentUserId, Long conversationId) {
        validateStudent(studentUserId);
        conversationRepository.findByIdAndStudentUserId(conversationId, studentUserId)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "会话不存在"));
        return messageRepository.findByConversationIdOrderBySentAtAsc(conversationId);
    }

    @Transactional
    public Message sendMessage(Long studentUserId, Long conversationId, SendMessageRequest request) {
        validateStudent(studentUserId);
        Conversation conversation = conversationRepository.findByIdAndStudentUserId(conversationId, studentUserId)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "会话不存在"));
        if (request.getMessageType() == 1 && (request.getContentText() == null || request.getContentText().isBlank())) {
            throw new BizException(ErrorCode.PARAM_ERROR, "文本消息内容不能为空");
        }
        Message message = new Message();
        message.setConversationId(conversationId);
        message.setSenderUserId(studentUserId);
        message.setMessageType(request.getMessageType());
        message.setContentText(request.getContentText());
        message.setFileUrl(request.getFileUrl());
        Message saved = messageRepository.save(message);

        conversation.setLastMessageAt(saved.getSentAt());
        conversationRepository.save(conversation);
        return saved;
    }

    public List<InterviewSchedule> listInterviews(Long studentUserId) {
        validateStudent(studentUserId);
        return interviewScheduleRepository.findByStudentUserId(studentUserId);
    }

    public List<Offer> listOffers(Long studentUserId) {
        validateStudent(studentUserId);
        return offerRepository.findByStudentUserIdOrderByCreatedAtDesc(studentUserId);
    }

    @Transactional
    public Offer handleOfferDecision(Long studentUserId, Long offerId, OfferDecisionRequest request) {
        validateStudent(studentUserId);
        Offer offer = offerRepository.findByIdAndStudentUserId(offerId, studentUserId)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "Offer不存在"));
        if (offer.getStatus() != 1) {
            throw new BizException(ErrorCode.OFFER_STATUS_INVALID, "当前Offer不可处理");
        }

        String action = request.getAction().trim().toLowerCase(Locale.ROOT);
        Integer targetStatus;
        if ("accept".equals(action)) {
            targetStatus = 2;
        } else if ("reject".equals(action)) {
            targetStatus = 3;
        } else {
            throw new BizException(ErrorCode.PARAM_ERROR, "action 仅支持 accept 或 reject");
        }

        Integer fromStatus = offer.getStatus();
        offer.setStatus(targetStatus);
        offer.setDecisionAt(LocalDateTime.now());
        if (targetStatus == 3) {
            offer.setRejectReason(request.getRejectReason());
        }
        offer = offerRepository.save(offer);

        OfferStatusLog log = new OfferStatusLog();
        log.setOfferId(offer.getId());
        log.setFromStatus(fromStatus);
        log.setToStatus(targetStatus);
        log.setOperatorUserId(studentUserId);
        log.setNote(targetStatus == 2 ? "学生接受Offer" : "学生拒绝Offer");
        offerStatusLogRepository.save(log);

        JobApplication app = jobApplicationRepository.findById(offer.getApplicationId())
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "投递记录不存在"));
        Integer fromAppStatus = app.getStatus();
        Integer toAppStatus = targetStatus == 2 ? 6 : 7;
        app.setStatus(toAppStatus);
        if (toAppStatus == 7) {
            app.setRejectReason(request.getRejectReason());
        }
        jobApplicationRepository.save(app);
        saveApplicationLog(app.getId(), fromAppStatus, toAppStatus, studentUserId, 1, "学生处理Offer");
        return offer;
    }

    @Transactional
    public EnterpriseReview createReview(Long studentUserId, CreateReviewRequest request) {
        validateStudent(studentUserId);
        JobApplication app = jobApplicationRepository.findByIdAndStudentUserId(request.getApplicationId(), studentUserId)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "投递记录不存在"));
        if (!Objects.equals(app.getEnterpriseId(), request.getEnterpriseId())) {
            throw new BizException(ErrorCode.PARAM_ERROR, "企业ID与投递记录不匹配");
        }
        if (app.getStatus() != 6 && app.getStatus() != 7) {
            throw new BizException(ErrorCode.APPLICATION_STATUS_INVALID, "仅流程结束后可评价");
        }
        if (enterpriseReviewRepository.existsByApplicationIdAndStudentUserId(app.getId(), studentUserId)) {
            throw new BizException(ErrorCode.PARAM_ERROR, "该投递已评价");
        }
        EnterpriseReview review = new EnterpriseReview();
        review.setApplicationId(request.getApplicationId());
        review.setEnterpriseId(request.getEnterpriseId());
        review.setStudentUserId(studentUserId);
        review.setRating(request.getRating());
        review.setContent(request.getContent());
        return enterpriseReviewRepository.save(review);
    }

    public List<EnterpriseReview> listMyReviews(Long studentUserId) {
        validateStudent(studentUserId);
        return enterpriseReviewRepository.findByStudentUserIdOrderByCreatedAtDesc(studentUserId);
    }

    @Transactional
    public Report createReport(Long studentUserId, CreateReportRequest request) {
        validateStudent(studentUserId);
        Report report = new Report();
        report.setReporterUserId(studentUserId);
        report.setTargetType(request.getTargetType());
        report.setTargetId(request.getTargetId());
        report.setReason((request.getReason() == null || request.getReason().isBlank()) ? "未填写原因" : request.getReason().trim());
        report.setEvidenceUrl(request.getEvidenceUrl());
        report.setStatus(1);
        return reportRepository.save(report);
    }

    public List<Report> listMyReports(Long studentUserId) {
        validateStudent(studentUserId);
        return reportRepository.findByReporterUserIdOrderByCreatedAtDesc(studentUserId);
    }

    private Map<String, Object> parseResumeContent(String resumeContentJson) {
        if (resumeContentJson == null || resumeContentJson.isBlank()) {
            return new LinkedHashMap<>();
        }
        try {
            return objectMapper.readValue(resumeContentJson, new TypeReference<Map<String, Object>>() {
            });
        } catch (Exception e) {
            return new LinkedHashMap<>();
        }
    }

    private String buildStorageFileName(String extension) {
        return System.currentTimeMillis() + "_" + UUID.randomUUID().toString().replace("-", "").substring(0, 10) + "." + extension;
    }

    private String getFileExtension(String fileName) {
        int idx = fileName.lastIndexOf('.');
        if (idx < 0 || idx == fileName.length() - 1) {
            return "";
        }
        return fileName.substring(idx + 1).toLowerCase(Locale.ROOT);
    }

    private String extractBaseName(String fileName) {
        int idx = fileName.lastIndexOf('.');
        String name = idx > 0 ? fileName.substring(0, idx) : fileName;
        String normalized = name.trim();
        if (normalized.isEmpty()) {
            return "我的上传简历";
        }
        return normalized.length() > 120 ? normalized.substring(0, 120) : normalized;
    }

    private String valueToString(Object value) {
        return value == null ? null : String.valueOf(value);
    }

    private String guessContentTypeByExtension(String fileName) {
        String ext = getFileExtension(fileName);
        switch (ext) {
            case "pdf":
                return "application/pdf";
            case "doc":
                return "application/msword";
            case "docx":
                return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            default:
                return "application/octet-stream";
        }
    }

    public static class ResumeFileInfo {
        private final Path filePath;
        private final String fileName;
        private final String contentType;

        public ResumeFileInfo(Path filePath, String fileName, String contentType) {
            this.filePath = filePath;
            this.fileName = fileName;
            this.contentType = contentType;
        }

        public Path getFilePath() {
            return filePath;
        }

        public String getFileName() {
            return fileName;
        }

        public String getContentType() {
            return contentType;
        }
    }

    private String generateApplicationNo() {
        String time = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        int random = ThreadLocalRandom.current().nextInt(1000, 9999);
        return "AP" + time + random;
    }

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private void saveApplicationLog(
            Long applicationId,
            Integer fromStatus,
            Integer toStatus,
            Long operatorUserId,
            Integer operatorRole,
            String note
    ) {
        ApplicationStatusLog log = new ApplicationStatusLog();
        log.setApplicationId(applicationId);
        log.setFromStatus(fromStatus);
        log.setToStatus(toStatus);
        log.setOperatorUserId(operatorUserId);
        log.setOperatorRole(operatorRole);
        log.setNote(note);
        applicationStatusLogRepository.save(log);
    }
}








