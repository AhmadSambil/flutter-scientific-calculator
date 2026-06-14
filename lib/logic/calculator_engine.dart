import 'dart:math' as math;

/// Angle mode for trigonometric functions.
enum AngleMode { degree, radian }

/// Core calculator engine. Implements a self-contained recursive-descent
/// expression parser/evaluator supporting standard arithmetic, scientific
/// functions, constants, factorial, and percentage — without relying on
/// any third-party math-parsing package (avoids version/API drift issues).
///
/// This class is UI-independent and fully testable.
class CalculatorEngine {
  AngleMode angleMode = AngleMode.degree;
  double _memory = 0.0;
  bool memoryHasValue = false;

  // Internal parser state.
  late String _src;
  late int _pos;

  /// Evaluates a calculator display expression (with UI symbols like
  /// ×, ÷, π, √, etc.) and returns a formatted result string.
  ///
  /// Throws [FormatException] on invalid/malformed expressions.
  String evaluate(String expression) {
    if (expression.trim().isEmpty) return '0';

    String expr = _preprocess(expression);

    _src = expr;
    _pos = 0;
    final result = _parseExpression();
    _skipSpaces();
    if (_pos != _src.length) {
      throw const FormatException('Invalid expression');
    }

    if (result.isNaN || result.isInfinite) {
      throw const FormatException('Math Error');
    }

    return _formatResult(result);
  }

  // ===================== PREPROCESSING =====================

  /// Normalizes UI symbols and auto-closes unmatched parentheses.
  String _preprocess(String input) {
    String expr = input;
    expr = expr.replaceAll('×', '*');
    expr = expr.replaceAll('÷', '/');
    expr = expr.replaceAll(' ', '');
    expr = _autoCloseParens(expr);
    return expr;
  }

  String _autoCloseParens(String expr) {
    int open = 0;
    int close = 0;
    for (final c in expr.split('')) {
      if (c == '(') open++;
      if (c == ')') close++;
    }
    while (open > close) {
      expr += ')';
      close++;
    }
    return expr;
  }

  // ===================== RECURSIVE DESCENT PARSER =====================
  //
  // Grammar (highest to lowest precedence):
  //   atom        -> number | constant | function(arg) | '(' expr ')'
  //   factorial   -> atom '!'*
  //   power       -> factorial ('^' unary)?      (right-associative)
  //   unary       -> ('-' | '+')? power
  //   term        -> unary (('*' | '/' | implicit) unary)*
  //   expression  -> term (('+' | '-') term)*
  //
  // Implicit multiplication: after parsing a complete unary factor, if the
  // next token can start a new factor (a digit-less identifier, '(', etc.)
  // without an explicit operator, multiplication is inferred.

  double _parseExpression() {
    double value = _parseTerm();
    while (true) {
      _skipSpaces();
      if (_peek() == '+') {
        _pos++;
        value += _parseTerm();
      } else if (_peek() == '-') {
        _pos++;
        value -= _parseTerm();
      } else {
        break;
      }
    }
    return value;
  }

  double _parseTerm() {
    double value = _parseUnary();
    while (true) {
      _skipSpaces();
      final c = _peek();
      if (c == '*') {
        _pos++;
        value *= _parseUnary();
      } else if (c == '/') {
        _pos++;
        final divisor = _parseUnary();
        if (divisor == 0) throw const FormatException('Division by zero');
        value /= divisor;
      } else if (_canStartImplicitFactor(c)) {
        // Implicit multiplication, e.g. "2(3+4)" or "2pi" or "3sin(2)"
        value *= _parseUnary();
      } else {
        break;
      }
    }
    return value;
  }

  /// Whether the upcoming character can begin a new factor for implicit
  /// multiplication (used after a complete factor has been parsed).
  bool _canStartImplicitFactor(String? c) {
    if (c == null) return false;
    return c == '(' || RegExp(r'[a-zA-Zπ√]').hasMatch(c);
  }

  double _parseUnary() {
    _skipSpaces();
    final c = _peek();
    if (c == '-') {
      _pos++;
      return -_parseUnary();
    }
    if (c == '+') {
      _pos++;
      return _parseUnary();
    }
    return _parsePower();
  }

  double _parsePower() {
    double base = _parseFactorial();
    _skipSpaces();
    if (_peek() == '^') {
      _pos++;
      // Right-associative: exponent may itself be unary (e.g. 2^-1)
      final exponent = _parseUnary();
      return math.pow(base, exponent).toDouble();
    }
    return base;
  }

  double _parseFactorial() {
    double value = _parseAtom();
    _skipSpaces();
    while (_peek() == '!') {
      _pos++;
      final n = value.round();
      if (value < 0 || value != n) {
        throw const FormatException('Invalid factorial');
      }
      value = _factorial(n);
    }
    return value;
  }

  double _parseAtom() {
    _skipSpaces();
    final c = _peek();

    if (c == null) {
      throw const FormatException('Unexpected end of expression');
    }

    // Parenthesized expression
    if (c == '(') {
      _pos++;
      final value = _parseExpression();
      _skipSpaces();
      _expect(')');
      return value;
    }

    // Handle percentage applied directly to a parenthesized/number atom
    // is covered by checking for '%' after parsing — see _parsePostPercent.

    // Numbers
    if (RegExp(r'[0-9.]').hasMatch(c)) {
      return _parsePostPercent(_parseNumber());
    }

    // Constants and functions (identifiers)
    if (RegExp(r'[a-zA-Zπ√]').hasMatch(c)) {
      return _parseIdentifierOrFunction();
    }

    throw FormatException('Unexpected character: $c');
  }

