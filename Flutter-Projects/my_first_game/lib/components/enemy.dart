import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../flame_shooter_game.dart';
import 'player.dart';

class Enemy extends PositionComponent
    with HasGameReference<FlameShooterGame>, CollisionCallbacks {
  final double speed;
  final Random _random = Random();
  late Color _color;
  late Paint _bodyPaint;
  late Paint _glowPaint;

  Enemy({required Vector2 position, required this.speed})
      : super(
          position: position,
          size: Vector2(50, 50),
          anchor: Anchor.center,
        ) {
    final hue = _random.nextDouble() * 60 + 0; // red-orange range
    _color = HSVColor.fromAHSV(1.0, hue, 0.9, 0.9).toColor();
    _bodyPaint = Paint()..color = _color;
    _glowPaint = Paint()
      ..color = _color.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
    if (position.y > game.size.y + 60) {
      removeFromParent();
      game.loseLife();
    }
  }

  void destroy() {
    removeFromParent();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      destroy();
      game.loseLife();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2;

    // Glow
    canvas.drawCircle(center, radius + 4, _glowPaint);

    // Body
    final bodyPath = Path();
    const points = 6;
    for (int i = 0; i < points; i++) {
      final angle = (i * 2 * pi / points) - pi / 2;
      final r = i.isEven ? radius : radius * 0.55;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        bodyPath.moveTo(x, y);
      } else {
        bodyPath.lineTo(x, y);
      }
    }
    bodyPath.close();
    canvas.drawPath(bodyPath, _bodyPaint);

    // Eye
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.25, eyePaint);
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(center, radius * 0.12, pupilPaint);
  }
}
