import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../asphalt_game.dart';
import '../car_data.dart';

class PlayerCar extends PositionComponent
    with HasGameReference<AsphaltGame>, CollisionCallbacks {
  final CarData carData;
  int currentLane;

  static const double carW = 54.0;
  static const double carH = 108.0;

  double _targetX = 0;
  bool _isChangingLane = false;
  double _invincibleTimer = 0;
  bool get isInvincible => _invincibleTimer > 0;

  PlayerCar({required this.carData, required int initialLane})
      : currentLane = initialLane,
        super(size: Vector2(carW, carH), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = Vector2(game.getLaneCenter(currentLane), game.size.y - 150);
    _targetX = position.x;
    add(RectangleHitbox(
      size: Vector2(carW * 0.7, carH * 0.82),
      anchor: Anchor.center,
      position: Vector2(carW / 2, carH / 2),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_invincibleTimer > 0) _invincibleTimer -= dt;

    final dx = _targetX - position.x;
    if (dx.abs() > 1) {
      position.x += dx * 7.0 * dt;
    } else {
      position.x = _targetX;
      _isChangingLane = false;
    }
  }

  void moveLeft() {
    if (currentLane > 0 && !_isChangingLane) {
      currentLane--;
      _targetX = game.getLaneCenter(currentLane);
      _isChangingLane = true;
    }
  }

  void moveRight() {
    if (currentLane < AsphaltGame.laneCount - 1 && !_isChangingLane) {
      currentLane++;
      _targetX = game.getLaneCenter(currentLane);
      _isChangingLane = true;
    }
  }

  void hit() {
    _invincibleTimer = 2.5;
    game.loseLife();
  }

  void resetToLane(int lane) {
    currentLane = lane;
    _targetX = game.getLaneCenter(lane);
    position = Vector2(_targetX, game.size.y - 150);
    _invincibleTimer = 0;
    _isChangingLane = false;
  }

  @override
  void render(Canvas canvas) {
    // Blink during invincibility
    if (isInvincible && ((_invincibleTimer * 8).toInt() % 2 == 0)) return;

    switch (carData.type) {
      case CarType.bugattiChiron:
        _drawBugattiChiron(canvas);
      case CarType.lamborghiniUrus:
        _drawLamborghiniUrus(canvas);
      case CarType.ferrariSF90:
        _drawFerrariSF90(canvas);
    }
  }

  // ── Shared helpers ─────────────────────────────────────────────────────

  void _drawWheel(Canvas canvas, Offset c, double r, Color rimColor) {
    // Tyre
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFF111111));
    // Brake disc
    canvas.drawCircle(c, r * 0.74, Paint()..color = const Color(0xFF2E2E2E));
    // Rim fill
    canvas.drawCircle(c, r * 0.65, Paint()..color = rimColor);
    // 5 spokes
    for (int i = 0; i < 5; i++) {
      final a = i * 2 * pi / 5;
      canvas.drawLine(
        Offset(c.dx + cos(a) * r * 0.18, c.dy + sin(a) * r * 0.18),
        Offset(c.dx + cos(a) * r * 0.60, c.dy + sin(a) * r * 0.60),
        Paint()
          ..color = Colors.white60
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      );
    }
    // Hub cap
    canvas.drawCircle(c, r * 0.19, Paint()..color = const Color(0xFF9E9E9E));
  }

  void _glowOval(Canvas canvas, Rect rect, Color color) {
    canvas.drawOval(
      rect.inflate(3),
      Paint()
        ..color = color.withOpacity(0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawOval(rect, Paint()..color = color);
    canvas.drawOval(
      rect.deflate(rect.height * 0.25),
      Paint()..color = Colors.white.withOpacity(0.5),
    );
  }

  void _glowCircle(Canvas canvas, Offset c, double r, Color color) {
    canvas.drawCircle(
      c, r + 3,
      Paint()
        ..color = color.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(c, r, Paint()..color = color);
    canvas.drawCircle(c, r * 0.45, Paint()..color = Colors.white.withOpacity(0.6));
  }

  // ── Bugatti Chiron ─────────────────────────────────────────────────────
  void _drawBugattiChiron(Canvas canvas) {
    const w = carW;
    const h = carH;

    // --- Shadow ---
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, h * 0.52), width: w * 0.85, height: h * 0.82),
      Paint()
        ..color = Colors.black38
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // --- Body path (wide Chiron silhouette) ---
    final body = Path()
      ..moveTo(w * 0.50, h * 0.01)
      ..cubicTo(w * 0.70, h * 0.01, w * 0.94, h * 0.14, w * 0.95, h * 0.36)
      ..cubicTo(w * 0.97, h * 0.50, w * 0.97, h * 0.62, w * 0.93, h * 0.72)
      ..cubicTo(w * 0.88, h * 0.88, w * 0.76, h * 0.97, w * 0.58, h * 0.99)
      ..lineTo(w * 0.42, h * 0.99)
      ..cubicTo(w * 0.24, h * 0.97, w * 0.12, h * 0.88, w * 0.07, h * 0.72)
      ..cubicTo(w * 0.03, h * 0.62, w * 0.03, h * 0.50, w * 0.05, h * 0.36)
      ..cubicTo(w * 0.06, h * 0.14, w * 0.30, h * 0.01, w * 0.50, h * 0.01)
      ..close();

    // Blue front half + carbon rear half
    canvas.save();
    canvas.clipPath(body);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.56),
      Paint()..color = const Color(0xFF1B3A8C),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.44, w, h * 0.56),
      Paint()..color = const Color(0xFF181818),
    );
    // Blend zone
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.42, w, h * 0.18),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF1B3A8C), Color(0xFF181818)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, h * 0.42, w, h * 0.18)),
    );
    // Subtle carbon fibre weave on rear
    for (double cy = h * 0.56; cy < h; cy += 6) {
      canvas.drawLine(
        Offset(0, cy), Offset(w, cy),
        Paint()..color = const Color(0x10FFFFFF)..strokeWidth = 1,
      );
    }
    canvas.restore();

    // Body outline (chrome edge)
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0xFF87CEEB).withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // --- C-shaped side air intakes ---
    _chironIntake(canvas, true, w, h);
    _chironIntake(canvas, false, w, h);

    // --- Front splitter ---
    final splitter = Path()
      ..moveTo(w * 0.30, h * 0.005)
      ..lineTo(w * 0.70, h * 0.005)
      ..lineTo(w * 0.76, h * 0.055)
      ..lineTo(w * 0.24, h * 0.055)
      ..close();
    canvas.drawPath(splitter, Paint()..color = Colors.black87);

    // --- Windshield ---
    final ws = Path()
      ..moveTo(w * 0.28, h * 0.16)
      ..lineTo(w * 0.72, h * 0.16)
      ..lineTo(w * 0.68, h * 0.37)
      ..lineTo(w * 0.32, h * 0.37)
      ..close();
    canvas.drawPath(ws, Paint()..color = const Color(0xBB5BA3D0));
    // Windshield glare streak
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.31, h * 0.17)
        ..lineTo(w * 0.45, h * 0.17)
        ..lineTo(w * 0.40, h * 0.28)
        ..lineTo(w * 0.30, h * 0.28)
        ..close(),
      Paint()..color = Colors.white24,
    );

    // --- Roof panel ---
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.50, h * 0.46), width: w * 0.34, height: h * 0.12),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF0D1A40),
    );

    // --- Rear window ---
    final rw2 = Path()
      ..moveTo(w * 0.30, h * 0.57)
      ..lineTo(w * 0.70, h * 0.57)
      ..lineTo(w * 0.66, h * 0.70)
      ..lineTo(w * 0.34, h * 0.70)
      ..close();
    canvas.drawPath(rw2, Paint()..color = const Color(0xBB3A6080));

    // --- Rear diffuser ---
    final diffuser = Path()
      ..moveTo(w * 0.18, h * 0.955)
      ..lineTo(w * 0.82, h * 0.955)
      ..lineTo(w * 0.80, h * 0.995)
      ..lineTo(w * 0.20, h * 0.995)
      ..close();
    canvas.drawPath(diffuser, Paint()..color = const Color(0xFF252525));
    for (double fx = w * 0.22; fx < w * 0.80; fx += w * 0.086) {
      canvas.drawLine(
        Offset(fx, h * 0.955), Offset(fx, h * 0.995),
        Paint()..color = Colors.black54..strokeWidth = 1.5,
      );
    }

    // --- Headlights (twin circular LED rings) ---
    _glowCircle(canvas, Offset(w * 0.24, h * 0.075), 6.5, const Color(0xFFFFFFDD));
    _glowCircle(canvas, Offset(w * 0.76, h * 0.075), 6.5, const Color(0xFFFFFFDD));
    // Horseshoe grille arc
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.08), width: w * 0.24, height: h * 0.09),
      pi, pi, false,
      Paint()
        ..color = const Color(0xFFD4AF37)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    // --- Taillights ---
    _glowOval(canvas, Rect.fromLTWH(w * 0.10, h * 0.905, w * 0.24, h * 0.042), const Color(0xFFFF2200));
    _glowOval(canvas, Rect.fromLTWH(w * 0.66, h * 0.905, w * 0.24, h * 0.042), const Color(0xFFFF2200));
    // Exhaust pipes
    canvas.drawOval(Rect.fromLTWH(w * 0.17, h * 0.955, w * 0.10, h * 0.022),
        Paint()..color = const Color(0xFF3A3A3A));
    canvas.drawOval(Rect.fromLTWH(w * 0.73, h * 0.955, w * 0.10, h * 0.022),
        Paint()..color = const Color(0xFF3A3A3A));

    // --- Wheels ---
    _drawWheel(canvas, Offset(w * 0.10, h * 0.215), 9.5, const Color(0xFF455A64));
    _drawWheel(canvas, Offset(w * 0.90, h * 0.215), 9.5, const Color(0xFF455A64));
    _drawWheel(canvas, Offset(w * 0.10, h * 0.775), 9.5, const Color(0xFF455A64));
    _drawWheel(canvas, Offset(w * 0.90, h * 0.775), 9.5, const Color(0xFF455A64));

    // --- Bugatti logo badge ---
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.27), width: 9, height: 6),
      Paint()..color = const Color(0xFFD4AF37),
    );
  }

  void _chironIntake(Canvas canvas, bool left, double w, double h) {
    final chrome = Paint()..color = const Color(0xFFB0BEC5);
    final dark = Paint()..color = const Color(0xFF080808);

    final x0 = left ? w * 0.03 : w * 0.97;
    final x1 = left ? w * 0.19 : w * 0.81;
    final sign = left ? 1.0 : -1.0;

    // Outer chrome C shell
    final outer = Path();
    if (left) {
      outer
        ..moveTo(x1, h * 0.29)
        ..cubicTo(x0 + 2, h * 0.32, x0, h * 0.44, x0, h * 0.50)
        ..cubicTo(x0, h * 0.57, x0 + 2, h * 0.69, x1, h * 0.72)
        ..lineTo(x1, h * 0.65)
        ..cubicTo(x0 + sign * 7, h * 0.63, x0 + sign * 6, h * 0.55, x0 + sign * 6, h * 0.50)
        ..cubicTo(x0 + sign * 6, h * 0.45, x0 + sign * 7, h * 0.37, x1, h * 0.35)
        ..close();
    } else {
      outer
        ..moveTo(x1, h * 0.29)
        ..cubicTo(x0 - 2, h * 0.32, x0, h * 0.44, x0, h * 0.50)
        ..cubicTo(x0, h * 0.57, x0 - 2, h * 0.69, x1, h * 0.72)
        ..lineTo(x1, h * 0.65)
        ..cubicTo(x0 - 7, h * 0.63, x0 - 6, h * 0.55, x0 - 6, h * 0.50)
        ..cubicTo(x0 - 6, h * 0.45, x0 - 7, h * 0.37, x1, h * 0.35)
        ..close();
    }
    canvas.drawPath(outer, chrome);

    // Dark mesh opening
    final mesh = Path();
    if (left) {
      mesh
        ..moveTo(x1 - 1, h * 0.32)
        ..lineTo(x1 - 1, h * 0.68)
        ..lineTo(x0 + 8, h * 0.62)
        ..cubicTo(x0 + 5, h * 0.55, x0 + 5, h * 0.45, x0 + 8, h * 0.38)
        ..close();
    } else {
      mesh
        ..moveTo(x1 + 1, h * 0.32)
        ..lineTo(x1 + 1, h * 0.68)
        ..lineTo(x0 - 8, h * 0.62)
        ..cubicTo(x0 - 5, h * 0.55, x0 - 5, h * 0.45, x0 - 8, h * 0.38)
        ..close();
    }
    canvas.drawPath(mesh, dark);
  }

  // ── Lamborghini Urus ───────────────────────────────────────────────────
  void _drawLamborghiniUrus(Canvas canvas) {
    const w = carW;
    const h = carH;

    // --- Shadow ---
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, h * 0.52), width: w * 0.92, height: h * 0.84),
      Paint()
        ..color = Colors.black38
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // --- Body (boxy angular SUV) ---
    final body = Path()
      ..moveTo(w * 0.22, h * 0.04)
      ..lineTo(w * 0.78, h * 0.04)
      ..cubicTo(w * 0.94, h * 0.08, w * 0.99, h * 0.18, w * 0.97, h * 0.38)
      ..lineTo(w * 0.97, h * 0.74)
      ..cubicTo(w * 0.97, h * 0.88, w * 0.86, h * 0.97, w * 0.70, h * 0.98)
      ..lineTo(w * 0.30, h * 0.98)
      ..cubicTo(w * 0.14, h * 0.97, w * 0.03, h * 0.88, w * 0.03, h * 0.74)
      ..lineTo(w * 0.03, h * 0.38)
      ..cubicTo(w * 0.01, h * 0.18, w * 0.06, h * 0.08, w * 0.22, h * 0.04)
      ..close();

    canvas.save();
    canvas.clipPath(body);

    // Orange main body
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFE8620A),
    );
    // Black roof panel
    canvas.drawRect(
      Rect.fromLTWH(w * 0.16, h * 0.04, w * 0.68, h * 0.48),
      Paint()..color = const Color(0xFF111111),
    );
    // Subtle metallic sheen on sides
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.38, w * 0.06, h * 0.40),
      Paint()..color = Colors.white10,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.94, h * 0.38, w * 0.06, h * 0.40),
      Paint()..color = Colors.white10,
    );
    canvas.restore();

    // Body outline
    canvas.drawPath(
      body,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // --- Angular body crease lines ---
    canvas.drawLine(
      Offset(w * 0.07, h * 0.38), Offset(w * 0.93, h * 0.38),
      Paint()..color = Colors.black38..strokeWidth = 1.5,
    );
    // Side door crease
    canvas.drawLine(
      Offset(w * 0.04, h * 0.50), Offset(w * 0.96, h * 0.50),
      Paint()..color = Colors.white12..strokeWidth = 0.8,
    );

    // --- Windshield (panoramic) ---
    final ws = Path()
      ..moveTo(w * 0.18, h * 0.07)
      ..lineTo(w * 0.82, h * 0.07)
      ..lineTo(w * 0.78, h * 0.32)
      ..lineTo(w * 0.22, h * 0.32)
      ..close();
    canvas.drawPath(ws, Paint()..color = const Color(0xBB4A7090));
    // Glare
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.21, h * 0.08)
        ..lineTo(w * 0.42, h * 0.08)
        ..lineTo(w * 0.38, h * 0.20)
        ..lineTo(w * 0.21, h * 0.20)
        ..close(),
      Paint()..color = Colors.white.withOpacity(0.20),
    );

    // --- Rear window ---
    final rwp = Path()
      ..moveTo(w * 0.22, h * 0.53)
      ..lineTo(w * 0.78, h * 0.53)
      ..lineTo(w * 0.74, h * 0.70)
      ..lineTo(w * 0.26, h * 0.70)
      ..close();
    canvas.drawPath(rwp, Paint()..color = const Color(0xBB3A5570));

    // --- Y-shaped DRL headlights ---
    _urusHeadlight(canvas, true, w, h);
    _urusHeadlight(canvas, false, w, h);

    // --- LED taillight strip ---
    _glowOval(canvas, Rect.fromLTWH(w * 0.08, h * 0.905, w * 0.28, h * 0.038),
        const Color(0xFFFF1100));
    _glowOval(canvas, Rect.fromLTWH(w * 0.64, h * 0.905, w * 0.28, h * 0.038),
        const Color(0xFFFF1100));
    // Center connecting thin strip
    canvas.drawRect(
      Rect.fromLTWH(w * 0.36, h * 0.917, w * 0.28, h * 0.012),
      Paint()..color = const Color(0xFFFF1100).withOpacity(0.5),
    );

    // --- Roof rails ---
    canvas.drawLine(
      Offset(w * 0.25, h * 0.06), Offset(w * 0.25, h * 0.50),
      Paint()..color = Colors.white24..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(w * 0.75, h * 0.06), Offset(w * 0.75, h * 0.50),
      Paint()..color = Colors.white24..strokeWidth = 1.5,
    );

    // --- Lamborghini badge ---
    canvas.drawRect(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.26), width: 11, height: 8),
      Paint()..color = const Color(0xFFD4AF37),
    );

    // --- Wheels (wider for SUV) ---
    _drawWheel(canvas, Offset(w * 0.09, h * 0.20), 10.5, const Color(0xFF37474F));
    _drawWheel(canvas, Offset(w * 0.91, h * 0.20), 10.5, const Color(0xFF37474F));
    _drawWheel(canvas, Offset(w * 0.09, h * 0.78), 10.5, const Color(0xFF37474F));
    _drawWheel(canvas, Offset(w * 0.91, h * 0.78), 10.5, const Color(0xFF37474F));
  }

  void _urusHeadlight(Canvas canvas, bool left, double w, double h) {
    final paint = Paint()
      ..color = const Color(0xFFFFFFCC)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final cx = left ? w * 0.20 : w * 0.80;

    // Y shape: vertical stem + two angled arms
    canvas.drawLine(
      Offset(cx, h * 0.065), Offset(cx, h * 0.035),
      Paint()..color = const Color(0xFFFFFFCC)..strokeWidth = 2.5..strokeCap = StrokeCap.round,
    );
    final dir = left ? -1 : 1;
    canvas.drawLine(
      Offset(cx, h * 0.047),
      Offset(cx - dir * w * 0.08, h * 0.025),
      Paint()..color = const Color(0xFFFFFFCC)..strokeWidth = 2.0..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(cx, h * 0.047),
      Offset(cx + dir * w * 0.08, h * 0.025),
      Paint()..color = const Color(0xFFFFFFCC)..strokeWidth = 2.0..strokeCap = StrokeCap.round,
    );
    // Glow behind
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.045), width: w * 0.18, height: h * 0.055),
      paint,
    );
  }

  // ── Ferrari SF90 ───────────────────────────────────────────────────────
  void _drawFerrariSF90(Canvas canvas) {
    const w = carW;
    const h = carH;

    // --- Shadow ---
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, h * 0.52), width: w * 0.82, height: h * 0.80),
      Paint()
        ..color = Colors.black38
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // --- Body (sleek pointed nose) ---
    final body = Path()
      ..moveTo(w * 0.50, h * 0.005)
      ..cubicTo(w * 0.70, h * 0.01, w * 0.93, h * 0.14, w * 0.93, h * 0.40)
      ..cubicTo(w * 0.95, h * 0.56, w * 0.92, h * 0.72, w * 0.88, h * 0.82)
      ..cubicTo(w * 0.82, h * 0.94, w * 0.70, h * 0.99, w * 0.54, h * 0.995)
      ..lineTo(w * 0.46, h * 0.995)
      ..cubicTo(w * 0.30, h * 0.99, w * 0.18, h * 0.94, w * 0.12, h * 0.82)
      ..cubicTo(w * 0.08, h * 0.72, w * 0.05, h * 0.56, w * 0.07, h * 0.40)
      ..cubicTo(w * 0.07, h * 0.14, w * 0.30, h * 0.01, w * 0.50, h * 0.005)
      ..close();

    canvas.save();
    canvas.clipPath(body);

    // Ferrari red main body
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFCC0000),
    );
    // Black roof
    canvas.drawRect(
      Rect.fromLTWH(w * 0.24, h * 0.14, w * 0.52, h * 0.44),
      Paint()..color = const Color(0xFF101010),
    );
    // Subtle metallic highlight on bodywork flanks
    canvas.drawRect(
      Rect.fromLTWH(w * 0.07, h * 0.30, w * 0.04, h * 0.38),
      Paint()..color = Colors.white10,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.89, h * 0.30, w * 0.04, h * 0.38),
      Paint()..color = Colors.white10,
    );
    canvas.restore();

    // Body outline
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0xFF880000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // --- Gold central spine stripe ---
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.50, h * 0.50), width: 3.5, height: h * 0.62),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFD4AF37),
    );

    // --- NACA hood ducts (two small scoops on hood) ---
    for (final dx in [w * 0.38, w * 0.62]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(dx, h * 0.12), width: 6, height: 9),
        Paint()..color = const Color(0xFF880000),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(dx, h * 0.12), width: 4, height: 7),
        Paint()..color = Colors.black87,
      );
    }

    // --- Side skirts ---
    canvas.drawRect(
      Rect.fromLTWH(w * 0.07, h * 0.42, w * 0.055, h * 0.34),
      Paint()..color = Colors.black54,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.875, h * 0.42, w * 0.055, h * 0.34),
      Paint()..color = Colors.black54,
    );

    // --- Windshield ---
    final ws = Path()
      ..moveTo(w * 0.27, h * 0.15)
      ..lineTo(w * 0.73, h * 0.15)
      ..lineTo(w * 0.70, h * 0.37)
      ..lineTo(w * 0.30, h * 0.37)
      ..close();
    canvas.drawPath(ws, Paint()..color = const Color(0xBB3D7DA8));
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.29, h * 0.16)
        ..lineTo(w * 0.43, h * 0.16)
        ..lineTo(w * 0.39, h * 0.27)
        ..lineTo(w * 0.29, h * 0.27)
        ..close(),
      Paint()..color = Colors.white.withOpacity(0.20),
    );

    // --- Rear window ---
    final rwp = Path()
      ..moveTo(w * 0.29, h * 0.57)
      ..lineTo(w * 0.71, h * 0.57)
      ..lineTo(w * 0.67, h * 0.70)
      ..lineTo(w * 0.33, h * 0.70)
      ..close();
    canvas.drawPath(rwp, Paint()..color = const Color(0xBB2A5070));

    // --- Sharp blade headlights ---
    _ferrariHeadlight(canvas, true, w, h);
    _ferrariHeadlight(canvas, false, w, h);

    // --- Quad round taillights ---
    for (final pos in [
      Offset(w * 0.21, h * 0.915),
      Offset(w * 0.33, h * 0.912),
      Offset(w * 0.67, h * 0.912),
      Offset(w * 0.79, h * 0.915),
    ]) {
      _glowCircle(canvas, pos, 4.5, const Color(0xFFFF2200));
    }
    // Connect inner pair with thin strip
    canvas.drawRect(
      Rect.fromLTWH(w * 0.34, h * 0.918, w * 0.32, h * 0.010),
      Paint()..color = const Color(0xFFFF2200).withOpacity(0.5),
    );

    // --- Dual exhausts ---
    canvas.drawOval(Rect.fromLTWH(w * 0.26, h * 0.955, w * 0.12, h * 0.024),
        Paint()..color = const Color(0xFF2A2A2A));
    canvas.drawOval(Rect.fromLTWH(w * 0.62, h * 0.955, w * 0.12, h * 0.024),
        Paint()..color = const Color(0xFF2A2A2A));

    // --- Prancing horse badge ---
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.27), width: 8, height: 10),
      Paint()..color = const Color(0xFFD4AF37),
    );

    // --- Wheels ---
    _drawWheel(canvas, Offset(w * 0.10, h * 0.21), 9.0, const Color(0xFF212121));
    _drawWheel(canvas, Offset(w * 0.90, h * 0.21), 9.0, const Color(0xFF212121));
    _drawWheel(canvas, Offset(w * 0.10, h * 0.77), 9.0, const Color(0xFF212121));
    _drawWheel(canvas, Offset(w * 0.90, h * 0.77), 9.0, const Color(0xFF212121));
  }

  void _ferrariHeadlight(Canvas canvas, bool left, double w, double h) {
    final cx = left ? w * 0.27 : w * 0.73;
    final tipX = left ? w * 0.50 : w * 0.50;
    final outerX = left ? w * 0.10 : w * 0.90;

    // Sharp blade shape
    final blade = Path()
      ..moveTo(tipX, h * 0.025)
      ..lineTo(cx, h * 0.07)
      ..lineTo(outerX, h * 0.10)
      ..lineTo(outerX, h * 0.065)
      ..close();
    canvas.drawPath(
      blade,
      Paint()
        ..color = const Color(0xFFFFFFDD)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawPath(blade, Paint()..color = const Color(0xFFFFFFDD));
  }
}
