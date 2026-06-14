import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calc_button.dart';
import '../providers/calculator_provider.dart';
import 'animated_calc_button.dart';

/// The scientific calculator button grid: trig functions, logarithms,
/// powers, factorial, constants, parentheses, and memory operations.
///
/// Designed to be scrollable on smaller screens to avoid overflow.
class ScientificKeypad extends StatelessWidget {
  const ScientificKeypad({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();
    final isDeg = provider.angleMode.name == 'degree';

    final rows = <List<CalcButton>>[
      [
        CalcButton(label: isDeg ? 'DEG' : 'RAD', type: ButtonType.functionBtn),
        const CalcButton(label: '(', type: ButtonType.functionBtn),
        const CalcButton(label: ')', type: ButtonType.functionBtn),
        const CalcButton(label: 'x!', type: ButtonType.functionBtn),
      ],
      [
        const CalcButton(label: 'sin', type: ButtonType.functionBtn),
        const CalcButton(label: 'cos', type: ButtonType.functionBtn),
        const CalcButton(label: 'tan', type: ButtonType.functionBtn),
        const CalcButton(label: 'π', type: ButtonType.functionBtn),
      ],
      [
        const CalcButton(label: 'asin', type: ButtonType.functionBtn),
        const CalcButton(label: 'acos', type: ButtonType.functionBtn),
        const CalcButton(label: 'atan', type: ButtonType.functionBtn),
        const CalcButton(label: 'e', type: ButtonType.functionBtn),
      ],
      [
        const CalcButton(label: 'log', type: ButtonType.functionBtn),
        const CalcButton(label: 'ln', type: ButtonType.functionBtn),
        const CalcButton(label: '√', type: ButtonType.functionBtn),
        const CalcButton(label: 'xʸ', type: ButtonType.functionBtn),
      ],
      [
        const CalcButton(label: 'x²', type: ButtonType.functionBtn),
        const CalcButton(label: 'x³', type: ButtonType.functionBtn),
        const CalcButton(label: '10ˣ', type: ButtonType.functionBtn),
        const CalcButton(label: 'eˣ', type: ButtonType.functionBtn),
      ],
      [
        CalcButton(
          label: 'MC',
          type: ButtonType.functionBtn,
        ),
        const CalcButton(label: 'MR', type: ButtonType.functionBtn),
        const CalcButton(label: 'M+', type: ButtonType.functionBtn),
        const CalcButton(label: 'M-', type: ButtonType.functionBtn),
      ],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in rows)
          Expanded(
            child: Row(
              children: [
                for (final btn in row)
                  AnimatedCalcButton(
                    button: btn,
                    isActive: btn.label == 'MR' && provider.memoryHasValue,
                    onTap: () => provider.onButtonPressed(btn.label),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
