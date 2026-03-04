import 'package:flutter/material.dart';

import '../../viewmodels/student_home_view_model.dart';

class StudentOfferCenterPage extends StatelessWidget {
  const StudentOfferCenterPage({
    super.key,
    required this.vm,
    required this.onMessage,
  });

  final StudentHomeViewModel vm;
  final void Function(String text) onMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offer中心')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF4FF), Colors.white],
          ),
        ),
        child: AnimatedBuilder(
          animation: vm,
          builder: (_, __) {
            final sent =
                vm.offers.where((item) => _toInt(item['status']) == 1).length;
            final accepted =
                vm.offers.where((item) => _toInt(item['status']) == 2).length;
            final rejected =
                vm.offers.where((item) => _toInt(item['status']) == 3).length;
            return RefreshIndicator(
              onRefresh: () async => _safeAction(() async {
                await vm.loadOffers();
                await vm.loadApplications();
              }),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _summary(sent, accepted, rejected),
                  const SizedBox(height: 12),
                  if (vm.offers.isEmpty)
                    const _EmptyBlock(text: '暂无Offer记录')
                  else
                    ...vm.offers.map((offer) => _offerCard(context, offer)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _summary(int sent, int accepted, int rejected) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _metric('待处理', '$sent', const Color(0xFF8A3FFC)),
            _metric('已接受', '$accepted', const Color(0xFF157347)),
            _metric('已拒绝', '$rejected', const Color(0xFFAA2B2B)),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value, Color color) {
    return Container(
      width: 104,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _offerCard(BuildContext context, Map<String, dynamic> offer) {
    final offerId = _toInt(offer['id']);
    final status = _toInt(offer['status']);
    final canOperate = status == 1 && offerId != null;
    final terms = _text(offer['termsText']);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Offer ${_text(offer['offerNo'])}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                _statusTag(_statusLabel(status), _statusColor(status)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
                '薪资范围: ${_salaryRange(offer['salaryMin'], offer['salaryMax'])}'),
            Text('有效期: ${_formatDateTime(offer['expiresAt'])}'),
            Text('实习开始: ${_text(offer['internshipStartDate'])}'),
            Text('实习结束: ${_text(offer['internshipEndDate'])}'),
            if (terms != '-') Text('条款: $terms'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: canOperate ? () => _acceptOffer(offerId!) : null,
                  child: const Text('接受'),
                ),
                FilledButton.tonal(
                  onPressed:
                      canOperate ? () => _rejectOffer(context, offerId!) : null,
                  child: const Text('拒绝'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _acceptOffer(int offerId) async {
    await _safeAction(() async {
      await vm.offerDecision(offerId: offerId, action: 'accept');
      onMessage('已接受Offer');
    });
  }

  Future<void> _rejectOffer(BuildContext context, int offerId) async {
    String? reason;
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('拒绝Offer'),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 3,
          decoration: const InputDecoration(labelText: '拒绝原因（可选）'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              reason = controller.text.trim().isEmpty
                  ? null
                  : controller.text.trim();
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('确认拒绝'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != true) {
      return;
    }
    await _safeAction(() async {
      await vm.offerDecision(
        offerId: offerId,
        action: 'reject',
        rejectReason: reason,
      );
      onMessage('已拒绝Offer');
    });
  }

  Future<void> _safeAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      onMessage(e.toString());
    }
  }

  String _statusLabel(int? status) {
    switch (status) {
      case 1:
        return '待处理';
      case 2:
        return '已接受';
      case 3:
        return '已拒绝';
      case 4:
        return '已过期';
      default:
        return '未知';
    }
  }

  Color _statusColor(int? status) {
    switch (status) {
      case 1:
        return const Color(0xFF8A3FFC);
      case 2:
        return const Color(0xFF157347);
      case 3:
      case 4:
        return const Color(0xFFAA2B2B);
      default:
        return const Color(0xFF5B6575);
    }
  }

  String _salaryRange(dynamic min, dynamic max) {
    final minText = _text(min);
    final maxText = _text(max);
    if (minText == '-' && maxText == '-') {
      return '面议';
    }
    return '$minText - $maxText';
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

  String _text(dynamic value) {
    final text = value?.toString();
    if (text == null || text.trim().isEmpty || text == 'null') {
      return '-';
    }
    return text;
  }

  String _formatDateTime(dynamic value) {
    final raw = _text(value);
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

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 36, color: Color(0xFF95A3B8)),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Color(0xFF6B778C))),
        ],
      ),
    );
  }
}
