import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Circular press-and-hold control button.
///
/// Matches the reference screenshot's pink glowing circular button:
/// moves the car for as long as it's held, stops immediately on release
/// or if the pointer leaves the button — no separate stop button needed.
class CircularControlButton extends StatefulWidget {
  final IconData icon;
  final double size;
  final bool enabled;
  final VoidCallback onPressStart;
  final VoidCallback onPressEnd;
  final Color accent;

  const CircularControlButton({
    super.key,
    required this.icon,
    required this.onPressStart,
    required this.onPressEnd,
    this.size = 72,
    this.enabled = true,
    this.accent = AppColors.pink,
  });

  @override
  State<CircularControlButton> createState() => _CircularControlButtonState();
}

class _CircularControlButtonState extends State<CircularControlButton> {
  bool _pressed = false;

  void _start() {
    if (!widget.enabled || _pressed) return;
    setState(() => _pressed = true);
    widget.onPressStart();
  }

  void _end() {
    if (!_pressed) return;
    setState(() => _pressed = false);
    widget.onPressEnd();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.enabled ? widget.accent : AppColors.surfaceOutline;
    return GestureDetector(
      onTapDown: (_) => _start(),
      onTapUp: (_) => _end(),
      onTapCancel: _end,
      onLongPressStart: (_) => _start(),
      onLongPressEnd: (_) => _end(),
      onLongPressCancel: _end,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: _pressed
                ? [accent, accent.withValues(alpha: 0.75)]
                : [AppColors.surfaceRaised, AppColors.surface],
          ),
          border: Border.all(color: accent, width: _pressed ? 2.5 : 1.4),
          boxShadow: _pressed
              ? [BoxShadow(color: accent.withValues(alpha: 0.55), blurRadius: 22, spreadRadius: 2)]
              : [const BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Icon(
          widget.icon,
          color: _pressed ? AppColors.background : accent,
          size: widget.size * 0.42,
        ),
      ),
    );
  }
}
