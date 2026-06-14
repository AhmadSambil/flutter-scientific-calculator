import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calc_button.dart';
import '../providers/calculator_provider.dart';
import 'animated_calc_button.dart';

/// The standard calculator button grid: digits, basic operators,
/// percentage, sign toggle, clear, and backspace.
class StandardKeypad extends StatelessWidget {
  const StandardKeypad({super.key});

  static const List<List<CalcButton>> _rows = [
    [
      CalcButton(label: 'C', type: ButtonType.functionBtn),
      CalcButton(label: '±', type: ButtonType.functionBtn),
      CalcButton(label: '%', type: ButtonType.functionBtn),
      CalcButton(label: '÷', type: ButtonType.operatorBtn),
    ],
    [
      CalcButton(label: '7', type: ButtonType.number),
      CalcButton(label: '8', type: ButtonType.number),
      CalcButton(label: '9', type: ButtonType.number),
      CalcButton(label: '×', type: ButtonType.operatorBtn),
    ],
    [
      CalcButton(label: '4', type: ButtonType.number),
      CalcButton(label: '5', type: ButtonType.number),
      CalcButton(label: '6', type: ButtonType.number),
      CalcButton(label: '-', type: ButtonType.operatorBtn),
    ],
    [
      CalcButton(label: '1', type: ButtonType.number),
      CalcButton(label: '2', type: ButtonType.number),
      CalcButton(label: '3', type: ButtonType.number),
      CalcButton(label: '+', type: ButtonType.operatorBtn),
    ],
    [
      CalcButton(label: '0', type: ButtonType.number, flex: 2),
      CalcButton(label: '.', type: ButtonType.number),
      CalcButton(label: '⌫', type: ButtonType.functionBtn, icon: Icons.backspace_outlined),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CalculatorProvider>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in _rows)
          Expanded(
            child: Row(
              children: [
                for (final btn in row)
                  AnimatedCalcButton(
                    button: btn,
                    onTap: () => provider.onButtonPressed(btn.label),
                  ),
              ],
            ),
          ),
        // Equals button on its own row for emphasis.
        Expanded(
          child: Row(
            children: [
              AnimatedCalcButton(
                button: const CalcButton(label: '=', type: ButtonType.equalsBtn, flex: 4),
                onTap: () => provider.onButtonPressed('='),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
