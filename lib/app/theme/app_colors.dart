import 'package:flutter/material.dart';

class AppColors {
  // Light Theme - Editorial Luxury (Forest Green + Champagne Gold + Warm Ivory)
  // A cohesive collection of tones that feel rich, warm, and highly professional.

  static const Color primary = Color(0xFF0F2E22);        // Rich, velvety dark forest green
  static const Color secondary = Color(0xFF23533F);      // Sophisticated deep emerald
  static const Color accent = Color(0xFFC5A059);         // Elegant warm brushed champagne gold
  static const Color lightGold = Color(0xFFE5D5B3);      // Creamy champagne accent backdrop
  
  // Semantic Statuses (Subtle, refined luxury tones rather than bright neon flags)
  static const Color success = Color(0xFF2C5E43);        // Deep sage green
  static const Color warning = Color(0xFFB57E2F);        // Burnished amber
  static const Color error = Color(0xFFB34E43);          // Warm terracotta red
  static const Color info = Color(0xFF2C4C63);           // Muted steel blue

  // Backgrounds and Surfaces
  static const Color background = Color(0xFFFAF9F5);     // Warm, soft ivory cream
  static const Color surface = Colors.white;             // Pure white
  static const Color softSurface = Color(0xFFF3F1EA);    // Silk-finish surface
  static const Color onBackground = Color(0xFF0D1713);   // Darkest forest charcoal for high contrast
  static const Color onSurface = Color(0xFF0D1713);
  
  // Typography
  static const Color textPrimary = Color(0xFF0D1713);    // Luxury ink primary
  static const Color textSecondary = Color(0xFF5E6D64);  // Warm grey-green secondary text
  static const Color textLight = Color(0xFF9EAFA5);      // Muted sage placeholder/light text
  static const Color border = Color(0xFFEAE7DF);         // Fine line ivory border

  // Dark Theme - Deep Forest Night (High-contrast luxury midnight forest)
  static const Color primaryDark = Color(0xFFC5A059);    // Champagne Gold for primary elements
  static const Color secondaryDark = Color(0xFF387E60);  // Bright forest green accents
  static const Color backgroundDark = Color(0xFF0B120F); // Velvet night forest black
  static const Color surfaceDark = Color(0xFF131D19);    // Deep forest container surface
  static const Color elevatedSurfaceDark = Color(0xFF1B2823); // Elevated dark surface
  static const Color onBackgroundDark = Color(0xFFF6F4EE); // Light warm ivory on dark
  static const Color onSurfaceDark = Color(0xFFF6F4EE);

  static const Color textPrimaryDark = Color(0xFFF6F4EE);
  static const Color textSecondaryDark = Color(0xFF9EAFA5);
  static const Color textLightDark = Color(0xFF5E6D64);
  static const Color borderDark = Color(0xFF1B2823);
  static const Color accentDark = Color(0xFFD9B978);     // Slightly brighter champagne gold for dark readability

  // Status/Health Colors (Premium palette coordination)
  static const Color healthOnTrack = Color(0xFF2C5E43);      // Sage Green
  static const Color healthAttention = Color(0xFFB57E2F);    // Muted Amber
  static const Color healthAtRisk = Color(0xFFB34E43);       // Terracotta
  static const Color healthCompleted = Color(0xFFC5A059);    // Champagne Gold
  static const Color healthPaused = Color(0xFF9EAFA5);       // Muted Sage
}
