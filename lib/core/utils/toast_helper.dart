import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';

enum ToastType { success, error, info, warning }

class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
  }) {
    final color = switch (type) {
      ToastType.success => AppColors.success,
      ToastType.error => AppColors.error,
      ToastType.warning => AppColors.warning,
      ToastType.info => AppColors.primary,
    };

    final icon = switch (type) {
      ToastType.success => Icons.check_circle_outline,
      ToastType.error => Icons.error_outline,
      ToastType.warning => Icons.warning_amber_rounded,
      ToastType.info => Icons.info_outline,
    };

    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 80,
        right: 20,
        child: _ToastWidget(message: message, color: color, icon: icon),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () => entry.remove());
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color color;
  final IconData icon;

  const _ToastWidget({
    required this.message,
    required this.color,
    required this.icon,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                widget.message,
                style: AppText.body.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
