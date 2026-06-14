import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../theme/app_colors.dart';

/// Displays the calculation history with the ability to delete individual
/// entries, clear all, or tap an entry to reuse its result.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<CalculatorProvider>();
    final history = provider.history;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear all',
              onPressed: () => _confirmClearAll(context, provider),
            ),
        ],
      ),
      body: history.isEmpty
          ? _EmptyHistory(isDark: isDark)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return _HistoryTile(
                  expression: item.expression,
                  result: item.result,
                  isDark: isDark,
                  onTap: () {
                    provider.useHistoryItem(item);
                    Navigator.pop(context);
                  },
                  onDelete: () => provider.deleteHistoryItem(index),
                );
              },
            ),
    );
  }

  void _confirmClearAll(BuildContext context, CalculatorProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to delete all history?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(ctx);
            },
            child: const Text('Clear', style: TextStyle(color: AppColors.errorColor)),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final String expression;
  final String result;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryTile({
    required this.expression,
    required this.result,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('$expression-$result-${DateTime.now().microsecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    expression,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkExpressionText
                          : AppColors.lightExpressionText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '= $result',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkDisplayText : AppColors.lightDisplayText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  final bool isDark;
  const _EmptyHistory({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 64,
            color: isDark ? AppColors.darkExpressionText : AppColors.lightExpressionText,
          ),
          const SizedBox(height: 16),
          Text(
            'No history yet',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.darkExpressionText : AppColors.lightExpressionText,
            ),
          ),
        ],
      ),
    );
  }
}
