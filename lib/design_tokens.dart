import 'package:flutter/material.dart';

// Design tokens shared across screens (see DESIGN.md).
const Color kBg = Color(0xFFFFFFFF);
const Color kSurface = Color(0xFFF8F8F8);
const Color kCard = Color(0xFFFFFFFF);
const Color kBorder = Color(0xFFE0E0E0);
const Color kText = Color(0xFF484848);
const Color kTextSub = Color(0xFF727272);
const Color kDisabled = Color(0xFFC8C8C8);
const Color kAction = Color(0xFFE60012);
const Color kSuccess = Color(0xFF468254);

/// Per-participant colors, already used by the wheel and participant list.
const List<Color> kWheelColors = [
  Color(0xFFEF4444),
  Color(0xFFF97316),
  Color(0xFFEAB308),
  Color(0xFF22C55E),
  Color(0xFF06B6D4),
  Color(0xFF3B82F6),
  Color(0xFF8B5CF6),
  Color(0xFFD946EF),
  Color(0xFFF43F5E),
];

/// Readable text color on each [kWheelColors] entry.
const List<Color> kWheelTextColors = [
  Colors.white, // red
  Colors.white, // orange
  kText, // yellow
  kText, // green
  kText, // cyan
  Colors.white, // blue
  Colors.white, // violet
  Colors.white, // fuchsia
  Colors.white, // rose
];

Color participantColor(int index) => kWheelColors[index % kWheelColors.length];
Color participantTextColor(int index) =>
    kWheelTextColors[index % kWheelTextColors.length];