  /// After parsing a number, checks for a trailing '%' and converts
  /// it to a division by 100 (basic calculator percent behavior).
  double _parsePostPercent(double value) {
    _skipSpaces();
    if (_peek() == '%') {
      _pos++;
      return value / 100;
    }
    return value;
  }

  double _parseNumber() {
    final start = _pos;
    bool hasDot = false;
    while (_pos < _src.length) {
      final ch = _src[_pos];
      if (RegExp(r'[0-9]').hasMatch(ch)) {
        _pos++;
      } else if (ch == '.' && !hasDot) {
        hasDot = true;
        _pos++;
      } else {
        break;
      }
    }
    final numStr = _src.substring(start, _pos);
    final value = double.tryParse(numStr);
    if (value == null) throw FormatException('Invalid number: $numStr');
    return value;
  }

  /// Parses constants (pi, e) and functions (sin, cos, log, sqrt, etc.)
  double _parseIdentifierOrFunction() {
    // Special single-char symbols
    if (_peek() == 'π') {
      _pos++;
      return _parsePostPercent(math.pi);
    }
    if (_peek() == '√') {
      _pos++;
      final arg = _parseFunctionArg();
      if (arg < 0) throw const FormatException('Invalid sqrt');
      return math.sqrt(arg);
    }

    // Read alphabetic identifier
    final start = _pos;
    while (_pos < _src.length && RegExp(r'[a-zA-Z]').hasMatch(_src[_pos])) {
      _pos++;
    }
    final name = _src.substring(start, _pos);

    switch (name) {
      case 'pi':
        return _parsePostPercent(math.pi);
      case 'e':
        return _parsePostPercent(math.e);
      case 'sqrt':
        final arg = _parseFunctionArg();
        if (arg < 0) throw const FormatException('Invalid sqrt');
        return math.sqrt(arg);
      case 'sin':
        return _applyTrig(math.sin, _parseFunctionArg());
      case 'cos':
        return _applyTrig(math.cos, _parseFunctionArg());
      case 'tan':
        return _applyTrig(math.tan, _parseFunctionArg());
      case 'asin':
        return _applyInverseTrig(math.asin, _parseFunctionArg());
      case 'acos':
        return _applyInverseTrig(math.acos, _parseFunctionArg());
      case 'atan':
        return _applyInverseTrig(math.atan, _parseFunctionArg());
      case 'log':
        final arg = _parseFunctionArg();
        if (arg <= 0) throw const FormatException('Invalid log');
        return math.log(arg) / math.ln10;
      case 'ln':
        final arg = _parseFunctionArg();
        if (arg <= 0) throw const FormatException('Invalid ln');
        return math.log(arg);
      default:
        throw FormatException('Unknown identifier: $name');
    }
  }

  /// Parses a parenthesized argument, e.g. "(30)" following a function name.
  double _parseFunctionArg() {
    _skipSpaces();
    _expect('(');
    final value = _parseExpression();
    _skipSpaces();
    _expect(')');
    return value;
  }

  double _applyTrig(double Function(double) fn, double arg) {
    final radians = angleMode == AngleMode.degree ? arg * math.pi / 180 : arg;
    return fn(radians);
  }

  double _applyInverseTrig(double Function(double) fn, double arg) {
    final result = fn(arg);
    return angleMode == AngleMode.degree ? result * 180 / math.pi : result;
  }

  // ===================== PARSER HELPERS =====================

  String? _peek() => _pos < _src.length ? _src[_pos] : null;

  void _skipSpaces() {
    while (_pos < _src.length && _src[_pos] == ' ') {
      _pos++;
    }
  }

  void _expect(String char) {
    _skipSpaces();
    if (_peek() != char) {
      throw FormatException('Expected "$char" at position $_pos');
    }
    _pos++;
  }

  // ===================== FORMATTING =====================

  /// Formats the numeric result, trimming trailing zeros and limiting
  /// decimal precision to avoid floating-point artifacts.
  String _formatResult(double result) {
    if (result == result.roundToDouble() && result.abs() < 1e15) {
      return result.toInt().toString();
    }

    String formatted = result.toStringAsFixed(10);
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    }
    return formatted;
  }

  // ===================== MEMORY FUNCTIONS =====================

  void memoryClear() {
    _memory = 0.0;
    memoryHasValue = false;
  }

  void memoryAdd(double value) {
    _memory += value;
    memoryHasValue = true;
  }

  void memorySubtract(double value) {
    _memory -= value;
    memoryHasValue = true;
  }

  double memoryRecall() => _memory;

  // ===================== STATIC HELPERS =====================

  /// Computes n! iteratively as a double. Results beyond ~170! become
  /// infinite and are caught by the isInfinite check in [evaluate].
  double _factorial(int n) {
    if (n < 0) throw const FormatException('Invalid factorial');
    double result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  static double get piValue => math.pi;
  static double get eValue => math.e;
}
