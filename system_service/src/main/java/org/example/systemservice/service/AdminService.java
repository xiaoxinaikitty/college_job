package org.example.systemservice.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.systemservice.common.ErrorCode;
import org.example.systemservice.dto.admin.*;
import org.example.systemservice.entity.*;
import org.example.systemservice.exception.BizException;
import org.example.systemservice.repository.*;
import org.example.systemservice.security.JwtTokenProvider;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

@Service
public class AdminService {

    private final UserRepository userRepository;
    private final EnterpriseRepository enterpriseRepository;
    private final EnterpriseCertificationRepository enterpriseCertificationRepository;
    private final JobPostingRepository jobPostingRepository;
    private final JobApplicationRepository jobApplicationRepository;
    private final ApplicationStatusLogRepository applicationStatusLogRepository;
    private final InterviewScheduleRepository interviewScheduleRepository;
    private final OfferRepository offerRepository;
    private final ResumeRepository resumeRepository;
    private final ReportRepository reportRepository;
    private final EnterpriseReviewRepository enterpriseReviewRepository;
    private final MessageRepository messageRepository;
    private final PenaltyRecordRepository penaltyRecordRepository;
    private final UserNotificationRepository userNotificationRepository;
    private final AdminOperationLogRepository adminOperationLogRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final ObjectMapper objectMapper;

    private final Map<Long, String> reviewStatusOverrides = new ConcurrentHashMap<>();
    private final Map<Long, PenaltyMeta> penaltyMetaStore = new ConcurrentHashMap<>();
    private final Map<Long, NotificationDraft> notificationStore = new ConcurrentHashMap<>();
    private final Map<Long, RuleItem> ruleStore = new ConcurrentHashMap<>();
    private final Map<String, Set<String>> rolePermissions = new ConcurrentHashMap<>();
    private final AtomicLong notificationIdGen = new AtomicLong(1L);

    private volatile Long cachedAdminUserId;
    private volatile LocalDateTime adminLastLoginAt;

    public AdminService(
            UserRepository userRepository,
            EnterpriseRepository enterpriseRepository,
            EnterpriseCertificationRepository enterpriseCertificationRepository,
            JobPostingRepository jobPostingRepository,
            JobApplicationRepository jobApplicationRepository,
            ApplicationStatusLogRepository applicationStatusLogRepository,
            InterviewScheduleRepository interviewScheduleRepository,
            OfferRepository offerRepository,
            ResumeRepository resumeRepository,
            ReportRepository reportRepository,
            EnterpriseReviewRepository enterpriseReviewRepository,
            MessageRepository messageRepository,
            PenaltyRecordRepository penaltyRecordRepository,
            UserNotificationRepository userNotificationRepository,
            AdminOperationLogRepository adminOperationLogRepository,
            PasswordEncoder passwordEncoder,
            JwtTokenProvider jwtTokenProvider,
            ObjectMapper objectMapper
    ) {
        this.userRepository = userRepository;
        this.enterpriseRepository = enterpriseRepository;
        this.enterpriseCertificationRepository = enterpriseCertificationRepository;
        this.jobPostingRepository = jobPostingRepository;
        this.jobApplicationRepository = jobApplicationRepository;
        this.applicationStatusLogRepository = applicationStatusLogRepository;
        this.interviewScheduleRepository = interviewScheduleRepository;
        this.offerRepository = offerRepository;
        this.resumeRepository = resumeRepository;
        this.reportRepository = reportRepository;
        this.enterpriseReviewRepository = enterpriseReviewRepository;
        this.messageRepository = messageRepository;
        this.penaltyRecordRepository = penaltyRecordRepository;
        this.userNotificationRepository = userNotificationRepository;
        this.adminOperationLogRepository = adminOperationLogRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenProvider = jwtTokenProvider;
        this.objectMapper = objectMapper;
        initRules();
        initRoles();
    }

    private void initRules() {
        addRule(1L, "企业审核", "营业执照有效性校验", "统一信用代码异常", "人工复核");
        addRule(2L, "岗位审核", "高风险关键词拦截", "岗位描述包含风险词", "标记并审核");
        addRule(3L, "举报治理", "重复举报聚合", "24小时举报>=3次", "升级工单");
        addRule(4L, "评价治理", "低分评价预警", "连续低分评价", "运营复核");
        addRule(5L, "账号治理", "异常活跃冻结策略", "高频违规操作", "冻结账号");
    }

    private void initRoles() {
        Set<String> all = permissionItems().stream().map(it -> it.get("key")).collect(Collectors.toCollection(LinkedHashSet::new));
        rolePermissions.put("super_admin", all);
        rolePermissions.put("auditor", new LinkedHashSet<>(List.of("dashboard:view", "enterpriseAudit:view", "jobAudit:view", "reports:view", "reviews:view", "logs:view")));
        rolePermissions.put("operator", new LinkedHashSet<>(List.of("dashboard:view", "users:view", "applications:view", "notifications:view", "penalties:view")));
    }

    private void addRule(Long id, String module, String ruleName, String hitCondition, String action) {
        RuleItem item = new RuleItem();
        item.id = id;
        item.module = module;
        item.ruleName = ruleName;
        item.hitCondition = hitCondition;
        item.action = action;
        item.enabled = true;
        item.updatedAt = LocalDateTime.now();
        ruleStore.put(id, item);
    }

    private Long resolveOperatorId(Long operatorId) {
        if (operatorId != null && userRepository.existsByIdAndUserTypeAndIsDeleted(operatorId, 3, 0)) {
            return operatorId;
        }
        return ensureAdminUser();
    }

    private Long ensureAdminUser() {
        if (cachedAdminUserId != null && userRepository.existsByIdAndUserTypeAndIsDeleted(cachedAdminUserId, 3, 0)) {
            return cachedAdminUserId;
        }
        Optional<User> existing = userRepository.findTopByUserTypeAndIsDeletedOrderByIdAsc(3, 0);
        if (existing.isPresent()) {
            cachedAdminUserId = existing.get().getId();
            return cachedAdminUserId;
        }
        User admin = new User();
        admin.setUserType(3);
        admin.setAccountStatus(1);
        admin.setNickname("系统管理员");
        admin.setRealName("系统管理员");
        admin.setPasswordHash(passwordEncoder.encode("123456"));
        admin = userRepository.save(admin);
        cachedAdminUserId = admin.getId();
        return admin.getId();
    }

    private void log(Long operatorId, String module, String action, String targetType, Long targetId, Map<String, Object> detail) {
        try {
            Map<String, Object> payload = new LinkedHashMap<>(detail == null ? Collections.emptyMap() : detail);
            payload.putIfAbsent("result", "成功");
            payload.putIfAbsent("ip", "127.0.0.1");
            AdminOperationLog op = new AdminOperationLog();
            op.setOperatorUserId(resolveOperatorId(operatorId));
            op.setModule(module);
            op.setAction(action);
            op.setTargetType(targetType);
            op.setTargetId(targetId);
            op.setDetailJson(objectMapper.writeValueAsString(payload));
            op.setOperatedAt(LocalDateTime.now());
            adminOperationLogRepository.save(op);
        } catch (Exception ignored) {
        }
    }

    @Transactional
    public Map<String, Object> login(AdminLoginRequest request) {
        String account = normalize(request.getAccount());
        String password = request.getPassword() == null ? "" : request.getPassword();
        if (!"admin".equals(account) || !"123456".equals(password)) {
            throw new BizException(ErrorCode.PASSWORD_ERROR, "管理员账号或密码错误");
        }
        Long adminId = ensureAdminUser();
        adminLastLoginAt = LocalDateTime.now();
        log(adminId, "auth", "login", "admin", adminId, Map.of());

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("token", jwtTokenProvider.createToken(adminId, 3));
        data.put("expiresIn", jwtTokenProvider.getExpireSeconds());
        data.put("user", adminUser(adminId));
        data.put("permissions", new ArrayList<>(rolePermissions.get("super_admin")));
        return data;
    }

