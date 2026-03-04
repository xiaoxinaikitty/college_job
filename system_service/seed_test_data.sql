-- College Job System Seed Data
-- 用途：为学生端 / 企业端 / 管理员端导入一批可联调的真实测试数据
-- 执行方式：
--   mysql -uroot -p123456 -D college_job < seed_test_data.sql

USE college_job;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

SET @PWD_HASH = '$2a$10$OfKBzIB1Mk3HLj0ljNv/vOueWYbaSREBJGJvkXnCXo5ufU.pdEEsK';

-- =========================================================
-- 1) 用户（学生 / 企业 / 管理员）
-- =========================================================
INSERT IGNORE INTO cjs_user (
  id, user_type, account_status, phone, email, password_hash, nickname, real_name, avatar_url, last_login_at, created_at, updated_at, is_deleted
) VALUES
  (10001, 3, 1, '18800010001', 'admin.ops@collegejob.com', @PWD_HASH, '运营管理员', '运营管理员', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 40 DAY), NOW(), 0),
  (10002, 3, 1, '18800010002', 'admin.audit@collegejob.com', @PWD_HASH, '审核管理员', '审核管理员', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 35 DAY), NOW(), 0),

  (10101, 1, 1, '13900001001', 'linchen@campus.edu.cn', @PWD_HASH, '林晨', '林晨', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 12 DAY), NOW(), 0),
  (10102, 1, 1, '13900001002', 'wangya@campus.edu.cn', @PWD_HASH, '王雅', '王雅', NULL, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 11 DAY), NOW(), 0),
  (10103, 1, 1, '13900001003', 'chenhao@campus.edu.cn', @PWD_HASH, '陈浩', '陈浩', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY), NOW(), 0),
  (10104, 1, 1, '13900001004', 'liuting@campus.edu.cn', @PWD_HASH, '刘婷', '刘婷', NULL, DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 9 DAY), NOW(), 0),
  (10105, 1, 2, '13900001005', 'zhaolei@campus.edu.cn', @PWD_HASH, '赵磊', '赵磊', NULL, DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY), NOW(), 0),
  (10106, 1, 1, '13900001006', 'sunmeng@campus.edu.cn', @PWD_HASH, '孙萌', '孙萌', NULL, DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY), NOW(), 0),
  (10107, 1, 1, '13900001007', 'zhengyu@campus.edu.cn', @PWD_HASH, '郑宇', '郑宇', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 6 DAY), NOW(), 0),
  (10108, 1, 3, '13900001008', 'zhouxin@campus.edu.cn', @PWD_HASH, '周欣', '周欣', NULL, DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), NOW(), 0),

  (10201, 2, 1, '13900002001', 'hr@xingyun.com', @PWD_HASH, '星云科技HR', '徐雯', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 15 DAY), NOW(), 0),
  (10202, 2, 1, '13900002002', 'hr@qingheedu.com', @PWD_HASH, '青禾教育HR', '李航', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 14 DAY), NOW(), 0),
  (10203, 2, 1, '13900002003', 'hr@haichuanai.com', @PWD_HASH, '海川智能HR', '王璐', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 13 DAY), NOW(), 0),
  (10204, 2, 2, '13900002004', 'hr@yunfanmall.com', @PWD_HASH, '云帆电商HR', '赵晨', NULL, DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 12 DAY), NOW(), 0),
  (10205, 2, 1, '13900002005', 'hr@bluewhale.com', @PWD_HASH, '蓝鲸数据HR', '周宁', NULL, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 11 DAY), NOW(), 0);

-- =========================================================
-- 2) 企业与企业认证
-- =========================================================
INSERT IGNORE INTO cjs_enterprise (
  id, owner_user_id, enterprise_name, unified_credit_code, industry, city, address, website, logo_url, intro, certified_status, enterprise_status, created_at, updated_at
) VALUES
  (11001, 10201, '星云科技有限公司', '91310100MA1FL001X1', '互联网/软件服务', '上海', '上海市浦东新区张江高科路88号', 'https://www.xingyun-tech.com', NULL, '专注企业级SaaS与AI智能中台建设，提供实习生培养计划。', 3, 1, DATE_SUB(NOW(), INTERVAL 15 DAY), NOW()),
  (11002, 10202, '青禾教育科技有限公司', '91440101MA5QH002X2', '教育科技', '广州', '广州市天河区科韵路101号', 'https://www.qinghe-edu.com', NULL, '在线教育内容与学习平台运营，持续招聘运营和产品实习生。', 2, 1, DATE_SUB(NOW(), INTERVAL 14 DAY), NOW()),
  (11003, 10203, '海川智能科技有限公司', '91110108MA7HC003X3', '人工智能/机器人', '北京', '北京市海淀区中关村南大街27号', 'https://www.haichuan-ai.com', NULL, '聚焦计算机视觉与工业智能质检。', 3, 1, DATE_SUB(NOW(), INTERVAL 13 DAY), NOW()),
  (11004, 10204, '云帆电商运营有限公司', '91330106MA2YF004X4', '电子商务', '杭州', '杭州市西湖区文三路200号', 'https://www.yunfanmall.com', NULL, '跨境电商运营服务商。', 4, 1, DATE_SUB(NOW(), INTERVAL 12 DAY), NOW()),
  (11005, 10205, '蓝鲸数据技术有限公司', '91440300MA5BW005X5', '大数据服务', '深圳', '深圳市南山区科苑大道66号', 'https://www.bluewhale-data.com', NULL, '提供数据治理、BI与增长分析服务。', 3, 2, DATE_SUB(NOW(), INTERVAL 11 DAY), NOW());

