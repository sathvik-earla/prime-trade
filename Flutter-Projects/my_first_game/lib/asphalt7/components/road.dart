import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../asphalt_game.dart';
import '../level_theme.dart';

class Road extends Component with HasGameReference<AsphaltGame> {
  double _dashOffset = 0;
  double _nearBldgOffset = 0;   // fast layer
  double _farBldgOffset = 0;    // slow layer

  static const double _dashLen = 42.0;
  static const double _dashGap = 32.0;

  // Deterministic hash → [0,1)
  static double _rng(int seed) {
    int s = (seed * 1664525 + 1013904223) & 0x7FFFFFFF;
    s = (s * 1664525 + 1013904223) & 0x7FFFFFFF;
    return s / 0x7FFFFFFF;
  }

  @override
  void update(double dt) {
    final s = game.speed * dt;
    _dashOffset = (_dashOffset + s) % (_dashLen + _dashGap);
    _nearBldgOffset += s * 0.55;
    _farBldgOffset  += s * 0.22;
  }

  @override
  void render(Canvas canvas) {
    final g = game;
    final sw = g.size.x;
    final sh = g.size.y;
    final rl = g.roadLeft;
    final rw = g.roadWidth;
    final lw = g.laneWidth;
    final theme = g.currentTheme;

    _drawSky(canvas, sw, sh, theme);
    _drawFarBuildings(canvas, sw, sh, rl, rw, theme);
    _drawGround(canvas, sw, sh, rl, rw, theme);
    _drawNearBuildings(canvas, sw, sh, rl, rw, theme);
    _drawKerbs(canvas, sh, rl, rw, theme);
    _drawRoadSurface(canvas, sh, rl, rw, theme);
    _drawLaneMarkings(canvas, sh, rl, lw);
    _drawRoadEdges(canvas, sh, rl, rw, theme);
    if (theme.hasFog) _drawFog(canvas, sw, sh, theme);
  }

  // ── Sky ────────────────────────────────────────────────────────────────