    public Map<String, Object> me() {
        Long adminId = ensureAdminUser();
        return Map.of(
                "user", adminUser(adminId),
                "permissions", new ArrayList<>(rolePermissions.get("super_admin"))
        );
    }

    public Map<String, Object> logout(Long operatorId) {
        Long adminId = resolveOperatorId(operatorId);
        log(adminId, "auth", "logout", "admin", adminId, Map.of());
        return Map.of("success", true, "logoutAt", LocalDateTime.now());
    }

    public Map<String, Object> dashboardMetrics() {
        long register = userRepository.findAll().stream()
                .filter(u -> Objects.equals(u.getIsDeleted(), 0))
                .filter(u -> !Objects.equals(u.getUserType(), 3))
                .count();
        long jobs = jobPostingRepository.count();
        long applications = jobApplicationRepository.count();
        long interviews = interviewScheduleRepository.count();
        long offers = offerRepository.count();
        long hired = jobApplicationRepository.findAll().stream().filter(a -> Objects.equals(a.getStatus(), 6)).count();

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("register", metric(register, 12, true));
        result.put("jobs", metric(jobs, 8, true));
        result.put("applications", metric(applications, 10, true));
        result.put("interviews", metric(interviews, 6, true));
        result.put("offers", metric(offers, 3, true));
        result.put("hired", metric(hired, 2, true));
        return result;
    }

    public List<Map<String, Object>> dashboardTrend(Integer days) {
        int d = days == null ? 7 : Math.max(1, Math.min(days, 30));
        LocalDate start = LocalDate.now().minusDays(d - 1L);

        Map<LocalDate, Long> registerMap = countByDay(userRepository.findAll().stream()
                .filter(u -> Objects.equals(u.getIsDeleted(), 0))
                .filter(u -> !Objects.equals(u.getUserType(), 3))
                .map(User::getCreatedAt)
                .toList());
        Map<LocalDate, Long> appMap = countByDay(jobApplicationRepository.findAll().stream().map(JobApplication::getCreatedAt).toList());
        Map<LocalDate, Long> offerMap = countByDay(offerRepository.findAll().stream().map(Offer::getCreatedAt).toList());

        List<Map<String, Object>> rows = new ArrayList<>();
        for (int i = 0; i < d; i++) {
            LocalDate day = start.plusDays(i);
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("day", day.format(DateTimeFormatter.ofPattern("MM-dd")));
            row.put("register", registerMap.getOrDefault(day, 0L));
            row.put("application", appMap.getOrDefault(day, 0L));
            row.put("offer", offerMap.getOrDefault(day, 0L));
            rows.add(row);
        }
        return rows;
    }

    public List<Map<String, Object>> dashboardPipeline() {
        long entPending = enterpriseCertificationRepository.findAll().stream().filter(it -> Objects.equals(it.getAuditStatus(), 1)).count();
        long jobPending = jobPostingRepository.findAll().stream().filter(it -> Objects.equals(it.getStatus(), 2)).count();
        long reportProcessing = reportRepository.findAll().stream().filter(it -> Objects.equals(it.getStatus(), 2)).count();
        long riskReview = enterpriseReviewRepository.findAll().stream().filter(it -> "risk".equals(reviewStatus(it))).count();
        return List.of(
                pipeline("企业资质待审", entPending, "pending"),
                pipeline("岗位待审", jobPending, "pending"),
                pipeline("举报处理中", reportProcessing, "danger"),
                pipeline("风险评价", riskReview, "info")
        );
    }

    public List<Map<String, Object>> dashboardTodos() {
        long entPending = enterpriseCertificationRepository.findAll().stream().filter(it -> Objects.equals(it.getAuditStatus(), 1)).count();
        long jobPending = jobPostingRepository.findAll().stream().filter(it -> Objects.equals(it.getStatus(), 2)).count();
        long reports = reportRepository.findAll().stream().filter(it -> Objects.equals(it.getStatus(), 1) || Objects.equals(it.getStatus(), 2)).count();
        long appWarn = jobApplicationRepository.findAll().stream().filter(this::isOverdue).count();
        long noticeDraft = notificationStore.values().stream().filter(it -> "draft".equals(it.status)).count();
        return List.of(
                todo(1L, "处理企业资质审核待办", entPending, "/admin/enterprise-audit"),
                todo(2L, "处理岗位审核待办", jobPending, "/admin/job-audit"),
                todo(3L, "处理举报工单", reports, "/admin/reports"),
                todo(4L, "跟进投递流程预警", appWarn, "/admin/applications"),
                todo(5L, "发布平台通知公告", noticeDraft, "/admin/notifications")
        );
    }

    public Map<String, Object> listEnterpriseAudits(Integer page, Integer pageSize, String keyword, String status, String riskLevel) {
        Integer statusVal = parseEnterpriseAuditStatus(status);
        String key = normalize(keyword);
        String risk = normalize(riskLevel);
        Map<Long, Enterprise> entMap = enterpriseRepository.findAll().stream().collect(Collectors.toMap(Enterprise::getId, it -> it));
        Map<Long, User> userMap = userRepository.findAll().stream().collect(Collectors.toMap(User::getId, it -> it));

        List<Map<String, Object>> rows = enterpriseCertificationRepository.findAll().stream()
                .sorted(Comparator.comparing(EnterpriseCertification::getSubmittedAt, Comparator.nullsLast(LocalDateTime::compareTo)).reversed())
                .map(cert -> {
                    Enterprise ent = entMap.get(cert.getEnterpriseId());
                    User submitter = userMap.get(cert.getSubmitterUserId());
                    String lv = enterpriseRisk(ent, cert);
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("id", cert.getId());
                    m.put("enterpriseName", ent == null ? "-" : safe(ent.getEnterpriseName()));
                    m.put("creditCode", ent == null ? "-" : safe(ent.getUnifiedCreditCode()));
                    m.put("industry", ent == null ? "-" : safe(ent.getIndustry()));
                    m.put("city", ent == null ? "-" : safe(ent.getCity()));
                    m.put("submitter", displayUser(submitter));
                    m.put("submittedAt", cert.getSubmittedAt());
                    m.put("riskLevel", lv);
                    m.put("status", enterpriseAuditStatusCode(cert.getAuditStatus()));
                    m.put("statusLabel", enterpriseAuditStatusLabel(cert.getAuditStatus()));
                    m.put("licenseFileUrl", safe(cert.getLicenseFileUrl()));
                    m.put("note", safe(cert.getAuditRemark()));
                    return m;
                })
                .filter(m -> statusVal == null || Objects.equals(parseEnterpriseAuditStatus((String) m.get("status")), statusVal))
                .filter(m -> risk == null || risk.equals(m.get("riskLevel")))
                .filter(m -> key == null || containsAny(key, m.get("enterpriseName"), m.get("creditCode")))
                .toList();
        return page(rows, page, pageSize);
    }

