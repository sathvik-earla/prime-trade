import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'asphalt7/asphalt_game.dart';
import 'asphalt7/overlays/car_select_overlay.dart';
import 'asphalt7/overlays/hud_overlay.dart';
import 'asphalt7/overlays/game_over_overlay.dart';

void main() {
  runApp(const Asphalt7App());
}

class Asphalt7App extends StatelessWidget {
  const Asphalt7App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asphalt 7',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: GameWidget<AsphaltGame>(
        game: AsphaltGame(),
        overlayBuilderMap: {
          'CarSelect': (context, game) => CarSelectOverlay(game: game),
          'HUD': (context, game) => HudOverlay(game: game),
          'GameOver': (context, game) => GameOverOverlay(game: game),
        },
        initialActiveOverlays: const [],
      ),
    );
  }
}
