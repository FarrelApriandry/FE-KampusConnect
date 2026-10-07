import 'package:flutter/material.dart';

/// Design tokens — KC-DESIGN-001 §3 (Color System).
/// Neutral foundation dengan satu primary accent yang kuat.
abstract final class AppColors {
  // Neutrals
  static const Color background = Color(0xFFF7F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF151515);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color border = Color(0xFFE7E7E2);

  // Brand
  static const Color primary = Color(0xFF173F35);
  static const Color primarySoft = Color(0xFFE6F0EC);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Semantics
  static const Color success = Color(0xFF24704A);
  static const Color successSoft = Color(0xFFE8F3EC);
  static const Color warning = Color(0xFF9A6A13);
  static const Color warningSoft = Color(0xFFFBF1DC);
  static const Color danger = Color(0xFFB63A3A);
  static const Color dangerSoft = Color(0xFFFAECEC);
}