    public Map<String, Object> enterpriseAuditDetail(Long id) {
        return ((List<Map<String, Object>>) listEnterpriseAudits(1, Integer.MAX_VALUE, null, null, null).get("records")).stream()
                .filter(m -> Objects.equals(m.get("id"), id))
                .findFirst()
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "企业资质记录不存在"));
    }

    @Transactional
    public Map<String, Object> approveEnterpriseAudit(Long operatorId, Long id, AdminApproveRequest request) {
        Long adminId = resolveOperatorId(operatorId);
        EnterpriseCertification cert = enterpriseCertificationRepository.findById(id)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "企业资质记录不存在"));
        Enterprise ent = enterpriseRepository.findById(cert.getEnterpriseId())
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "企业不存在"));
        cert.setAuditStatus(2);
        cert.setAuditRemark(normalize(request == null ? null : request.getNote()));
        cert.setAuditedBy(adminId);
        cert.setAuditedAt(LocalDateTime.now());
        enterpriseCertificationRepository.save(cert);
        ent.setCertifiedStatus(3);
        enterpriseRepository.save(ent);
        log(adminId, "enterpriseAudit", "approve", "enterpriseCertification", id, Map.of());
        return enterpriseAuditDetail(id);
    }

    @Transactional
    public Map<String, Object> rejectEnterpriseAudit(Long operatorId, Long id, AdminRejectRequest request) {
        Long adminId = resolveOperatorId(operatorId);
        EnterpriseCertification cert = enterpriseCertificationRepository.findById(id)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "企业资质记录不存在"));
        Enterprise ent = enterpriseRepository.findById(cert.getEnterpriseId())
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "企业不存在"));
        cert.setAuditStatus(3);
        cert.setAuditRemark(request.getReason().trim());
        cert.setAuditedBy(adminId);
        cert.setAuditedAt(LocalDateTime.now());
        enterpriseCertificationRepository.save(cert);
        ent.setCertifiedStatus(4);
        enterpriseRepository.save(ent);
        log(adminId, "enterpriseAudit", "reject", "enterpriseCertification", id, Map.of("reason", request.getReason().trim()));
        return enterpriseAuditDetail(id);
    }

    public Map<String, Object> listJobAudits(Integer page, Integer pageSize, String keyword, String status, String city) {
        Integer statusVal = parseJobAuditStatus(status);
        String key = normalize(keyword);
        String cityVal = normalize(city);
        Map<Long, Enterprise> entMap = enterpriseRepository.findAll().stream().collect(Collectors.toMap(Enterprise::getId, it -> it));

        List<Map<String, Object>> rows = jobPostingRepository.findAll().stream()
                .sorted(Comparator.comparing(JobPosting::getCreatedAt, Comparator.nullsLast(LocalDateTime::compareTo)).reversed())
                .filter(job -> statusVal == null
                        ? (Objects.equals(job.getStatus(), 2) || Objects.equals(job.getStatus(), 3) || Objects.equals(job.getStatus(), 4))
                        : Objects.equals(job.getStatus(), statusVal))
                .map(job -> {
                    Enterprise ent = entMap.get(job.getEnterpriseId());
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("id", job.getId());
                    m.put("title", safe(job.getTitle()));
                    m.put("enterpriseName", ent == null ? "-" : safe(ent.getEnterpriseName()));
                    m.put("city", safe(job.getCity()));
                    m.put("category", safe(job.getCategory()));
                    m.put("salaryRange", salaryRange(job.getSalaryMin(), job.getSalaryMax()));
                    m.put("submittedAt", job.getCreatedAt());
                    m.put("status", jobAuditStatusCode(job.getStatus()));
                    m.put("statusLabel", jobAuditStatusLabel(job.getStatus()));
                    m.put("riskLevel", jobRisk(job));
                    m.put("reason", safe(job.getRejectReason()));
                    return m;
                })
                .filter(m -> key == null || containsAny(key, m.get("title"), m.get("enterpriseName")))
                .filter(m -> cityVal == null || cityVal.equals(m.get("city")))
                .toList();
        return page(rows, page, pageSize);
    }

    public Map<String, Object> jobAuditDetail(Long id) {
        JobPosting job = jobPostingRepository.findById(id)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "岗位不存在"));
        Enterprise ent = enterpriseRepository.findById(job.getEnterpriseId()).orElse(null);
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", job.getId());
        m.put("title", safe(job.getTitle()));
        m.put("enterpriseName", ent == null ? "-" : safe(ent.getEnterpriseName()));
        m.put("city", safe(job.getCity()));
        m.put("category", safe(job.getCategory()));
        m.put("salaryRange", salaryRange(job.getSalaryMin(), job.getSalaryMax()));
        m.put("submittedAt", job.getCreatedAt());
        m.put("status", jobAuditStatusCode(job.getStatus()));
        m.put("statusLabel", jobAuditStatusLabel(job.getStatus()));
        m.put("riskLevel", jobRisk(job));
        m.put("reason", safe(job.getRejectReason()));
        m.put("description", safe(job.getDescription()));
        m.put("requirementText", safe(job.getRequirementText()));
        return m;
    }

    @Transactional
    public Map<String, Object> approveJobAudit(Long operatorId, Long id) {
        Long adminId = resolveOperatorId(operatorId);
        JobPosting job = jobPostingRepository.findById(id)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "岗位不存在"));
        job.setStatus(3);
        job.setRejectReason(null);
        if (job.getPublishAt() == null) {
            job.setPublishAt(LocalDateTime.now());
        }
        jobPostingRepository.save(job);
        log(adminId, "jobAudit", "approve", "job", id, Map.of());
        return jobAuditDetail(id);
    }

    @Transactional
    public Map<String, Object> rejectJobAudit(Long operatorId, Long id, AdminRejectRequest request) {
        Long adminId = resolveOperatorId(operatorId);
        JobPosting job = jobPostingRepository.findById(id)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "岗位不存在"));
        job.setStatus(4);
        job.setRejectReason(request.getReason().trim());
        jobPostingRepository.save(job);
        log(adminId, "jobAudit", "reject", "job", id, Map.of("reason", request.getReason().trim()));
        return jobAuditDetail(id);
    }

    public Map<String, Object> listUsers(Integer page, Integer pageSize, String keyword, String userType, String status) {
        String key = normalize(keyword);
        Integer typeVal = parseUserTypeCode(userType);
        Integer statusVal = parseUserStatus(status);

        List<Map<String, Object>> rows = userRepository.findAll().stream()
                .filter(u -> Objects.equals(u.getIsDeleted(), 0))
                .filter(u -> Objects.equals(u.getUserType(), 1) || Objects.equals(u.getUserType(), 2))
                .filter(u -> typeVal == null || Objects.equals(u.getUserType(), typeVal))
                .filter(u -> statusVal == null || Objects.equals(u.getAccountStatus(), statusVal))
                .filter(u -> key == null || containsAny(key, u.getNickname(), u.getPhone()))
                .sorted(Comparator.comparing(User::getCreatedAt, Comparator.nullsLast(LocalDateTime::compareTo)).reversed())
                .map(this::userSummary)
                .toList();
        return page(rows, page, pageSize);
    }

    public Map<String, Object> userDetail(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "用户不存在"));
        Map<String, Object> m = new LinkedHashMap<>(userSummary(user));
        m.put("email", safe(user.getEmail()));
        m.put("realName", safe(user.getRealName()));
        m.put("avatarUrl", safe(user.getAvatarUrl()));
        if (Objects.equals(user.getUserType(), 1)) {
            m.put("resumeCount", resumeRepository.countByStudentUserId(user.getId()));
            m.put("applicationCount", jobApplicationRepository.findByStudentUserIdOrderByCreatedAtDesc(user.getId()).size());
        }
        if (Objects.equals(user.getUserType(), 2)) {
            Enterprise ent = enterpriseRepository.findByOwnerUserId(user.getId()).orElse(null);
            if (ent != null) {
                m.put("enterpriseId", ent.getId());
                m.put("enterpriseName", safe(ent.getEnterpriseName()));
                m.put("enterpriseStatus", enterpriseStatusLabel(ent.getEnterpriseStatus()));
                m.put("certifiedStatus", enterpriseCertifiedStatusLabel(ent.getCertifiedStatus()));
            }
        }
        return m;
    }

    @Transactional
    public Map<String, Object> updateUserStatus(Long operatorId, Long id, AdminUserStatusRequest request) {
        Long adminId = resolveOperatorId(operatorId);
        User user = userRepository.findById(id)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "用户不存在"));
        Integer statusVal = parseUserStatus(request.getStatus());
        if (statusVal == null) {
            throw new BizException(ErrorCode.PARAM_ERROR, "用户状态不合法");
        }
        user.setAccountStatus(statusVal);
        userRepository.save(user);
        if (Objects.equals(user.getUserType(), 2)) {
            enterpriseRepository.findByOwnerUserId(user.getId()).ifPresent(ent -> {
                ent.setEnterpriseStatus(Objects.equals(statusVal, 3) ? 2 : 1);
                enterpriseRepository.save(ent);
            });
        }
        log(adminId, "users", "status_update", "user", id, Map.of("status", request.getStatus()));
        return userDetail(id);
    }

    @Transactional
    public Map<String, Object> freezeUser(Long operatorId, Long id, AdminFreezeRequest request) {
        Long adminId = resolveOperatorId(operatorId);
        User user = userRepository.findById(id)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "用户不存在"));
        user.setAccountStatus(3);
        userRepository.save(user);
        if (Objects.equals(user.getUserType(), 2)) {
            enterpriseRepository.findByOwnerUserId(user.getId()).ifPresent(ent -> {
                ent.setEnterpriseStatus(2);
                enterpriseRepository.save(ent);
            });
        }
        String reason = normalize(request.getReason()) == null ? "违规行为处理" : request.getReason().trim();
        PenaltyRecord p = createPenaltyRecord(adminId, Objects.equals(user.getUserType(), 2) ? 2 : 1, user.getId(), 2, reason);
        penaltyMetaStore.put(p.getId(), new PenaltyMeta(displayUser(user), Objects.equals(user.getUserType(), 2) ? "企业" : "学生", "冻结账号 " + request.getDurationDays() + " 天", "高"));
        log(adminId, "users", "freeze", "user", id, Map.of("reason", reason));
        return userDetail(id);
    }

    public Map<String, Object> listApplicationMonitors(Integer page, Integer pageSize, String keyword, String stage) {
        String key = normalize(keyword);
        String stageVal = normalize(stage);
        Map<Long, User> userMap = userRepository.findAll().stream().collect(Collectors.toMap(User::getId, it -> it));
        Map<Long, Enterprise> entMap = enterpriseRepository.findAll().stream().collect(Collectors.toMap(Enterprise::getId, it -> it));
        Map<Long, JobPosting> jobMap = jobPostingRepository.findAll().stream().collect(Collectors.toMap(JobPosting::getId, it -> it));

        List<Map<String, Object>> rows = jobApplicationRepository.findAll().stream()
                .sorted(Comparator.comparing(JobApplication::getSubmittedAt, Comparator.nullsLast(LocalDateTime::compareTo)).reversed())
                .map(app -> {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("id", app.getId());
                    m.put("applicationNo", safe(app.getApplicationNo()));
                    m.put("studentName", displayUser(userMap.get(app.getStudentUserId())));
                    m.put("enterpriseName", entMap.get(app.getEnterpriseId()) == null ? "-" : safe(entMap.get(app.getEnterpriseId()).getEnterpriseName()));
                    m.put("jobTitle", jobMap.get(app.getJobId()) == null ? "-" : safe(jobMap.get(app.getJobId()).getTitle()));
                    m.put("currentStage", appStage(app.getStatus()));
                    m.put("stageStatus", appStageStatus(app.getStatus()));
                    m.put("submittedAt", app.getSubmittedAt());
                    m.put("lastActionAt", app.getLastActionAt());
                    m.put("overdueHours", overdueHours(app.getLastActionAt()));
                    return m;
                })
                .filter(m -> stageVal == null || stageVal.equals(m.get("currentStage")))
                .filter(m -> key == null || containsAny(key, m.get("applicationNo"), m.get("studentName"), m.get("enterpriseName")))
                .toList();
        return page(rows, page, pageSize);
    }

    public Map<String, Object> applicationMonitorDetail(Long id) {
        JobApplication app = jobApplicationRepository.findById(id)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "投递记录不存在"));
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", app.getId());
        m.put("applicationNo", app.getApplicationNo());
        m.put("currentStage", appStage(app.getStatus()));
        m.put("stageStatus", appStageStatus(app.getStatus()));
        m.put("submittedAt", app.getSubmittedAt());
        m.put("lastActionAt", app.getLastActionAt());
        m.put("overdueHours", overdueHours(app.getLastActionAt()));
        m.put("statusLogs", applicationStatusLogRepository.findByApplicationIdOrderByCreatedAtAsc(id));
        m.put("interviews", interviewScheduleRepository.findByApplicationIdOrderByScheduledAtDesc(id));
        m.put("offer", offerRepository.findByApplicationId(id).orElse(null));
        return m;
    }

    public Map<String, Object> listReports(Integer page, Integer pageSize, String keyword, String status) {
        String key = normalize(keyword);
        Integer statusVal = parseReportStatus(status);
        Map<Long, User> userMap = userRepository.findAll().stream().collect(Collectors.toMap(User::getId, it -> it));
        Map<Long, Enterprise> entMap = enterpriseRepository.findAll().stream().collect(Collectors.toMap(Enterprise::getId, it -> it));
        Map<Long, JobPosting> jobMap = jobPostingRepository.findAll().stream().collect(Collectors.toMap(JobPosting::getId, it -> it));

        List<Map<String, Object>> rows = reportRepository.findAll().stream()
                .sorted(Comparator.comparing(Report::getCreatedAt, Comparator.nullsLast(LocalDateTime::compareTo)).reversed())
                .filter(r -> statusVal == null || Objects.equals(r.getStatus(), statusVal))
                .map(r -> reportRow(r, userMap, entMap, jobMap))
                .filter(m -> key == null || containsAny(key, m.get("reportNo"), m.get("targetName"), m.get("reporter")))
                .toList();
        return page(rows, page, pageSize);
    }

    @Transactional
    public Map<String, Object> acceptReport(Long operatorId, Long id, AdminReportAcceptRequest request) {
        Long adminId = resolveOperatorId(operatorId);
        Report report = reportRepository.findById(id)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "举报记录不存在"));
        report.setStatus(2);
        report.setHandlerUserId(adminId);
        report.setHandleResult(normalize(request == null ? null : request.getNote()));
        report.setHandledAt(LocalDateTime.now());
        reportRepository.save(report);
        log(adminId, "reports", "accept", "report", id, Map.of());
        return Map.of("id", id, "status", "processing", "statusLabel", "处理中");
    }

    @Transactional
    public Map<String, Object> closeReport(Long operatorId, Long id, AdminReportCloseRequest request) {
        Long adminId = resolveOperatorId(operatorId);
        Report report = reportRepository.findById(id)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "举报记录不存在"));
        report.setStatus(3);
        report.setHandlerUserId(adminId);
        report.setHandleResult(request.getResult().trim());
        report.setHandledAt(LocalDateTime.now());
        reportRepository.save(report);
        if (Boolean.TRUE.equals(request.getWithPenalty())) {
            createPenaltyRecord(adminId, Objects.equals(report.getTargetType(), 2) ? 2 : 1, report.getTargetId(), 1, "举报结案处罚: " + request.getResult().trim());
        }
        log(adminId, "reports", "close", "report", id, Map.of("withPenalty", Boolean.TRUE.equals(request.getWithPenalty())));
        return Map.of("id", id, "status", "closed", "statusLabel", "已结案");
    }

    public Map<String, Object> listReviews(Integer page, Integer pageSize, String keyword, String status, Integer rating) {
        String key = normalize(keyword);
        String statusVal = normalize(status);
        Map<Long, User> userMap = userRepository.findAll().stream().collect(Collectors.toMap(User::getId, it -> it));
        Map<Long, Enterprise> entMap = enterpriseRepository.findAll().stream().collect(Collectors.toMap(Enterprise::getId, it -> it));

        List<Map<String, Object>> rows = enterpriseReviewRepository.findAll().stream()
                .sorted(Comparator.comparing(EnterpriseReview::getCreatedAt, Comparator.nullsLast(LocalDateTime::compareTo)).reversed())
                .filter(r -> rating == null || Objects.equals(r.getRating(), rating))
                .map(r -> {
                    String code = reviewStatus(r);
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("id", r.getId());
                    m.put("reviewer", displayUser(userMap.get(r.getStudentUserId())));
                    m.put("enterpriseName", entMap.get(r.getEnterpriseId()) == null ? "-" : safe(entMap.get(r.getEnterpriseId()).getEnterpriseName()));
                    m.put("rating", r.getRating());
                    m.put("content", safe(r.getContent()));
                    m.put("status", code);
                    m.put("statusLabel", "risk".equals(code) ? "风险" : "正常");
                    m.put("createdAt", r.getCreatedAt());
                    return m;
                })
                .filter(m -> statusVal == null || statusVal.equals(m.get("status")))
                .filter(m -> key == null || containsAny(key, m.get("content"), m.get("reviewer"), m.get("enterpriseName")))
                .toList();
        return page(rows, page, pageSize);
    }

    @Transactional
    public Map<String, Object> updateReviewStatus(Long operatorId, Long id, AdminReviewStatusRequest request) {
        Long adminId = resolveOperatorId(operatorId);
        EnterpriseReview review = enterpriseReviewRepository.findById(id)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "评价不存在"));
        String status = normalize(request.getStatus());
        if (!"normal".equals(status) && !"risk".equals(status)) {
            throw new BizException(ErrorCode.PARAM_ERROR, "评价状态不合法");
        }
        reviewStatusOverrides.put(review.getId(), status);
        log(adminId, "reviews", "status_update", "review", id, Map.of("status", status));
        return Map.of("id", id, "status", status, "statusLabel", "risk".equals(status) ? "风险" : "正常");
    }

    public Map<String, Object> listPenalties(Integer page, Integer pageSize, String keyword, String targetType, String status) {
        String key = normalize(keyword);
        String targetTypeVal = normalize(targetType);
        Integer statusVal = parsePenaltyStatus(status);

        Map<Long, User> userMap = userRepository.findAll().stream().collect(Collectors.toMap(User::getId, it -> it));
        Map<Long, Enterprise> entMap = enterpriseRepository.findAll().stream().collect(Collectors.toMap(Enterprise::getId, it -> it));
        Map<Long, JobPosting> jobMap = jobPostingRepository.findAll().stream().collect(Collectors.toMap(JobPosting::getId, it -> it));

        List<Map<String, Object>> rows = penaltyRecordRepository.findAll().stream()
                .sorted(Comparator.comparing(PenaltyRecord::getCreatedAt, Comparator.nullsLast(LocalDateTime::compareTo)).reversed())
                .filter(p -> statusVal == null || Objects.equals(p.getStatus(), statusVal))
                .map(p -> penaltyRow(p, userMap, entMap, jobMap))
                .filter(m -> targetTypeVal == null || targetTypeVal.equals(m.get("targetType")))
                .filter(m -> key == null || containsAny(key, m.get("target"), m.get("action")))
                .toList();
        return page(rows, page, pageSize);
    }

    @Transactional
    public Map<String, Object> createPenalty(Long operatorId, AdminPenaltyCreateRequest request) {
        Long adminId = resolveOperatorId(operatorId);
        Integer targetType = parsePenaltyTargetType(request.getTargetType());
        if (targetType == null) {
            throw new BizException(ErrorCode.PARAM_ERROR, "目标类型仅支持学生或企业");
        }
        PenaltyRecord p = createPenaltyRecord(
                adminId,
                targetType,
                request.getTargetId() == null ? 0L : request.getTargetId(),
                parsePenaltyType(request.getAction()),
                request.getReason().trim()
        );
        penaltyMetaStore.put(p.getId(), new PenaltyMeta(request.getTarget().trim(), request.getTargetType().trim(), request.getAction().trim(), request.getSeverity().trim()));
        log(adminId, "penalties", "create", "penalty", p.getId(), Map.of());
        return penaltySimple(p);
    }

    @Transactional
    public Map<String, Object> revokePenalty(Long operatorId, Long id, AdminRejectRequest request) {
        Long adminId = resolveOperatorId(operatorId);
        PenaltyRecord p = penaltyRecordRepository.findById(id)
                .orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "处罚记录不存在"));
        p.setStatus(2);
        penaltyRecordRepository.save(p);
        log(adminId, "penalties", "revoke", "penalty", id, Map.of("reason", request.getReason().trim()));
        return penaltySimple(p);
    }

    public Map<String, Object> listNotifications(Integer page, Integer pageSize, String keyword, String status) {
        String key = normalize(keyword);
        String statusVal = normalize(status);
        List<Map<String, Object>> rows = notificationStore.values().stream()
                .sorted(Comparator.comparing((NotificationDraft n) -> n.createdAt).reversed())
                .filter(n -> statusVal == null || statusVal.equals(n.status))
                .map(this::notificationRow)
                .filter(m -> key == null || containsAny(key, m.get("title"), m.get("audience")))
                .toList();
        return page(rows, page, pageSize);
    }

    @Transactional
    public Map<String, Object> createNotification(Long operatorId, AdminNotificationCreateRequest request) {
        Long adminId = resolveOperatorId(operatorId);
        NotificationDraft draft = new NotificationDraft();
        draft.id = notificationIdGen.getAndIncrement();
        draft.title = request.getTitle().trim();
        draft.channel = request.getChannel().trim();
        draft.audience = request.getAudience().trim();
        draft.content = normalize(request.getContent()) == null ? draft.title : request.getContent().trim();
        draft.status = "draft";
        draft.createdAt = LocalDateTime.now();
        notificationStore.put(draft.id, draft);
        log(adminId, "notifications", "create", "notification", draft.id, Map.of());
        return notificationRow(draft);
    }

    @Transactional
    public Map<String, Object> publishNotification(Long operatorId, Long id) {
        Long adminId = resolveOperatorId(operatorId);
        NotificationDraft draft = notificationStore.get(id);
        if (draft == null) {
            throw new BizException(ErrorCode.DATA_NOT_FOUND, "通知草稿不存在");
        }
        draft.status = "published";
        draft.publishAt = LocalDateTime.now();
        List<Long> userIds = resolveAudienceUsers(draft.audience);
        if (!userIds.isEmpty()) {
            List<UserNotification> list = userIds.stream().map(uid -> {
                UserNotification n = new UserNotification();
                n.setUserId(uid);
                n.setBizType("admin_notice");
                n.setBizId(id);
                n.setTitle(draft.title);
                n.setContent(draft.content);
                n.setIsRead(0);
                return n;
            }).toList();
            userNotificationRepository.saveAll(list);
        }
        log(adminId, "notifications", "publish", "notification", id, Map.of("deliverCount", userIds.size()));
        Map<String, Object> row = notificationRow(draft);
        row.put("deliverCount", userIds.size());
        return row;
    }

    public List<Map<String, Object>> listRules() {
        return ruleStore.values().stream().sorted(Comparator.comparing(r -> r.id)).map(this::ruleRow).toList();
    }

    @Transactional
    public Map<String, Object> toggleRule(Long operatorId, Long id, AdminRuleToggleRequest request) {
        Long adminId = resolveOperatorId(operatorId);
        RuleItem rule = ruleStore.get(id);
        if (rule == null) {
            throw new BizException(ErrorCode.DATA_NOT_FOUND, "策略不存在");
        }
        rule.enabled = request.getEnabled();
        rule.updatedAt = LocalDateTime.now();
        log(adminId, "rules", "toggle", "rule", id, Map.of());
        return ruleRow(rule);
    }

    public Map<String, Object> listLogs(Integer page, Integer pageSize, String keyword, String module, String result, String startAt, String endAt) {
        String key = normalize(keyword);
        String moduleVal = normalize(module);
        String resultVal = normalize(result);
        LocalDateTime start = parseDateTime(startAt, false);
        LocalDateTime end = parseDateTime(endAt, true);
        Map<Long, User> userMap = userRepository.findAll().stream().collect(Collectors.toMap(User::getId, it -> it));

        List<Map<String, Object>> rows = adminOperationLogRepository.findAll().stream()
                .sorted(Comparator.comparing(AdminOperationLog::getOperatedAt, Comparator.nullsLast(LocalDateTime::compareTo)).reversed())
                .map(log -> logRow(log, userMap))
                .filter(m -> moduleVal == null || moduleVal.equals(m.get("module")))
                .filter(m -> resultVal == null || resultVal.equals(m.get("result")))
                .filter(m -> {
                    LocalDateTime t = (LocalDateTime) m.get("createdAt");
                    if (start != null && (t == null || t.isBefore(start))) {
                        return false;
                    }
                    if (end != null && (t == null || t.isAfter(end))) {
                        return false;
                    }
                    return true;
                })
                .filter(m -> key == null || containsAny(key, m.get("operator"), m.get("action"), m.get("target")))
                .toList();
        return page(rows, page, pageSize);
    }

    public List<Map<String, String>> listPermissions() {
        return permissionItems();
    }

    public List<Map<String, Object>> listRoles() {
        List<Map<String, Object>> rows = new ArrayList<>();
        for (Map.Entry<String, Set<String>> e : rolePermissions.entrySet()) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("role", e.getKey());
            m.put("roleLabel", roleLabel(e.getKey()));
            m.put("members", roleMembers(e.getKey()));
            m.put("permissions", new ArrayList<>(e.getValue()));
            rows.add(m);
        }
        rows.sort(Comparator.comparing(m -> (String) m.get("role")));
        return rows;
    }

    @Transactional
    public Map<String, Object> updateRolePermissions(Long operatorId, String role, AdminRolePermissionsUpdateRequest request) {
        Long adminId = resolveOperatorId(operatorId);
        String roleCode = normalize(role);
        if (roleCode == null) {
            throw new BizException(ErrorCode.PARAM_ERROR, "角色不能为空");
        }
        Set<String> set = request.getPermissions().stream()
                .filter(Objects::nonNull)
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .collect(Collectors.toCollection(LinkedHashSet::new));
        rolePermissions.put(roleCode, set);
        log(adminId, "permissions", "role_permission_update", "role", null, Map.of("role", roleCode));
        return Map.of("role", roleCode, "roleLabel", roleLabel(roleCode), "permissions", new ArrayList<>(set));
    }

    public List<Map<String, Object>> listAdminAccounts() {
        Long adminId = ensureAdminUser();
        List<User> admins = userRepository.findByUserTypeAndIsDeletedOrderByIdAsc(3, 0);
        if (admins.isEmpty()) {
            admins = List.of(userRepository.findById(adminId).orElseThrow(() -> new BizException(ErrorCode.DATA_NOT_FOUND, "管理员不存在")));
        }
        List<Map<String, Object>> rows = new ArrayList<>();
        for (User u : admins) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", u.getId());
            m.put("name", displayUser(u));
            m.put("account", Objects.equals(u.getId(), adminId) ? "admin" : "admin_" + u.getId());
            m.put("roleLabel", Objects.equals(u.getId(), adminId) ? "超级管理员" : "审核管理员");
            m.put("lastLoginAt", Objects.equals(u.getId(), adminId) ? adminLastLoginAt : u.getLastLoginAt());
            m.put("status", userStatusCode(u.getAccountStatus()));
            rows.add(m);
        }
        return rows;
    }

    private Map<String, Object> adminUser(Long id) {
        User user = userRepository.findById(id).orElse(null);
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", id);
        m.put("name", user == null ? "系统管理员" : displayUser(user));
        m.put("role", "super_admin");
        m.put("roleLabel", "超级管理员");
        m.put("avatarText", "AD");
        return m;
    }

    private List<Map<String, String>> permissionItems() {
        return List.of(
                permission("dashboard:view", "看板查看"),
                permission("enterpriseAudit:view", "企业审核"),
                permission("jobAudit:view", "岗位审核"),
                permission("users:view", "用户管理"),
                permission("applications:view", "流程监控"),
                permission("reports:view", "举报处理"),
                permission("reviews:view", "评价管理"),
                permission("penalties:view", "处罚记录"),
                permission("notifications:view", "通知中心"),
                permission("rules:view", "审核策略"),
                permission("logs:view", "系统日志"),
                permission("permissions:view", "权限中心")
        );
    }

    private Map<String, String> permission(String key, String label) {
        Map<String, String> m = new LinkedHashMap<>();
        m.put("key", key);
        m.put("label", label);
        return m;
    }

    private Map<String, Object> metric(long value, long trend, boolean trendUp) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("value", value);
        m.put("trend", trend);
        m.put("trendUp", trendUp);
        return m;
    }

    private Map<String, Object> pipeline(String label, long value, String type) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("label", label);
        m.put("value", value);
        m.put("type", type);
        return m;
    }

    private Map<String, Object> todo(Long id, String title, long count, String route) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", id);
        m.put("title", title);
        m.put("count", count);
        m.put("route", route);
        return m;
    }

    private Map<String, Object> page(List<Map<String, Object>> records, Integer page, Integer pageSize) {
        int p = page == null ? 1 : Math.max(1, page);
        int size = pageSize == null ? 10 : Math.max(1, pageSize);
        int from = (p - 1) * size;
        int to = Math.min(from + size, records.size());
        List<Map<String, Object>> slice = from >= records.size() ? Collections.emptyList() : records.subList(from, to);
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("records", slice);
        m.put("page", p);
        m.put("pageSize", size);
        m.put("total", records.size());
        return m;
    }

    private Map<LocalDate, Long> countByDay(List<LocalDateTime> times) {
        Map<LocalDate, Long> map = new HashMap<>();
        for (LocalDateTime t : times) {
            if (t == null) {
                continue;
            }
            LocalDate d = t.toLocalDate();
            map.put(d, map.getOrDefault(d, 0L) + 1L);
        }
        return map;
    }

    private Map<String, Object> userSummary(User user) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", user.getId());
        m.put("nickname", displayUser(user));
        m.put("phone", safe(user.getPhone()));
        m.put("userType", userTypeCode(user.getUserType()));
        m.put("userTypeLabel", userTypeLabel(user.getUserType()));
        m.put("status", userStatusCode(user.getAccountStatus()));
        m.put("statusLabel", userStatusLabel(user.getAccountStatus()));
        m.put("registerAt", user.getCreatedAt());
        m.put("lastLoginAt", user.getLastLoginAt());
        m.put("riskLevel", userRisk(user));
        return m;
    }

    private Map<String, Object> reportRow(Report report, Map<Long, User> users, Map<Long, Enterprise> ents, Map<Long, JobPosting> jobs) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", report.getId());
        m.put("reportNo", "RP" + String.format("%06d", report.getId()));
        m.put("reporter", displayUser(users.get(report.getReporterUserId())));
        m.put("targetType", reportTargetTypeLabel(report.getTargetType()));
        m.put("targetName", reportTargetName(report, users, ents, jobs));
        m.put("reason", safe(report.getReason()));
        m.put("status", reportStatusCode(report.getStatus()));
        m.put("statusLabel", reportStatusLabel(report.getStatus()));
        m.put("createdAt", report.getCreatedAt());
        m.put("processor", displayUser(users.get(report.getHandlerUserId())));
        m.put("result", safe(report.getHandleResult()));
        return m;
    }

    private String reportTargetName(Report report, Map<Long, User> users, Map<Long, Enterprise> ents, Map<Long, JobPosting> jobs) {
        if (Objects.equals(report.getTargetType(), 1)) {
            JobPosting job = jobs.get(report.getTargetId());
            return job == null ? "岗位#" + report.getTargetId() : safe(job.getTitle());
        }
        if (Objects.equals(report.getTargetType(), 2)) {
            Enterprise ent = ents.get(report.getTargetId());
            return ent == null ? "企业#" + report.getTargetId() : safe(ent.getEnterpriseName());
        }
        if (Objects.equals(report.getTargetType(), 3)) {
            return displayUser(users.get(report.getTargetId()));
        }
        if (Objects.equals(report.getTargetType(), 4)) {
            return messageRepository.findById(report.getTargetId()).map(msg -> "消息#" + msg.getId()).orElse("消息#" + report.getTargetId());
        }
        return "目标#" + report.getTargetId();
    }

    private String reviewStatus(EnterpriseReview review) {
        String v = reviewStatusOverrides.get(review.getId());
        if (v != null) {
            return v;
        }
        return review.getRating() != null && review.getRating() <= 2 ? "risk" : "normal";
    }

    private PenaltyRecord createPenaltyRecord(Long operatorId, Integer targetType, Long targetId, Integer penaltyType, String reason) {
        PenaltyRecord p = new PenaltyRecord();
        p.setTargetType(targetType);
        p.setTargetId(targetId == null ? 0L : targetId);
        p.setPenaltyType(penaltyType);
        p.setReason(reason);
        p.setStatus(1);
        p.setOperatorUserId(operatorId);
        return penaltyRecordRepository.save(p);
    }

    private Map<String, Object> penaltyRow(PenaltyRecord p, Map<Long, User> users, Map<Long, Enterprise> ents, Map<Long, JobPosting> jobs) {
        PenaltyMeta meta = penaltyMetaStore.get(p.getId());
        String target;
        String targetType;
        String action;
        String severity;
        if (meta != null) {
            target = meta.target;
            targetType = meta.targetType;
            action = meta.action;
            severity = meta.severity;
        } else {
            if (Objects.equals(p.getTargetType(), 2)) {
                Enterprise ent = ents.get(p.getTargetId());
                target = ent == null ? "企业#" + p.getTargetId() : safe(ent.getEnterpriseName());
                targetType = "企业";
            } else if (Objects.equals(p.getTargetType(), 3)) {
                JobPosting job = jobs.get(p.getTargetId());
                target = job == null ? "岗位#" + p.getTargetId() : safe(job.getTitle());
                targetType = "岗位";
            } else {
                target = displayUser(users.get(p.getTargetId()));
                targetType = "学生";
            }
            action = penaltyTypeLabel(p.getPenaltyType());
            severity = penaltySeverityLabel(p.getPenaltyType());
        }
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", p.getId());
        m.put("target", target);
        m.put("targetType", targetType);
        m.put("action", action);
        m.put("severity", severity);
        m.put("status", penaltyStatusCode(p.getStatus()));
        m.put("statusLabel", penaltyStatusLabel(p.getStatus()));
        m.put("operator", displayUser(users.get(p.getOperatorUserId())));
        m.put("createdAt", p.getCreatedAt());
        m.put("reason", safe(p.getReason()));
        return m;
    }

    private Map<String, Object> penaltySimple(PenaltyRecord p) {
        return Map.of("id", p.getId(), "status", penaltyStatusCode(p.getStatus()), "statusLabel", penaltyStatusLabel(p.getStatus()));
    }

    private List<Long> resolveAudienceUsers(String audience) {
        String v = normalize(audience);
        List<User> users = userRepository.findAll().stream().filter(u -> Objects.equals(u.getIsDeleted(), 0)).toList();
        if (v == null || "全体用户".equals(v)) {
            return users.stream().filter(u -> Objects.equals(u.getUserType(), 1) || Objects.equals(u.getUserType(), 2)).map(User::getId).toList();
        }
        if ("学生用户".equals(v)) {
            return users.stream().filter(u -> Objects.equals(u.getUserType(), 1)).map(User::getId).toList();
        }
        if ("企业用户".equals(v)) {
            return users.stream().filter(u -> Objects.equals(u.getUserType(), 2)).map(User::getId).toList();
        }
        if ("待审核企业".equals(v)) {
            return enterpriseRepository.findAll().stream().filter(e -> Objects.equals(e.getCertifiedStatus(), 2)).map(Enterprise::getOwnerUserId).toList();
        }
        return Collections.emptyList();
    }

    private Map<String, Object> notificationRow(NotificationDraft n) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", n.id);
        m.put("title", n.title);
        m.put("channel", n.channel);
        m.put("audience", n.audience);
        m.put("status", n.status);
        m.put("statusLabel", "published".equals(n.status) ? "已发布" : "草稿");
        m.put("publishAt", n.publishAt);
        return m;
    }

    private Map<String, Object> ruleRow(RuleItem r) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", r.id);
        m.put("module", r.module);
        m.put("ruleName", r.ruleName);
        m.put("hitCondition", r.hitCondition);
        m.put("action", r.action);
        m.put("enabled", r.enabled);
        m.put("updatedAt", r.updatedAt);
        return m;
    }

    private Map<String, Object> logRow(AdminOperationLog log, Map<Long, User> users) {
        Map<String, Object> detail = parseJson(log.getDetailJson());
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", log.getId());
        m.put("operator", displayUser(users.get(log.getOperatorUserId())));
        m.put("action", log.getAction());
        m.put("target", detail.getOrDefault("target", safe(log.getTargetType()) + (log.getTargetId() == null ? "" : "#" + log.getTargetId())));
        m.put("module", log.getModule());
        m.put("ip", detail.getOrDefault("ip", "127.0.0.1"));
        m.put("result", detail.getOrDefault("result", "成功"));
        m.put("createdAt", log.getOperatedAt());
        return m;
    }

    private Map<String, Object> parseJson(String json) {
        if (normalize(json) == null) {
            return Collections.emptyMap();
        }
        try {
            return objectMapper.readValue(json, new TypeReference<Map<String, Object>>() {});
        } catch (Exception ex) {
            return Collections.emptyMap();
        }
    }

    private String normalize(String v) {
        if (v == null) {
            return null;
        }
        String t = v.trim();
        return t.isEmpty() ? null : t;
    }

    private String safe(String v) {
        return v == null ? "-" : v;
    }

    private boolean containsAny(String keyword, Object... values) {
        if (keyword == null) {
            return true;
        }
        String key = keyword.toLowerCase(Locale.ROOT);
        for (Object value : values) {
            if (value != null && value.toString().toLowerCase(Locale.ROOT).contains(key)) {
                return true;
            }
        }
        return false;
    }

    private String displayUser(User user) {
        if (user == null) {
            return "-";
        }
        if (normalize(user.getNickname()) != null) {
            return user.getNickname().trim();
        }
        if (normalize(user.getRealName()) != null) {
            return user.getRealName().trim();
        }
        if (normalize(user.getPhone()) != null) {
            return user.getPhone().trim();
        }
        return "用户#" + user.getId();
    }

    private boolean isOverdue(JobApplication app) {
        return overdueHours(app.getLastActionAt()) >= 72;
    }

    private long overdueHours(LocalDateTime lastActionAt) {
        if (lastActionAt == null) {
            return 0;
        }
        return Math.max(0, ChronoUnit.HOURS.between(lastActionAt, LocalDateTime.now()));
    }

    private String appStage(Integer status) {
        if (Objects.equals(status, 4)) {
            return "面试中";
        }
        if (Objects.equals(status, 5)) {
            return "Offer阶段";
        }
        if (Objects.equals(status, 6)) {
            return "已录用";
        }
        if (Objects.equals(status, 7) || Objects.equals(status, 8)) {
            return "已淘汰";
        }
        return "沟通中";
    }

    private String appStageStatus(Integer status) {
        if (Objects.equals(status, 6)) {
            return "success";
        }
        if (Objects.equals(status, 7) || Objects.equals(status, 8)) {
            return "danger";
        }
        if (Objects.equals(status, 5)) {
            return "pending";
        }
        if (Objects.equals(status, 4)) {
            return "info";
        }
        return "processing";
    }

    private String enterpriseRisk(Enterprise ent, EnterpriseCertification cert) {
        if (ent == null) {
            return "高";
        }
        if (normalize(ent.getUnifiedCreditCode()) == null || normalize(cert.getLicenseFileUrl()) == null) {
            return "高";
        }
        if (normalize(ent.getIndustry()) == null || normalize(ent.getCity()) == null) {
            return "中";
        }
        return "低";
    }

    private String jobRisk(JobPosting job) {
        String text = (safe(job.getTitle()) + safe(job.getDescription())).toLowerCase(Locale.ROOT);
        if (text.contains("刷单") || text.contains("引流") || text.contains("日结")) {
            return "高";
        }
        if (job.getSalaryMin() != null && job.getSalaryMax() != null && job.getSalaryMin().compareTo(job.getSalaryMax()) > 0) {
            return "中";
        }
        return "低";
    }

    private String salaryRange(BigDecimal min, BigDecimal max) {
        String minVal = min == null ? "-" : min.stripTrailingZeros().toPlainString();
        String maxVal = max == null ? "-" : max.stripTrailingZeros().toPlainString();
        return minVal + " - " + maxVal;
    }

    private Integer parseEnterpriseAuditStatus(String status) {
        String v = normalize(status);
        if (v == null) {
            return null;
        }
        return switch (v) {
            case "pending" -> 1;
            case "approved" -> 2;
            case "rejected" -> 3;
            default -> null;
        };
    }

    private Integer parseJobAuditStatus(String status) {
        String v = normalize(status);
        if (v == null) {
            return null;
        }
        return switch (v) {
            case "pending" -> 2;
            case "approved" -> 3;
            case "rejected" -> 4;
            default -> null;
        };
    }

    private Integer parseUserTypeCode(String userType) {
        String v = normalize(userType);
        if (v == null) {
            return null;
        }
        return switch (v) {
            case "student" -> 1;
            case "enterprise" -> 2;
            default -> null;
        };
    }

    private Integer parseUserStatus(String status) {
        String v = normalize(status);
        if (v == null) {
            return null;
        }
        return switch (v) {
            case "active" -> 1;
            case "disabled" -> 2;
            case "frozen" -> 3;
            default -> null;
        };
    }

    private Integer parseReportStatus(String status) {
        String v = normalize(status);
        if (v == null) {
            return null;
        }
        return switch (v) {
            case "pending" -> 1;
            case "processing" -> 2;
            case "closed" -> 3;
            default -> null;
        };
    }

    private Integer parsePenaltyStatus(String status) {
        String v = normalize(status);
        if (v == null) {
            return null;
        }
        return switch (v) {
            case "effective" -> 1;
            case "expired" -> 2;
            default -> null;
        };
    }

    private Integer parsePenaltyTargetType(String targetType) {
        String v = normalize(targetType);
        if (v == null) {
            return null;
        }
        return switch (v) {
            case "学生" -> 1;
            case "企业" -> 2;
            default -> null;
        };
    }

    private Integer parsePenaltyType(String action) {
        String v = normalize(action);
        if (v == null) {
            return 1;
        }
        if (v.contains("冻结")) {
            return 2;
        }
        if (v.contains("下线")) {
            return 3;
        }
        return 1;
    }

    private String enterpriseAuditStatusCode(Integer status) {
        if (Objects.equals(status, 1)) {
            return "pending";
        }
        if (Objects.equals(status, 2)) {
            return "approved";
        }
        if (Objects.equals(status, 3)) {
            return "rejected";
        }
        return "pending";
    }

    private String enterpriseAuditStatusLabel(Integer status) {
        if (Objects.equals(status, 1)) {
            return "待审核";
        }
        if (Objects.equals(status, 2)) {
            return "已通过";
        }
        if (Objects.equals(status, 3)) {
            return "已驳回";
        }
        return "待审核";
    }

    private String jobAuditStatusCode(Integer status) {
        if (Objects.equals(status, 2)) {
            return "pending";
        }
        if (Objects.equals(status, 3)) {
            return "approved";
        }
        if (Objects.equals(status, 4)) {
            return "rejected";
        }
        return "pending";
    }

    private String jobAuditStatusLabel(Integer status) {
        if (Objects.equals(status, 2)) {
            return "待审核";
        }
        if (Objects.equals(status, 3)) {
            return "已上线";
        }
        if (Objects.equals(status, 4)) {
            return "已驳回";
        }
        return "待审核";
    }

    private String userTypeCode(Integer userType) {
        if (Objects.equals(userType, 1)) {
            return "student";
        }
        if (Objects.equals(userType, 2)) {
            return "enterprise";
        }
        if (Objects.equals(userType, 3)) {
            return "admin";
        }
        return "unknown";
    }

    private String userTypeLabel(Integer userType) {
        if (Objects.equals(userType, 1)) {
            return "学生";
        }
        if (Objects.equals(userType, 2)) {
            return "企业";
        }
        if (Objects.equals(userType, 3)) {
            return "管理员";
        }
        return "未知";
    }

    private String userStatusCode(Integer status) {
        if (Objects.equals(status, 1)) {
            return "active";
        }
        if (Objects.equals(status, 2)) {
            return "disabled";
        }
        if (Objects.equals(status, 3)) {
            return "frozen";
        }
        return "disabled";
    }

    private String userStatusLabel(Integer status) {
        if (Objects.equals(status, 1)) {
            return "正常";
        }
        if (Objects.equals(status, 2)) {
            return "禁用";
        }
        if (Objects.equals(status, 3)) {
            return "冻结";
        }
        return "未知";
    }

    private String userRisk(User user) {
        if (Objects.equals(user.getAccountStatus(), 3)) {
            return "高";
        }
        if (Objects.equals(user.getAccountStatus(), 2)) {
            return "中";
        }
        return "低";
    }

    private String reportTargetTypeLabel(Integer targetType) {
        if (Objects.equals(targetType, 1)) {
            return "岗位";
        }
        if (Objects.equals(targetType, 2)) {
            return "企业";
        }
        if (Objects.equals(targetType, 3)) {
            return "用户";
        }
        if (Objects.equals(targetType, 4)) {
            return "消息";
        }
        return "未知";
    }

    private String reportStatusCode(Integer status) {
        if (Objects.equals(status, 1)) {
            return "pending";
        }
        if (Objects.equals(status, 2)) {
            return "processing";
        }
        if (Objects.equals(status, 3)) {
            return "closed";
        }
        return "pending";
    }

    private String reportStatusLabel(Integer status) {
        if (Objects.equals(status, 1)) {
            return "待处理";
        }
        if (Objects.equals(status, 2)) {
            return "处理中";
        }
        if (Objects.equals(status, 3)) {
            return "已结案";
        }
        return "待处理";
    }

    private String penaltyStatusCode(Integer status) {
        return Objects.equals(status, 2) ? "expired" : "effective";
    }

    private String penaltyStatusLabel(Integer status) {
        return Objects.equals(status, 2) ? "已结束" : "生效中";
    }

    private String penaltyTypeLabel(Integer penaltyType) {
        if (Objects.equals(penaltyType, 2)) {
            return "冻结账号";
        }
        if (Objects.equals(penaltyType, 3)) {
            return "下线处理";
        }
        return "警告";
    }

    private String penaltySeverityLabel(Integer penaltyType) {
        if (Objects.equals(penaltyType, 3)) {
            return "高";
        }
        if (Objects.equals(penaltyType, 2)) {
            return "中";
        }
        return "低";
    }

    private String roleLabel(String role) {
        if ("super_admin".equals(role)) {
            return "超级管理员";
        }
        if ("auditor".equals(role)) {
            return "审核管理员";
        }
        if ("operator".equals(role)) {
            return "运营管理员";
        }
        return "自定义角色";
    }

    private Integer roleMembers(String role) {
        return 1;
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

    private String enterpriseCertifiedStatusLabel(Integer status) {
        if (Objects.equals(status, 1)) {
            return "未提交";
        }
        if (Objects.equals(status, 2)) {
            return "待审核";
        }
        if (Objects.equals(status, 3)) {
            return "认证通过";
        }
        if (Objects.equals(status, 4)) {
            return "认证驳回";
        }
        return "未知";
    }

    private LocalDateTime parseDateTime(String value, boolean endOfDay) {
        String v = normalize(value);
        if (v == null) {
            return null;
        }
        try {
            return LocalDateTime.parse(v);
        } catch (DateTimeParseException ignored) {
        }
        try {
            LocalDate d = LocalDate.parse(v);
            return endOfDay ? d.atTime(LocalTime.MAX) : d.atStartOfDay();
        } catch (DateTimeParseException ignored) {
            return null;
        }
    }

    private static class PenaltyMeta {
        private final String target;
        private final String targetType;
        private final String action;
        private final String severity;

        private PenaltyMeta(String target, String targetType, String action, String severity) {
            this.target = target;
            this.targetType = targetType;
            this.action = action;
            this.severity = severity;
        }
    }

    private static class NotificationDraft {
        private Long id;
        private String title;
        private String channel;
        private String audience;
        private String content;
        private String status;
        private LocalDateTime publishAt;
        private LocalDateTime createdAt;
    }

    private static class RuleItem {
        private Long id;
        private String module;
        private String ruleName;
        private String hitCondition;
        private String action;
        private Boolean enabled;
        private LocalDateTime updatedAt;
    }
}
