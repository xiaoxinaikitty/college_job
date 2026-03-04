package org.example.systemservice.controller;

import jakarta.validation.Valid;
import org.example.systemservice.common.ApiResponse;
import org.example.systemservice.dto.admin.*;
import org.example.systemservice.service.AdminService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final AdminService adminService;

    public AdminController(AdminService adminService) {
        this.adminService = adminService;
    }

    @PostMapping("/auth/login")
    public ApiResponse<Map<String, Object>> login(@Valid @RequestBody AdminLoginRequest request) {
        return ApiResponse.success("登录成功", adminService.login(request));
    }

    @GetMapping("/auth/me")
    public ApiResponse<Map<String, Object>> me() {
        return ApiResponse.success(adminService.me());
    }

    @PostMapping("/auth/logout")
    public ApiResponse<Map<String, Object>> logout(
            @RequestHeader(value = "X-User-Id", required = false) Long operatorId
    ) {
        return ApiResponse.success("退出成功", adminService.logout(operatorId));
    }

    @GetMapping("/dashboard/metrics")
    public ApiResponse<Map<String, Object>> dashboardMetrics() {
        return ApiResponse.success(adminService.dashboardMetrics());
    }

    @GetMapping("/dashboard/trend")
    public ApiResponse<List<Map<String, Object>>> dashboardTrend(
            @RequestParam(required = false) Integer days
    ) {
        return ApiResponse.success(adminService.dashboardTrend(days));
    }

    @GetMapping("/dashboard/pipeline")
    public ApiResponse<List<Map<String, Object>>> dashboardPipeline() {
        return ApiResponse.success(adminService.dashboardPipeline());
    }

    @GetMapping("/dashboard/todos")
    public ApiResponse<List<Map<String, Object>>> dashboardTodos() {
        return ApiResponse.success(adminService.dashboardTodos());
    }

    @GetMapping("/enterprise-audits")
    public ApiResponse<Map<String, Object>> listEnterpriseAudits(
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String riskLevel
    ) {
        return ApiResponse.success(adminService.listEnterpriseAudits(page, pageSize, keyword, status, riskLevel));
    }

    @GetMapping("/enterprise-audits/{id}")
    public ApiResponse<Map<String, Object>> enterpriseAuditDetail(@PathVariable Long id) {
        return ApiResponse.success(adminService.enterpriseAuditDetail(id));
    }

    @PostMapping("/enterprise-audits/{id}/approve")
    public ApiResponse<Map<String, Object>> approveEnterpriseAudit(
            @RequestHeader(value = "X-User-Id", required = false) Long operatorId,
            @PathVariable Long id,
            @Valid @RequestBody(required = false) AdminApproveRequest request
    ) {
        return ApiResponse.success("审核通过", adminService.approveEnterpriseAudit(operatorId, id, request));
    }

    @PostMapping("/enterprise-audits/{id}/reject")
    public ApiResponse<Map<String, Object>> rejectEnterpriseAudit(
            @RequestHeader(value = "X-User-Id", required = false) Long operatorId,
            @PathVariable Long id,
            @Valid @RequestBody AdminRejectRequest request
    ) {
        return ApiResponse.success("审核驳回", adminService.rejectEnterpriseAudit(operatorId, id, request));
    }

    @GetMapping("/job-audits")
    public ApiResponse<Map<String, Object>> listJobAudits(
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String city
    ) {
        return ApiResponse.success(adminService.listJobAudits(page, pageSize, keyword, status, city));
    }

    @GetMapping("/job-audits/{id}")
    public ApiResponse<Map<String, Object>> jobAuditDetail(@PathVariable Long id) {
        return ApiResponse.success(adminService.jobAuditDetail(id));
    }

    @PostMapping("/job-audits/{id}/approve")
    public ApiResponse<Map<String, Object>> approveJobAudit(
            @RequestHeader(value = "X-User-Id", required = false) Long operatorId,
            @PathVariable Long id
    ) {
        return ApiResponse.success("审核通过", adminService.approveJobAudit(operatorId, id));
    }

    @PostMapping("/job-audits/{id}/reject")
    public ApiResponse<Map<String, Object>> rejectJobAudit(
            @RequestHeader(value = "X-User-Id", required = false) Long operatorId,
            @PathVariable Long id,
            @Valid @RequestBody AdminRejectRequest request
    ) {
        return ApiResponse.success("审核驳回", adminService.rejectJobAudit(operatorId, id, request));
    }

    @GetMapping("/users")
    public ApiResponse<Map<String, Object>> listUsers(
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String userType,
            @RequestParam(required = false) String status
    ) {
        return ApiResponse.success(adminService.listUsers(page, pageSize, keyword, userType, status));
    }

    @GetMapping("/users/{id}")
    public ApiResponse<Map<String, Object>> userDetail(@PathVariable Long id) {
        return ApiResponse.success(adminService.userDetail(id));
    }

    @PostMapping("/users/{id}/status")
    public ApiResponse<Map<String, Object>> updateUserStatus(
            @RequestHeader(value = "X-User-Id", required = false) Long operatorId,
            @PathVariable Long id,
            @Valid @RequestBody AdminUserStatusRequest request
    ) {
        return ApiResponse.success("用户状态更新成功", adminService.updateUserStatus(operatorId, id, request));
    }

    @PostMapping("/users/{id}/freeze")
    public ApiResponse<Map<String, Object>> freezeUser(
            @RequestHeader(value = "X-User-Id", required = false) Long operatorId,
            @PathVariable Long id,
            @Valid @RequestBody AdminFreezeRequest request
    ) {
        return ApiResponse.success("冻结成功", adminService.freezeUser(operatorId, id, request));
    }

    @GetMapping("/application-monitors")
    public ApiResponse<Map<String, Object>> listApplicationMonitors(
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String stage
    ) {
        return ApiResponse.success(adminService.listApplicationMonitors(page, pageSize, keyword, stage));
    }

    @GetMapping("/application-monitors/{id}")
    public ApiResponse<Map<String, Object>> applicationMonitorDetail(@PathVariable Long id) {
        return ApiResponse.success(adminService.applicationMonitorDetail(id));
    }

    @GetMapping("/reports")
    public ApiResponse<Map<String, Object>> listReports(
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String status
    ) {
        return ApiResponse.success(adminService.listReports(page, pageSize, keyword, status));
    }

    @PostMapping("/reports/{id}/accept")
    public ApiResponse<Map<String, Object>> acceptReport(
            @RequestHeader(value = "X-User-Id", required = false) Long operatorId,
            @PathVariable Long id,
            @Valid @RequestBody(required = false) AdminReportAcceptRequest request
    ) {
        return ApiResponse.success("受理成功", adminService.acceptReport(operatorId, id, request));
    }

    @PostMapping("/reports/{id}/close")
    public ApiResponse<Map<String, Object>> closeReport(
            @RequestHeader(value = "X-User-Id", required = false) Long operatorId,
            @PathVariable Long id,
            @Valid @RequestBody AdminReportCloseRequest request
    ) {
        return ApiResponse.success("结案成功", adminService.closeReport(operatorId, id, request));
    }

    @GetMapping("/reviews")
    public ApiResponse<Map<String, Object>> listReviews(
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Integer rating
    ) {
        return ApiResponse.success(adminService.listReviews(page, pageSize, keyword, status, rating));
    }

    @PostMapping("/reviews/{id}/status")
    public ApiResponse<Map<String, Object>> updateReviewStatus(
            @RequestHeader(value = "X-User-Id", required = false) Long operatorId,
            @PathVariable Long id,
            @Valid @RequestBody AdminReviewStatusRequest request
    ) {
        return ApiResponse.success("评价状态更新成功", adminService.updateReviewStatus(operatorId, id, request));
    }

    @GetMapping("/penalties")
    public ApiResponse<Map<String, Object>> listPenalties(
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String targetType,
            @RequestParam(required = false) String status
    ) {
        return ApiResponse.success(adminService.listPenalties(page, pageSize, keyword, targetType, status));
    }

    @PostMapping("/penalties")
    public ApiResponse<Map<String, Object>> createPenalty(
            @RequestHeader(value = "X-User-Id", required = false) Long operatorId,
            @Valid @RequestBody AdminPenaltyCreateRequest request
    ) {
        return ApiResponse.success("处罚创建成功", adminService.createPenalty(operatorId, request));
    }

    @PostMapping("/penalties/{id}/revoke")
    public ApiResponse<Map<String, Object>> revokePenalty(
            @RequestHeader(value = "X-User-Id", required = false) Long operatorId,
            @PathVariable Long id,
            @Valid @RequestBody AdminRejectRequest request
    ) {
        return ApiResponse.success("处罚撤销成功", adminService.revokePenalty(operatorId, id, request));
    }

    @GetMapping("/notifications")
    public ApiResponse<Map<String, Object>> listNotifications(
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String status
    ) {
        return ApiResponse.success(adminService.listNotifications(page, pageSize, keyword, status));
    }

    @PostMapping("/notifications")
    public ApiResponse<Map<String, Object>> createNotification(
            @RequestHeader(value = "X-User-Id", required = false) Long operatorId,
            @Valid @RequestBody AdminNotificationCreateRequest request
    ) {
        return ApiResponse.success("通知创建成功", adminService.createNotification(operatorId, request));
    }

    @PostMapping("/notifications/{id}/publish")
    public ApiResponse<Map<String, Object>> publishNotification(
            @RequestHeader(value = "X-User-Id", required = false) Long operatorId,
            @PathVariable Long id
    ) {
        return ApiResponse.success("通知发布成功", adminService.publishNotification(operatorId, id));
    }

    @GetMapping("/rules")
    public ApiResponse<List<Map<String, Object>>> listRules() {
        return ApiResponse.success(adminService.listRules());
    }

    @PostMapping("/rules/{id}/toggle")
    public ApiResponse<Map<String, Object>> toggleRule(
            @RequestHeader(value = "X-User-Id", required = false) Long operatorId,
            @PathVariable Long id,
            @Valid @RequestBody AdminRuleToggleRequest request
    ) {
        return ApiResponse.success("策略状态更新成功", adminService.toggleRule(operatorId, id, request));
    }

    @GetMapping("/logs")
    public ApiResponse<Map<String, Object>> listLogs(
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String module,
            @RequestParam(required = false) String result,
            @RequestParam(required = false) String startAt,
            @RequestParam(required = false) String endAt
    ) {
        return ApiResponse.success(adminService.listLogs(page, pageSize, keyword, module, result, startAt, endAt));
    }

    @GetMapping("/permissions")
    public ApiResponse<List<Map<String, String>>> listPermissions() {
        return ApiResponse.success(adminService.listPermissions());
    }

    @GetMapping("/roles")
    public ApiResponse<List<Map<String, Object>>> listRoles() {
        return ApiResponse.success(adminService.listRoles());
    }

    @PutMapping("/roles/{role}/permissions")
    public ApiResponse<Map<String, Object>> updateRolePermissions(
            @RequestHeader(value = "X-User-Id", required = false) Long operatorId,
            @PathVariable String role,
            @Valid @RequestBody AdminRolePermissionsUpdateRequest request
    ) {
        return ApiResponse.success("角色权限更新成功", adminService.updateRolePermissions(operatorId, role, request));
    }

    @GetMapping("/accounts")
    public ApiResponse<List<Map<String, Object>>> listAdminAccounts() {
        return ApiResponse.success(adminService.listAdminAccounts());
    }
}
