import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Colors (Warm Editorial)
  static const Color primary = Color(0xFF0A122C); // Deep Slate Indigo
  static const Color secondary = Color(0xFF7C3AED); // Soft Violet Lavender
  static const Color accent = Color(0xFFC5A880); // Warm Premium Gold Accent
  
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Info Blue

  static const Color background = Color(0xFFFAF9F6); // Warm Stone Off-White
  static const Color surface = Colors.white;
  static const Color onBackground = Color(0xFF0A122C); // Dark Charcoal Indigo
  static const Color onSurface = Color(0xFF0A122C);
  
  static const Color textPrimary = Color(0xFF0A122C);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);

  // Dark Mode Colors (Deep Midnight Space)
  static const Color primaryDark = Color(0xFFC084FC); // Soft lavender highlight
  static const Color secondaryDark = Color(0xFF818CF8); // Muted indigo
  static const Color backgroundDark = Color(0xFF0A0F1D); // Deep Midnight Navy
  static const Color surfaceDark = Color(0xFF131A2E); // Elevated Slate Surface
  static const Color onBackgroundDark = Color(0xFFF8FAFC);
  static const Color onSurfaceDark = Color(0xFFF8FAFC);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textLightDark = Color(0xFF475569);
  static const Color borderDark = Color(0xFF1E293B);

  // Status/Health Colors
  static const Color healthOnTrack = Color(0xFF10B981);      // 🟢 Green
  static const Color healthAttention = Color(0xFFF59E0B);    // 🟡 Amber
  static const Color healthAtRisk = Color(0xFFEF4444);       // 🔴 Red
  static const Color healthCompleted = Color(0xFF3B82F6);    // 🔵 Blue
  static const Color healthPaused = Color(0xFF64748B);       // ⚪ Gray
}