INSERT IGNORE INTO cjs_enterprise_certification (
  id, enterprise_id, license_file_url, submitter_user_id, audit_status, audit_remark, audited_by, submitted_at, audited_at
) VALUES
  (12001, 11001, 'https://oss.example.com/licenses/xingyun_license.jpg', 10201, 2, '资料齐全，审核通过', 7, DATE_SUB(NOW(), INTERVAL 14 DAY), DATE_SUB(NOW(), INTERVAL 13 DAY)),
  (12002, 11002, 'https://oss.example.com/licenses/qinghe_license.jpg', 10202, 1, NULL, NULL, DATE_SUB(NOW(), INTERVAL 6 DAY), NULL),
  (12003, 11003, 'https://oss.example.com/licenses/haichuan_license.jpg', 10203, 2, '企业资质有效', 10002, DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 9 DAY)),
  (12004, 11004, 'https://oss.example.com/licenses/yunfan_license.jpg', 10204, 3, '营业执照信息与主体不一致', 7, DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY)),
  (12005, 11005, 'https://oss.example.com/licenses/bluewhale_license.jpg', 10205, 2, '审核通过', 10001, DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY));

INSERT IGNORE INTO cjs_audit_record (
  id, audit_type, target_id, status, auditor_user_id, reject_reason, created_at, audited_at
) VALUES
  (12101, 1, 12001, 2, 7, NULL, DATE_SUB(NOW(), INTERVAL 14 DAY), DATE_SUB(NOW(), INTERVAL 13 DAY)),
  (12102, 1, 12002, 1, NULL, NULL, DATE_SUB(NOW(), INTERVAL 6 DAY), NULL),
  (12103, 1, 12004, 3, 7, '主体信息不一致', DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY));

