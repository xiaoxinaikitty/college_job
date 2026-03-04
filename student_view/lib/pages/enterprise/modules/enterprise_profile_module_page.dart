import 'package:flutter/material.dart';

import '../../../viewmodels/enterprise_home_view_model.dart';

class EnterpriseProfileModulePage extends StatelessWidget {
  const EnterpriseProfileModulePage({
    super.key,
    required this.vm,
    required this.onMessage,
  });

  final EnterpriseHomeViewModel vm;
  final void Function(String text) onMessage;

  @override
  Widget build(BuildContext context) {
    final profile = vm.profile;
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          vm.loadProfile(),
          vm.loadJobs(),
          vm.loadApplications(),
          vm.loadInterviews(),
          vm.loadOffers(),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _profileCard(context, profile),
          _certificationCard(context, profile),
          _dashboardCard(),
          _adminFutureCard(),
        ],
      ),
    );
  }

  Widget _profileCard(BuildContext context, Map<String, dynamic> profile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('企业资料',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton(
                  onPressed: () => _openEditProfile(context, profile),
                  child: const Text('编辑'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _kv('企业名称', _toText(profile['enterpriseName'])),
            _kv('统一社会信用代码', _toText(profile['unifiedCreditCode'])),
            _kv('行业', _toText(profile['industry'])),
            _kv('城市', _toText(profile['city'])),
            _kv('地址', _toText(profile['address'])),
            _kv('官网', _toText(profile['website'])),
            _kv('简介', _toText(profile['intro'])),
          ],
        ),
      ),
    );
  }

  Widget _certificationCard(
      BuildContext context, Map<String, dynamic> profile) {
    final status = _toInt(profile['certifiedStatus']);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('企业认证',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                _statusTag(_toText(profile['certifiedStatusLabel']), status),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: () => _openCertificationSubmit(context),
                  child: const Text('提交认证'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _kv('企业状态', _toText(profile['enterpriseStatusLabel'])),
            _kv('最近认证ID', _toText(profile['latestCertificationId'])),
            _kv('最近提交时间',
                _formatDateTime(profile['latestCertificationSubmittedAt'])),
            _kv(
              '最近审核状态',
              _toText(profile['latestCertificationAuditStatus']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard() {
    final appStatus = <int, int>{};
    for (final app in vm.applications) {
      final status = _toInt(app['status']);
      if (status == null) {
        continue;
      }
      appStatus[status] = (appStatus[status] ?? 0) + 1;
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('运营概览', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _metric('岗位', vm.jobs.length.toString()),
                _metric('候选人', vm.applications.length.toString()),
                _metric('面试', vm.interviews.length.toString()),
                _metric('Offer', vm.offers.length.toString()),
                _metric('待查看', '${appStatus[1] ?? 0}'),
                _metric('待面试', '${appStatus[4] ?? 0}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminFutureCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('管理员联动预留', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('1. 岗位支持“提交审核”状态，待管理员审核后上线'),
            Text('2. 企业认证支持“待审核/通过/驳回”状态回写'),
            Text('3. 后续可在此页展示管理员反馈与处罚通知'),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF11653F),
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _statusTag(String label, int? status) {
    Color bg = const Color(0xFFE6ECF3);
    Color fg = const Color(0xFF4A5668);
    if (status == 2) {
      bg = const Color(0xFFFFF1D6);
      fg = const Color(0xFF9B6A00);
    } else if (status == 3) {
      bg = const Color(0xFFDDF5E8);
      fg = const Color(0xFF157347);
    } else if (status == 4) {
      bg = const Color(0xFFFCE2E2);
      fg = const Color(0xFFAB1E1E);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              key,
              style: const TextStyle(color: Color(0xFF657083), fontSize: 13),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _openEditProfile(
    BuildContext context,
    Map<String, dynamic> profile,
  ) async {
    final enterpriseNameCtl = TextEditingController(
      text: _rawText(profile['enterpriseName']),
    );
    final creditCtl = TextEditingController(
      text: _rawText(profile['unifiedCreditCode']),
    );
    final industryCtl =
        TextEditingController(text: _rawText(profile['industry']));
    final cityCtl = TextEditingController(text: _rawText(profile['city']));
    final addressCtl =
        TextEditingController(text: _rawText(profile['address']));
    final websiteCtl =
        TextEditingController(text: _rawText(profile['website']));
    final logoCtl = TextEditingController(text: _rawText(profile['logoUrl']));
    final introCtl = TextEditingController(text: _rawText(profile['intro']));
    final editControllers = <TextEditingController>[
      enterpriseNameCtl,
      creditCtl,
      industryCtl,
      cityCtl,
      addressCtl,
      websiteCtl,
      logoCtl,
      introCtl,
    ];

    if (!context.mounted) {
      _disposeControllersSafely(editControllers);
      return;
    }
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('编辑企业资料'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: enterpriseNameCtl,
                  decoration: const InputDecoration(labelText: '企业名称*'),
                ),
                TextField(
                  controller: creditCtl,
                  decoration: const InputDecoration(labelText: '统一社会信用代码'),
                ),
                TextField(
                  controller: industryCtl,
                  decoration: const InputDecoration(labelText: '行业'),
                ),
                TextField(
                  controller: cityCtl,
                  decoration: const InputDecoration(labelText: '城市'),
                ),
                TextField(
                  controller: addressCtl,
                  decoration: const InputDecoration(labelText: '地址'),
                ),
                TextField(
                  controller: websiteCtl,
                  decoration: const InputDecoration(labelText: '官网'),
                ),
                TextField(
                  controller: logoCtl,
                  decoration: const InputDecoration(labelText: 'Logo链接'),
                ),
                TextField(
                  controller: introCtl,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: '企业简介'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final name = enterpriseNameCtl.text.trim();
              if (name.isEmpty) {
                onMessage('企业名称不能为空');
                return;
              }
              try {
                await vm.updateProfile({
                  'enterpriseName': name,
                  'unifiedCreditCode': _nullable(creditCtl.text),
                  'industry': _nullable(industryCtl.text),
                  'city': _nullable(cityCtl.text),
                  'address': _nullable(addressCtl.text),
                  'website': _nullable(websiteCtl.text),
                  'logoUrl': _nullable(logoCtl.text),
                  'intro': _nullable(introCtl.text),
                });
                if (!dialogContext.mounted) {
                  return;
                }
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.of(dialogContext).pop(true);
              } catch (e) {
                onMessage(e.toString());
              }
            },
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF128C53)),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    _disposeControllersSafely(editControllers);

    if (saved == true) {
      onMessage('企业资料更新成功');
    }
  }

  Future<void> _openCertificationSubmit(BuildContext context) async {
    final urlCtl = TextEditingController();
    final remarkCtl = TextEditingController();
    final certControllers = <TextEditingController>[urlCtl, remarkCtl];
    if (!context.mounted) {
      _disposeControllersSafely(certControllers);
      return;
    }
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('提交企业认证'),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlCtl,
                decoration: const InputDecoration(
                  labelText: '营业执照文件URL*',
                  hintText: 'https://example.com/license.png',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: remarkCtl,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: '提交说明'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final url = urlCtl.text.trim();
              if (url.isEmpty) {
                onMessage('请填写营业执照文件URL');
                return;
              }
              try {
                await vm.submitCertification(
                  licenseFileUrl: url,
                  submitRemark: _nullable(remarkCtl.text),
                );
                if (!dialogContext.mounted) {
                  return;
                }
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.of(dialogContext).pop(true);
              } catch (e) {
                onMessage(e.toString());
              }
            },
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF128C53)),
            child: const Text('提交'),
          ),
        ],
      ),
    );
    _disposeControllersSafely(certControllers);
    if (saved == true) {
      onMessage('企业认证已提交，等待管理员审核');
    }
  }

  void _disposeControllersSafely(List<TextEditingController> controllers) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 320), () {
        for (final controller in controllers) {
          controller.dispose();
        }
      });
    });
  }

  String _toText(dynamic value) {
    final text = value?.toString();
    if (text == null || text.trim().isEmpty || text == 'null') {
      return '-';
    }
    return text;
  }

  String _rawText(dynamic value) => value?.toString() ?? '';

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  String? _nullable(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  String _formatDateTime(dynamic value) {
    final raw = _toText(value);
    if (raw == '-') {
      return raw;
    }
    final dt = DateTime.tryParse(raw);
    if (dt == null) {
      return raw;
    }
    final local = dt.toLocal();
    return '${local.year}-${_two(local.month)}-${_two(local.day)} '
        '${_two(local.hour)}:${_two(local.minute)}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
