import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/calculator_app_bar.dart';
import '../widgets/calculator_display.dart';
import '../widgets/standard_keypad.dart';
import '../widgets/scientific_keypad.dart';
import 'history_screen.dart';

/// The main calculator screen. Adapts layout for phone/tablet and
/// portrait/landscape orientations, with animated transitions between
/// Standard and Scientific modes.
class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<CalculatorProvider>();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CalculatorAppBar(
            onHistoryTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 350),
                pageBuilder: (_, __, ___) => const HistoryScreen(),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                    child: child,
                  );
                },
              ),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;
              final isTablet = constraints.maxWidth > 600;

              if (isLandscape) {
                return _LandscapeLayout(provider: provider, isTablet: isTablet);
              }
              return _PortraitLayout(provider: provider, isTablet: isTablet);
            },
          ),
        ),
      ),
    );
  }
}

/// Portrait layout: display on top, keypad below with animated mode switch.
class _PortraitLayout extends StatelessWidget {
  final CalculatorProvider provider;
  final bool isTablet;

  const _PortraitLayout({required this.provider, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: provider.mode == CalcMode.scientific ? 2 : 3,
          child: CalculatorDisplay(
            expression: provider.expression,
            display: provider.display,
            hasError: provider.hasError,
          ),
        ),
        Expanded(
          flex: 5,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 8, vertical: 8),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: child,
                  ),
                );
              },
              child: provider.mode == CalcMode.standard
                  ? const StandardKeypad(key: ValueKey('standard'))
                  : const ScientificKeypad(key: ValueKey('scientific')),
            ),
          ),
        ),
      ],
    );
  }
}

/// Landscape layout: display on left, keypad on right (or scientific
/// keypad alongside standard for larger screens).
class _LandscapeLayout extends StatelessWidget {
  final CalculatorProvider provider;
  final bool isTablet;

  const _LandscapeLayout({required this.provider, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: CalculatorDisplay(
            expression: provider.expression,
            display: provider.display,
            hasError: provider.hasError,
          ),
        ),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: provider.mode == CalcMode.standard
                  ? const StandardKeypad(key: ValueKey('standard-land'))
                  : const ScientificKeypad(key: ValueKey('scientific-land')),
            ),
          ),
        ),
      ],
    );
  }
}
