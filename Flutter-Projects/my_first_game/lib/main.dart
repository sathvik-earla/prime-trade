import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'flame_shooter_game.dart';
import 'overlays/hud_overlay.dart';
import 'overlays/game_over_overlay.dart';

void main() {
  runApp(const FlameShooterApp());
}

class FlameShooterApp extends StatelessWidget {
  const FlameShooterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flame Shooter',
      theme: ThemeData.dark(),
      home: GameWidget<FlameShooterGame>(
        game: FlameShooterGame(),
        overlayBuilderMap: {
          'HUD': (context, game) => HudOverlay(game: game),
          'GameOver': (context, game) => GameOverOverlay(game: game),
        },
        initialActiveOverlays: const ['HUD'],
      ),
    );
  }
}
