import 'package:flutter/material.dart';

enum LevelId { newYork, tokyo, dubai, monaco, shanghai }

class LevelTheme {
  final LevelId id;
  final String cityName;
  final String emoji;
  final double scoreStart;

  // Sky / ground
  final Color skyTop;
  final Color skyBottom;
  final Color groundNear;
  final Color groundFar;

  // Buildings
  final Color buildingFar;
  final Color buildingMid;
  final Color buildingNear;
  final Color buildingHighlight;
  final Color windowDim;
  final Color windowLit;

  // Special FX
  final bool hasNeon;
  final bool nightMode;
  final bool hasFog;
  final List<Color> accentColors;

  // Road tint
  final Color roadTint;
  final Color kerbA;
  final Color kerbB;

  const LevelTheme({
    required this.id,
    required this.cityName,
    required this.emoji,
    required this.scoreStart,
    required this.skyTop,
    required this.skyBottom,
    required this.groundNear,
    required this.groundFar,
    required this.buildingFar,
    required this.buildingMid,
    required this.buildingNear,
    required this.buildingHighlight,
    required this.windowDim,
    required this.windowLit,
    required this.hasNeon,
    required this.nightMode,
    required this.hasFog,
    required this.accentColors,
    required this.roadTint,
    required this.kerbA,
    required this.kerbB,
  });

  // ── 5 city levels ──────────────────────────────────────────────────────

  static const newYork = LevelTheme(
    id: LevelId.newYork,
    cityName: 'New York',
    emoji: '🗽',
    scoreStart: 0,
    skyTop: Color(0xFF4A90C8),
    skyBottom: Color(0xFF87CEEB),
    groundNear: Color(0xFF2A4520),
    groundFar: Color(0xFF3A5F30),
    buildingFar: Color(0xFF5A6378),
    buildingMid: Color(0xFF4A5568),
    buildingNear: Color(0xFF3A4456),
    buildingHighlight: Color(0xFF718096),
    windowDim: Color(0xFF1A2030),
    windowLit: Color(0xFFFFEA88),
    hasNeon: false,
    nightMode: false,
    hasFog: false,
    accentColors: [Color(0xFF718096), Color(0xFF4A5568)],
    roadTint: Color(0xFF2D2D2D),
    kerbA: Color(0xFFCC1111),
    kerbB: Colors.white,
  );

  static const tokyo = LevelTheme(
    id: LevelId.tokyo,
    cityName: 'Tokyo',
    emoji: '🗼',
    scoreStart: 600,
    skyTop: Color(0xFF0A0A1A),
    skyBottom: Color(0xFF1A0A2E),
    groundNear: Color(0xFF1A1A2A),
    groundFar: Color(0xFF101018),
    buildingFar: Color(0xFF1A1A2E),
    buildingMid: Color(0xFF141428),
    buildingNear: Color(0xFF0E0E1E),
    buildingHighlight: Color(0xFF2A2A4A),
    windowDim: Color(0xFF0A0A18),
    windowLit: Color(0xFFFF6CB7),
    hasNeon: true,
    nightMode: true,
    hasFog: false,
    accentColors: [
      Color(0xFFFF0080),
      Color(0xFF00FFFF),
      Color(0xFFFFFF00),
      Color(0xFF00FF80),
    ],
    roadTint: Color(0xFF1A1A2A),
    kerbA: Color(0xFFFF0080),
    kerbB: Color(0xFF00FFFF),
  );

  static const dubai = LevelTheme(
    id: LevelId.dubai,
    cityName: 'Dubai',
    emoji: '🏙️',
    scoreStart: 1400,
    skyTop: Color(0xFF87BFDD),
    skyBottom: Color(0xFFD4A96A),
    groundNear: Color(0xFFC19A6B),
    groundFar: Color(0xFFD4B483),
    buildingFar: Color(0xFFB8A88A),
    buildingMid: Color(0xFFC8B090),
    buildingNear: Color(0xFFE8D5B0),
    buildingHighlight: Color(0xFFF0E0C0),
    windowDim: Color(0xFF8A7A60),
    windowLit: Color(0xFFFFFFDD),
    hasNeon: false,
    nightMode: false,
    hasFog: false,
    accentColors: [Color(0xFFD4AF37), Color(0xFFF5E6CC)],
    roadTint: Color(0xFF3A3020),
    kerbA: Color(0xFFD4AF37),
    kerbB: Color(0xFFF5E6CC),
  );

  static const monaco = LevelTheme(
    id: LevelId.monaco,
    cityName: 'Monaco',
    emoji: '🏁',
    scoreStart: 2600,
    skyTop: Color(0xFF1E6EA8),
    skyBottom: Color(0xFF4AAFDE),
    groundNear: Color(0xFF1A5C3A),
    groundFar: Color(0xFF2A7A50),
    buildingFar: Color(0xFFDDB898),
    buildingMid: Color(0xFFCC9988),
    buildingNear: Color(0xFFBB8877),
    buildingHighlight: Color(0xFFEEBBAA),
    windowDim: Color(0xFF886655),
    windowLit: Color(0xFFFFE0B0),
    hasNeon: false,
    nightMode: false,
    hasFog: false,
    accentColors: [
      Color(0xFFFF4444),
      Color(0xFFFFFFFF),
      Color(0xFF4488FF),
    ],
    roadTint: Color(0xFF383838),
    kerbA: Color(0xFFDD3333),
    kerbB: Colors.white,
  );

  static const shanghai = LevelTheme(
    id: LevelId.shanghai,
    cityName: 'Shanghai',
    emoji: '🌆',
    scoreStart: 4200,
    skyTop: Color(0xFF1A1A3A),
    skyBottom: Color(0xFF2A2A5A),
    groundNear: Color(0xFF1A2030),
    groundFar: Color(0xFF151828),
    buildingFar: Color(0xFF1E2540),
    buildingMid: Color(0xFF1A2038),
    buildingNear: Color(0xFF151A30),
    buildingHighlight: Color(0xFF252A48),
    windowDim: Color(0xFF0A0E20),
    windowLit: Color(0xFFAADDFF),
    hasNeon: true,
    nightMode: true,
    hasFog: true,
    accentColors: [
      Color(0xFF00AAFF),
      Color(0xFF8844FF),
      Color(0xFF00FFCC),
    ],
    roadTint: Color(0xFF1A1A2E),
    kerbA: Color(0xFF0044AA),
    kerbB: Color(0xFF00AAFF),
  );

  static const List<LevelTheme> all = [newYork, tokyo, dubai, monaco, shanghai];

  // ── Helpers ───────────────────────────────────────────────────────────

  /// Deterministic "random" from an integer seed
  static double rng(int seed) {
    int s = ((seed * 1664525 + 1013904223) & 0x7FFFFFFF);
    s = ((s * 1664525 + 1013904223) & 0x7FFFFFFF);
    return s / 0x7FFFFFFF;
  }

  Color buildingColor(int seed, {bool near = false}) {
    final r = rng(seed);
    if (near) {
      return Color.lerp(buildingNear, buildingHighlight, r * 0.5)!;
    }
    return Color.lerp(buildingFar, buildingMid, r)!;
  }

  Color neonColor(int seed) {
    if (accentColors.isEmpty) return windowLit;
    return accentColors[seed % accentColors.length];
  }
}
