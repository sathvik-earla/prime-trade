import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../asphalt_game.dart';
import 'player_car.dart';

class TrafficCar extends PositionComponent
    with HasGameReference<AsphaltGame>, CollisionCallbacks {
  final int lane;
  final String trafficType;

  static const double carW = 50.0;
  static const double carH = 100.0;

  late double _ownSpeed;
  late Color _bodyColor;
  late Color _roofColor;

  static final _rng = Random();
  static const _palette = [
    Color(0xFF1565C0), Color(0xFF558B2F), Color(0xFF6A1B9A),
    Color(0xFFBF360C), Color(0xFF37474F), Color(0xFFC62828),
    Color(0xFF00695C), Color(0xFF827717), Color(0xFF4A148C),
    Color(0xFF01579B), Color(0xFF33691E), Color(0xFF880E4F),
  ];

  TrafficCar({required this.lane, required this.trafficType})
      : super(size: Vector2(carW, carH), anchor: Anchor.center) {
    _ownSpeed = 80 + _rng.nextDouble() * 130;
    _bodyColor = _palette[_rng.nextInt(_palette.length)];
    _roofColor = _palette[_rng.nextInt(_palette.length)];
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = Vector2(game.getLaneCenter(lane), -carH / 2 - 10);
    add(RectangleHitbox(
      size: Vector2(carW * 0.72, carH * 0.84),
      anchor: Anchor.center,
      position: Vector2(carW / 2, carH / 2),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += (game.speed - _ownSpeed) * dt;
    if (position.y > game.size.y + carH) removeFromParent();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other.parent is PlayerCar) {
      final player = other.parent as PlayerCar;
      if (!player.isInvincible) player.hit();
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  void _wheel(Canvas canvas, Offset c, double r) {
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFF111111));
    canvas.drawCircle(c, r * 0.65, Paint()..color = const Color(0xFF444444));
    canvas.drawCircle(c, r * 0.28, Paint()..color = const Color(0xFF888888));
  }

  void _glass(Canvas canvas, Path path) {
    canvas.drawPath(path, Paint()..color = const Color(0xAA3A6080));
    // Glare streak
    final bounds = path.getBounds();
    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(
      Rect.fromLTWH(bounds.left, bounds.top, bounds.width * 0.4, bounds.height),
      Paint()..color = Colors.white.withOpacity(0.15),
    );
    canvas.restore();
  }

  void _taillight(Canvas canvas, Rect rect) {
    canvas.drawRect(
      rect.inflate(2),
      Paint()
        ..color = const Color(0xFFFF2200).withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRect(rect, Paint()..color = const Color(0xFFFF2200));
    canvas.drawRect(rect.deflate(rect.shortestSide * 0.3),
        Paint()..color = const Color(0xFFFF7755));
  }

  void _headlight(Canvas canvas, Rect rect) {
    canvas.drawRect(
      rect.inflate(2),
      Paint()
        ..color = const Color(0xFFFFFFCC).withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawRect(rect, Paint()..color = const Color(0xFFFFFFCC));
  }

  // ── Render ───────────────────────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    switch (trafficType) {
      case 'truck':
        _drawTruck(canvas);
      case 'suv':
        _drawSuv(canvas);
      case 'hatchback':
        _drawHatchback(canvas);
      case 'sports':
        _drawSports(canvas);
      default:
        _drawSedan(canvas);
    }
  }

  void _drawSedan(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, h * 0.52), width: w * 0.84, height: h * 0.80),
      Paint()..color = Colors.black26..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Body
    final body = Path()
      ..moveTo(w * 0.50, h * 0.02)
      ..cubicTo(w * 0.78, h * 0.04, w * 0.93, h * 0.16, w * 0.92, h * 0.42)
      ..cubicTo(w * 0.93, h * 0.68, w * 0.82, h * 0.92, w * 0.55, h * 0.97)
      ..lineTo(w * 0.45, h * 0.97)
      ..cubicTo(w * 0.18, h * 0.92, w * 0.07, h * 0.68, w * 0.08, h * 0.42)
      ..cubicTo(w * 0.07, h * 0.16, w * 0.22, h * 0.04, w * 0.50, h * 0.02)
      ..close();
    canvas.drawPath(body, Paint()..color = _bodyColor);

    // Roof
    canvas.save();
    canvas.clipPath(body);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.18, h * 0.20, w * 0.64, h * 0.42),
        const Radius.circular(4),
      ),
      Paint()..color = _roofColor.withOpacity(0.75),
    );
    canvas.restore();

    // Windshield
    _glass(canvas, Path()
      ..moveTo(w * 0.25, h * 0.175)
      ..lineTo(w * 0.75, h * 0.175)
      ..lineTo(w * 0.71, h * 0.365)
      ..lineTo(w * 0.29, h * 0.365)
      ..close());

    // Rear window
    _glass(canvas, Path()
      ..moveTo(w * 0.27, h * 0.555)
      ..lineTo(w * 0.73, h * 0.555)
      ..lineTo(w * 0.69, h * 0.695)
      ..lineTo(w * 0.31, h * 0.695)
      ..close());

    // Headlights (front/top — faces away from player)
    _headlight(canvas, Rect.fromLTWH(w * 0.12, h * 0.025, w * 0.22, h * 0.042));
    _headlight(canvas, Rect.fromLTWH(w * 0.66, h * 0.025, w * 0.22, h * 0.042));

    // Taillights (rear/bottom — faces player)
    _taillight(canvas, Rect.fromLTWH(w * 0.10, h * 0.905, w * 0.24, h * 0.038));
    _taillight(canvas, Rect.fromLTWH(w * 0.66, h * 0.905, w * 0.24, h * 0.038));

    // Body outline
    canvas.drawPath(body,
        Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 0.8);

    // Wheels
    _wheel(canvas, Offset(w * 0.11, h * 0.21), 9.0);
    _wheel(canvas, Offset(w * 0.89, h * 0.21), 9.0);
    _wheel(canvas, Offset(w * 0.11, h * 0.77), 9.0);
    _wheel(canvas, Offset(w * 0.89, h * 0.77), 9.0);
  }

  void _drawTruck(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, h * 0.52), width: w * 0.9, height: h * 0.85),
      Paint()..color = Colors.black26..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Cargo box (rear/top section)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.06, h * 0.04, w * 0.88, h * 0.58),
        const Radius.circular(3),
      ),
      Paint()..color = _bodyColor,
    );
    // Cargo texture lines
    for (double cy = h * 0.12; cy < h * 0.60; cy += h * 0.07) {
      canvas.drawLine(
        Offset(w * 0.08, cy), Offset(w * 0.92, cy),
        Paint()..color = Colors.black12..strokeWidth = 1,
      );
    }
    // Cargo door outline
    canvas.drawRect(
      Rect.fromLTWH(w * 0.12, h * 0.06, w * 0.76, h * 0.54),
      Paint()..color = Colors.black12..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );

    // Cab (front/bottom section)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.62, w * 0.84, h * 0.30),
        const Radius.circular(3),
      ),
      Paint()..color = _bodyColor.withOpacity(0.9),
    );

    // Cab windshield
    _glass(canvas, Path()
      ..moveTo(w * 0.18, h * 0.635)
      ..lineTo(w * 0.82, h * 0.635)
      ..lineTo(w * 0.78, h * 0.755)
      ..lineTo(w * 0.22, h * 0.755)
      ..close());

    // Headlights
    _headlight(canvas, Rect.fromLTWH(w * 0.08, h * 0.038, w * 0.22, h * 0.040));
    _headlight(canvas, Rect.fromLTWH(w * 0.70, h * 0.038, w * 0.22, h * 0.040));

    // Taillights
    _taillight(canvas, Rect.fromLTWH(w * 0.08, h * 0.885, w * 0.26, h * 0.038));
    _taillight(canvas, Rect.fromLTWH(w * 0.66, h * 0.885, w * 0.26, h * 0.038));

    // Wheels (larger)
    _wheel(canvas, Offset(w * 0.10, h * 0.145), 9.5);
    _wheel(canvas, Offset(w * 0.90, h * 0.145), 9.5);
    _wheel(canvas, Offset(w * 0.10, h * 0.825), 9.5);
    _wheel(canvas, Offset(w * 0.90, h * 0.825), 9.5);
  }

  void _drawSuv(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, h * 0.52), width: w * 0.90, height: h * 0.83),
      Paint()..color = Colors.black26..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Boxy body
    final body = Path()
      ..moveTo(w * 0.18, h * 0.04)
      ..lineTo(w * 0.82, h * 0.04)
      ..cubicTo(w * 0.96, h * 0.10, w * 0.98, h * 0.22, w * 0.96, h * 0.42)
      ..lineTo(w * 0.96, h * 0.76)
      ..cubicTo(w * 0.96, h * 0.90, w * 0.84, h * 0.97, w * 0.68, h * 0.98)
      ..lineTo(w * 0.32, h * 0.98)
      ..cubicTo(w * 0.16, h * 0.97, w * 0.04, h * 0.90, w * 0.04, h * 0.76)
      ..lineTo(w * 0.04, h * 0.42)
      ..cubicTo(w * 0.02, h * 0.22, w * 0.04, h * 0.10, w * 0.18, h * 0.04)
      ..close();
    canvas.drawPath(body, Paint()..color = _bodyColor);

    // Roof panel
    canvas.save();
    canvas.clipPath(body);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.14, h * 0.06, w * 0.72, h * 0.52),
        const Radius.circular(3),
      ),
      Paint()..color = _roofColor.withOpacity(0.65),
    );
    canvas.restore();

    // Windshield
    _glass(canvas, Path()
      ..moveTo(w * 0.17, h * 0.08)
      ..lineTo(w * 0.83, h * 0.08)
      ..lineTo(w * 0.79, h * 0.315)
      ..lineTo(w * 0.21, h * 0.315)
      ..close());

    // Rear window
    _glass(canvas, Path()
      ..moveTo(w * 0.21, h * 0.535)
      ..lineTo(w * 0.79, h * 0.535)
      ..lineTo(w * 0.75, h * 0.685)
      ..lineTo(w * 0.25, h * 0.685)
      ..close());

    // Side door line
    canvas.drawLine(
      Offset(w * 0.04, h * 0.50), Offset(w * 0.96, h * 0.50),
      Paint()..color = Colors.black.withOpacity(0.20)..strokeWidth = 1.2,
    );

    // Headlights (rectangular — SUV style)
    _headlight(canvas, Rect.fromLTWH(w * 0.06, h * 0.044, w * 0.26, h * 0.040));
    _headlight(canvas, Rect.fromLTWH(w * 0.68, h * 0.044, w * 0.26, h * 0.040));

    // Taillights (full-width LED bar style)
    _taillight(canvas, Rect.fromLTWH(w * 0.06, h * 0.900, w * 0.30, h * 0.036));
    _taillight(canvas, Rect.fromLTWH(w * 0.64, h * 0.900, w * 0.30, h * 0.036));
    canvas.drawRect(
      Rect.fromLTWH(w * 0.36, h * 0.910, w * 0.28, h * 0.012),
      Paint()..color = const Color(0xFFFF2200).withOpacity(0.45),
    );

    canvas.drawPath(body,
        Paint()..color = Colors.black.withOpacity(0.20)..style = PaintingStyle.stroke..strokeWidth = 0.8);

    _wheel(canvas, Offset(w * 0.09, h * 0.20), 10.0);
    _wheel(canvas, Offset(w * 0.91, h * 0.20), 10.0);
    _wheel(canvas, Offset(w * 0.09, h * 0.78), 10.0);
    _wheel(canvas, Offset(w * 0.91, h * 0.78), 10.0);
  }

  void _drawHatchback(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, h * 0.52), width: w * 0.82, height: h * 0.78),
      Paint()..color = Colors.black26..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Compact body
    final body = Path()
      ..moveTo(w * 0.50, h * 0.03)
      ..cubicTo(w * 0.76, h * 0.05, w * 0.90, h * 0.16, w * 0.90, h * 0.40)
      ..cubicTo(w * 0.91, h * 0.62, w * 0.84, h * 0.88, w * 0.60, h * 0.96)
      ..lineTo(w * 0.40, h * 0.96)
      ..cubicTo(w * 0.16, h * 0.88, w * 0.09, h * 0.62, w * 0.10, h * 0.40)
      ..cubicTo(w * 0.10, h * 0.16, w * 0.24, h * 0.05, w * 0.50, h * 0.03)
      ..close();
    canvas.drawPath(body, Paint()..color = _bodyColor);

    // Large roof (hatchback has big glass area)
    canvas.save();
    canvas.clipPath(body);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.20, h * 0.17, w * 0.60, h * 0.50),
        const Radius.circular(5),
      ),
      Paint()..color = _roofColor.withOpacity(0.70),
    );
    canvas.restore();

    // Big windshield
    _glass(canvas, Path()
      ..moveTo(w * 0.23, h * 0.175)
      ..lineTo(w * 0.77, h * 0.175)
      ..lineTo(w * 0.72, h * 0.385)
      ..lineTo(w * 0.28, h * 0.385)
      ..close());

    // Hatchback rear — large rear window slopes steeply
    _glass(canvas, Path()
      ..moveTo(w * 0.24, h * 0.535)
      ..lineTo(w * 0.76, h * 0.535)
      ..lineTo(w * 0.66, h * 0.720)
      ..lineTo(w * 0.34, h * 0.720)
      ..close());

    // Headlights
    _headlight(canvas, Rect.fromLTWH(w * 0.14, h * 0.034, w * 0.20, h * 0.038));
    _headlight(canvas, Rect.fromLTWH(w * 0.66, h * 0.034, w * 0.20, h * 0.038));

    // Taillights
    _taillight(canvas, Rect.fromLTWH(w * 0.11, h * 0.896, w * 0.22, h * 0.036));
    _taillight(canvas, Rect.fromLTWH(w * 0.67, h * 0.896, w * 0.22, h * 0.036));

    canvas.drawPath(body,
        Paint()..color = Colors.black.withOpacity(0.20)..style = PaintingStyle.stroke..strokeWidth = 0.8);

    _wheel(canvas, Offset(w * 0.11, h * 0.215), 8.5);
    _wheel(canvas, Offset(w * 0.89, h * 0.215), 8.5);
    _wheel(canvas, Offset(w * 0.11, h * 0.765), 8.5);
    _wheel(canvas, Offset(w * 0.89, h * 0.765), 8.5);
  }

  void _drawSports(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, h * 0.52), width: w * 0.80, height: h * 0.78),
      Paint()..color = Colors.black26..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Sleek low body
    final body = Path()
      ..moveTo(w * 0.50, h * 0.01)
      ..cubicTo(w * 0.72, h * 0.02, w * 0.92, h * 0.13, w * 0.93, h * 0.38)
      ..cubicTo(w * 0.94, h * 0.56, w * 0.90, h * 0.74, w * 0.82, h * 0.87)
      ..cubicTo(w * 0.74, h * 0.96, w * 0.64, h * 0.99, w * 0.50, h * 0.99)
      ..cubicTo(w * 0.36, h * 0.99, w * 0.26, h * 0.96, w * 0.18, h * 0.87)
      ..cubicTo(w * 0.10, h * 0.74, w * 0.06, h * 0.56, w * 0.07, h * 0.38)
      ..cubicTo(w * 0.08, h * 0.13, w * 0.28, h * 0.02, w * 0.50, h * 0.01)
      ..close();
    canvas.drawPath(body, Paint()..color = _bodyColor);

    // Dark cabin
    canvas.save();
    canvas.clipPath(body);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.18, w * 0.56, h * 0.36),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF111111),
    );
    canvas.restore();

    // Windshield
    _glass(canvas, Path()
      ..moveTo(w * 0.26, h * 0.18)
      ..lineTo(w * 0.74, h * 0.18)
      ..lineTo(w * 0.70, h * 0.36)
      ..lineTo(w * 0.30, h * 0.36)
      ..close());

    // Rear window
    _glass(canvas, Path()
      ..moveTo(w * 0.30, h * 0.55)
      ..lineTo(w * 0.70, h * 0.55)
      ..lineTo(w * 0.66, h * 0.66)
      ..lineTo(w * 0.34, h * 0.66)
      ..close());

    // Front splitter
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.32, h * 0.015)
        ..lineTo(w * 0.68, h * 0.015)
        ..lineTo(w * 0.72, h * 0.060)
        ..lineTo(w * 0.28, h * 0.060)
        ..close(),
      Paint()..color = Colors.black87,
    );

    // Sharp headlights
    _headlight(canvas, Rect.fromLTWH(w * 0.14, h * 0.025, w * 0.18, h * 0.036));
    _headlight(canvas, Rect.fromLTWH(w * 0.68, h * 0.025, w * 0.18, h * 0.036));

    // Taillights
    _taillight(canvas, Rect.fromLTWH(w * 0.12, h * 0.905, w * 0.22, h * 0.034));
    _taillight(canvas, Rect.fromLTWH(w * 0.66, h * 0.905, w * 0.22, h * 0.034));

    canvas.drawPath(body,
        Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 0.8);

    _wheel(canvas, Offset(w * 0.10, h * 0.205), 9.0);
    _wheel(canvas, Offset(w * 0.90, h * 0.205), 9.0);
    _wheel(canvas, Offset(w * 0.10, h * 0.775), 9.0);
    _wheel(canvas, Offset(w * 0.90, h * 0.775), 9.0);
  }
}
