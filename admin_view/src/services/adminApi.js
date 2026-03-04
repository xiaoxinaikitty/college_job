import { httpRequest } from './http'

export const adminApi = {
  login(payload) {
    return httpRequest('/api/admin/auth/login', {
      method: 'POST',
      body: payload,
      withAuth: false,
    })
  },
  me() {
    return httpRequest('/api/admin/auth/me')
  },
  logout() {
    return httpRequest('/api/admin/auth/logout', { method: 'POST' })
  },

  dashboardMetrics() {
    return httpRequest('/api/admin/dashboard/metrics')
  },
  dashboardTrend(days = 7) {
    return httpRequest('/api/admin/dashboard/trend', { query: { days } })
  },
  dashboardPipeline() {
    return httpRequest('/api/admin/dashboard/pipeline')
  },
  dashboardTodos() {
    return httpRequest('/api/admin/dashboard/todos')
  },

  listEnterpriseAudits(params) {
    return httpRequest('/api/admin/enterprise-audits', { query: params })
  },
  enterpriseAuditDetail(id) {
    return httpRequest(`/api/admin/enterprise-audits/${id}`)
  },
  approveEnterpriseAudit(id, note = '') {
    return httpRequest(`/api/admin/enterprise-audits/${id}/approve`, {
      method: 'POST',
      body: { note },
    })
  },
  rejectEnterpriseAudit(id, reason) {
    return httpRequest(`/api/admin/enterprise-audits/${id}/reject`, {
      method: 'POST',
      body: { reason },
    })
  },

  listJobAudits(params) {
    return httpRequest('/api/admin/job-audits', { query: params })
  },
  jobAuditDetail(id) {
    return httpRequest(`/api/admin/job-audits/${id}`)
  },
  approveJobAudit(id) {
    return httpRequest(`/api/admin/job-audits/${id}/approve`, { method: 'POST' })
  },
  rejectJobAudit(id, reason) {
    return httpRequest(`/api/admin/job-audits/${id}/reject`, {
      method: 'POST',
      body: { reason },
    })
  },

  listUsers(params) {
    return httpRequest('/api/admin/users', { query: params })
  },
  userDetail(id) {
    return httpRequest(`/api/admin/users/${id}`)
  },
  updateUserStatus(id, status) {
    return httpRequest(`/api/admin/users/${id}/status`, {
      method: 'POST',
      body: { status },
    })
  },
  freezeUser(id, payload) {
    return httpRequest(`/api/admin/users/${id}/freeze`, {
      method: 'POST',
      body: payload,
    })
  },

  listApplicationMonitors(params) {
    return httpRequest('/api/admin/application-monitors', { query: params })
  },
  applicationMonitorDetail(id) {
    return httpRequest(`/api/admin/application-monitors/${id}`)
  },

  listReports(params) {
    return httpRequest('/api/admin/reports', { query: params })
  },
  acceptReport(id, note = '') {
    return httpRequest(`/api/admin/reports/${id}/accept`, {
      method: 'POST',
      body: { note },
    })
  },
  closeReport(id, payload) {
    return httpRequest(`/api/admin/reports/${id}/close`, {
      method: 'POST',
      body: payload,
    })
  },

  listReviews(params) {
    return httpRequest('/api/admin/reviews', { query: params })
  },
  updateReviewStatus(id, payload) {
    return httpRequest(`/api/admin/reviews/${id}/status`, {
      method: 'POST',
      body: payload,
    })
  },

  listPenalties(params) {
    return httpRequest('/api/admin/penalties', { query: params })
  },
  createPenalty(payload) {
    return httpRequest('/api/admin/penalties', {
      method: 'POST',
      body: payload,
    })
  },
  revokePenalty(id, reason) {
    return httpRequest(`/api/admin/penalties/${id}/revoke`, {
      method: 'POST',
      body: { reason },
    })
  },

  listNotifications(params) {
    return httpRequest('/api/admin/notifications', { query: params })
  },
  createNotification(payload) {
    return httpRequest('/api/admin/notifications', {
      method: 'POST',
      body: payload,
    })
  },
  publishNotification(id) {
    return httpRequest(`/api/admin/notifications/${id}/publish`, {
      method: 'POST',
    })
  },

  listRules() {
    return httpRequest('/api/admin/rules')
  },
  toggleRule(id, enabled) {
    return httpRequest(`/api/admin/rules/${id}/toggle`, {
      method: 'POST',
      body: { enabled },
    })
  },

  listLogs(params) {
    return httpRequest('/api/admin/logs', { query: params })
  },

  listPermissions() {
    return httpRequest('/api/admin/permissions')
  },
  listRoles() {
    return httpRequest('/api/admin/roles')
  },
  updateRolePermissions(role, permissions) {
    return httpRequest(`/api/admin/roles/${role}/permissions`, {
      method: 'PUT',
      body: { permissions },
    })
  },
  listAccounts() {
    return httpRequest('/api/admin/accounts')
  },
}

export function formatDateTime(value) {
  if (!value) {
    return '-'
  }
  if (typeof value !== 'string') {
    return String(value)
  }
  const base = value.replace('T', ' ')
  const dotIndex = base.indexOf('.')
  return dotIndex > -1 ? base.slice(0, dotIndex) : base
}