-- =========================================================
-- 3) 简历、岗位、投递
-- =========================================================
INSERT IGNORE INTO cjs_resume (
  id, student_user_id, title, is_default, resume_status, resume_content_json, completion_score, created_at, updated_at
) VALUES
  (13001, 10101, '林晨-产品运营实习简历', 1, 1,
   JSON_OBJECT(
     'basicInfo', JSON_OBJECT('name','林晨','school','华东师范大学','major','信息管理','grade','大三','phone','13900001001','email','linchen@campus.edu.cn'),
     'education', JSON_ARRAY(JSON_OBJECT('school','华东师范大学','degree','本科','major','信息管理','start','2023-09','end','2027-06')),
     'internships', JSON_ARRAY(JSON_OBJECT('company','校园新媒体中心','role','运营助理','desc','负责活动策划与数据复盘')),
     'projects', JSON_ARRAY(JSON_OBJECT('name','校园活动报名小程序','role','产品负责人','desc','完成需求文档与用户访谈')),
     'skills', JSON_ARRAY('Axure','SQL','Excel','数据分析')
   ), 92.50, DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),

  (13002, 10102, '王雅-前端开发实习简历', 1, 1,
   JSON_OBJECT(
     'basicInfo', JSON_OBJECT('name','王雅','school','华南理工大学','major','软件工程','grade','大四','phone','13900001002','email','wangya@campus.edu.cn'),
     'education', JSON_ARRAY(JSON_OBJECT('school','华南理工大学','degree','本科','major','软件工程','start','2022-09','end','2026-06')),
     'internships', JSON_ARRAY(JSON_OBJECT('company','学院实验室','role','前端开发','desc','负责Vue3后台系统重构')),
     'projects', JSON_ARRAY(JSON_OBJECT('name','二手交易平台','role','前端主程','desc','实现Flutter与Web双端')),
     'skills', JSON_ARRAY('Flutter','Vue3','TypeScript','Git')
   ), 95.00, DATE_SUB(NOW(), INTERVAL 11 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),

  (13003, 10103, '陈浩-后端开发实习简历', 1, 1,
   JSON_OBJECT(
     'basicInfo', JSON_OBJECT('name','陈浩','school','北京邮电大学','major','计算机科学','grade','研一','phone','13900001003','email','chenhao@campus.edu.cn'),
     'education', JSON_ARRAY(JSON_OBJECT('school','北京邮电大学','degree','硕士','major','计算机科学','start','2025-09','end','2028-06')),
     'internships', JSON_ARRAY(JSON_OBJECT('company','开源社区','role','后端贡献者','desc','参与SpringBoot组件维护')),
     'projects', JSON_ARRAY(JSON_OBJECT('name','校招流程管理系统','role','后端负责人','desc','搭建权限、审核、日志模块')),
     'skills', JSON_ARRAY('Java','SpringBoot','MySQL','Redis')
   ), 96.00, DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),

  (13004, 10104, '刘婷-数据分析实习简历', 1, 1, JSON_OBJECT('basicInfo', JSON_OBJECT('name','刘婷'), 'skills', JSON_ARRAY('Python','SQL','PowerBI')), 88.00, DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (13005, 10105, '赵磊-测试开发实习简历', 1, 1, JSON_OBJECT('basicInfo', JSON_OBJECT('name','赵磊'), 'skills', JSON_ARRAY('测试用例','接口测试','JMeter')), 86.00, DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY)),
  (13006, 10106, '孙萌-新媒体运营实习简历', 1, 1, JSON_OBJECT('basicInfo', JSON_OBJECT('name','孙萌'), 'skills', JSON_ARRAY('文案','短视频','数据复盘')), 84.50, DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (13007, 10107, '郑宇-算法工程实习简历', 1, 1, JSON_OBJECT('basicInfo', JSON_OBJECT('name','郑宇'), 'skills', JSON_ARRAY('Python','机器学习','深度学习')), 90.00, DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (13008, 10108, '周欣-设计实习简历', 1, 1, JSON_OBJECT('basicInfo', JSON_OBJECT('name','周欣'), 'skills', JSON_ARRAY('Figma','UI设计','交互设计')), 82.00, DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY));
INSERT IGNORE INTO cjs_job_posting (
  id, enterprise_id, publisher_user_id, title, category, city, salary_min, salary_max, internship_months,
  education_requirement, description, requirement_text, status, reject_reason, publish_at, offline_at, created_at, updated_at
) VALUES
  (14001, 11001, 10201, '产品运营实习生', '产品/运营', '上海', 5000, 7000, 3, '本科及以上', '参与产品活动策划、用户增长与数据分析。', '沟通能力强，熟悉Excel与基础SQL。', 3, NULL, DATE_SUB(NOW(), INTERVAL 9 DAY), NULL, DATE_SUB(NOW(), INTERVAL 10 DAY), NOW()),
  (14002, 11001, 10201, 'Flutter开发实习生', '技术研发', '上海', 7000, 10000, 4, '本科及以上', '参与Flutter学生端与企业端功能迭代。', '熟悉Dart、状态管理与网络请求。', 3, NULL, DATE_SUB(NOW(), INTERVAL 8 DAY), NULL, DATE_SUB(NOW(), INTERVAL 9 DAY), NOW()),
  (14003, 11001, 10201, '测试开发实习生', '技术研发', '上海', 6000, 8500, 3, '本科及以上', '搭建自动化测试脚本与接口测试体系。', '有接口测试经验优先。', 2, NULL, NULL, NULL, DATE_SUB(NOW(), INTERVAL 2 DAY), NOW()),
  (14004, 11001, 10201, '直播运营实习生', '市场运营', '上海', 4500, 6000, 3, '大专及以上', '负责直播间日常运营与排期。', '需要晚班，接受弹性时间。', 4, '岗位描述不完整，需补充真实性说明', NULL, NULL, DATE_SUB(NOW(), INTERVAL 3 DAY), NOW()),

  (14005, 11002, 10202, '课程运营实习生', '教育运营', '广州', 4500, 6500, 3, '本科及以上', '协助课程上架、活动推广与社群运营。', '具备基础文案能力。', 3, NULL, DATE_SUB(NOW(), INTERVAL 7 DAY), NULL, DATE_SUB(NOW(), INTERVAL 8 DAY), NOW()),
  (14006, 11003, 10203, 'Java后端实习生', '技术研发', '北京', 8000, 12000, 6, '本科及以上', '参与后端接口开发、数据库设计与性能优化。', '熟悉Java/SpringBoot/MySQL。', 3, NULL, DATE_SUB(NOW(), INTERVAL 8 DAY), NULL, DATE_SUB(NOW(), INTERVAL 9 DAY), NOW()),
  (14007, 11003, 10203, '算法实习生', '算法', '北京', 9000, 15000, 6, '硕士优先', '参与CV算法建模与评估。', '熟悉Python与深度学习框架。', 2, NULL, NULL, NULL, DATE_SUB(NOW(), INTERVAL 1 DAY), NOW()),
  (14008, 11003, 10203, '数据产品实习生', '产品', '北京', 7000, 10000, 4, '本科及以上', '负责数据产品需求拆解与埋点规划。', '需要数据分析能力。', 5, NULL, DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 13 DAY), NOW()),

  (14009, 11005, 10205, 'BI分析实习生', '数据分析', '深圳', 7000, 11000, 4, '本科及以上', '参与数据报表搭建、指标体系建设。', '熟悉SQL与可视化工具。', 3, NULL, DATE_SUB(NOW(), INTERVAL 6 DAY), NULL, DATE_SUB(NOW(), INTERVAL 7 DAY), NOW()),
  (14010, 11004, 10204, '新媒体实习生', '市场运营', '杭州', 4000, 5500, 3, '本科及以上', '负责公众号及短视频内容生产。', '需有作品集。', 1, NULL, NULL, NULL, DATE_SUB(NOW(), INTERVAL 2 DAY), NOW()),
  (14011, 11004, 10204, '电商运营实习生', '电商运营', '杭州', 4500, 6500, 3, '本科及以上', '参与店铺活动策划与投放。', '需具备活动复盘能力。', 4, '企业认证未通过，岗位驳回', NULL, NULL, DATE_SUB(NOW(), INTERVAL 4 DAY), NOW()),
  (14012, 11002, 10202, '用户增长实习生', '增长运营', '广州', 5000, 7500, 3, '本科及以上', '协助增长活动策略、渠道拉新与效果分析。', '有校园增长项目经验优先。', 2, NULL, NULL, NULL, DATE_SUB(NOW(), INTERVAL 1 DAY), NOW());

INSERT IGNORE INTO cjs_audit_record (
  id, audit_type, target_id, status, auditor_user_id, reject_reason, created_at, audited_at
) VALUES
  (12111, 2, 14003, 1, NULL, NULL, DATE_SUB(NOW(), INTERVAL 2 DAY), NULL),
  (12112, 2, 14004, 3, 7, '岗位描述不完整', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (12113, 2, 14007, 1, NULL, NULL, DATE_SUB(NOW(), INTERVAL 1 DAY), NULL),
  (12114, 2, 14011, 3, 10002, '企业认证未通过', DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),
  (12115, 2, 14012, 1, NULL, NULL, DATE_SUB(NOW(), INTERVAL 1 DAY), NULL);

INSERT IGNORE INTO cjs_job_application (
  id, application_no, job_id, enterprise_id, student_user_id, resume_id, status, reject_reason,
  submitted_at, last_action_at, created_at, updated_at
) VALUES
  (15001, 'APP2026030001', 14001, 11001, 10101, 13001, 3, NULL, DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY), NOW()),
  (15002, 'APP2026030002', 14001, 11001, 10102, 13002, 4, NULL, DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY), NOW()),
  (15003, 'APP2026030003', 14002, 11001, 10103, 13003, 5, NULL, DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY), NOW()),
  (15004, 'APP2026030004', 14002, 11001, 10104, 13004, 6, NULL, DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 6 DAY), NOW()),
  (15005, 'APP2026030005', 14006, 11003, 10105, 13005, 7, '技术栈匹配度不足', DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 6 DAY), NOW()),
  (15006, 'APP2026030006', 14006, 11003, 10106, 13006, 2, NULL, DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), NOW()),
  (15007, 'APP2026030007', 14005, 11002, 10107, 13007, 1, NULL, DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), NOW()),
  (15008, 'APP2026030008', 14009, 11005, 10108, 13008, 8, '学生主动撤回', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), NOW()),
  (15009, 'APP2026030009', 14006, 11003, 10101, 13001, 4, NULL, DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), NOW()),
  (15010, 'APP2026030010', 14009, 11005, 10102, 13002, 5, NULL, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), NOW()),
  (15011, 'APP2026030011', 1, 1, 10103, 13003, 3, NULL, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), NOW()),
  (15012, 'APP2026030012', 2, 1, 10104, 13004, 6, NULL, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), NOW()),
  (15013, 'APP2026030013', 14001, 11001, 10106, 13006, 3, NULL, DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), NOW());

