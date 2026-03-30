import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../asphalt_game.dart';
import 'player_car.dart';

class NitroPickup extends PositionComponent
    with HasGameReference<AsphaltGame>, CollisionCallbacks {
  final int lane;
  double _pulse = 0;

  static const double _size = 32.0;

  NitroPickup({required this.lane})
      : super(size: Vector2(_size, _size), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = Vector2(game.getLaneCenter(lane), -_size / 2 - 10);
    add(CircleHitbox(radius: _size / 2));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += game.speed * dt;
    _pulse = (_pulse + dt * 3.5) % (2 * pi);
    if (position.y > game.size.y + _size) removeFromParent();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other.parent is PlayerCar || other is PlayerCar) {
      game.collectNitro(40);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final r = _size / 2;
    final c = Offset(r, r);
    final glow = 2.5 + sin(_pulse) * 1.5;

    // Outer glow ring
    canvas.drawCircle(
      c, r + glow,
      Paint()
        ..color = const Color(0xFF00BFFF).withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Rotating outer ring
    final ringPaint = Paint()
      ..color = const Color(0xFF00BFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(c, r - 1, ringPaint);

    // Spinning dashes
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(_pulse * 0.6);
    for (int i = 0; i < 6; i++) {
      final a = i * pi / 3;
      canvas.drawLine(
        Offset(cos(a) * (r - 5), sin(a) * (r - 5)),
        Offset(cos(a) * (r - 1), sin(a) * (r - 1)),
        Paint()
          ..color = const Color(0xFF80DFFF)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.restore();

    // Inner filled circle with gradient-like shading
    canvas.drawCircle(
      c, r - 5,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0xFF00E5FF), Color(0xFF006080)],
        ).createShader(Rect.fromCircle(center: c, radius: r - 5)),
    );

    // "N" letter
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.w900,
      letterSpacing: 0,
    );
    final tp = TextPainter(
      text: const TextSpan(text: 'N', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));
  }
}
