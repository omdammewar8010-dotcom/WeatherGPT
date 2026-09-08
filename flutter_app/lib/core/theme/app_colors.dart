import 'package:flutter/material.dart';

class AppColors {
  // Brand Base (Gov-Tech Dark Palette)
  static const Color primary = Color(0xFF0F172A);        // Slate 900
  static const Color primaryLight = Color(0xFF1E293B);   // Slate 800
  static const Color accent = Color(0xFF0284C7);         // Sky 600
  static const Color accentLight = Color(0xFF38BDF8);    // Sky 400
  static const Color background = Color(0xFF0B0F17);     // Dark Canvas
  static const Color surface = Color(0xFF161E2E);        // Elevated Card Surface
  static const Color surfaceLight = Color(0xFF222F43);   // Lighter Surface
  static const Color surfaceBorder = Color(0xFF26334D);  // Subtle Card Stroke

  // Semantic Risk Tiers (Standardized Emergency Palette)
  static const Color riskLow = Color(0xFF10B981);        // Emerald 500 (0-29)
  static const Color riskModerate = Color(0xFFF59E0B);   // Amber 500 (30-59)
  static const Color riskHigh = Color(0xFFF97316);       // Orange 500 (60-79)
  static const Color riskCritical = Color(0xFFEF4444);   // Rose 500 (80-100)

  // Typography & Content
  static const Color textPrimary = Color(0xFFF8FAFC);    // Slate 50
  static const Color textSecondary = Color(0xFF94A3B8);  // Slate 400
  static const Color textMuted = Color(0xFF64748B);      // Slate 500
  static const Color divider = Color(0xFF1E293B);

  // Status & Utility
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF0284C7);

  // Helpers
  static Color getRiskColor(int score) {
    if (score >= 80) return riskCritical;
    if (score >= 60) return riskHigh;
    if (score >= 30) return riskModerate;
    return riskLow;
  }

  static String getRiskLabel(int score) {
    if (score >= 80) return 'CRITICAL';
    if (score >= 60) return 'HIGH';
    if (score >= 30) return 'MODERATE';
    return 'LOW';
  }
}
