import 'package:flutter/material.dart';
import '../flame_shooter_game.dart';

class HudOverlay extends StatelessWidget {
  final FlameShooterGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(milliseconds: 100)),
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Score
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
                ),
                child: Text(
                  'SCORE: ${game.score}',
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              // Lives
              Row(
                children: List.generate(
                  game.lives.clamp(0, 5),
                  (index) => const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.favorite, color: Colors.redAccent, size: 24),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
