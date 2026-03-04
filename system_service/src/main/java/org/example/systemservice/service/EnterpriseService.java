package org.example.systemservice.service;

import org.example.systemservice.common.ErrorCode;
import org.example.systemservice.dto.enterprise.*;
import org.example.systemservice.dto.student.SendMessageRequest;
import org.example.systemservice.entity.*;
import org.example.systemservice.exception.BizException;
import org.example.systemservice.repository.*;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.ThreadLocalRandom;
import java.util.stream.Collectors;

@Service
public class EnterpriseService {

    private final UserRepository userRepository;
    private final EnterpriseRepository enterpriseRepository;
    private final EnterpriseCertificationRepository enterpriseCertificationRepository;
    private final JobPostingRepository jobPostingRepository;
    private final JobApplicationRepository jobApplicationRepository;
    private final ApplicationStatusLogRepository applicationStatusLogRepository;
    private final ConversationRepository conversationRepository;
    private final MessageRepository messageRepository;
    private final InterviewScheduleRepository interviewScheduleRepository;
    private final InterviewStudentConfirmRepository interviewStudentConfirmRepository;
    private final OfferRepository offerRepository;
    private final OfferStatusLogRepository offerStatusLogRepository;

    private static final Set<Integer> ENTERPRISE_ALLOWED_APPLICATION_STATUS =
            Set.of(2, 3, 4, 5, 6, 7);

    public EnterpriseService(
            UserRepository userRepository,
            EnterpriseRepository enterpriseRepository,
            EnterpriseCertificationRepository enterpriseCertificationRepository,
            JobPostingRepository jobPostingRepository,
            JobApplicationRepository jobApplicationRepository,
            ApplicationStatusLogRepository applicationStatusLogRepository,
            ConversationRepository conversationRepository,
            MessageRepository messageRepository,
            InterviewScheduleRepository interviewScheduleRepository,
            InterviewStudentConfirmRepository interviewStudentConfirmRepository,
            OfferRepository offerRepository,
            OfferStatusLogRepository offerStatusLogRepository
    ) {
        this.userRepository = userRepository;
        this.enterpriseRepository = enterpriseRepository;
        this.enterpriseCertificationRepository = enterpriseCertificationRepository;
        this.jobPostingRepository = jobPostingRepository;
        this.jobApplicationRepository = jobApplicationRepository;
        this.applicationStatusLogRepository = applicationStatusLogRepository;
        this.conversationRepository = conversationRepository;
        this.messageRepository = messageRepository;
        this.interviewScheduleRepository = interviewScheduleRepository;
        this.interviewStudentConfirmRepository = interviewStudentConfirmRepository;
        this.offerRepository = offerRepository;
        this.offerStatusLogRepository = offerStatusLogRepository;
    }

    public Map<String, Object> profileDetail(Long enterpriseUserId) {
        Enterprise enterprise = validateEnterprise(enterpriseUserId);
        return buildEnterpriseProfile(enterprise);
    }

    @Transactional
    public Map<String, Object> updateProfile(
            Long enterpriseUserId,
            EnterpriseProfileUpdateRequest request
    ) {
        Enterprise enterprise = validateEnterprise(enterpriseUserId);

        enterprise.setEnterpriseName(request.getEnterpriseName().trim());
        enterprise.setUnifiedCreditCode(normalize(request.getUnifiedCreditCode()));
        enterprise.setIndustry(normalize(request.getIndustry()));
        enterprise.setCity(normalize(request.getCity()));
        enterprise.setAddress(normalize(request.getAddress()));
        enterprise.setWebsite(normalize(request.getWebsite()));
        enterprise.setLogoUrl(normalize(request.getLogoUrl()));
        enterprise.setIntro(normalize(request.getIntro()));

        try {
            enterprise = enterpriseRepository.save(enterprise);
        } catch (DataIntegrityViolationException ex) {
            throw new BizException(ErrorCode.PARAM_ERROR, "统一社会信用代码重复");
        }

        final String enterpriseName = enterprise.getEnterpriseName();
        userRepository.findById(enterpriseUserId).ifPresent(user -> {
            user.setNickname(enterpriseName);
            userRepository.save(user);
        });

        return buildEnterpriseProfile(enterprise);
    }

