import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/player.dart';
import 'components/enemy.dart';
import 'components/star_background.dart';

class FlameShooterGame extends FlameGame
    with HasCollisionDetection, TapDetector, PanDetector {
  late Player player;
  int score = 0;
  int lives = 3;
  bool isGameOver = false;

  final Random _random = Random();
  double _enemySpawnTimer = 0;
  double _enemySpawnInterval = 2.0;

  @override
  Color backgroundColor() => const Color(0xFF0A0A1A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add star background
    add(StarBackground());

    // Add player
    player = Player();
    add(player);

    overlays.add('HUD');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isGameOver) return;

    _enemySpawnTimer += dt;
    if (_enemySpawnTimer >= _enemySpawnInterval) {
      _enemySpawnTimer = 0;
      _spawnEnemy();
      // Gradually increase spawn rate
      if (_enemySpawnInterval > 0.6) {
        _enemySpawnInterval -= 0.03;
      }
    }
  }

  void _spawnEnemy() {
    final x = _random.nextDouble() * (size.x - 60) + 30;
    final speed = 80 + _random.nextDouble() * 60;
    final enemy = Enemy(position: Vector2(x, -40), speed: speed);
    add(enemy);
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (!isGameOver) {
      player.shoot();
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (!isGameOver) {
      player.move(info.delta.global.x);
    }
  }

  void addScore(int points) {
    score += points;
  }

  void loseLife() {
    lives--;
    if (lives <= 0) {
      triggerGameOver();
    }
  }

  void triggerGameOver() {
    isGameOver = true;
    overlays.remove('HUD');
    overlays.add('GameOver');
    pauseEngine();
  }

  void restartGame() {
    score = 0;
    lives = 3;
    isGameOver = false;
    _enemySpawnTimer = 0;
    _enemySpawnInterval = 2.0;

    // Remove all enemies and bullets
    children.whereType<Enemy>().toList().forEach((e) => e.removeFromParent());

    overlays.remove('GameOver');
    overlays.add('HUD');

    player.reset();
    resumeEngine();
  }
}
