# College Internship System - MVP Closed Loop DDL

> Target DB: MySQL 8.0+  
> Charset: utf8mb4  
> Engine: InnoDB

```sql
-- =========================================================
-- 0) Database
-- =========================================================
CREATE DATABASE IF NOT EXISTS college_job
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE college_job;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =========================================================
-- 1) Auth & RBAC (基础权限闭环)
-- =========================================================
CREATE TABLE IF NOT EXISTS cjs_user (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_type TINYINT UNSIGNED NOT NULL COMMENT '1-student 2-enterprise 3-admin',
  account_status TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1-active 2-disabled 3-locked',
  phone VARCHAR(20) NULL,
  email VARCHAR(128) NULL,
  password_hash VARCHAR(255) NOT NULL,
  nickname VARCHAR(64) NULL,
  real_name VARCHAR(64) NULL,
  avatar_url VARCHAR(512) NULL,
  last_login_at DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  is_deleted TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uk_cjs_user_phone (phone),
  UNIQUE KEY uk_cjs_user_email (email),
  KEY idx_cjs_user_type_status (user_type, account_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户主表';

CREATE TABLE IF NOT EXISTS cjs_role (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  role_code VARCHAR(64) NOT NULL,
  role_name VARCHAR(64) NOT NULL,
  status TINYINT UNSIGNED NOT NULL DEFAULT 1,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_cjs_role_code (role_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色';

CREATE TABLE IF NOT EXISTS cjs_permission (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  perm_code VARCHAR(100) NOT NULL,
  perm_name VARCHAR(100) NOT NULL,
  perm_type TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1-menu 2-button 3-api',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_cjs_permission_code (perm_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='权限点';

CREATE TABLE IF NOT EXISTS cjs_user_role (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  role_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_cjs_user_role (user_id, role_id),
  CONSTRAINT fk_cjs_user_role_user FOREIGN KEY (user_id) REFERENCES cjs_user(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_user_role_role FOREIGN KEY (role_id) REFERENCES cjs_role(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户-角色';

CREATE TABLE IF NOT EXISTS cjs_role_permission (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  role_id BIGINT UNSIGNED NOT NULL,
  permission_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_cjs_role_permission (role_id, permission_id),
  CONSTRAINT fk_cjs_role_permission_role FOREIGN KEY (role_id) REFERENCES cjs_role(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_role_permission_perm FOREIGN KEY (permission_id) REFERENCES cjs_permission(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色-权限';

CREATE TABLE IF NOT EXISTS cjs_admin_operation_log (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  operator_user_id BIGINT UNSIGNED NOT NULL,
  module VARCHAR(64) NOT NULL,
  action VARCHAR(64) NOT NULL,
  target_type VARCHAR(64) NULL,
  target_id BIGINT UNSIGNED NULL,
  detail_json JSON NULL,
  operated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_cjs_admin_op_user_time (operator_user_id, operated_at),
  CONSTRAINT fk_cjs_admin_op_user FOREIGN KEY (operator_user_id) REFERENCES cjs_user(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='后台操作日志';

-- =========================================================
-- 2) Enterprise & Audit (企业认证 + 审核闭环)
-- =========================================================
CREATE TABLE IF NOT EXISTS cjs_enterprise (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  owner_user_id BIGINT UNSIGNED NOT NULL,
  enterprise_name VARCHAR(200) NOT NULL,
  unified_credit_code VARCHAR(64) NULL,
  industry VARCHAR(128) NULL,
  city VARCHAR(64) NULL,
  address VARCHAR(255) NULL,
  website VARCHAR(255) NULL,
  logo_url VARCHAR(512) NULL,
  intro TEXT NULL,
  certified_status TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1-unsubmitted 2-pending 3-approved 4-rejected',
  enterprise_status TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1-normal 2-frozen',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_cjs_enterprise_owner (owner_user_id),
  UNIQUE KEY uk_cjs_enterprise_credit (unified_credit_code),
  KEY idx_cjs_enterprise_status (certified_status, enterprise_status),
  CONSTRAINT fk_cjs_enterprise_owner FOREIGN KEY (owner_user_id) REFERENCES cjs_user(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='企业主体';

CREATE TABLE IF NOT EXISTS cjs_enterprise_certification (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  enterprise_id BIGINT UNSIGNED NOT NULL,
  license_file_url VARCHAR(512) NOT NULL,
  submitter_user_id BIGINT UNSIGNED NOT NULL,
  audit_status TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1-pending 2-approved 3-rejected',
  audit_remark VARCHAR(255) NULL,
  audited_by BIGINT UNSIGNED NULL,
  submitted_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  audited_at DATETIME(3) NULL,
  PRIMARY KEY (id),
  KEY idx_cjs_ent_cert_status_time (audit_status, submitted_at),
  CONSTRAINT fk_cjs_ent_cert_ent FOREIGN KEY (enterprise_id) REFERENCES cjs_enterprise(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_ent_cert_submitter FOREIGN KEY (submitter_user_id) REFERENCES cjs_user(id) ON DELETE RESTRICT,
  CONSTRAINT fk_cjs_ent_cert_auditor FOREIGN KEY (audited_by) REFERENCES cjs_user(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='企业资质';

CREATE TABLE IF NOT EXISTS cjs_audit_record (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  audit_type TINYINT UNSIGNED NOT NULL COMMENT '1-enterprise_cert 2-job',
  target_id BIGINT UNSIGNED NOT NULL,
  status TINYINT UNSIGNED NOT NULL COMMENT '1-pending 2-approved 3-rejected',
  auditor_user_id BIGINT UNSIGNED NULL,
  reject_reason VARCHAR(255) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  audited_at DATETIME(3) NULL,
  PRIMARY KEY (id),
  KEY idx_cjs_audit_type_target (audit_type, target_id),
  KEY idx_cjs_audit_status_time (status, created_at),
  CONSTRAINT fk_cjs_audit_user FOREIGN KEY (auditor_user_id) REFERENCES cjs_user(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='审核记录';

-- =========================================================
-- 3) Resume / Job / Application (求职投递闭环)
-- =========================================================
CREATE TABLE IF NOT EXISTS cjs_resume (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  student_user_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(128) NOT NULL,
  is_default TINYINT UNSIGNED NOT NULL DEFAULT 0,
  resume_status TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1-active 2-archived',
  resume_content_json JSON NOT NULL COMMENT '教育/项目/实习/技能等统一JSON',
  completion_score DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_cjs_resume_user_status (student_user_id, resume_status),
  CONSTRAINT fk_cjs_resume_user FOREIGN KEY (student_user_id) REFERENCES cjs_user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生简历';

CREATE TABLE IF NOT EXISTS cjs_job_posting (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  enterprise_id BIGINT UNSIGNED NOT NULL,
  publisher_user_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(200) NOT NULL,
  category VARCHAR(64) NULL,
  city VARCHAR(64) NULL,
  salary_min DECIMAL(10,2) NULL,
  salary_max DECIMAL(10,2) NULL,
  internship_months TINYINT UNSIGNED NULL,
  education_requirement VARCHAR(64) NULL,
  description TEXT NOT NULL,
  requirement_text TEXT NULL,
  status TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1-draft 2-pending 3-online 4-rejected 5-offline',
  reject_reason VARCHAR(255) NULL,
  publish_at DATETIME(3) NULL,
  offline_at DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_cjs_job_ent_status (enterprise_id, status),
  KEY idx_cjs_job_city_status (city, status),
  CONSTRAINT fk_cjs_job_ent FOREIGN KEY (enterprise_id) REFERENCES cjs_enterprise(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_job_user FOREIGN KEY (publisher_user_id) REFERENCES cjs_user(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='岗位';

CREATE TABLE IF NOT EXISTS cjs_job_application (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  application_no VARCHAR(32) NOT NULL,
  job_id BIGINT UNSIGNED NOT NULL,
  enterprise_id BIGINT UNSIGNED NOT NULL,
  student_user_id BIGINT UNSIGNED NOT NULL,
  resume_id BIGINT UNSIGNED NOT NULL,
  status TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1-submitted 2-viewed 3-communicating 4-interview 5-offer 6-hired 7-rejected 8-withdrawn',
  reject_reason VARCHAR(255) NULL,
  submitted_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  last_action_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_cjs_application_no (application_no),
  UNIQUE KEY uk_cjs_job_student_once (job_id, student_user_id),
  KEY idx_cjs_app_ent_status (enterprise_id, status),
  KEY idx_cjs_app_student_status (student_user_id, status),
  CONSTRAINT fk_cjs_app_job FOREIGN KEY (job_id) REFERENCES cjs_job_posting(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_app_ent FOREIGN KEY (enterprise_id) REFERENCES cjs_enterprise(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_app_student FOREIGN KEY (student_user_id) REFERENCES cjs_user(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_app_resume FOREIGN KEY (resume_id) REFERENCES cjs_resume(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='投递记录';

CREATE TABLE IF NOT EXISTS cjs_application_status_log (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  application_id BIGINT UNSIGNED NOT NULL,
  from_status TINYINT UNSIGNED NULL,
  to_status TINYINT UNSIGNED NOT NULL,
  operator_user_id BIGINT UNSIGNED NULL,
  operator_role TINYINT UNSIGNED NULL COMMENT '1-student 2-enterprise 3-admin',
  note VARCHAR(255) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_cjs_app_log_app_time (application_id, created_at),
  CONSTRAINT fk_cjs_app_log_app FOREIGN KEY (application_id) REFERENCES cjs_job_application(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_app_log_user FOREIGN KEY (operator_user_id) REFERENCES cjs_user(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='投递状态流转日志';

-- =========================================================
-- 4) Chat / Interview / Offer (沟通面试Offer闭环)
-- =========================================================
CREATE TABLE IF NOT EXISTS cjs_conversation (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  application_id BIGINT UNSIGNED NOT NULL,
  enterprise_id BIGINT UNSIGNED NOT NULL,
  student_user_id BIGINT UNSIGNED NOT NULL,
  status TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1-active 2-closed',
  last_message_at DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_cjs_conversation_application (application_id),
  KEY idx_cjs_conversation_student (student_user_id),
  KEY idx_cjs_conversation_enterprise (enterprise_id),
  CONSTRAINT fk_cjs_conv_application FOREIGN KEY (application_id) REFERENCES cjs_job_application(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_conv_enterprise FOREIGN KEY (enterprise_id) REFERENCES cjs_enterprise(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_conv_student FOREIGN KEY (student_user_id) REFERENCES cjs_user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='沟通会话';

CREATE TABLE IF NOT EXISTS cjs_message (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  conversation_id BIGINT UNSIGNED NOT NULL,
  sender_user_id BIGINT UNSIGNED NOT NULL,
  message_type TINYINT UNSIGNED NOT NULL COMMENT '1-text 2-image 3-file 4-system',
  content_text TEXT NULL,
  file_url VARCHAR(512) NULL,
  sent_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_cjs_message_conv_time (conversation_id, sent_at),
  KEY idx_cjs_message_sender_time (sender_user_id, sent_at),
  CONSTRAINT fk_cjs_message_conv FOREIGN KEY (conversation_id) REFERENCES cjs_conversation(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_message_sender FOREIGN KEY (sender_user_id) REFERENCES cjs_user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会话消息';

CREATE TABLE IF NOT EXISTS cjs_interview_schedule (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  application_id BIGINT UNSIGNED NOT NULL,
  created_by_user_id BIGINT UNSIGNED NOT NULL,
  interview_type TINYINT UNSIGNED NOT NULL COMMENT '1-online 2-offline',
  status TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1-pending 2-confirmed 3-completed 4-cancelled',
  scheduled_at DATETIME(3) NOT NULL,
  duration_minutes INT UNSIGNED NOT NULL DEFAULT 30,
  meeting_link VARCHAR(512) NULL,
  location VARCHAR(255) NULL,
  remark VARCHAR(255) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_cjs_interview_app (application_id),
  KEY idx_cjs_interview_time_status (scheduled_at, status),
  CONSTRAINT fk_cjs_interview_app FOREIGN KEY (application_id) REFERENCES cjs_job_application(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_interview_creator FOREIGN KEY (created_by_user_id) REFERENCES cjs_user(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='面试安排';

CREATE TABLE IF NOT EXISTS cjs_interview_feedback (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  interview_id BIGINT UNSIGNED NOT NULL,
  evaluator_user_id BIGINT UNSIGNED NOT NULL,
  result TINYINT UNSIGNED NOT NULL COMMENT '1-pass 2-hold 3-fail',
  comment_text TEXT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_cjs_interview_feedback_once (interview_id, evaluator_user_id),
  CONSTRAINT fk_cjs_interview_feedback_interview FOREIGN KEY (interview_id) REFERENCES cjs_interview_schedule(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_interview_feedback_user FOREIGN KEY (evaluator_user_id) REFERENCES cjs_user(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='面试反馈';

CREATE TABLE IF NOT EXISTS cjs_interview_student_confirm (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  interview_id BIGINT UNSIGNED NOT NULL,
  student_user_id BIGINT UNSIGNED NOT NULL,
  action_type TINYINT UNSIGNED NOT NULL COMMENT '1-confirm 2-reschedule 3-decline',
  note VARCHAR(255) NULL,
  expected_reschedule_at DATETIME(3) NULL,
  submitted_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_cjs_interview_student_confirm (interview_id, student_user_id),
  KEY idx_cjs_interview_student_confirm_student (student_user_id, submitted_at),
  CONSTRAINT fk_cjs_interview_student_confirm_interview FOREIGN KEY (interview_id) REFERENCES cjs_interview_schedule(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_interview_student_confirm_student FOREIGN KEY (student_user_id) REFERENCES cjs_user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生面试确认';

CREATE TABLE IF NOT EXISTS cjs_offer (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  offer_no VARCHAR(32) NOT NULL,
  application_id BIGINT UNSIGNED NOT NULL,
  job_id BIGINT UNSIGNED NOT NULL,
  enterprise_id BIGINT UNSIGNED NOT NULL,
  student_user_id BIGINT UNSIGNED NOT NULL,
  offered_by_user_id BIGINT UNSIGNED NOT NULL,
  salary_min DECIMAL(10,2) NULL,
  salary_max DECIMAL(10,2) NULL,
  internship_start_date DATE NULL,
  internship_end_date DATE NULL,
  terms_text TEXT NULL,
  status TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1-sent 2-accepted 3-rejected 4-expired',
  expires_at DATETIME(3) NULL,
  decision_at DATETIME(3) NULL,
  reject_reason VARCHAR(255) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_cjs_offer_no (offer_no),
  UNIQUE KEY uk_cjs_offer_application (application_id),
  KEY idx_cjs_offer_student_status (student_user_id, status),
  CONSTRAINT fk_cjs_offer_app FOREIGN KEY (application_id) REFERENCES cjs_job_application(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_offer_job FOREIGN KEY (job_id) REFERENCES cjs_job_posting(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_offer_ent FOREIGN KEY (enterprise_id) REFERENCES cjs_enterprise(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_offer_student FOREIGN KEY (student_user_id) REFERENCES cjs_user(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_offer_operator FOREIGN KEY (offered_by_user_id) REFERENCES cjs_user(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Offer';

CREATE TABLE IF NOT EXISTS cjs_offer_status_log (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  offer_id BIGINT UNSIGNED NOT NULL,
  from_status TINYINT UNSIGNED NULL,
  to_status TINYINT UNSIGNED NOT NULL,
  operator_user_id BIGINT UNSIGNED NULL,
  note VARCHAR(255) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_cjs_offer_log_offer_time (offer_id, created_at),
  CONSTRAINT fk_cjs_offer_log_offer FOREIGN KEY (offer_id) REFERENCES cjs_offer(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_offer_log_user FOREIGN KEY (operator_user_id) REFERENCES cjs_user(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Offer状态流转日志';

-- =========================================================
-- 5) Review / Report / Penalty / Notification (治理闭环)
-- =========================================================
CREATE TABLE IF NOT EXISTS cjs_enterprise_review (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  enterprise_id BIGINT UNSIGNED NOT NULL,
  application_id BIGINT UNSIGNED NOT NULL,
  student_user_id BIGINT UNSIGNED NOT NULL,
  rating TINYINT UNSIGNED NOT NULL COMMENT '1-5',
  content VARCHAR(500) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_cjs_review_app_student (application_id, student_user_id),
  KEY idx_cjs_review_ent (enterprise_id),
  CONSTRAINT fk_cjs_review_ent FOREIGN KEY (enterprise_id) REFERENCES cjs_enterprise(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_review_app FOREIGN KEY (application_id) REFERENCES cjs_job_application(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_review_student FOREIGN KEY (student_user_id) REFERENCES cjs_user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='企业评价';

CREATE TABLE IF NOT EXISTS cjs_report (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  reporter_user_id BIGINT UNSIGNED NOT NULL,
  target_type TINYINT UNSIGNED NOT NULL COMMENT '1-job 2-enterprise 3-user 4-message',
  target_id BIGINT UNSIGNED NOT NULL,
  reason VARCHAR(255) NOT NULL,
  evidence_url VARCHAR(512) NULL,
  status TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1-pending 2-processing 3-closed',
  handler_user_id BIGINT UNSIGNED NULL,
  handle_result VARCHAR(255) NULL,
  handled_at DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_cjs_report_status_time (status, created_at),
  KEY idx_cjs_report_target (target_type, target_id),
  CONSTRAINT fk_cjs_report_reporter FOREIGN KEY (reporter_user_id) REFERENCES cjs_user(id) ON DELETE CASCADE,
  CONSTRAINT fk_cjs_report_handler FOREIGN KEY (handler_user_id) REFERENCES cjs_user(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='举报';

CREATE TABLE IF NOT EXISTS cjs_penalty_record (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  target_type TINYINT UNSIGNED NOT NULL COMMENT '1-user 2-enterprise 3-job',
  target_id BIGINT UNSIGNED NOT NULL,
  penalty_type TINYINT UNSIGNED NOT NULL COMMENT '1-warning 2-freeze 3-offline',
  reason VARCHAR(255) NOT NULL,
  status TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1-active 2-revoked',
  operator_user_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_cjs_penalty_target (target_type, target_id, status),
  CONSTRAINT fk_cjs_penalty_operator FOREIGN KEY (operator_user_id) REFERENCES cjs_user(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='处罚记录';

CREATE TABLE IF NOT EXISTS cjs_user_notification (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  biz_type VARCHAR(64) NULL COMMENT 'application/interview/offer/audit/report',
  biz_id BIGINT UNSIGNED NULL,
  title VARCHAR(255) NOT NULL,
  content VARCHAR(1000) NOT NULL,
  is_read TINYINT UNSIGNED NOT NULL DEFAULT 0,
  read_at DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_cjs_notice_user_read (user_id, is_read, created_at),
  CONSTRAINT fk_cjs_notice_user FOREIGN KEY (user_id) REFERENCES cjs_user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='站内通知';

SET FOREIGN_KEY_CHECKS = 1;
```