    @Transactional
    public Map<String, Object> submitCertification(
            Long enterpriseUserId,
            EnterpriseCertificationSubmitRequest request
    ) {
        Enterprise enterprise = validateEnterprise(enterpriseUserId);

        EnterpriseCertification certification = new EnterpriseCertification();
        certification.setEnterpriseId(enterprise.getId());
        certification.setSubmitterUserId(enterpriseUserId);
        certification.setLicenseFileUrl(request.getLicenseFileUrl().trim());
        certification.setAuditStatus(1);
        certification.setAuditRemark(normalize(request.getSubmitRemark()));
        certification = enterpriseCertificationRepository.save(certification);

        enterprise.setCertifiedStatus(2);
        enterpriseRepository.save(enterprise);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("enterpriseId", enterprise.getId());
        result.put("certifiedStatus", enterprise.getCertifiedStatus());
        result.put("certifiedStatusLabel", certifiedStatusLabel(enterprise.getCertifiedStatus()));
        result.put("certificationId", certification.getId());
        result.put("licenseFileUrl", certification.getLicenseFileUrl());
        result.put("submittedAt", certification.getSubmittedAt());
        result.put("auditStatus", certification.getAuditStatus());
        return result;
    }

    @Transactional
    public JobPosting createJob(Long enterpriseUserId, EnterpriseJobUpsertRequest request) {
        Enterprise enterprise = validateEnterprise(enterpriseUserId);
        validateSalaryRange(request.getSalaryMin(), request.getSalaryMax());
        LocalDateTime now = LocalDateTime.now();

        JobPosting job = new JobPosting();
        fillJobFields(job, request);
        job.setEnterpriseId(enterprise.getId());
        job.setPublisherUserId(enterpriseUserId);
        if (Boolean.TRUE.equals(request.getSubmitForReview())) {
            job.setStatus(2);
            job.setPublishAt(null);
        } else {
            job.setStatus(3);
            job.setPublishAt(now);
        }
        job.setRejectReason(null);
        job.setOfflineAt(null);

        job.setCreatedAt(now);
        job.setUpdatedAt(now);
        return jobPostingRepository.save(job);
    }

