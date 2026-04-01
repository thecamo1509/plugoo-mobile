import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Plugoo Design System — Color Palette
///
/// SINGLE SOURCE OF TRUTH for all colors in the app.
/// Never use Color() literals directly in widgets — always reference this file.
/// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF3D35CC);
  static const Color primaryContainer = Color(0xFFEDECFF);

  static const Color secondary = Color(0xFF00C896);
  static const Color secondaryLight = Color(0xFF5DFFC3);
  static const Color secondaryDark = Color(0xFF00976D);
  static const Color secondaryContainer = Color(0xFFE0FFF5);

  // ── Neutrals ──────────────────────────────────────────────────────────────────
  static const Color grey900 = Color(0xFF1A1A2E);
  static const Color grey800 = Color(0xFF2D2D44);
  static const Color grey700 = Color(0xFF4A4A6A);
  static const Color grey500 = Color(0xFF8888AA);
  static const Color grey300 = Color(0xFFCCCCDD);
  static const Color grey100 = Color(0xFFF5F5FA);

  // ── Semantic ───────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFE53E3E);
  static const Color errorContainer = Color(0xFFFFEBEB);
  static const Color success = Color(0xFF38A169);
  static const Color successContainer = Color(0xFFEBFFF4);
  static const Color warning = Color(0xFFD69E2E);
  static const Color warningContainer = Color(0xFFFFFAEB);
  static const Color info = Color(0xFF3182CE);
  static const Color infoContainer = Color(0xFFEBF4FF);

  // ── Surfaces ───────────────────────────────────────────────────────────────────
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8F8FC);
  static const Color background = Color(0xFFF5F5FA);
  static const Color overlay = Color(0x80000000);

  // ── Dark mode surfaces ─────────────────────────────────────────────────────────
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color surfaceVariantDark = Color(0xFF2D2D44);
  static const Color backgroundDark = Color(0xFF0F0F1A);
}
