import 'package:flutter/material.dart';
import '../asphalt_game.dart';

class GameOverOverlay extends StatelessWidget {
  final AsphaltGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Color(0xFFFF2200),
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                game.selectedCar.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 36),
              _ScoreBox(score: game.score.toInt()),
              const SizedBox(height: 40),
              _ActionButton(
                label: 'RESTART',
                color: const Color(0xFFFFD700),
                textColor: Colors.black,
                onTap: game.restartGame,
              ),
              const SizedBox(height: 14),
              _ActionButton(
                label: 'CHANGE CAR',
                color: Colors.transparent,
                textColor: Colors.white70,
                border: Colors.white24,
                onTap: () {
                  game.restartGame();
                  game.overlays.remove('HUD');
                  game.overlays.add('CarSelect');
                  game.pauseEngine();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final int score;
  const _ScoreBox({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'FINAL SCORE',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            score.toString().padLeft(6, '0'),
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 44,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final Color? border;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(26),
          border: border != null ? Border.all(color: border!) : null,
          boxShadow: color != Colors.transparent
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 16,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }
}
