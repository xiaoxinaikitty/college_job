import 'package:flutter/material.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _AuthBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: const Color(0xFFD8E4FA)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1F0F172A),
                          blurRadius: 40,
                          offset: Offset(0, 14),
                        ),
                      ],
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF2563EB),
            Color(0xFF60A5FA),
            Color(0xFFEFF6FF),
          ],
          stops: [0.0, 0.26, 0.56, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _blurCircle(
              size: 300,
              color: const Color(0x66FFFFFF),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -90,
            child: _blurCircle(
              size: 280,
              color: const Color(0x4DFFFFFF),
            ),
          ),
          Positioned(
            top: 72,
            left: 22,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(0.42)),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                child: Text(
                  'Campus Job System',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blurCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF1FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Color(0xFF2667FF),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF5B6B85),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class SegmentSwitch extends StatelessWidget {
  const SegmentSwitch({
    super.key,
    required this.leftTitle,
    required this.rightTitle,
    required this.leftSelected,
    required this.onTapLeft,
    required this.onTapRight,
    this.backgroundColor = const Color(0xFFEFF3FF),
  });

  final String leftTitle;
  final String rightTitle;
  final bool leftSelected;
  final VoidCallback onTapLeft;
  final VoidCallback onTapRight;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFDCE6F7)),
      ),
      child: Row(
        children: [
          _segmentButton(
            title: leftTitle,
            selected: leftSelected,
            onTap: onTapLeft,
          ),
          _segmentButton(
            title: rightTitle,
            selected: !leftSelected,
            onTap: onTapRight,
          ),
        ],
      ),
    );
  }

  Widget _segmentButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x182667FF),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color:
                  selected ? const Color(0xFF2667FF) : const Color(0xFF6E7A8F),
            ),
          ),
        ),
      ),
    );
  }
}
