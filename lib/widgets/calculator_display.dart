import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// The main display area showing the current expression (small, top)
/// and the live result/display value (large, bottom).
///
/// Supports tap-to-copy with a subtle snackbar confirmation.
class CalculatorDisplay extends StatelessWidget {
  final String expression;
  final String display;
  final bool hasError;

  const CalculatorDisplay({
    super.key,
    required this.expression,
    required this.display,
    required this.hasError,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: display));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: () => _copyToClipboard(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        alignment: Alignment.bottomRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Expression preview line
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                expression.isEmpty ? '' : expression,
                key: ValueKey(expression),
                style: TextStyle(
                  fontSize: 22,
                  color: isDark
                      ? AppColors.darkExpressionText
                      : AppColors.lightExpressionText,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            // Main result display with auto-fit sizing
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                alignment: Alignment.centerRight,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: FittedBox(
                key: ValueKey(display),
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  display,
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w300,
                    color: hasError
                        ? AppColors.errorColor
                        : (isDark
                            ? AppColors.darkDisplayText
                            : AppColors.lightDisplayText),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
