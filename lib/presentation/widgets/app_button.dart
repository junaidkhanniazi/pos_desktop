import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDisabled;
  final double? width;
  final double? height;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = true,
    this.isDisabled = false,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isPrimary ? AppColors.primary : Colors.white;
    final fgColor = isPrimary ? Colors.white : AppColors.primary;

    return MouseRegion(
      cursor: isDisabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width ?? 120,
        height: height ?? 44,
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.textLight.withOpacity(0.3) : bgColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            if (!isDisabled)
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
          ],
          border: Border.all(color: isPrimary ? bgColor : AppColors.primary),
        ),
        child: TextButton.icon(
          onPressed: isDisabled ? null : onPressed,

          icon: icon != null
              ? Icon(icon, size: 18, color: fgColor)
              : const SizedBox.shrink(),
          label: Text(label, style: AppText.button.copyWith(color: fgColor)),
        ),
      ),
    );
  }
}