  void _drawSky(Canvas canvas, double sw, double sh, LevelTheme theme) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, sw, sh * 0.45),
      Paint()
        ..shader = LinearGradient(
          colors: [theme.skyTop, theme.skyBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, sw, sh * 0.45)),
    );
    // Stars for night themes
    if (theme.nightMode) {
      final starPaint = Paint()..color = Colors.white70;
      for (int i = 0; i < 60; i++) {
        final sx = _rng(i * 31 + 7) * sw;
        final sy = _rng(i * 17 + 3) * sh * 0.38;
        final sr = _rng(i * 53 + 11) * 1.5 + 0.5;
        canvas.drawCircle(Offset(sx, sy), sr, starPaint);
      }
    }
  }

  // ── Far buildings (silhouettes, slow parallax) ──────────────────────────

  void _drawFarBuildings(Canvas canvas, double sw, double sh,
      double rl, double rw, LevelTheme theme) {
    const bldgW = 38.0;
    const spacing = 42.0;
    const maxH = 0.30; // fraction of screen height
    const baseY = 0.40; // horizon line

    final leftEdge = rl - 6;
    final rightStart = rl + rw + 6;
    final totalW = sw;

    void drawStrip(double startX, double endX, int seed) {
      int idx = 0;
      double x = startX - (_farBldgOffset % (spacing * 12));
      while (x < endX + spacing) {
        if (x + bldgW > startX && x < endX) {
          final h = (_rng(seed + idx * 7) * maxH + 0.08) * sh;
          final w = _rng(seed + idx * 13) * 16 + 28;
          final col = theme.buildingColor(seed + idx);
          final rect = Rect.fromLTWH(x, sh * baseY - h, w, h);
          canvas.drawRect(rect, Paint()..color = col);
          // Simple top edge highlight
          canvas.drawRect(
            Rect.fromLTWH(x, sh * baseY - h, w, 2),
            Paint()..color = theme.buildingHighlight.withOpacity(0.5),
          );
        }
        x += spacing + _rng(seed + idx * 19) * 10;
        idx++;
      }
    }

    drawStrip(0, leftEdge, 1001);
    drawStrip(rightStart, totalW, 2002);
  }

  // ── Ground / environment sides ─────────────────────────────────────────

  void _drawGround(Canvas canvas, double sw, double sh,
      double rl, double rw, LevelTheme theme) {
    // Left band
    canvas.drawRect(
      Rect.fromLTWH(0, 0, rl, sh),
      Paint()
        ..shader = LinearGradient(
          colors: [theme.groundFar, theme.groundNear],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(0, 0, rl, sh)),
    );
    // Right band
    canvas.drawRect(
      Rect.fromLTWH(rl + rw, 0, sw - rl - rw, sh),
      Paint()
        ..shader = LinearGradient(
          colors: [theme.groundNear, theme.groundFar],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(rl + rw, 0, sw - rl - rw, sh)),
    );
  }

  // ── Near buildings ─────────────────────────────────────────────────────

  void _drawNearBuildings(Canvas canvas, double sw, double sh,
      double rl, double rw, LevelTheme theme) {
    const spacing = 68.0;
    const cols = 14;

    // Left side — buildings flush against road
    for (int i = 0; i < cols; i++) {
      final yBase = (i * spacing - _nearBldgOffset % (spacing * cols));
      _drawBuilding(canvas, theme, i * 3 + 10,
          x: 0,
          y: yBase,
          maxW: rl - 8,
          sh: sh,
          alignRight: true);
    }

    // Right side
    for (int i = 0; i < cols; i++) {
      final yBase = (i * spacing + spacing * 0.5 - _nearBldgOffset % (spacing * cols));
      _drawBuilding(canvas, theme, i * 3 + 100,
          x: rl + rw + 8,
          y: yBase,
          maxW: sw - rl - rw - 8,
          sh: sh,
          alignRight: false);
    }
  }

  void _drawBuilding(
    Canvas canvas,
    LevelTheme theme,
    int seed, {
    required double x,
    required double y,
    required double maxW,
    required double sh,
    required bool alignRight,
  }) {
    final bW = (_rng(seed) * maxW * 0.45 + maxW * 0.35).clamp(18.0, maxW);
    final bH = (_rng(seed + 1) * sh * 0.38 + sh * 0.12).clamp(50.0, sh * 0.55);
    final bX = alignRight ? (x + maxW - bW) : x;
    final bY = y - bH;

    if (bY > sh || bY + bH < -20) return;

    final bodyColor = theme.buildingColor(seed, near: true);
    final rect = Rect.fromLTWH(bX, bY, bW, bH);

    // Body with vertical gradient for depth
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            bodyColor.withOpacity(0.9),
            bodyColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect),
    );

    // Roof line highlight
    canvas.drawRect(
      Rect.fromLTWH(bX, bY, bW, 2.5),
      Paint()..color = theme.buildingHighlight.withOpacity(0.6),
    );

    // Side shading (one side slightly darker)
    canvas.drawRect(
      Rect.fromLTWH(alignRight ? bX : bX + bW - 4, bY, 4, bH),
      Paint()..color = Colors.black26,
    );

    // Windows
    _drawWindows(canvas, theme, seed, bX, bY, bW, bH);

    // Theme-specific rooftop details
    _drawRooftop(canvas, theme, seed, bX, bY, bW);

    // Neon signs for Tokyo / Shanghai
    if (theme.hasNeon) {
      _drawNeonSign(canvas, theme, seed, bX, bY, bW, bH);
    }
  }

  void _drawWindows(Canvas canvas, LevelTheme theme, int seed,
      double bX, double bY, double bW, double bH) {
    const wW = 4.0;
    const wH = 5.5;
    const gapX = 7.0;
    const gapY = 9.0;
    const margin = 5.0;

    int row = 0;
    double wy = bY + margin;
    while (wy + wH < bY + bH - margin) {
      int col = 0;
      double wx = bX + margin;
      while (wx + wW < bX + bW - margin) {
        final isLit = _rng(seed * 31 + row * 17 + col * 7) > 0.35;
        final flicker = theme.nightMode &&
            _rng(seed * 43 + row * 23 + col * 11) > 0.92;
        canvas.drawRect(
          Rect.fromLTWH(wx, wy, wW, wH),
          Paint()
            ..color = flicker
                ? theme.neonColor(seed + row)
                : (isLit ? theme.windowLit : theme.windowDim),
        );
        wx += wW + gapX;
        col++;
      }
      wy += wH + gapY;
      row++;
    }
  }

  void _drawRooftop(Canvas canvas, LevelTheme theme, int seed,
      double bX, double bY, double bW) {
    final variant = (seed % 5);
    final accentPaint = Paint()..color = theme.buildingHighlight;

    switch (theme.id) {
      case LevelId.dubai:
        // Pointed arch / minaret tip
        if (variant == 0) {
          final path = Path()
            ..moveTo(bX + bW / 2, bY - 18)
            ..lineTo(bX + bW * 0.3, bY)
            ..lineTo(bX + bW * 0.7, bY)
            ..close();
          canvas.drawPath(path, accentPaint);
          // Crescent
          canvas.drawArc(
            Rect.fromCenter(
                center: Offset(bX + bW / 2, bY - 16), width: 8, height: 8),
            0, pi, false,
            Paint()
              ..color = const Color(0xFFD4AF37)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
        } else if (variant == 1) {
          // Flat modern with gold band
          canvas.drawRect(
            Rect.fromLTWH(bX, bY - 4, bW, 4),
            Paint()..color = const Color(0xFFD4AF37),
          );
        } else {
          // Glass pyramid top
          final path = Path()
            ..moveTo(bX + bW / 2, bY - 12)
            ..lineTo(bX + bW * 0.2, bY)
            ..lineTo(bX + bW * 0.8, bY)
            ..close();
          canvas.drawPath(path,
              Paint()..color = theme.buildingHighlight.withOpacity(0.7));
        }

      case LevelId.monaco:
        // Terracotta / colorful rooftop
        final colors = [
          const Color(0xFFCC4444),
          const Color(0xFF8B4513),
          const Color(0xFFDDAA66),
        ];
        canvas.drawRect(
          Rect.fromLTWH(bX, bY - 5, bW, 5),
          Paint()..color = colors[seed % colors.length],
        );
        // Small chimney
        if (variant < 2) {
          canvas.drawRect(
            Rect.fromLTWH(bX + bW * 0.3, bY - 12, 5, 7),
            Paint()..color = colors[0],
          );
        }

      case LevelId.newYork:
        // Water tower
        if (variant == 0) {
          canvas.drawOval(
            Rect.fromLTWH(bX + bW * 0.5 - 5, bY - 12, 10, 12),
            Paint()..color = const Color(0xFF5D4037),
          );
          canvas.drawRect(
            Rect.fromLTWH(bX + bW * 0.5 - 3, bY - 14, 6, 3),
            Paint()..color = const Color(0xFF3E2723),
          );
        }
        // Antenna
        if (variant <= 2) {
          canvas.drawLine(
            Offset(bX + bW / 2, bY),
            Offset(bX + bW / 2, bY - 14),
            Paint()..color = Colors.grey..strokeWidth = 1.5,
          );
        }

      case LevelId.tokyo:
      case LevelId.shanghai:
        // Communication tower / antenna with blinking light
        canvas.drawLine(
          Offset(bX + bW / 2, bY),
          Offset(bX + bW / 2, bY - 20),
          Paint()..color = Colors.grey[600]!..strokeWidth = 1.5,
        );
        // Red blink light at top
        canvas.drawCircle(
          Offset(bX + bW / 2, bY - 21),
          2.5,
          Paint()
            ..color = const Color(0xFFFF2200)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
    }
  }

  void _drawNeonSign(Canvas canvas, LevelTheme theme, int seed,
      double bX, double bY, double bW, double bH) {
    if (_rng(seed * 37) < 0.5) return; // not every building

    final color = theme.neonColor(seed);
    final signY = bY + bH * (_rng(seed * 29) * 0.4 + 0.1);
    final signW = bW * 0.7;
    final signH = 7.0;
    final signX = bX + (bW - signW) / 2;

    // Glow
    canvas.drawRect(
      Rect.fromLTWH(signX - 2, signY - 2, signW + 4, signH + 4),
      Paint()
        ..color = color.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Sign body
    canvas.drawRect(
      Rect.fromLTWH(signX, signY, signW, signH),
      Paint()..color = color.withOpacity(0.9),
    );
    // Inner bright strip
    canvas.drawRect(
      Rect.fromLTWH(signX + 2, signY + 2, signW - 4, signH - 4),
      Paint()..color = Colors.white.withOpacity(0.3),
    );
  }

  // ── Kerbs ──────────────────────────────────────────────────────────────

  void _drawKerbs(Canvas canvas, double sh, double rl, double rw,
      LevelTheme theme) {
    const kW = 8.0;
    const kLen = 18.0;
    for (final kx in [rl - kW, rl + rw]) {
      double y = -(_dashOffset % (kLen * 2));
      bool first = true;
      while (y < sh) {
        canvas.drawRect(
          Rect.fromLTWH(kx, y, kW, kLen),
          Paint()..color = first ? theme.kerbA : theme.kerbB,
        );
        y += kLen;
        first = !first;
      }
    }
  }

  // ── Road surface ────────────────────────────────────────────────────────

  void _drawRoadSurface(Canvas canvas, double sh, double rl, double rw,
      LevelTheme theme) {
    canvas.drawRect(
      Rect.fromLTWH(rl, 0, rw, sh),
      Paint()
        ..shader = LinearGradient(
          colors: [
            theme.roadTint.withOpacity(0.85),
            theme.roadTint,
            theme.roadTint.withOpacity(0.85),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(rl, 0, rw, sh)),
    );

    // Subtle surface texture
    final tex = Paint()..color = Colors.white.withOpacity(0.04)..strokeWidth = 1;
    double ty = -(_dashOffset % 16);
    while (ty < sh) {
      canvas.drawLine(Offset(rl, ty), Offset(rl + rw, ty), tex);
      ty += 16;
    }

    // Edge vignette
    canvas.drawRect(
      Rect.fromLTWH(rl, 0, 20, sh),
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.black26, Colors.transparent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(rl, 0, 20, sh)),
    );
    canvas.drawRect(
      Rect.fromLTWH(rl + rw - 20, 0, 20, sh),
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.transparent, Colors.black26],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(rl + rw - 20, 0, 20, sh)),
    );
  }

  // ── Lane markings ───────────────────────────────────────────────────────

  void _drawLaneMarkings(Canvas canvas, double sh, double rl, double lw) {
    final dashPaint = Paint()
      ..color = Colors.white60
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    for (int i = 1; i < AsphaltGame.laneCount; i++) {
      final x = rl + lw * i;
      double y = -_dashOffset;
      while (y < sh) {
        canvas.drawLine(Offset(x, y), Offset(x, y + _dashLen), dashPaint);
        y += _dashLen + _dashGap;
      }
    }
  }

  // ── Road edges ──────────────────────────────────────────────────────────

  void _drawRoadEdges(Canvas canvas, double sh, double rl, double rw,
      LevelTheme theme) {
    final p = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 3.0;
    canvas.drawLine(Offset(rl + 1.5, 0), Offset(rl + 1.5, sh), p);
    canvas.drawLine(Offset(rl + rw - 1.5, 0), Offset(rl + rw - 1.5, sh), p);
  }

  // ── Fog overlay ─────────────────────────────────────────────────────────

  void _drawFog(Canvas canvas, double sw, double sh, LevelTheme theme) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, sw, sh),
      Paint()
        ..shader = LinearGradient(
          colors: [
            theme.skyTop.withOpacity(0.0),
            theme.skyTop.withOpacity(0.18),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ).createShader(Rect.fromLTWH(0, 0, sw, sh)),
    );
  }
}
