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
  final String? Function(String?)? validator;

  const AppInput({
    super.key,
    required this.controller,
    required this.hint,
    this.icon,
    this.type = InputType.text,
    this.obscureText = false,
    this.maxLength,
    this.onChanged,
    this.validator,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput>
    with SingleTickerProviderStateMixin {
  String? _errorText;
  bool _obscure = false;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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

  void _onChanged(String value) {
    if (widget.onChanged != null) widget.onChanged!(value);
    setState(() => _errorText = widget.validator?.call(value));
  }

  void _toggleObscure() {
    setState(() {
      _obscure = !_obscure;
      if (_obscure) {
        _animController.reverse();
      } else {
        _animController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      keyboardType: _getKeyboard(),
      inputFormatters: _getFormatters(),
      onChanged: _onChanged,
      style: AppText.body.copyWith(color: AppColors.textDark),
      validator: (value) {
        final result = widget.validator?.call(value);
        setState(() => _errorText = result);
        return result;
      },
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppText.small,
        prefixIcon: widget.icon != null
            ? Icon(widget.icon, color: AppColors.textLight, size: 20)
            : null,
        suffixIcon: widget.obscureText
            ? AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  final rotation = Tween(
                    begin: 0.0,
                    end: 0.5,
                  ).evaluate(_animController);
                  final opacity = Tween(
                    begin: 1.0,
                    end: 0.6,
                  ).evaluate(_animController);

                  return Transform.rotate(
                    angle: rotation * 3.1416, // half rotation
                    child: Opacity(
                      opacity: opacity,
                      child: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textMedium,
                          size: 20,
                        ),
                        onPressed: _toggleObscure,
                      ),
                    ),
                  );
                },
              )
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
    );
  }
}
