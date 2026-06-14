import 'package:flutter/material.dart';

/// Centralized color palette for both Light and Dark themes.
/// Designed with a premium, modern feel inspired by iOS/Samsung calculators.
class AppColors {
  // ---------- LIGHT THEME ----------
  static const Color lightBackground = Color(0xFFF5F6FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightDisplayText = Color(0xFF1C1C1E);
  static const Color lightExpressionText = Color(0xFF8E8E93);

  static const Color lightNumberButton = Color(0xFFFFFFFF);
  static const Color lightNumberText = Color(0xFF1C1C1E);

  static const Color lightOperatorButton = Color(0xFFEDEFF5);
  static const Color lightOperatorText = Color(0xFF1C1C1E);

  static const Color lightFunctionButton = Color(0xFFE3E6F0);
  static const Color lightFunctionText = Color(0xFF3A3A3C);

  static const Color lightAccent = Color(0xFFFF9F0A); // operator highlight
  static const Color lightAccentText = Colors.white;

  static const Color lightShadowDark = Color(0x1A000000);
  static const Color lightShadowLight = Color(0xFFFFFFFF);

  // ---------- DARK THEME ----------
  static const Color darkBackground = Color(0xFF0D0D0F);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkDisplayText = Color(0xFFFFFFFF);
  static const Color darkExpressionText = Color(0xFF8E8E93);

  static const Color darkNumberButton = Color(0xFF2C2C2E);
  static const Color darkNumberText = Color(0xFFFFFFFF);

  static const Color darkOperatorButton = Color(0xFF3A3A3C);
  static const Color darkOperatorText = Color(0xFFFFFFFF);

  static const Color darkFunctionButton = Color(0xFF2C2C2E);
  static const Color darkFunctionText = Color(0xFFD1D1D6);

  static const Color darkAccent = Color(0xFFFF9F0A);
  static const Color darkAccentText = Colors.white;

  static const Color darkShadowDark = Color(0x66000000);
  static const Color darkShadowLight = Color(0x14FFFFFF);

  // ---------- SHARED ----------
  static const Color errorColor = Color(0xFFFF3B30);
}
