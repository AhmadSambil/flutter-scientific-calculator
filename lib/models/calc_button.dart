import 'package:flutter/material.dart';

/// Types of buttons used to determine styling.
enum ButtonType { number, operatorBtn, functionBtn, accentBtn, equalsBtn }

/// Represents a single calculator button definition.
class CalcButton {
  final String label;
  final ButtonType type;
  final IconData? icon;
  final int flex;

  const CalcButton({
    required this.label,
    required this.type,
    this.icon,
    this.flex = 1,
  });
}
