import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'car_data.dart';
import 'level_theme.dart';
import 'components/road.dart';
import 'components/player_car.dart';
import 'components/traffic_car.dart';
import 'components/nitro_pickup.dart';

class AsphaltGame extends FlameGame
    with HasCollisionDetection, PanDetector, KeyboardEvents {
  CarData selectedCar = CarData.bugattiChiron;
  PlayerCar? playerCar;
  Road? road;
  bool gameStarted = false;

  double speed = 240;
  double score = 0;
  int lives = 3;
  bool isGameOver = false;
  double nitro = 0;
  static const double maxNitro = 100;
  bool isNitroActive = false;

  final Random _random = Random();
  double _trafficTimer = 0;
  double _trafficInterval = 2.0;
  double _nitroTimer = 0;
  static const double _nitroSpawnInterval = 8.0;

  // Lane layout
  static const int laneCount = 4;
  late double roadLeft;
  late double roadWidth;
  late double laneWidth;

  // ── Level / theme ──────────────────────────────────────────────────────
  LevelTheme get currentTheme {
    for (int i = LevelTheme.all.length - 1; i >= 0; i--) {
      if (score >= LevelTheme.all[i].scoreStart) return LevelTheme.all[i];
    }
    return LevelTheme.all.first;
  }

  int get currentLevel {
    for (int i = LevelTheme.all.length - 1; i >= 0; i--) {
      if (score >= LevelTheme.all[i].scoreStart) return i + 1;
    }
    return 1;
  }

  LevelTheme? _lastTheme;
  String levelBannerText = '';
  double levelBannerTimer = 0;

  double get speedKmh =>
      ((speed / selectedCar.maxSpeed) * double.parse(
            selectedCar.topSpeed.replaceAll(' km/h', ''),
          ))
          .clamp(0, 999);

  @override
  Color backgroundColor() => const Color(0xFF111111);

  void _initRoadMetrics() {
    roadLeft = size.x * 0.08;
    roadWidth = size.x * 0.84;
    laneWidth = roadWidth / laneCount;
  }

  double getLaneCenter(int lane) =>
      roadLeft + laneWidth * lane + laneWidth / 2;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initRoadMetrics();
    overlays.add('CarSelect');
  }

  Future<void> startGame(CarData car) async {
    selectedCar = car;
    speed = 240;
    overlays.remove('CarSelect');

    road = Road();
    await add(road!);

    playerCar = PlayerCar(carData: selectedCar, initialLane: 1);
    await add(playerCar!);

    _lastTheme = LevelTheme.all.first;
    gameStarted = true;
    overlays.add('HUD');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!gameStarted || isGameOver) return;

    final nitroMultiplier = isNitroActive ? 1.4 : 1.0;
    final targetSpeed =
        (240 + score * 0.06).clamp(240.0, selectedCar.maxSpeed * nitroMultiplier);
    speed += (targetSpeed - speed) * dt * 0.4;
    score += speed * dt * 0.012;

    // Level change detection
    final theme = currentTheme;
    if (_lastTheme != null && _lastTheme!.id != theme.id) {
      levelBannerText = '${theme.emoji}  ${theme.cityName.toUpperCase()}';
      levelBannerTimer = 3.0;
    }
    _lastTheme = theme;
    if (levelBannerTimer > 0) levelBannerTimer -= dt;

    if (isNitroActive) {
      nitro -= 28 * dt;
      if (nitro <= 0) {
        nitro = 0;
        isNitroActive = false;
      }
    }

    _trafficTimer += dt;
    if (_trafficTimer >= _trafficInterval) {
      _trafficTimer = 0;
      _spawnTraffic();
      _trafficInterval = (_random.nextDouble() * 1.4 + 0.9).clamp(0.7, 2.2);
    }

    _nitroTimer += dt;
    if (_nitroTimer >= _nitroSpawnInterval) {
      _nitroTimer = 0;
      add(NitroPickup(lane: _random.nextInt(laneCount)));
    }
  }

  void _spawnTraffic() {
    const types = ['sedan', 'truck', 'suv', 'hatchback', 'sports'];
    add(TrafficCar(
      lane: _random.nextInt(laneCount),
      trafficType: types[_random.nextInt(types.length)],
    ));
  }

  void collectNitro(double amount) {
    nitro = (nitro + amount).clamp(0, maxNitro);
  }

  void activateNitro() {
    if (nitro > 10) isNitroActive = true;
  }

  void loseLife() {
    lives--;
    speed *= 0.55;
    if (lives <= 0) _triggerGameOver();
  }

  void _triggerGameOver() {
    isGameOver = true;
    overlays.remove('HUD');
    overlays.add('GameOver');
    pauseEngine();
  }

  void restartGame() {
    score = 0;
    lives = 3;
    speed = 240;
    nitro = 0;
    isGameOver = false;
    isNitroActive = false;
    _trafficTimer = 0;
    _nitroTimer = 0;

    _lastTheme = LevelTheme.all.first;
    levelBannerTimer = 0;
    children.whereType<TrafficCar>().toList().forEach((c) => c.removeFromParent());
    children.whereType<NitroPickup>().toList().forEach((c) => c.removeFromParent());
    playerCar?.resetToLane(1);

    overlays.remove('GameOver');
    overlays.add('HUD');
    resumeEngine();
  }

  // ── Input ──────────────────────────────────────────────────────────────

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is RawKeyDownEvent && gameStarted && !isGameOver) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) playerCar?.moveLeft();
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) playerCar?.moveRight();
      if (event.logicalKey == LogicalKeyboardKey.space) activateNitro();
    }
    return KeyEventResult.handled;
  }

  @override
  void onPanEnd(DragEndInfo info) {
    final dx = info.velocity.x;
    if (dx < -280) playerCar?.moveLeft();
    if (dx > 280) playerCar?.moveRight();
  }
}
