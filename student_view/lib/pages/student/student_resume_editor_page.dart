import 'dart:convert';

import 'package:flutter/material.dart';

class ResumeEditorResult {
  const ResumeEditorResult({
    required this.title,
    required this.contentJson,
    required this.completionScore,
  });

  final String title;
  final String contentJson;
  final double completionScore;
}

class StudentResumeEditorPage extends StatefulWidget {
  const StudentResumeEditorPage({
    super.key,
    this.initialTitle,
    this.initialContentJson,
  });

  final String? initialTitle;
  final String? initialContentJson;

  @override
  State<StudentResumeEditorPage> createState() =>
      _StudentResumeEditorPageState();
}

class _StudentResumeEditorPageState extends State<StudentResumeEditorPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtl = TextEditingController();
  final _nameCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _schoolCtl = TextEditingController();
  final _majorCtl = TextEditingController();
  final _graduationYearCtl = TextEditingController();
  final _targetPositionCtl = TextEditingController();
  final _targetCityCtl = TextEditingController();
  final _internMonthsCtl = TextEditingController();
  final _selfIntroCtl = TextEditingController();
  final _internCompanyCtl = TextEditingController();
  final _internRoleCtl = TextEditingController();
  final _internDescCtl = TextEditingController();
  final _projectNameCtl = TextEditingController();
  final _projectRoleCtl = TextEditingController();
  final _projectDescCtl = TextEditingController();
  final _skillsCtl = TextEditingController();
  final _certificatesCtl = TextEditingController();

  String _gender = '男';
  String _degree = '本科';

  @override
  void initState() {
    super.initState();
    _bindControllerListeners();
    _fillInitialData();
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _nameCtl.dispose();
    _phoneCtl.dispose();
    _emailCtl.dispose();
    _schoolCtl.dispose();
    _majorCtl.dispose();
    _graduationYearCtl.dispose();
    _targetPositionCtl.dispose();
    _targetCityCtl.dispose();
    _internMonthsCtl.dispose();
    _selfIntroCtl.dispose();
    _internCompanyCtl.dispose();
    _internRoleCtl.dispose();
    _internDescCtl.dispose();
    _projectNameCtl.dispose();
    _projectRoleCtl.dispose();
    _projectDescCtl.dispose();
    _skillsCtl.dispose();
    _certificatesCtl.dispose();
    super.dispose();
  }

  void _bindControllerListeners() {
    final controllers = <TextEditingController>[
      _titleCtl,
      _nameCtl,
      _phoneCtl,
      _emailCtl,
      _schoolCtl,
      _majorCtl,
      _graduationYearCtl,
      _targetPositionCtl,
      _targetCityCtl,
      _internMonthsCtl,
      _selfIntroCtl,
      _internCompanyCtl,
      _internRoleCtl,
      _internDescCtl,
      _projectNameCtl,
      _projectRoleCtl,
      _projectDescCtl,
      _skillsCtl,
      _certificatesCtl,
    ];
    for (final c in controllers) {
      c.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void _fillInitialData() {
    _titleCtl.text = (widget.initialTitle ?? '').trim();
    final jsonText = widget.initialContentJson;
    if (jsonText == null || jsonText.trim().isEmpty) {
      return;
    }
    try {
      final root = jsonDecode(jsonText);
      if (root is! Map<String, dynamic>) {
        return;
      }
      final basic = _asMap(root['basic']);
      _nameCtl.text = _asText(basic['fullName']);
      _phoneCtl.text = _asText(basic['phone']);
      _emailCtl.text = _asText(basic['email']);
      final gender = _asText(basic['gender']);
      if (gender.isNotEmpty) {
        _gender = gender;
      }

      final educationList = _asList(root['education']);
      if (educationList.isNotEmpty) {
        final edu = _asMap(educationList.first);
        _schoolCtl.text = _asText(edu['school']);
        _majorCtl.text = _asText(edu['major']);
        _graduationYearCtl.text = _asText(edu['graduationYear']);
        final degree = _asText(edu['degree']);
        if (degree.isNotEmpty) {
          _degree = degree;
        }
      }

      final intention = _asMap(root['jobIntention']);
      _targetPositionCtl.text = _asText(intention['targetPosition']);
      _targetCityCtl.text = _asText(intention['targetCity']);
      _internMonthsCtl.text = _asText(intention['internshipMonths']);

      final internship = _asMap(root['internship']);
      _internCompanyCtl.text = _asText(internship['company']);
      _internRoleCtl.text = _asText(internship['role']);
      _internDescCtl.text = _asText(internship['description']);

      final project = _asMap(root['project']);
      _projectNameCtl.text = _asText(project['name']);
      _projectRoleCtl.text = _asText(project['role']);
      _projectDescCtl.text = _asText(project['description']);

      _skillsCtl.text = _joinList(root['skills']);
      _certificatesCtl.text = _joinList(root['certificates']);
      _selfIntroCtl.text = _asText(root['selfEvaluation']);
    } catch (_) {
      // Ignore invalid json from legacy/uploaded resumes.
    }
  }

  @override
  Widget build(BuildContext context) {
    final completion = _calculateCompletion();
    return Scaffold(
      appBar: AppBar(
        title: const Text('简历编辑'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _section(
              title: '完整度',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '当前完整度 ${completion.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: completion / 100,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            _section(
              title: '基本信息',
              child: Column(
                children: [
                  _textField(_titleCtl, '简历标题*', '如：Java后端实习简历',
                      required: true),
                  _textField(_nameCtl, '姓名*', '请输入姓名', required: true),
                  Row(
                    children: [
                      Expanded(
                          child: _textField(_phoneCtl, '手机号*', '请输入手机号',
                              required: true)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _textField(_emailCtl, '邮箱*', '请输入邮箱',
                              required: true)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _gender,
                          decoration: const InputDecoration(labelText: '性别'),
                          items: const [
                            DropdownMenuItem(value: '男', child: Text('男')),
                            DropdownMenuItem(value: '女', child: Text('女')),
                            DropdownMenuItem(value: '其他', child: Text('其他')),
                          ],
                          onChanged: (v) => setState(() => _gender = v ?? '男'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _degree,
                          decoration: const InputDecoration(labelText: '学历*'),
                          items: const [
                            DropdownMenuItem(value: '大专', child: Text('大专')),
                            DropdownMenuItem(value: '本科', child: Text('本科')),
                            DropdownMenuItem(value: '硕士', child: Text('硕士')),
                            DropdownMenuItem(value: '博士', child: Text('博士')),
                          ],
                          onChanged: (v) => setState(() => _degree = v ?? '本科'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _section(
              title: '教育背景',
              child: Column(
                children: [
                  _textField(_schoolCtl, '学校*', '请输入学校名称', required: true),
                  _textField(_majorCtl, '专业*', '请输入专业名称', required: true),
                  _textField(_graduationYearCtl, '毕业年份*', '如：2027',
                      required: true),
                ],
              ),
            ),
            _section(
              title: '求职意向',
              child: Column(
                children: [
                  _textField(_targetPositionCtl, '目标岗位*', '如：后端开发实习生',
                      required: true),
                  _textField(_targetCityCtl, '意向城市*', '如：上海/北京',
                      required: true),
                  _textField(_internMonthsCtl, '可实习时长（月）', '如：3-6'),
                ],
              ),
            ),
            _section(
              title: '实习经历',
              child: Column(
                children: [
                  _textField(_internCompanyCtl, '公司名称', '请输入公司名称'),
                  _textField(_internRoleCtl, '岗位名称', '请输入岗位名称'),
                  _textField(_internDescCtl, '工作描述', '简要描述工作内容与成果',
                      maxLines: 3),
                ],
              ),
            ),
            _section(
              title: '项目经历',
              child: Column(
                children: [
                  _textField(_projectNameCtl, '项目名称', '请输入项目名称'),
                  _textField(_projectRoleCtl, '项目角色', '如：后端开发'),
                  _textField(_projectDescCtl, '项目描述', '描述你的职责与成果', maxLines: 3),
                ],
              ),
            ),
            _section(
              title: '技能与证书',
              child: Column(
                children: [
                  _textField(_skillsCtl, '技能标签*', '如：Java,SpringBoot,MySQL',
                      required: true),
                  _textField(_certificatesCtl, '证书（逗号分隔）', '如：英语六级,计算机二级'),
                ],
              ),
            ),
            _section(
              title: '个人评价',
              child: _textField(_selfIntroCtl, '自我评价*', '突出你的优势、经历和目标',
                  required: true, maxLines: 4),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _submit,
              child: const Text('保存简历'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EBF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    String hint, {
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        validator: (value) {
          final text = (value ?? '').trim();
          if (required && text.isEmpty) {
            return '请填写$label';
          }
          if (label.contains('邮箱') && text.isNotEmpty) {
            final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
            if (!ok) {
              return '邮箱格式不正确';
            }
          }
          return null;
        },
      ),
    );
  }

  double _calculateCompletion() {
    final checks = <bool>[
      _titleCtl.text.trim().isNotEmpty,
      _nameCtl.text.trim().isNotEmpty,
      _phoneCtl.text.trim().isNotEmpty,
      _emailCtl.text.trim().isNotEmpty,
      _schoolCtl.text.trim().isNotEmpty,
      _majorCtl.text.trim().isNotEmpty,
      _graduationYearCtl.text.trim().isNotEmpty,
      _targetPositionCtl.text.trim().isNotEmpty,
      _targetCityCtl.text.trim().isNotEmpty,
      _skillsCtl.text.trim().isNotEmpty,
      _selfIntroCtl.text.trim().isNotEmpty,
      _internCompanyCtl.text.trim().isNotEmpty ||
          _projectNameCtl.text.trim().isNotEmpty,
    ];
    final filled = checks.where((e) => e).length;
    return (filled / checks.length) * 100;
  }

  List<String> _splitByComma(String value) {
    return value
        .split(RegExp(r'[，,]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v));
    }
    return <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic raw) {
    if (raw is List) {
      return raw;
    }
    return <dynamic>[];
  }

  String _asText(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  String _joinList(dynamic raw) {
    final list = _asList(raw);
    if (list.isEmpty) {
      return '';
    }
    return list
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .join(',');
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final completion = _calculateCompletion();
    final content = {
      'basic': {
        'fullName': _nameCtl.text.trim(),
        'gender': _gender,
        'phone': _phoneCtl.text.trim(),
        'email': _emailCtl.text.trim(),
      },
      'education': [
        {
          'school': _schoolCtl.text.trim(),
          'major': _majorCtl.text.trim(),
          'degree': _degree,
          'graduationYear': _graduationYearCtl.text.trim(),
        }
      ],
      'jobIntention': {
        'targetPosition': _targetPositionCtl.text.trim(),
        'targetCity': _targetCityCtl.text.trim(),
        'internshipMonths': _internMonthsCtl.text.trim(),
      },
      'internship': {
        'company': _internCompanyCtl.text.trim(),
        'role': _internRoleCtl.text.trim(),
        'description': _internDescCtl.text.trim(),
      },
      'project': {
        'name': _projectNameCtl.text.trim(),
        'role': _projectRoleCtl.text.trim(),
        'description': _projectDescCtl.text.trim(),
      },
      'skills': _splitByComma(_skillsCtl.text.trim()),
      'certificates': _splitByComma(_certificatesCtl.text.trim()),
      'selfEvaluation': _selfIntroCtl.text.trim(),
    };

    Navigator.pop(
      context,
      ResumeEditorResult(
        title: _titleCtl.text.trim(),
        contentJson: jsonEncode(content),
        completionScore: completion,
      ),
    );
  }
}
