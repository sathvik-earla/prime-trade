import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../flame_shooter_game.dart';
import 'enemy.dart';

class Bullet extends PositionComponent
    with HasGameReference<FlameShooterGame>, CollisionCallbacks {
  static const double _speed = 500;

  final Paint _paint = Paint()
    ..color = const Color(0xFFFFEB3B)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

  Bullet({required Vector2 position})
      : super(
          position: position,
          size: Vector2(6, 20),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= _speed * dt;
    if (position.y < -20) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Enemy) {
      other.destroy();
      removeFromParent();
      game.addScore(10);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(3),
      ),
      _paint,
    );
  }
}
