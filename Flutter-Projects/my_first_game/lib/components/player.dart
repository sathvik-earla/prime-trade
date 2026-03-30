import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../flame_shooter_game.dart';
import 'bullet.dart';

class Player extends PositionComponent
    with HasGameReference<FlameShooterGame>, CollisionCallbacks {
  static const double _shootCooldown = 0.3;

  double _shootTimer = 0;
  final Paint _bodyPaint = Paint()..color = const Color(0xFF00E5FF);
  final Paint _wingPaint = Paint()..color = const Color(0xFF0080FF);
  final Paint _enginePaint = Paint()
    ..color = const Color(0xFFFF6600)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

  Player()
      : super(
          size: Vector2(50, 60),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = Vector2(game.size.x / 2, game.size.y - 80);
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_shootTimer > 0) _shootTimer -= dt;

    // Keep within screen bounds
    position.x = position.x.clamp(size.x / 2, game.size.x - size.x / 2);
  }

  void move(double dx) {
    position.x += dx;
  }

  void shoot() {
    if (_shootTimer <= 0) {
      _shootTimer = _shootCooldown;
      game.add(Bullet(position: Vector2(position.x, position.y - size.y / 2)));
    }
  }

  void reset() {
    position = Vector2(game.size.x / 2, game.size.y - 80);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Engine glow
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(size.x / 2, size.y - 5), width: 20, height: 14),
      _enginePaint,
    );

    // Left wing
    final leftWingPath = Path()
      ..moveTo(size.x / 2, size.y * 0.4)
      ..lineTo(0, size.y * 0.75)
      ..lineTo(size.x * 0.3, size.y * 0.6)
      ..close();
    canvas.drawPath(leftWingPath, _wingPaint);

    // Right wing
    final rightWingPath = Path()
      ..moveTo(size.x / 2, size.y * 0.4)
      ..lineTo(size.x, size.y * 0.75)
      ..lineTo(size.x * 0.7, size.y * 0.6)
      ..close();
    canvas.drawPath(rightWingPath, _wingPaint);

    // Body
    final bodyPath = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(size.x * 0.7, size.y * 0.5)
      ..lineTo(size.x * 0.65, size.y * 0.85)
      ..lineTo(size.x * 0.35, size.y * 0.85)
      ..lineTo(size.x * 0.3, size.y * 0.5)
      ..close();
    canvas.drawPath(bodyPath, _bodyPaint);

    // Cockpit
    final cockpitPaint = Paint()..color = const Color(0xFFB3E5FC);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(size.x / 2, size.y * 0.3), width: 16, height: 20),
      cockpitPaint,
    );
  }
}
