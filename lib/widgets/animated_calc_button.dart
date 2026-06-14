import 'package:flutter/material.dart';
import '../models/calc_button.dart';
import '../theme/app_colors.dart';

/// A premium animated button used throughout the calculator.
///
/// Provides a scale-down "press" animation, soft shadows for a
/// neumorphism-inspired look, and theme-aware coloring.
class AnimatedCalcButton extends StatefulWidget {
  final CalcButton button;
  final VoidCallback onTap;
  final bool isActive;

  const AnimatedCalcButton({
    super.key,
    required this.button,
    required this.onTap,
    this.isActive = false,
  });

  @override
  State<AnimatedCalcButton> createState() => _AnimatedCalcButtonState();
}

class _AnimatedCalcButtonState extends State<AnimatedCalcButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _getColors(isDark, widget.button.type, widget.isActive);

    return Expanded(
      flex: widget.button.flex,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(
                      widget.button.flex > 1 ? 32 : 50,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? AppColors.darkShadowDark
                            : AppColors.lightShadowDark,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: widget.button.icon != null
                      ? Icon(widget.button.icon, color: colors.foreground, size: 24)
                      : Text(
                          widget.button.label,
                          style: TextStyle(
                            fontSize: widget.button.label.length > 2 ? 18 : 26,
                            fontWeight: FontWeight.w500,
                            color: colors.foreground,
                          ),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  _BtnColors _getColors(bool isDark, ButtonType type, bool isActive) {
    if (isActive) {
      return _BtnColors(
        background: isDark ? AppColors.darkAccent : AppColors.lightAccent,
        foreground: Colors.white,
      );
    }

    switch (type) {
      case ButtonType.number:
        return _BtnColors(
          background: isDark ? AppColors.darkNumberButton : AppColors.lightNumberButton,
          foreground: isDark ? AppColors.darkNumberText : AppColors.lightNumberText,
        );
      case ButtonType.operatorBtn:
        return _BtnColors(
          background: isDark ? AppColors.darkOperatorButton : AppColors.lightOperatorButton,
          foreground: isDark ? AppColors.darkOperatorText : AppColors.lightOperatorText,
        );
      case ButtonType.functionBtn:
        return _BtnColors(
          background: isDark ? AppColors.darkFunctionButton : AppColors.lightFunctionButton,
          foreground: isDark ? AppColors.darkFunctionText : AppColors.lightFunctionText,
        );
      case ButtonType.accentBtn:
      case ButtonType.equalsBtn:
        return _BtnColors(
          background: isDark ? AppColors.darkAccent : AppColors.lightAccent,
          foreground: Colors.white,
        );
    }
  }
}

class _BtnColors {
  final Color background;
  final Color foreground;
  _BtnColors({required this.background, required this.foreground});
}
