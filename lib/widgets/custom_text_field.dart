import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Custom text field with modern styling and animations
class CustomTextField extends StatefulWidget {
  final Color? accentColor;
  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixPressed;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final int maxLines;
  final String? hintText;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixPressed,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.hintText,
    this.enabled = true,
  this.accentColor,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;
  Color get _accentColor => widget.accentColor ?? AppTheme.primaryEmerald;
  
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.fastAnimation,
      vsync: this,
    );

    _borderColorAnimation = ColorTween(
      begin: AppTheme.textSecondary.withOpacity(0.3),
      end: _accentColor,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.defaultCurve,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChanged(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });

    if (hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: AppTheme.buttonRadius,
            // No boxShadow or glow
          ),
          child: Focus(
            onFocusChange: _onFocusChanged,
            child: TextFormField(
              controller: widget.controller,
              validator: widget.validator,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              maxLines: widget.maxLines,
              enabled: widget.enabled,
              style: AppTheme.bodyStyle,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hintText,
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
            color: _isFocused
              ? _accentColor
              : AppTheme.textSecondary,
                      )
                    : null,
                suffixIcon: widget.suffixIcon != null
                    ? IconButton(
                        onPressed: widget.onSuffixPressed,
                        icon: Icon(
                          widget.suffixIcon,
              color: _isFocused
                ? _accentColor
                : AppTheme.textSecondary,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: AppTheme.buttonRadius,
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppTheme.buttonRadius,
                  borderSide: BorderSide(
                    color: AppTheme.textSecondary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppTheme.buttonRadius,
                  borderSide: BorderSide(
                    color: _borderColorAnimation.value ?? _accentColor,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: AppTheme.buttonRadius,
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: AppTheme.buttonRadius,
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
                labelStyle: AppTheme.bodyStyle.copyWith(
          color: _isFocused
            ? _accentColor
            : AppTheme.textSecondary,
                ),
                hintStyle: AppTheme.captionStyle,
                errorStyle: AppTheme.captionStyle.copyWith(
                  color: Colors.red,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
