import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';

/// A custom, branded app bar with animated theme toggle, mode switch
/// (Standard/Scientific), and access to calculation history.
class CalculatorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onHistoryTap;

  const CalculatorAppBar({super.key, required this.onHistoryTap});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final calcProvider = context.watch<CalculatorProvider>();
    final isDark = themeProvider.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App title with mode indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calculator',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkDisplayText : AppColors.lightDisplayText,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  calcProvider.mode == CalcMode.standard ? 'Standard' : 'Scientific',
                  key: ValueKey(calcProvider.mode),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkExpressionText
                        : AppColors.lightExpressionText,
                  ),
                ),
              ),
            ],
          ),
          // Action buttons
          Row(
            children: [
              // Mode switch toggle
              _CircleIconButton(
                icon: calcProvider.mode == CalcMode.standard
                    ? Icons.functions
                    : Icons.calculate_outlined,
                tooltip: 'Switch mode',
                onTap: calcProvider.toggleMode,
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              // History
              _CircleIconButton(
                icon: Icons.history,
                tooltip: 'History',
                onTap: onHistoryTap,
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              // Theme toggle with animated icon transition
              _CircleIconButton(
                icon: isDark ? Icons.light_mode : Icons.dark_mode,
                tooltip: 'Toggle theme',
                onTap: themeProvider.toggleTheme,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDark;

  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isDark ? AppColors.darkShadowDark : AppColors.lightShadowDark,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Icon(
              icon,
              key: ValueKey(icon),
              size: 20,
              color: isDark ? AppColors.darkDisplayText : AppColors.lightDisplayText,
            ),
          ),
        ),
      ),
    );
  }
}
