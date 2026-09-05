import 'package:flutter/material.dart';

/// Meezan's calm, nature-inspired palette.
///
/// The brand pivots on two seed families that mirror the app's core duality:
/// a deep teal/olive **spiritual** tone and a warm sand/gold **worldly** tone.
/// A single soft-gold accent ties the two together (the "balance" point).
class AppColors {
  AppColors._();

  // Seeds -------------------------------------------------------------------
  /// Deep teal-green — anchors the spiritual side and the app's overall mood.
  static const Color seedTeal = Color(0xFF1F6E63);

  /// Warm sand/gold — anchors the worldly (productivity) side.
  static const Color seedSand = Color(0xFFCBA135);

  // Ring colours (kept vivid & consistent across light/dark for the hero) ---
  static const Color spiritualRing = Color(0xFF2E9E8C); // luminous teal
  static const Color spiritualRingDark = Color(0xFF4FD1B8);
  static const Color worldlyRing = Color(0xFFE0A64E); // warm gold
  static const Color worldlyRingDark = Color(0xFFF2C066);

  // Priority coding ---------------------------------------------------------
  static const Color priorityHigh = Color(0xFFC0554E);
  static const Color priorityMedium = Color(0xFFD79A3E);
  static const Color priorityLow = Color(0xFF5E8C7B);

  // Growth (streak plant) ---------------------------------------------------
  static const Color growthLeaf = Color(0xFF4F9D6E);
  static const Color growthStem = Color(0xFF3B7A55);
  static const Color soil = Color(0xFF7A5A3A);
}
