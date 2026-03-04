import 'package:flutter/material.dart';

import '../../viewmodels/student_home_view_model.dart';

class StudentReportCreatePage extends StatefulWidget {
  const StudentReportCreatePage({
    super.key,
    required this.vm,
    required this.onMessage,
  });

  final StudentHomeViewModel vm;
  final void Function(String text) onMessage;

  @override
  State<StudentReportCreatePage> createState() =>
      _StudentReportCreatePageState();
}

class _StudentReportCreatePageState extends State<StudentReportCreatePage> {
  final TextEditingController _reasonCtl = TextEditingController();
  final TextEditingController _evidenceCtl = TextEditingController();

  int _targetType = 2; // 2: enterprise, 4: message
  int _selectedEnterpriseIndex = 0;
  int _selectedConversationIndex = 0;
  int _selectedMessageIndex = 0;

  bool _loadingMessages = false;
  bool _submitting = false;
  List<Map<String, dynamic>> _messages = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  @override
  void dispose() {
    _reasonCtl.dispose();
    _evidenceCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enterprises = _enterpriseEntries();
    final conversations = widget.vm.conversations;
    final canEnterprise = enterprises.isNotEmpty;
    final canMessage = conversations.isNotEmpty && _messages.isNotEmpty;

    if (_selectedEnterpriseIndex >= enterprises.length) {
      _selectedEnterpriseIndex = 0;
    }
    if (_selectedConversationIndex >= conversations.length) {
      _selectedConversationIndex = 0;
    }
    if (_selectedMessageIndex >= _messages.length) {
      _selectedMessageIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('提交举报')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F5FF), Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _tipCard(),
            const SizedBox(height: 12),
            _targetTypeCard(),
            const SizedBox(height: 12),
            if (_targetType == 2)
              _enterpriseCard(enterprises)
            else
              _messageCard(conversations),
            const SizedBox(height: 12),
            _reasonCard(),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _submitting
                  ? null
                  : () => _submit(
                        canEnterprise: canEnterprise,
                        canMessage: canMessage,
                        enterprises: enterprises,
                      ),
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('提交举报'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tipCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.shield_outlined, color: Color(0xFF2667FF)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '你可以直接举报企业或聊天消息，系统会自动关联目标ID，无需手工填写。',
                style: TextStyle(color: Color(0xFF475569), height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _targetTypeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('举报类型', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(
                  value: 2,
                  icon: Icon(Icons.business_outlined),
                  label: Text('举报企业'),
                ),
                ButtonSegment<int>(
                  value: 4,
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  label: Text('举报消息'),
                ),
              ],
              selected: <int>{_targetType},
              onSelectionChanged: (selected) async {
                final value = selected.first;
                setState(() => _targetType = value);
                if (value == 4) {
                  await _loadConversationMessages();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _enterpriseCard(List<_EnterpriseEntry> entries) {
    if (entries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 14),
          child: Column(
            children: const [
              Icon(Icons.business_outlined, size: 32, color: Color(0xFF94A3B8)),
              SizedBox(height: 8),
              Text('暂无可举报企业', style: TextStyle(fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text(
                '请先产生投递或沟通记录',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }
    final selected = entries[_selectedEnterpriseIndex];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('举报企业', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedEnterpriseIndex,
              decoration: const InputDecoration(labelText: '选择企业'),
              items: [
                for (var i = 0; i < entries.length; i++)
                  DropdownMenuItem<int>(
                    value: i,
                    child: Text(
                      entries[i].enterpriseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _selectedEnterpriseIndex = value ?? 0),
            ),
            const SizedBox(height: 8),
            _kv('企业名称', selected.enterpriseName),
            _kv('关联岗位', selected.jobTitle),
          ],
        ),
      ),
    );
  }

  Widget _messageCard(List<Map<String, dynamic>> conversations) {
    if (conversations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 14),
          child: Column(
            children: const [
              Icon(Icons.chat_bubble_outline_rounded,
                  size: 32, color: Color(0xFF94A3B8)),
              SizedBox(height: 8),
              Text('暂无会话可举报', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('举报聊天消息', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedConversationIndex,
              isExpanded: true,
              decoration: const InputDecoration(labelText: '选择会话'),
              selectedItemBuilder: (_) => [
                for (var i = 0; i < conversations.length; i++)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _toText(conversations[i]['counterpartName']),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              items: [
                for (var i = 0; i < conversations.length; i++)
                  DropdownMenuItem<int>(
                    value: i,
                    child: Text(
                      _toText(conversations[i]['counterpartName']),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) async {
                setState(() {
                  _selectedConversationIndex = value ?? 0;
                  _selectedMessageIndex = 0;
                });
                await _loadConversationMessages();
              },
            ),
            const SizedBox(height: 8),
            if (_loadingMessages)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (_messages.isEmpty)
              const Text(
                '该会话暂无消息可举报',
                style: TextStyle(color: Color(0xFF64748B)),
              )
            else ...[
              DropdownButtonFormField<int>(
                value: _selectedMessageIndex,
                isExpanded: true,
                decoration: const InputDecoration(labelText: '选择消息'),
                selectedItemBuilder: (_) => [
                  for (var i = 0; i < _messages.length; i++)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _messagePreview(_messages[i]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                items: [
                  for (var i = 0; i < _messages.length; i++)
                    DropdownMenuItem<int>(
                      value: i,
                      child: Text(
                        _messagePreview(_messages[i]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) =>
                    setState(() => _selectedMessageIndex = value ?? 0),
              ),
              const SizedBox(height: 8),
              Text(
                '消息内容：${_toText(_messages[_selectedMessageIndex]['contentText'])}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF334155)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _reasonCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _reasonCtl,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: '举报原因',
                hintText: '请详细描述问题，如虚假岗位、辱骂消息、诱导收费等',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _evidenceCtl,
              decoration: const InputDecoration(
                labelText: '证据链接（可选）',
                hintText: '例如：截图网盘链接',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Text(
              key,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _prepareData() async {
    try {
      await Future.wait([
        widget.vm.loadApplications(),
        widget.vm.loadConversations(),
        widget.vm.loadReports(),
      ]);
      if (_targetType == 4) {
        await _loadConversationMessages();
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      widget.onMessage(e.toString());
    }
  }

  Future<void> _loadConversationMessages() async {
    final conversations = widget.vm.conversations;
    if (conversations.isEmpty) {
      setState(() => _messages = <Map<String, dynamic>>[]);
      return;
    }
    final selected = conversations[_selectedConversationIndex];
    final conversationId = _toInt(selected['id']);
    if (conversationId == null) {
      setState(() => _messages = <Map<String, dynamic>>[]);
      return;
    }
    setState(() => _loadingMessages = true);
    try {
      final list = await widget.vm.listMessages(conversationId);
      if (!mounted) {
        return;
      }
      setState(() {
        _messages = list.reversed.take(30).toList().reversed.toList();
        _selectedMessageIndex = 0;
      });
    } catch (e) {
      widget.onMessage(e.toString());
      if (mounted) {
        setState(() => _messages = <Map<String, dynamic>>[]);
      }
    } finally {
      if (mounted) {
        setState(() => _loadingMessages = false);
      }
    }
  }

  List<_EnterpriseEntry> _enterpriseEntries() {
    final map = <int, _EnterpriseEntry>{};
    for (final item in widget.vm.applications) {
      final enterpriseId = _toInt(item['enterpriseId']);
      if (enterpriseId == null) {
        continue;
      }
      map[enterpriseId] = _EnterpriseEntry(
        enterpriseId: enterpriseId,
        enterpriseName: _toText(item['enterpriseName']),
        jobTitle: _toText(item['jobTitle']),
      );
    }
    return map.values.toList();
  }

  Future<void> _submit({
    required bool canEnterprise,
    required bool canMessage,
    required List<_EnterpriseEntry> enterprises,
  }) async {
    final reason = _reasonCtl.text.trim();
    if (reason.isEmpty) {
      widget.onMessage('请填写举报原因');
      return;
    }

    int? targetId;
    if (_targetType == 2) {
      if (!canEnterprise) {
        widget.onMessage('暂无可举报企业');
        return;
      }
      targetId = enterprises[_selectedEnterpriseIndex].enterpriseId;
    } else if (_targetType == 4) {
      if (!canMessage) {
        widget.onMessage('暂无可举报消息');
        return;
      }
      targetId = _toInt(_messages[_selectedMessageIndex]['id']);
    }

    if (targetId == null) {
      widget.onMessage('举报目标异常，请刷新后重试');
      return;
    }

    setState(() => _submitting = true);
    try {
      await widget.vm.createReport(
        targetType: _targetType,
        targetId: targetId,
        reason: reason,
        evidenceUrl:
            _evidenceCtl.text.trim().isEmpty ? null : _evidenceCtl.text.trim(),
      );
      widget.onMessage('举报提交成功');
      if (!mounted) {
        return;
      }
      Navigator.pop(context, true);
    } catch (e) {
      widget.onMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  String _messagePreview(Map<String, dynamic> message) {
    final content = _toText(message['contentText']);
    final sentAt = _toText(message['sentAt']);
    return '${_short(content, 26)} · ${_short(sentAt, 16)}';
  }

  String _short(String value, int maxLen) {
    if (value.length <= maxLen) {
      return value;
    }
    return '${value.substring(0, maxLen)}...';
  }

  String _toText(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') {
      return '-';
    }
    return text;
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }
}

class _EnterpriseEntry {
  const _EnterpriseEntry({
    required this.enterpriseId,
    required this.enterpriseName,
    required this.jobTitle,
  });

  final int enterpriseId;
  final String enterpriseName;
  final String jobTitle;
}