INSERT IGNORE INTO cjs_application_status_log (
  id, application_id, from_status, to_status, operator_user_id, operator_role, note, created_at
) VALUES
  (15101, 15001, NULL, 1, 10101, 1, '提交投递', DATE_SUB(NOW(), INTERVAL 8 DAY)),
  (15102, 15001, 1, 2, 10201, 2, '已查看简历', DATE_SUB(NOW(), INTERVAL 7 DAY)),
  (15103, 15001, 2, 3, 10201, 2, '进入沟通阶段', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  (15104, 15002, NULL, 1, 10102, 1, '提交投递', DATE_SUB(NOW(), INTERVAL 7 DAY)),
  (15105, 15002, 1, 3, 10201, 2, '发起沟通', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  (15106, 15002, 3, 4, 10201, 2, '安排面试', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (15107, 15003, NULL, 1, 10103, 1, '提交投递', DATE_SUB(NOW(), INTERVAL 7 DAY)),
  (15108, 15003, 1, 4, 10201, 2, '简历优秀，直接面试', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  (15109, 15003, 4, 5, 10201, 2, '面试通过，发放Offer', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (15110, 15004, NULL, 1, 10104, 1, '提交投递', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  (15111, 15004, 1, 4, 10201, 2, '安排面试', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  (15112, 15004, 4, 5, 10201, 2, '发放Offer', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (15113, 15004, 5, 6, 10104, 1, '学生接受Offer', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (15114, 15005, NULL, 1, 10105, 1, '提交投递', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  (15115, 15005, 1, 7, 10203, 2, '不符合岗位要求', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  (15116, 15006, NULL, 1, 10106, 1, '提交投递', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  (15117, 15006, 1, 2, 10203, 2, '简历已查看', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  (15118, 15007, NULL, 1, 10107, 1, '提交投递', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  (15119, 15008, NULL, 1, 10108, 1, '提交投递', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  (15120, 15008, 1, 8, 10108, 1, '学生撤回', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  (15121, 15009, NULL, 1, 10101, 1, '提交投递', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  (15122, 15009, 1, 4, 10203, 2, '进入面试阶段', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (15123, 15010, NULL, 1, 10102, 1, '提交投递', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  (15124, 15010, 1, 4, 10205, 2, '安排初试', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (15125, 15010, 4, 5, 10205, 2, '发放Offer', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (15126, 15011, NULL, 1, 10103, 1, '提交投递', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (15127, 15011, 1, 3, 6, 2, '发起沟通', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (15128, 15012, NULL, 1, 10104, 1, '提交投递', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (15129, 15012, 1, 4, 6, 2, '安排面试', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (15130, 15012, 4, 6, 10104, 1, '录用完成', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (15131, 15013, NULL, 1, 10106, 1, '提交投递', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  (15132, 15013, 1, 3, 10201, 2, '进入沟通', DATE_SUB(NOW(), INTERVAL 5 DAY));
-- =========================================================
-- 4) 沟通 / 面试 / Offer
-- =========================================================
INSERT IGNORE INTO cjs_conversation (
  id, application_id, enterprise_id, student_user_id, status, last_message_at, created_at, updated_at
) VALUES
  (16001, 15001, 11001, 10101, 1, DATE_SUB(NOW(), INTERVAL 8 HOUR), DATE_SUB(NOW(), INTERVAL 6 DAY), NOW()),
  (16002, 15002, 11001, 10102, 1, DATE_SUB(NOW(), INTERVAL 12 HOUR), DATE_SUB(NOW(), INTERVAL 6 DAY), NOW()),
  (16003, 15003, 11001, 10103, 1, DATE_SUB(NOW(), INTERVAL 5 HOUR), DATE_SUB(NOW(), INTERVAL 5 DAY), NOW()),
  (16004, 15004, 11001, 10104, 2, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), NOW()),
  (16005, 15005, 11003, 10105, 2, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), NOW()),
  (16006, 15006, 11003, 10106, 1, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), NOW()),
  (16007, 15009, 11003, 10101, 1, DATE_SUB(NOW(), INTERVAL 4 HOUR), DATE_SUB(NOW(), INTERVAL 2 DAY), NOW()),
  (16008, 15010, 11005, 10102, 1, DATE_SUB(NOW(), INTERVAL 2 HOUR), DATE_SUB(NOW(), INTERVAL 2 DAY), NOW()),
  (16009, 15011, 1, 10103, 1, DATE_SUB(NOW(), INTERVAL 1 HOUR), DATE_SUB(NOW(), INTERVAL 1 DAY), NOW()),
  (16010, 15013, 11001, 10106, 1, DATE_SUB(NOW(), INTERVAL 30 HOUR), DATE_SUB(NOW(), INTERVAL 5 DAY), NOW());

INSERT IGNORE INTO cjs_message (
  id, conversation_id, sender_user_id, message_type, content_text, file_url, sent_at
) VALUES
  (16101, 16001, 10201, 1, '你好林晨，看到你投递了运营实习岗位，方便沟通一下项目经历吗？', NULL, DATE_SUB(NOW(), INTERVAL 3 DAY)),
  (16102, 16001, 10101, 1, '您好，可以的。我最近做过校园活动增长项目。', NULL, DATE_SUB(NOW(), INTERVAL 3 DAY)),
  (16103, 16001, 10201, 1, '很不错，稍后给你安排线上沟通。', NULL, DATE_SUB(NOW(), INTERVAL 8 HOUR)),

  (16104, 16002, 10201, 1, '王雅你好，想了解一下你做Flutter项目的规模。', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (16105, 16002, 10102, 1, '主要是校园服务类APP，日活大概3000。', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (16106, 16002, 10201, 1, '好的，我们给你发面试安排。', NULL, DATE_SUB(NOW(), INTERVAL 12 HOUR)),

  (16107, 16003, 10201, 1, '陈浩你好，一面通过，准备发Offer。', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (16108, 16003, 10103, 1, '感谢，期待加入团队。', NULL, DATE_SUB(NOW(), INTERVAL 5 HOUR)),

  (16109, 16004, 10201, 1, '刘婷，恭喜你通过面试。', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (16110, 16004, 10104, 1, '谢谢，我已确认入职。', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)),

  (16111, 16005, 10203, 1, '赵磊你好，当前岗位已满编，感谢投递。', NULL, DATE_SUB(NOW(), INTERVAL 3 DAY)),
  (16112, 16005, 10105, 1, '收到，感谢反馈。', NULL, DATE_SUB(NOW(), INTERVAL 3 DAY)),

  (16113, 16006, 10203, 1, '孙萌你好，简历我们已查看，本周会反馈。', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (16114, 16006, 10106, 1, '好的，辛苦啦。', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY)),

  (16115, 16007, 10203, 1, '林晨，你的二面时间拟定在后天下午。', NULL, DATE_SUB(NOW(), INTERVAL 5 HOUR)),
  (16116, 16007, 10101, 1, '可以，我这边时间没问题。', NULL, DATE_SUB(NOW(), INTERVAL 4 HOUR)),

  (16117, 16008, 10205, 1, '王雅你好，Offer已发送，请在3天内确认。', NULL, DATE_SUB(NOW(), INTERVAL 2 HOUR)),
  (16118, 16008, 10102, 1, '收到，我会尽快答复。', NULL, DATE_SUB(NOW(), INTERVAL 1 HOUR)),

  (16119, 16009, 6, 1, '欢迎投递，我们先沟通一下后端项目经验。', NULL, DATE_SUB(NOW(), INTERVAL 1 HOUR)),
  (16120, 16009, 10103, 1, '好的，我做过SpringBoot微服务项目。', NULL, DATE_SUB(NOW(), INTERVAL 50 MINUTE)),

  (16121, 16010, 10201, 1, '孙萌你好，请补充你的作品链接。', NULL, DATE_SUB(NOW(), INTERVAL 30 HOUR)),
  (16122, 16010, 10106, 1, '好的，我今晚补充。', NULL, DATE_SUB(NOW(), INTERVAL 29 HOUR));

INSERT IGNORE INTO cjs_interview_schedule (
  id, application_id, created_by_user_id, interview_type, status, scheduled_at, duration_minutes, meeting_link, location, remark, created_at, updated_at
) VALUES
  (17001, 15002, 10201, 1, 2, DATE_ADD(NOW(), INTERVAL 1 DAY), 45, 'https://meeting.tencent.com/room/xy-15002', NULL, '请提前10分钟进入会议', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW()),
  (17002, 15003, 10201, 1, 3, DATE_SUB(NOW(), INTERVAL 2 DAY), 60, 'https://meeting.tencent.com/room/xy-15003', NULL, '技术面试', DATE_SUB(NOW(), INTERVAL 4 DAY), NOW()),
  (17003, 15004, 10201, 2, 3, DATE_SUB(NOW(), INTERVAL 3 DAY), 60, NULL, '上海市浦东新区张江高科路88号A座8F', '现场面试', DATE_SUB(NOW(), INTERVAL 5 DAY), NOW()),
  (17004, 15009, 10203, 1, 1, DATE_ADD(NOW(), INTERVAL 2 DAY), 45, 'https://meeting.tencent.com/room/hc-15009', NULL, '算法负责人参与', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW()),
  (17005, 15010, 10205, 1, 4, DATE_SUB(NOW(), INTERVAL 1 DAY), 30, 'https://meeting.tencent.com/room/bw-15010', NULL, '候选人临时取消', DATE_SUB(NOW(), INTERVAL 2 DAY), NOW()),
  (17006, 15012, 6, 2, 3, DATE_SUB(NOW(), INTERVAL 1 DAY), 40, NULL, '深圳市南山区科技园A3', '复试通过', DATE_SUB(NOW(), INTERVAL 2 DAY), NOW());

INSERT IGNORE INTO cjs_interview_student_confirm (
  id, interview_id, student_user_id, action_type, note, expected_reschedule_at, submitted_at, created_at, updated_at
) VALUES
  (17201, 17001, 10102, 1, '已确认按时参加', NULL, DATE_SUB(NOW(), INTERVAL 20 HOUR), DATE_SUB(NOW(), INTERVAL 20 HOUR), NOW()),
  (17202, 17002, 10103, 1, '已参加', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), NOW()),
  (17203, 17003, 10104, 1, '已参加线下面试', NULL, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), NOW()),
  (17204, 17005, 10102, 2, '请求改期，课程冲突', DATE_ADD(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), NOW()),
  (17205, 17006, 10104, 1, '已确认', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), NOW());

INSERT IGNORE INTO cjs_interview_feedback (
  id, interview_id, evaluator_user_id, result, comment_text, created_at
) VALUES
  (17101, 17002, 10201, 1, '技术基础扎实，沟通清晰，建议录用。', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (17102, 17003, 10201, 1, '现场表现稳定，执行力好。', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  (17103, 17006, 6, 1, '后端能力符合预期，推荐录用。', DATE_SUB(NOW(), INTERVAL 1 DAY));

INSERT IGNORE INTO cjs_offer (
  id, offer_no, application_id, job_id, enterprise_id, student_user_id, offered_by_user_id, salary_min, salary_max,
  internship_start_date, internship_end_date, terms_text, status, expires_at, decision_at, reject_reason, created_at, updated_at
) VALUES
  (18001, 'OFF2026030001', 15003, 14002, 11001, 10103, 10201, 9000, 12000, DATE_ADD(CURDATE(), INTERVAL 7 DAY), DATE_ADD(CURDATE(), INTERVAL 187 DAY), '每周至少到岗4天，提供导师带教。', 1, DATE_ADD(NOW(), INTERVAL 3 DAY), NULL, NULL, DATE_SUB(NOW(), INTERVAL 1 DAY), NOW()),
  (18002, 'OFF2026030002', 15004, 14002, 11001, 10104, 10201, 8500, 11000, DATE_ADD(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 185 DAY), '转正评估通道开放。', 2, DATE_ADD(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), NULL, DATE_SUB(NOW(), INTERVAL 2 DAY), NOW()),
  (18003, 'OFF2026030003', 15010, 14009, 11005, 10102, 10205, 9500, 13000, DATE_ADD(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 190 DAY), '需驻场深圳，每周5天。', 3, DATE_ADD(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 HOUR), '与学业时间冲突', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW()),
  (18004, 'OFF2026030004', 15012, 2, 1, 10104, 6, 7000, 9000, DATE_ADD(CURDATE(), INTERVAL 6 DAY), DATE_ADD(CURDATE(), INTERVAL 186 DAY), '企业导师一对一带教。', 2, DATE_ADD(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 18 HOUR), NULL, DATE_SUB(NOW(), INTERVAL 1 DAY), NOW());

INSERT IGNORE INTO cjs_offer_status_log (
  id, offer_id, from_status, to_status, operator_user_id, note, created_at
) VALUES
  (18101, 18001, NULL, 1, 10201, '已发送Offer', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (18102, 18002, NULL, 1, 10201, '已发送Offer', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (18103, 18002, 1, 2, 10104, '学生接受Offer', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (18104, 18003, NULL, 1, 10205, '已发送Offer', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (18105, 18003, 1, 3, 10102, '学生拒绝Offer', DATE_SUB(NOW(), INTERVAL 1 HOUR)),
  (18106, 18004, NULL, 1, 6, '已发送Offer', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (18107, 18004, 1, 2, 10104, '学生接受Offer', DATE_SUB(NOW(), INTERVAL 18 HOUR));
-- =========================================================
-- 5) 评价 / 举报 / 处罚 / 通知 / 日志
-- =========================================================
INSERT IGNORE INTO cjs_enterprise_review (
  id, enterprise_id, application_id, student_user_id, rating, content, created_at
) VALUES
  (19001, 11001, 15004, 10104, 5, '面试流程规范，沟通反馈及时，导师很专业。', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (19002, 11001, 15003, 10103, 2, '面试安排多次变更，体验一般。', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (19003, 1, 15012, 10104, 4, '整体流程顺畅，建议增加实习生培训资料。', DATE_SUB(NOW(), INTERVAL 12 HOUR));

INSERT IGNORE INTO cjs_report (
  id, reporter_user_id, target_type, target_id, reason, evidence_url, status, handler_user_id, handle_result, handled_at, created_at
) VALUES
  (19101, 10101, 1, 14004, '岗位描述存在不实承诺', NULL, 1, NULL, NULL, NULL, DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (19102, 10103, 2, 11004, '企业认证信息异常', NULL, 2, 7, '已受理，正在核验资料', NULL, DATE_SUB(NOW(), INTERVAL 3 DAY)),
  (19103, 10102, 3, 10204, '沟通过程中出现不当言论', NULL, 3, 10001, '核实后给予警告并限制发布', DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY)),
  (19104, 10106, 4, 16111, '消息内容带有歧视性表达', NULL, 1, NULL, NULL, NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (19105, 10107, 1, 14011, '岗位疑似违规收费', NULL, 2, 10002, '企业已下线岗位等待复审', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (19106, 10104, 2, 1, '希望核查企业资质时效性', NULL, 3, 7, '已核查，资质正常', DATE_SUB(NOW(), INTERVAL 12 HOUR), DATE_SUB(NOW(), INTERVAL 2 DAY));

INSERT IGNORE INTO cjs_penalty_record (
  id, target_type, target_id, penalty_type, reason, status, operator_user_id, created_at
) VALUES
  (19201, 2, 11004, 3, '企业资质异常，岗位下线处理', 1, 7, DATE_SUB(NOW(), INTERVAL 3 DAY)),
  (19202, 1, 10105, 2, '账号异常操作，临时冻结', 1, 10001, DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (19203, 3, 14011, 3, '岗位违规，立即下线', 1, 10002, DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (19204, 1, 10108, 1, '多次撤回投递，警告记录', 2, 7, DATE_SUB(NOW(), INTERVAL 1 DAY));

INSERT IGNORE INTO cjs_user_notification (
  id, user_id, biz_type, biz_id, title, content, is_read, read_at, created_at
) VALUES
  (19301, 10101, 'application', 15001, '投递进度更新', '你投递的【产品运营实习生】已进入沟通阶段。', 0, NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (19302, 10102, 'interview', 17001, '面试通知', '你有一场新的线上面试待确认。', 0, NULL, DATE_SUB(NOW(), INTERVAL 20 HOUR)),
  (19303, 10103, 'offer', 18001, 'Offer已发放', '企业已向你发送Offer，请及时处理。', 0, NULL, DATE_SUB(NOW(), INTERVAL 5 HOUR)),
  (19304, 10104, 'offer', 18002, 'Offer状态更新', '你已接受Offer，祝实习顺利。', 1, DATE_SUB(NOW(), INTERVAL 12 HOUR), DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (19305, 10105, 'application', 15005, '投递结果通知', '很遗憾，本次投递未通过。', 1, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY)),
  (19306, 10106, 'application', 15006, '投递进度更新', '企业已查看你的简历。', 0, NULL, DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (19307, 10107, 'application', 15007, '投递成功', '你已成功投递岗位，请耐心等待。', 1, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY)),
  (19308, 10108, 'application', 15008, '投递已撤回', '你已撤回投递记录。', 1, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),
  (19309, 10201, 'review', 19002, '收到新的学生评价', '有一条新的企业评价，请及时查看。', 0, NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (19310, 10203, 'report', 19104, '举报提醒', '你所在企业相关沟通被举报，请关注。', 0, NULL, DATE_SUB(NOW(), INTERVAL 10 HOUR)),
  (19311, 10204, 'audit', 12004, '企业审核结果', '企业资质审核未通过，请修改后重提。', 1, DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY)),
  (19312, 10205, 'offer', 18003, 'Offer反馈通知', '候选人已拒绝Offer。', 0, NULL, DATE_SUB(NOW(), INTERVAL 1 HOUR)),
  (19313, 1, 'admin_notice', 90001, '平台公告', '系统将于周末进行例行维护。', 0, NULL, DATE_SUB(NOW(), INTERVAL 6 HOUR)),
  (19314, 2, 'admin_notice', 90001, '平台公告', '系统将于周末进行例行维护。', 1, DATE_SUB(NOW(), INTERVAL 2 HOUR), DATE_SUB(NOW(), INTERVAL 6 HOUR)),
  (19315, 6, 'admin_notice', 90002, '审核规范更新', '岗位发布审核标准已更新，请关注。', 0, NULL, DATE_SUB(NOW(), INTERVAL 8 HOUR));

INSERT IGNORE INTO cjs_admin_operation_log (
  id, operator_user_id, module, action, target_type, target_id, detail_json, operated_at
) VALUES
  (19401, 7, 'enterpriseAudit', 'approve', 'enterpriseCertification', 12001, JSON_OBJECT('result','成功','ip','127.0.0.1','target','星云科技资质'), DATE_SUB(NOW(), INTERVAL 13 DAY)),
  (19402, 7, 'enterpriseAudit', 'reject', 'enterpriseCertification', 12004, JSON_OBJECT('result','成功','ip','127.0.0.1','target','云帆电商资质'), DATE_SUB(NOW(), INTERVAL 7 DAY)),
  (19403, 10001, 'jobAudit', 'approve', 'job', 14001, JSON_OBJECT('result','成功','ip','127.0.0.1','target','产品运营实习生'), DATE_SUB(NOW(), INTERVAL 9 DAY)),
  (19404, 10002, 'jobAudit', 'reject', 'job', 14011, JSON_OBJECT('result','成功','ip','127.0.0.1','target','电商运营实习生'), DATE_SUB(NOW(), INTERVAL 3 DAY)),
  (19405, 10001, 'users', 'freeze', 'user', 10105, JSON_OBJECT('result','成功','ip','127.0.0.1','target','赵磊'), DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (19406, 7, 'reports', 'accept', 'report', 19102, JSON_OBJECT('result','成功','ip','127.0.0.1','target','举报RP19102'), DATE_SUB(NOW(), INTERVAL 3 DAY)),
  (19407, 10002, 'reports', 'close', 'report', 19103, JSON_OBJECT('result','成功','ip','127.0.0.1','target','举报RP19103'), DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (19408, 10001, 'penalties', 'create', 'penalty', 19201, JSON_OBJECT('result','成功','ip','127.0.0.1','target','云帆电商处罚'), DATE_SUB(NOW(), INTERVAL 3 DAY)),
  (19409, 7, 'notifications', 'publish', 'notification', 90001, JSON_OBJECT('result','成功','ip','127.0.0.1','target','平台公告'), DATE_SUB(NOW(), INTERVAL 6 HOUR)),
  (19410, 10001, 'auth', 'login', 'admin', 10001, JSON_OBJECT('result','成功','ip','127.0.0.1','target','运营管理员'), DATE_SUB(NOW(), INTERVAL 2 HOUR));

-- =========================================================
-- 6) RBAC（可选，便于后续管理员权限扩展）
-- =========================================================
INSERT IGNORE INTO cjs_role (id, role_code, role_name, status, created_at) VALUES
  (19501, 'super_admin', '超级管理员', 1, DATE_SUB(NOW(), INTERVAL 30 DAY)),
  (19502, 'auditor', '审核管理员', 1, DATE_SUB(NOW(), INTERVAL 30 DAY)),
  (19503, 'operator', '运营管理员', 1, DATE_SUB(NOW(), INTERVAL 30 DAY));

INSERT IGNORE INTO cjs_permission (id, perm_code, perm_name, perm_type, created_at) VALUES
  (19601, 'dashboard:view', '看板查看', 3, DATE_SUB(NOW(), INTERVAL 30 DAY)),
  (19602, 'enterpriseAudit:view', '企业审核', 3, DATE_SUB(NOW(), INTERVAL 30 DAY)),
  (19603, 'jobAudit:view', '岗位审核', 3, DATE_SUB(NOW(), INTERVAL 30 DAY)),
  (19604, 'users:view', '用户管理', 3, DATE_SUB(NOW(), INTERVAL 30 DAY)),
  (19605, 'applications:view', '流程监控', 3, DATE_SUB(NOW(), INTERVAL 30 DAY)),
  (19606, 'reports:view', '举报处理', 3, DATE_SUB(NOW(), INTERVAL 30 DAY)),
  (19607, 'reviews:view', '评价管理', 3, DATE_SUB(NOW(), INTERVAL 30 DAY)),
  (19608, 'penalties:view', '处罚记录', 3, DATE_SUB(NOW(), INTERVAL 30 DAY)),
  (19609, 'notifications:view', '通知中心', 3, DATE_SUB(NOW(), INTERVAL 30 DAY)),
  (19610, 'rules:view', '审核策略', 3, DATE_SUB(NOW(), INTERVAL 30 DAY)),
  (19611, 'logs:view', '系统日志', 3, DATE_SUB(NOW(), INTERVAL 30 DAY)),
  (19612, 'permissions:view', '权限中心', 3, DATE_SUB(NOW(), INTERVAL 30 DAY));

INSERT IGNORE INTO cjs_user_role (id, user_id, role_id, created_at) VALUES
  (19701, 7, 19501, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19702, 10001, 19503, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19703, 10002, 19502, DATE_SUB(NOW(), INTERVAL 20 DAY));

INSERT IGNORE INTO cjs_role_permission (id, role_id, permission_id, created_at) VALUES
  (19801, 19501, 19601, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19802, 19501, 19602, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19803, 19501, 19603, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19804, 19501, 19604, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19805, 19501, 19605, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19806, 19501, 19606, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19807, 19501, 19607, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19808, 19501, 19608, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19809, 19501, 19609, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19810, 19501, 19610, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19811, 19501, 19611, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19812, 19501, 19612, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19813, 19502, 19601, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19814, 19502, 19602, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19815, 19502, 19603, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19816, 19502, 19606, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19817, 19502, 19607, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19818, 19502, 19611, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19819, 19503, 19601, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19820, 19503, 19604, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19821, 19503, 19605, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19822, 19503, 19608, DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (19823, 19503, 19609, DATE_SUB(NOW(), INTERVAL 20 DAY));

SET FOREIGN_KEY_CHECKS = 1;

-- 导入后快速检查
SELECT 'cjs_user' AS table_name, COUNT(*) AS total FROM cjs_user
UNION ALL SELECT 'cjs_enterprise', COUNT(*) FROM cjs_enterprise
UNION ALL SELECT 'cjs_enterprise_certification', COUNT(*) FROM cjs_enterprise_certification
UNION ALL SELECT 'cjs_resume', COUNT(*) FROM cjs_resume
UNION ALL SELECT 'cjs_job_posting', COUNT(*) FROM cjs_job_posting
UNION ALL SELECT 'cjs_job_application', COUNT(*) FROM cjs_job_application
UNION ALL SELECT 'cjs_conversation', COUNT(*) FROM cjs_conversation
UNION ALL SELECT 'cjs_message', COUNT(*) FROM cjs_message
UNION ALL SELECT 'cjs_interview_schedule', COUNT(*) FROM cjs_interview_schedule
UNION ALL SELECT 'cjs_offer', COUNT(*) FROM cjs_offer
UNION ALL SELECT 'cjs_report', COUNT(*) FROM cjs_report
UNION ALL SELECT 'cjs_penalty_record', COUNT(*) FROM cjs_penalty_record
UNION ALL SELECT 'cjs_user_notification', COUNT(*) FROM cjs_user_notification
UNION ALL SELECT 'cjs_admin_operation_log', COUNT(*) FROM cjs_admin_operation_log;
