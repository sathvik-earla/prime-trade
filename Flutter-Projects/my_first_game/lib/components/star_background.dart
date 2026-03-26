import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../flame_shooter_game.dart';

class _Star {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class StarBackground extends Component with HasGameReference<FlameShooterGame> {
  final List<_Star> _stars = [];
  final Random _random = Random();
  static const int _starCount = 100;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    for (int i = 0; i < _starCount; i++) {
      _stars.add(_Star(
        x: _random.nextDouble() * game.size.x,
        y: _random.nextDouble() * game.size.y,
        size: _random.nextDouble() * 2.5 + 0.5,
        speed: _random.nextDouble() * 60 + 20,
        opacity: _random.nextDouble() * 0.7 + 0.3,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final star in _stars) {
      star.y += star.speed * dt;
      if (star.y > game.size.y) {
        star.y = 0;
        star.x = _random.nextDouble() * game.size.x;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    for (final star in _stars) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(star.opacity);
      canvas.drawCircle(Offset(star.x, star.y), star.size, paint);
    }
  }
}
