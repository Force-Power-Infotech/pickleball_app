import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Custom animated button with modern styling and haptic feedback
class AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;
  final bool isLoading;
  final bool enabled;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.boxShadow,
    this.width,
    this.height,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _loadingController;
  
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _loadingController.repeat();
      } else {
        _loadingController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled || widget.isLoading) return;
    
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled || widget.isLoading) return;
    
    _pressController.reverse();
  }

  void _handleTapCancel() {
    if (!widget.enabled || widget.isLoading) return;
    
    _pressController.reverse();
  }

  void _handleTap() {
    if (!widget.enabled || widget.isLoading) return;
    
    HapticFeedback.mediumImpact();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? AppTheme.primaryRed;
    final foregroundColor = widget.foregroundColor ?? AppTheme.textPrimary;
    final borderRadius = widget.borderRadius ?? AppTheme.buttonRadius;
    final padding = widget.padding ?? const EdgeInsets.symmetric(
      horizontal: 32,
      vertical: 16,
    );

    return AnimatedBuilder(
      animation: Listenable.merge([
        _pressController,
        _loadingController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: _handleTap,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.enabled && !widget.isLoading
                    ? LinearGradient(
                        colors: [
                          backgroundColor,
                          backgroundColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          AppTheme.textSecondary.withOpacity(0.3),
                          AppTheme.textSecondary.withOpacity(0.2),
                        ],
                      ),
                borderRadius: borderRadius,
                // Box shadows removed as requested
              ),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: padding,
                  child: widget.isLoading
                      ? _buildLoadingContent(foregroundColor)
                      : _buildButtonContent(foregroundColor),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent(Color foregroundColor) {
    return DefaultTextStyle(
      style: AppTheme.buttonStyle.copyWith(
        color: widget.enabled ? foregroundColor : AppTheme.textSecondary,
      ),
      child: IconTheme(
        data: IconThemeData(
          color: widget.enabled ? foregroundColor : AppTheme.textSecondary,
        ),
        child: widget.child,
      ),
    );
  }

  Widget _buildLoadingContent(Color foregroundColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'LOADING...',
          style: AppTheme.buttonStyle.copyWith(
            color: foregroundColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

/// Specialized button for score increment with large styling
class ScoreButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String teamName;
  final Color color;
  final bool isEnabled;

  const ScoreButton({
    super.key,
    required this.onPressed,
    required this.teamName,
    required this.color,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: isEnabled ? onPressed : null,
      enabled: isEnabled,
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 32,
            color: AppTheme.textPrimary,
          ),
          const SizedBox(height: 8),
          Text(
            teamName.toUpperCase(),
            style: AppTheme.buttonStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'WINS POINT',
            style: AppTheme.captionStyle.copyWith(
              fontSize: 12,
              color: AppTheme.textPrimary.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
