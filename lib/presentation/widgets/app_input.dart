import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_desktop/core/theme/app_colors.dart';
import 'package:pos_desktop/core/theme/app_text_styles.dart';

enum InputType { text, email, phone, number }

class AppInput extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final IconData? icon;
  final InputType type;
  final int? maxLength;
  final Function(String)? onChanged;

  const AppInput({
    super.key,
    required this.controller,
    required this.hint,
    this.icon,
    this.type = InputType.text,
    this.obscureText = false,
    this.maxLength,
    this.onChanged,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  String? _errorText;

  List<TextInputFormatter> _getFormatters() {
    switch (widget.type) {
      case InputType.phone:
        return [
          FilteringTextInputFormatter.digitsOnly,
          if (widget.maxLength != null)
            LengthLimitingTextInputFormatter(widget.maxLength),
        ];
      case InputType.number:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          if (widget.maxLength != null)
            LengthLimitingTextInputFormatter(widget.maxLength),
        ];
      default:
        return [
          if (widget.maxLength != null)
            LengthLimitingTextInputFormatter(widget.maxLength),
        ];
    }
  }

  TextInputType _getKeyboard() {
    switch (widget.type) {
      case InputType.email:
        return TextInputType.emailAddress;
      case InputType.phone:
        return TextInputType.phone;
      case InputType.number:
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }

  String? _validate(String? value) {
    if (value == null || value.isEmpty) {
      return "This field can't be empty";
    }

    switch (widget.type) {
      case InputType.email:
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) return "Enter a valid email address";
        break;
      case InputType.phone:
        if (value.length < 10) return "Enter a valid phone number";
        break;
      case InputType.number:
        if (double.tryParse(value) == null) return "Enter a valid number";
        break;
      default:
        break;
    }
    return null;
  }

  void _onChanged(String value) {
    final error = _validate(value);
    setState(() => _errorText = error);
    if (widget.onChanged != null) widget.onChanged!(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: _getKeyboard(),
          inputFormatters: _getFormatters(),
          onChanged: _onChanged,
          style: AppText.body.copyWith(color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppText.small,
            prefixIcon: widget.icon != null
                ? Icon(widget.icon, color: AppColors.textLight, size: 20)
                : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: _errorText == null
                    ? AppColors.border
                    : AppColors.error.withOpacity(0.7),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: _errorText == null ? AppColors.primary : AppColors.error,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            _errorText!,
            style: AppText.small.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