    @Transactional
    public JobPosting updateJob(
            Long enterpriseUserId,
            Long jobId,
            EnterpriseJobUpsertRequest request
    ) {
        Enterprise enterprise = validateEnterprise(enterpriseUserId);
        JobPosting job = jobPostingRepository.findByIdAndEnterpriseId(jobId, enterprise.getId())
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "岗位不存在"));

        validateSalaryRange(request.getSalaryMin(), request.getSalaryMax());
        fillJobFields(job, request);

        if (Boolean.TRUE.equals(request.getSubmitForReview())) {
            job.setStatus(2);
            job.setPublishAt(null);
        } else {
            job.setStatus(3);
            if (job.getPublishAt() == null) {
                job.setPublishAt(LocalDateTime.now());
            }
            job.setOfflineAt(null);
        }
        job.setRejectReason(null);
        return jobPostingRepository.save(job);
    }

    @Transactional
    public JobPosting offlineJob(Long enterpriseUserId, Long jobId) {
        Enterprise enterprise = validateEnterprise(enterpriseUserId);
        JobPosting job = jobPostingRepository.findByIdAndEnterpriseId(jobId, enterprise.getId())
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "岗位不存在"));

        job.setStatus(5);
        job.setOfflineAt(LocalDateTime.now());
        return jobPostingRepository.save(job);
    }

    public List<Map<String, Object>> listJobs(Long enterpriseUserId) {
        Enterprise enterprise = validateEnterprise(enterpriseUserId);
        List<JobPosting> jobs = jobPostingRepository.findByEnterpriseIdOrderByCreatedAtDesc(enterprise.getId());
        return jobs.stream().map(job -> {
            Map<String, Object> data = new LinkedHashMap<>();
            data.put("jobId", job.getId());
            data.put("title", job.getTitle());
            data.put("category", job.getCategory());
            data.put("city", job.getCity());
            data.put("salaryMin", job.getSalaryMin());
            data.put("salaryMax", job.getSalaryMax());
            data.put("internshipMonths", job.getInternshipMonths());
            data.put("educationRequirement", job.getEducationRequirement());
            data.put("description", job.getDescription());
            data.put("requirementText", job.getRequirementText());
            data.put("status", job.getStatus());
            data.put("statusLabel", jobStatusLabel(job.getStatus()));
            data.put("rejectReason", job.getRejectReason());
            data.put("publishAt", job.getPublishAt());
            data.put("offlineAt", job.getOfflineAt());
            data.put("createdAt", job.getCreatedAt());
            data.put("updatedAt", job.getUpdatedAt());
            data.put("applicationCount", jobApplicationRepository.countByJobId(job.getId()));
            return data;
        }).collect(Collectors.toList());
    }

    public Map<String, Object> jobDetail(Long enterpriseUserId, Long jobId) {
        Enterprise enterprise = validateEnterprise(enterpriseUserId);
        JobPosting job = jobPostingRepository.findByIdAndEnterpriseId(jobId, enterprise.getId())
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "岗位不存在"));

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("jobId", job.getId());
        data.put("title", job.getTitle());
        data.put("category", job.getCategory());
        data.put("city", job.getCity());
        data.put("salaryMin", job.getSalaryMin());
        data.put("salaryMax", job.getSalaryMax());
        data.put("internshipMonths", job.getInternshipMonths());
        data.put("educationRequirement", job.getEducationRequirement());
        data.put("description", job.getDescription());
        data.put("requirementText", job.getRequirementText());
        data.put("status", job.getStatus());
        data.put("statusLabel", jobStatusLabel(job.getStatus()));
        data.put("rejectReason", job.getRejectReason());
        data.put("publishAt", job.getPublishAt());
        data.put("offlineAt", job.getOfflineAt());
        data.put("createdAt", job.getCreatedAt());
        data.put("updatedAt", job.getUpdatedAt());
        data.put("applicationCount", jobApplicationRepository.countByJobId(job.getId()));
        return data;
    }

    public List<Map<String, Object>> listApplications(Long enterpriseUserId, Integer status, Long jobId) {
        Enterprise enterprise = validateEnterprise(enterpriseUserId);
        List<JobApplication> applications =
                jobApplicationRepository.findByEnterpriseIdOrderByCreatedAtDesc(enterprise.getId());

        List<JobApplication> filtered = applications.stream()
                .filter(app -> status == null || Objects.equals(app.getStatus(), status))
                .filter(app -> jobId == null || Objects.equals(app.getJobId(), jobId))
                .collect(Collectors.toList());

        Map<Long, JobPosting> jobMap = jobPostingRepository.findAllById(
                        filtered.stream().map(JobApplication::getJobId).collect(Collectors.toSet()))
                .stream().collect(Collectors.toMap(JobPosting::getId, it -> it));

        Map<Long, User> studentMap = userRepository.findAllById(
                        filtered.stream().map(JobApplication::getStudentUserId).collect(Collectors.toSet()))
                .stream().collect(Collectors.toMap(User::getId, it -> it));

        return filtered.stream().map(app -> {
            JobPosting job = jobMap.get(app.getJobId());
            User student = studentMap.get(app.getStudentUserId());
            Map<String, Object> data = new LinkedHashMap<>();
            data.put("applicationId", app.getId());
            data.put("applicationNo", app.getApplicationNo());
            data.put("jobId", app.getJobId());
            data.put("jobTitle", job == null ? "-" : job.getTitle());
            data.put("studentUserId", app.getStudentUserId());
            data.put("studentNickname", student == null ? "-" : nicknameOf(student));
            data.put("resumeId", app.getResumeId());
            data.put("status", app.getStatus());
            data.put("statusLabel", applicationStatusLabel(app.getStatus()));
            data.put("rejectReason", app.getRejectReason());
            data.put("submittedAt", app.getSubmittedAt());
            data.put("lastActionAt", app.getLastActionAt());
            data.put("interviewCount", interviewScheduleRepository.countByApplicationId(app.getId()));
            data.put("hasOffer", offerRepository.findByApplicationId(app.getId()).isPresent());
            return data;
        }).collect(Collectors.toList());
    }

    public Map<String, Object> applicationDetail(Long enterpriseUserId, Long applicationId) {
        Enterprise enterprise = validateEnterprise(enterpriseUserId);
        JobApplication application = jobApplicationRepository.findByIdAndEnterpriseId(applicationId, enterprise.getId())
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "投递记录不存在"));

        User student = userRepository.findById(application.getStudentUserId()).orElse(null);
        JobPosting job = jobPostingRepository.findById(application.getJobId()).orElse(null);
        List<ApplicationStatusLog> logs =
                applicationStatusLogRepository.findByApplicationIdOrderByCreatedAtAsc(applicationId);
        List<InterviewSchedule> interviews =
                interviewScheduleRepository.findByApplicationIdOrderByScheduledAtDesc(applicationId);
        Offer offer = offerRepository.findByApplicationId(applicationId).orElse(null);

        Map<String, Object> applicationMap = new LinkedHashMap<>();
        applicationMap.put("applicationId", application.getId());
        applicationMap.put("applicationNo", application.getApplicationNo());
        applicationMap.put("jobId", application.getJobId());
        applicationMap.put("jobTitle", job == null ? "-" : job.getTitle());
        applicationMap.put("studentUserId", application.getStudentUserId());
        applicationMap.put("studentNickname", student == null ? "-" : nicknameOf(student));
        applicationMap.put("resumeId", application.getResumeId());
        applicationMap.put("status", application.getStatus());
        applicationMap.put("statusLabel", applicationStatusLabel(application.getStatus()));
        applicationMap.put("rejectReason", application.getRejectReason());
        applicationMap.put("submittedAt", application.getSubmittedAt());
        applicationMap.put("lastActionAt", application.getLastActionAt());

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("application", applicationMap);
        result.put("statusLogs", logs);
        result.put("interviews", interviews);
        result.put("offer", offer);
        return result;
    }

    @Transactional
    public JobApplication updateApplicationStatus(
            Long enterpriseUserId,
            Long applicationId,
            EnterpriseApplicationStatusUpdateRequest request
    ) {
        Enterprise enterprise = validateEnterprise(enterpriseUserId);
        JobApplication application = jobApplicationRepository.findByIdAndEnterpriseId(applicationId, enterprise.getId())
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "投递记录不存在"));

        Integer toStatus = request.getToStatus();
        if (!ENTERPRISE_ALLOWED_APPLICATION_STATUS.contains(toStatus)) {
            throw new BizException(ErrorCode.PARAM_ERROR, "企业端不支持该状态");
        }
        if (Objects.equals(toStatus, 7) && normalize(request.getRejectReason()) == null) {
            throw new BizException(ErrorCode.PARAM_ERROR, "淘汰时必须填写原因");
        }

        Integer fromStatus = application.getStatus();
        if (Objects.equals(fromStatus, toStatus)) {
            return application;
        }

        application.setStatus(toStatus);
        if (Objects.equals(toStatus, 7)) {
            application.setRejectReason(normalize(request.getRejectReason()));
        } else {
            application.setRejectReason(null);
        }
        application = jobApplicationRepository.save(application);

        String note = normalize(request.getNote());
        if (note == null) {
            note = "企业更新投递状态为 " + applicationStatusLabel(toStatus);
        }
        saveApplicationLog(application.getId(), fromStatus, toStatus, enterpriseUserId, 2, note);
        return application;
    }

    public List<Map<String, Object>> listConversations(Long enterpriseUserId) {
        Enterprise enterprise = validateEnterprise(enterpriseUserId);
        List<Conversation> conversations = conversationRepository.findByEnterpriseIdOrderByUpdatedAtDesc(enterprise.getId());
        Map<Long, User> studentMap = userRepository.findAllById(
                        conversations.stream().map(Conversation::getStudentUserId).collect(Collectors.toSet()))
                .stream()
                .collect(Collectors.toMap(User::getId, it -> it));

        return conversations.stream().map(conversation -> {
            User student = studentMap.get(conversation.getStudentUserId());
            Map<String, Object> map = new LinkedHashMap<>();
            map.put("id", conversation.getId());
            map.put("applicationId", conversation.getApplicationId());
            map.put("studentUserId", conversation.getStudentUserId());
            map.put("counterpartName", studentDisplayName(student));
            map.put("lastMessageAt", conversation.getLastMessageAt());
            map.put("status", conversation.getStatus());
            return map;
        }).collect(Collectors.toList());
    }

    public List<Message> listMessages(Long enterpriseUserId, Long conversationId) {
        Enterprise enterprise = validateEnterprise(enterpriseUserId);
        conversationRepository.findByIdAndEnterpriseId(conversationId, enterprise.getId())
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "会话不存在"));
        return messageRepository.findByConversationIdOrderBySentAtAsc(conversationId);
    }

    @Transactional
    public Message sendMessage(Long enterpriseUserId, Long conversationId, SendMessageRequest request) {
        Enterprise enterprise = validateEnterprise(enterpriseUserId);
        Conversation conversation = conversationRepository.findByIdAndEnterpriseId(conversationId, enterprise.getId())
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "会话不存在"));
        if (request.getMessageType() == 1 && normalize(request.getContentText()) == null) {
            throw new BizException(ErrorCode.PARAM_ERROR, "文本消息内容不能为空");
        }
        Message message = new Message();
        message.setConversationId(conversationId);
        message.setSenderUserId(enterpriseUserId);
        message.setMessageType(request.getMessageType());
        message.setContentText(request.getContentText());
        message.setFileUrl(request.getFileUrl());
        Message saved = messageRepository.save(message);

        conversation.setLastMessageAt(saved.getSentAt());
        conversationRepository.save(conversation);
        return saved;
    }

    @Transactional
    public Map<String, Object> createInterview(
            Long enterpriseUserId,
            EnterpriseInterviewCreateRequest request
    ) {
        Enterprise enterprise = validateEnterprise(enterpriseUserId);
        JobApplication application = jobApplicationRepository
                .findByIdAndEnterpriseId(request.getApplicationId(), enterprise.getId())
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "投递记录不存在"));

        if (application.getStatus() != null
                && (application.getStatus() == 6 || application.getStatus() == 7 || application.getStatus() == 8)) {
            throw new BizException(ErrorCode.APPLICATION_STATUS_INVALID, "当前投递状态不可安排面试");
        }
        if (request.getInterviewType() == null
                || (request.getInterviewType() != 1 && request.getInterviewType() != 2)) {
            throw new BizException(ErrorCode.PARAM_ERROR, "interviewType 仅支持 1(线上) 或 2(线下)");
        }
        if (request.getDurationMinutes() == null || request.getDurationMinutes() <= 0) {
            throw new BizException(ErrorCode.PARAM_ERROR, "面试时长必须大于0");
        }
        if (request.getScheduledAt().isBefore(LocalDateTime.now().minusMinutes(5))) {
            throw new BizException(ErrorCode.PARAM_ERROR, "面试时间不能早于当前时间");
        }

        InterviewSchedule interview = new InterviewSchedule();
        interview.setApplicationId(application.getId());
        interview.setCreatedByUserId(enterpriseUserId);
        interview.setInterviewType(request.getInterviewType());
        interview.setStatus(1);
        interview.setScheduledAt(request.getScheduledAt());
        interview.setDurationMinutes(request.getDurationMinutes());
        interview.setMeetingLink(normalize(request.getMeetingLink()));
        interview.setLocation(normalize(request.getLocation()));
        interview.setRemark(normalize(request.getRemark()));
        LocalDateTime now = LocalDateTime.now();
        interview.setCreatedAt(now);
        interview.setUpdatedAt(now);
        interview = interviewScheduleRepository.save(interview);

        if (application.getStatus() != null
                && (application.getStatus() == 1 || application.getStatus() == 2 || application.getStatus() == 3)) {
            Integer fromStatus = application.getStatus();
            application.setStatus(4);
            jobApplicationRepository.save(application);
            saveApplicationLog(application.getId(), fromStatus, 4, enterpriseUserId, 2, "企业安排面试");
        }

        return buildInterviewMap(interview, application, null);
    }

    public List<Map<String, Object>> listInterviews(Long enterpriseUserId, Long applicationId) {
        Enterprise enterprise = validateEnterprise(enterpriseUserId);
        List<InterviewSchedule> interviews = interviewScheduleRepository.findByEnterpriseId(enterprise.getId());
        if (applicationId != null) {
            interviews = interviews.stream()
                    .filter(item -> Objects.equals(item.getApplicationId(), applicationId))
                    .collect(Collectors.toList());
        }

        Map<Long, JobApplication> applicationMap = jobApplicationRepository.findAllById(
                        interviews.stream().map(InterviewSchedule::getApplicationId).collect(Collectors.toSet()))
                .stream().collect(Collectors.toMap(JobApplication::getId, it -> it));

        Map<Long, User> studentMap = userRepository.findAllById(
                        applicationMap.values().stream()
                                .map(JobApplication::getStudentUserId)
                                .collect(Collectors.toSet()))
                .stream().collect(Collectors.toMap(User::getId, it -> it));

        return interviews.stream().map(interview -> {
            JobApplication app = applicationMap.get(interview.getApplicationId());
            User student = app == null ? null : studentMap.get(app.getStudentUserId());
            InterviewStudentConfirm confirm = interviewStudentConfirmRepository
                    .findByInterviewId(interview.getId())
                    .orElse(null);
            return buildInterviewMap(interview, app, student == null ? null : nicknameOf(student), confirm);
        }).collect(Collectors.toList());
    }

    @Transactional
    public Map<String, Object> submitInterviewResult(
            Long enterpriseUserId,
            Long interviewId,
            EnterpriseInterviewResultRequest request
    ) {
        Enterprise enterprise = validateEnterprise(enterpriseUserId);
        InterviewSchedule interview = interviewScheduleRepository.findByIdAndEnterpriseId(interviewId, enterprise.getId())
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "面试安排不存在"));

        String result = normalize(request.getResult());
        if (result == null) {
            throw new BizException(ErrorCode.PARAM_ERROR, "面试结果不能为空");
        }
        result = result.toLowerCase(Locale.ROOT);
        if (!"pass".equals(result) && !"fail".equals(result) && !"hold".equals(result)) {
            throw new BizException(ErrorCode.PARAM_ERROR, "result 仅支持 pass / fail / hold");
        }
        if (Objects.equals(interview.getStatus(), 4)) {
            throw new BizException(ErrorCode.APPLICATION_STATUS_INVALID, "已取消的面试不能填写结果");
        }

        String note = normalize(request.getNote());
        if (note != null) {
            interview.setRemark(note);
        }
        interview.setStatus(3);
        interview = interviewScheduleRepository.save(interview);

        JobApplication application = jobApplicationRepository.findByIdAndEnterpriseId(
                        interview.getApplicationId(),
                        enterprise.getId())
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "投递记录不存在"));
        Integer fromStatus = application.getStatus();

        Integer toStatus;
        if ("pass".equals(result)) {
            toStatus = 5;
            application.setRejectReason(null);
        } else if ("fail".equals(result)) {
            toStatus = 7;
            application.setRejectReason(note == null ? "面试未通过" : note);
        } else {
            toStatus = 3;
            application.setRejectReason(null);
        }
        application.setStatus(toStatus);
        application = jobApplicationRepository.save(application);
        saveApplicationLog(
                application.getId(),
                fromStatus,
                toStatus,
                enterpriseUserId,
                2,
                "企业填写面试结果: " + result
        );

        Map<String, Object> resultMap = new LinkedHashMap<>();
        resultMap.put("interviewId", interview.getId());
        resultMap.put("applicationId", application.getId());
        resultMap.put("interviewStatus", interview.getStatus());
        resultMap.put("applicationStatus", application.getStatus());
        resultMap.put("applicationStatusLabel", applicationStatusLabel(application.getStatus()));
        resultMap.put("result", result);
        resultMap.put("note", note);
        return resultMap;
    }

    @Transactional
    public Offer createOffer(Long enterpriseUserId, EnterpriseOfferCreateRequest request) {
        Enterprise enterprise = validateEnterprise(enterpriseUserId);
        JobApplication application = jobApplicationRepository
                .findByIdAndEnterpriseId(request.getApplicationId(), enterprise.getId())
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "投递记录不存在"));

        if (application.getStatus() != null && (application.getStatus() == 6 || application.getStatus() == 7)) {
            throw new BizException(ErrorCode.APPLICATION_STATUS_INVALID, "当前投递状态不可发放Offer");
        }
        if (offerRepository.findByApplicationId(application.getId()).isPresent()) {
            throw new BizException(ErrorCode.PARAM_ERROR, "该投递已发放Offer");
        }
        validateSalaryRange(request.getSalaryMin(), request.getSalaryMax());

        Offer offer = new Offer();
        offer.setOfferNo(generateOfferNo());
        offer.setApplicationId(application.getId());
        offer.setJobId(application.getJobId());
        offer.setEnterpriseId(application.getEnterpriseId());
        offer.setStudentUserId(application.getStudentUserId());
        offer.setOfferedByUserId(enterpriseUserId);
        offer.setSalaryMin(request.getSalaryMin());
        offer.setSalaryMax(request.getSalaryMax());
        offer.setInternshipStartDate(request.getInternshipStartDate());
        offer.setInternshipEndDate(request.getInternshipEndDate());
        offer.setTermsText(normalize(request.getTermsText()));
        offer.setStatus(1);
        offer.setExpiresAt(request.getExpiresAt());
        offer.setDecisionAt(null);
        offer.setRejectReason(null);
        LocalDateTime now = LocalDateTime.now();
        offer.setCreatedAt(now);
        offer.setUpdatedAt(now);

        offer = offerRepository.save(offer);

        OfferStatusLog log = new OfferStatusLog();
        log.setOfferId(offer.getId());
        log.setFromStatus(null);
        log.setToStatus(1);
        log.setOperatorUserId(enterpriseUserId);
        log.setNote("企业发放Offer");
        offerStatusLogRepository.save(log);

        if (!Objects.equals(application.getStatus(), 5)) {
            Integer fromStatus = application.getStatus();
            application.setStatus(5);
            application.setRejectReason(null);
            jobApplicationRepository.save(application);
            saveApplicationLog(application.getId(), fromStatus, 5, enterpriseUserId, 2, "企业发放Offer");
        }

        return offer;
    }

    public List<Map<String, Object>> listOffers(Long enterpriseUserId) {
        Enterprise enterprise = validateEnterprise(enterpriseUserId);
        List<Offer> offers = offerRepository.findByEnterpriseIdOrderByCreatedAtDesc(enterprise.getId());

        Map<Long, User> studentMap = userRepository.findAllById(
                        offers.stream().map(Offer::getStudentUserId).collect(Collectors.toSet()))
                .stream().collect(Collectors.toMap(User::getId, it -> it));

        Map<Long, JobPosting> jobMap = jobPostingRepository.findAllById(
                        offers.stream().map(Offer::getJobId).collect(Collectors.toSet()))
                .stream().collect(Collectors.toMap(JobPosting::getId, it -> it));

        return offers.stream().map(offer -> {
            User student = studentMap.get(offer.getStudentUserId());
            JobPosting job = jobMap.get(offer.getJobId());
            Map<String, Object> data = new LinkedHashMap<>();
            data.put("offerId", offer.getId());
            data.put("offerNo", offer.getOfferNo());
            data.put("applicationId", offer.getApplicationId());
            data.put("jobId", offer.getJobId());
            data.put("jobTitle", job == null ? "-" : job.getTitle());
            data.put("studentUserId", offer.getStudentUserId());
            data.put("studentNickname", student == null ? "-" : nicknameOf(student));
            data.put("salaryMin", offer.getSalaryMin());
            data.put("salaryMax", offer.getSalaryMax());
            data.put("internshipStartDate", offer.getInternshipStartDate());
            data.put("internshipEndDate", offer.getInternshipEndDate());
            data.put("termsText", offer.getTermsText());
            data.put("status", offer.getStatus());
            data.put("statusLabel", offerStatusLabel(offer.getStatus()));
            data.put("expiresAt", offer.getExpiresAt());
            data.put("decisionAt", offer.getDecisionAt());
            data.put("rejectReason", offer.getRejectReason());
            data.put("createdAt", offer.getCreatedAt());
            return data;
        }).collect(Collectors.toList());
    }

    private Enterprise validateEnterprise(Long enterpriseUserId) {
        boolean valid = userRepository.existsByIdAndUserTypeAndIsDeleted(enterpriseUserId, 2, 0);
        if (!valid) {
            throw new BizException(ErrorCode.USER_TYPE_MISMATCH, "企业身份无效");
        }
        Enterprise enterprise = enterpriseRepository.findByOwnerUserId(enterpriseUserId)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "企业信息不存在"));
        if (!Objects.equals(enterprise.getEnterpriseStatus(), 1)) {
            throw new BizException(ErrorCode.ACCOUNT_DISABLED, "企业账号已被冻结");
        }
        return enterprise;
    }

    private void fillJobFields(JobPosting job, EnterpriseJobUpsertRequest request) {
        job.setTitle(request.getTitle().trim());
        job.setCategory(normalize(request.getCategory()));
        job.setCity(normalize(request.getCity()));
        job.setSalaryMin(request.getSalaryMin());
        job.setSalaryMax(request.getSalaryMax());
        job.setInternshipMonths(request.getInternshipMonths());
        job.setEducationRequirement(normalize(request.getEducationRequirement()));
        job.setDescription(request.getDescription().trim());
        job.setRequirementText(normalize(request.getRequirementText()));
    }

    private void validateSalaryRange(BigDecimal salaryMin, BigDecimal salaryMax) {
        if (salaryMin != null && salaryMax != null && salaryMin.compareTo(salaryMax) > 0) {
            throw new BizException(ErrorCode.PARAM_ERROR, "最低薪资不能高于最高薪资");
        }
    }

    private Map<String, Object> buildEnterpriseProfile(Enterprise enterprise) {
        Map<String, Object> profile = new LinkedHashMap<>();
        profile.put("enterpriseId", enterprise.getId());
        profile.put("ownerUserId", enterprise.getOwnerUserId());
        profile.put("enterpriseName", enterprise.getEnterpriseName());
        profile.put("unifiedCreditCode", enterprise.getUnifiedCreditCode());
        profile.put("industry", enterprise.getIndustry());
        profile.put("city", enterprise.getCity());
        profile.put("address", enterprise.getAddress());
        profile.put("website", enterprise.getWebsite());
        profile.put("logoUrl", enterprise.getLogoUrl());
        profile.put("intro", enterprise.getIntro());
        profile.put("certifiedStatus", enterprise.getCertifiedStatus());
        profile.put("certifiedStatusLabel", certifiedStatusLabel(enterprise.getCertifiedStatus()));
        profile.put("enterpriseStatus", enterprise.getEnterpriseStatus());
        profile.put("enterpriseStatusLabel", enterpriseStatusLabel(enterprise.getEnterpriseStatus()));
        enterpriseCertificationRepository.findTopByEnterpriseIdOrderBySubmittedAtDesc(enterprise.getId())
                .ifPresent(cert -> {
                    profile.put("latestCertificationId", cert.getId());
                    profile.put("latestCertificationAuditStatus", cert.getAuditStatus());
                    profile.put("latestCertificationSubmittedAt", cert.getSubmittedAt());
                });
        return profile;
    }

    private Map<String, Object> buildInterviewMap(
            InterviewSchedule interview,
            JobApplication application,
            String studentNickname
    ) {
        return buildInterviewMap(interview, application, studentNickname, null);
    }

    private Map<String, Object> buildInterviewMap(
            InterviewSchedule interview,
            JobApplication application,
            String studentNickname,
            InterviewStudentConfirm confirm
    ) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("interviewId", interview.getId());
        map.put("applicationId", interview.getApplicationId());
        map.put("studentUserId", application == null ? null : application.getStudentUserId());
        map.put("studentNickname", studentNickname == null ? "-" : studentNickname);
        map.put("interviewType", interview.getInterviewType());
        map.put("interviewTypeLabel", interviewTypeLabel(interview.getInterviewType()));
        map.put("status", interview.getStatus());
        map.put("statusLabel", interviewStatusLabel(interview.getStatus()));
        map.put("scheduledAt", interview.getScheduledAt());
        map.put("durationMinutes", interview.getDurationMinutes());
        map.put("meetingLink", interview.getMeetingLink());
        map.put("location", interview.getLocation());
        map.put("remark", interview.getRemark());
        map.put("createdAt", interview.getCreatedAt());
        map.put("updatedAt", interview.getUpdatedAt());
        if (confirm != null) {
            map.put("confirmActionType", confirm.getActionType());
            map.put("confirmAction", interviewConfirmActionCode(confirm.getActionType()));
            map.put("confirmActionLabel", interviewConfirmActionLabel(confirm.getActionType()));
            map.put("confirmNote", confirm.getNote());
            map.put("confirmExpectedRescheduleAt", confirm.getExpectedRescheduleAt());
            map.put("confirmSubmittedAt", confirm.getSubmittedAt());
        }
        return map;
    }

    private String interviewConfirmActionCode(Integer actionType) {
        if (Objects.equals(actionType, 1)) {
            return "confirm";
        }
        if (Objects.equals(actionType, 2)) {
            return "reschedule";
        }
        if (Objects.equals(actionType, 3)) {
            return "decline";
        }
        return "unknown";
    }

    private String interviewConfirmActionLabel(Integer actionType) {
        if (Objects.equals(actionType, 1)) {
            return "确认参加";
        }
        if (Objects.equals(actionType, 2)) {
            return "申请改期";
        }
        if (Objects.equals(actionType, 3)) {
            return "无法参加";
        }
        return "未知";
    }

    private String certifiedStatusLabel(Integer status) {
        if (Objects.equals(status, 1)) {
            return "未提交";
        }
        if (Objects.equals(status, 2)) {
            return "待审核";
        }
        if (Objects.equals(status, 3)) {
            return "已通过";
        }
        if (Objects.equals(status, 4)) {
            return "已驳回";
        }
        return "未知";
    }

    private String enterpriseStatusLabel(Integer status) {
        if (Objects.equals(status, 1)) {
            return "正常";
        }
        if (Objects.equals(status, 2)) {
            return "冻结";
        }
        return "未知";
    }

    private String jobStatusLabel(Integer status) {
        if (Objects.equals(status, 1)) {
            return "草稿";
        }
        if (Objects.equals(status, 2)) {
            return "待审核";
        }
        if (Objects.equals(status, 3)) {
            return "已上线";
        }
        if (Objects.equals(status, 4)) {
            return "已驳回";
        }
        if (Objects.equals(status, 5)) {
            return "已下线";
        }
        return "未知";
    }

    private String applicationStatusLabel(Integer status) {
        if (Objects.equals(status, 1)) {
            return "已投递";
        }
        if (Objects.equals(status, 2)) {
            return "已查看";
        }
        if (Objects.equals(status, 3)) {
            return "沟通中";
        }
        if (Objects.equals(status, 4)) {
            return "面试中";
        }
        if (Objects.equals(status, 5)) {
            return "Offer阶段";
        }
        if (Objects.equals(status, 6)) {
            return "已录用";
        }
        if (Objects.equals(status, 7)) {
            return "已淘汰";
        }
        if (Objects.equals(status, 8)) {
            return "已撤回";
        }
        return "未知";
    }

    private String interviewTypeLabel(Integer type) {
        if (Objects.equals(type, 1)) {
            return "线上";
        }
        if (Objects.equals(type, 2)) {
            return "线下";
        }
        return "未知";
    }

    private String interviewStatusLabel(Integer status) {
        if (Objects.equals(status, 1)) {
            return "待确认";
        }
        if (Objects.equals(status, 2)) {
            return "已确认";
        }
        if (Objects.equals(status, 3)) {
            return "已完成";
        }
        if (Objects.equals(status, 4)) {
            return "已取消";
        }
        return "未知";
    }

    private String offerStatusLabel(Integer status) {
        if (Objects.equals(status, 1)) {
            return "已发放";
        }
        if (Objects.equals(status, 2)) {
            return "已接受";
        }
        if (Objects.equals(status, 3)) {
            return "已拒绝";
        }
        if (Objects.equals(status, 4)) {
            return "已过期";
        }
        return "未知";
    }

    private String nicknameOf(User user) {
        if (user.getNickname() != null && !user.getNickname().trim().isEmpty()) {
            return user.getNickname().trim();
        }
        return "学生#" + user.getId();
    }

    private String studentDisplayName(User user) {
        if (user == null) {
            return "学生";
        }
        if (user.getNickname() != null && !user.getNickname().trim().isEmpty()) {
            return user.getNickname().trim();
        }
        return "学生";
    }

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String generateOfferNo() {
        String time = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        int random = ThreadLocalRandom.current().nextInt(1000, 9999);
        return "OF" + time + random;
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
