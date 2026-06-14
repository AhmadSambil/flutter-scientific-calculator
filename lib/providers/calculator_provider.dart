import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../logic/calculator_engine.dart';
import '../models/history_item.dart';

/// Calculator UI mode.
enum CalcMode { standard, scientific }

/// Central state holder for the calculator: expression, result, history,
/// mode switching, memory, and angle mode. Notifies listeners on change
/// so the UI rebuilds reactively.
class CalculatorProvider extends ChangeNotifier {
  final CalculatorEngine _engine = CalculatorEngine();

  String _expression = '';
  String _display = '0';
  bool _hasError = false;
  CalcMode _mode = CalcMode.standard;
  final List<HistoryItem> _history = [];

  // ---------- GETTERS ----------
  String get expression => _expression;
  String get display => _display;
  bool get hasError => _hasError;
  CalcMode get mode => _mode;
  List<HistoryItem> get history => List.unmodifiable(_history.reversed);
  AngleMode get angleMode => _engine.angleMode;
  bool get memoryHasValue => _engine.memoryHasValue;

  // ---------- MODE SWITCHING ----------

  void toggleMode() {
    _mode = _mode == CalcMode.standard ? CalcMode.scientific : CalcMode.standard;
    notifyListeners();
  }

  void toggleAngleMode() {
    _engine.angleMode =
        _engine.angleMode == AngleMode.degree ? AngleMode.radian : AngleMode.degree;
    notifyListeners();
  }

  // ---------- INPUT HANDLING ----------

  /// Handles any button press by label. Provides haptic feedback for
  /// a premium tactile feel.
  void onButtonPressed(String value) {
    HapticFeedback.lightImpact();

    switch (value) {
      case 'C':
        _clear();
        break;
      case '⌫':
        _backspace();
        break;
      case '=':
        _calculate();
        break;
      case '±':
        _toggleSign();
        break;
      case 'MC':
        _engine.memoryClear();
        notifyListeners();
        break;
      case 'MR':
        _insertMemoryRecall();
        break;
      case 'M+':
        _memoryAdd();
        break;
      case 'M-':
        _memorySubtract();
        break;
      case 'DEG':
      case 'RAD':
        toggleAngleMode();
        break;
      default:
        _appendToExpression(value);
    }
  }

  void _clear() {
    _expression = '';
    _display = '0';
    _hasError = false;
    notifyListeners();
  }

  void _backspace() {
    if (_hasError) {
      _clear();
      return;
    }
    if (_expression.isNotEmpty) {
      _expression = _expression.substring(0, _expression.length - 1);
      _display = _expression.isEmpty ? '0' : _expression;
      notifyListeners();
    }
  }

  void _toggleSign() {
    if (_expression.isEmpty || _expression == '0') {
      _expression = '-';
    } else {
      // Toggle sign of the last number in the expression.
      final regex = RegExp(r'(-?\d+\.?\d*)$');
      final match = regex.firstMatch(_expression);
      if (match != null) {
        final numStr = match.group(0)!;
        final start = match.start;
        if (numStr.startsWith('-')) {
          _expression = _expression.substring(0, start) + numStr.substring(1);
        } else {
          _expression = '${_expression.substring(0, start)}-$numStr';
        }
      }
    }
    _display = _expression;
    notifyListeners();
  }

  void _appendToExpression(String value) {
    if (_hasError) {
      _expression = '';
      _hasError = false;
    }

    // Map scientific function buttons to their expression form.
    String toAppend = value;
    switch (value) {
      case 'sin':
      case 'cos':
      case 'tan':
      case 'asin':
      case 'acos':
      case 'atan':
      case 'log':
      case 'ln':
      case '√':
        toAppend = '$value(';
        break;
      case 'x²':
        toAppend = '^2';
        break;
      case 'x³':
        toAppend = '^3';
        break;
      case 'xʸ':
        toAppend = '^';
        break;
      case 'eˣ':
        toAppend = 'e^';
        break;
      case '10ˣ':
        toAppend = '10^';
        break;
      case 'x!':
        toAppend = '!';
        break;
    }

    // Prevent leading zeros issue: replace solitary "0" with new digit.
    if (_expression == '0' && RegExp(r'^[0-9]$').hasMatch(toAppend)) {
      _expression = toAppend;
    } else {
      _expression += toAppend;
    }

    _display = _expression;
    notifyListeners();
  }

  void _insertMemoryRecall() {
    final value = _engine.memoryRecall();
    final formatted = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
    _appendToExpression(formatted);
  }

  void _memoryAdd() {
    final value = _currentValueForMemory();
    if (value != null) _engine.memoryAdd(value);
    notifyListeners();
  }

  void _memorySubtract() {
    final value = _currentValueForMemory();
    if (value != null) _engine.memorySubtract(value);
    notifyListeners();
  }

  double? _currentValueForMemory() {
    try {
      final result = _engine.evaluate(_expression.isEmpty ? _display : _expression);
      return double.tryParse(result);
    } catch (_) {
      return double.tryParse(_display);
    }
  }

  /// Evaluates the current expression and updates the display + history.
  void _calculate() {
    if (_expression.isEmpty) return;

    try {
      final result = _engine.evaluate(_expression);
      _history.add(HistoryItem(
        expression: _expression,
        result: result,
        timestamp: DateTime.now(),
      ));
      _display = result;
      _expression = result;
      _hasError = false;
    } catch (_) {
      _display = 'Error';
      _hasError = true;
    }

    notifyListeners();
  }

  // ---------- HISTORY MANAGEMENT ----------

  void deleteHistoryItem(int index) {
    // index is relative to the reversed (display) list.
    final actualIndex = _history.length - 1 - index;
    _history.removeAt(actualIndex);
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  /// Loads a history entry back into the active expression for reuse.
  void useHistoryItem(HistoryItem item) {
    _expression = item.result;
    _display = item.result;
    _hasError = false;
    notifyListeners();
  }
}
