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
        return Stack(
          children: [
            // Score and lives at top
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.cyanAccent.withOpacity(0.5)),
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
                  Row(
                    children: List.generate(
                      game.lives.clamp(0, 5),
                      (index) => const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.favorite,
                            color: Colors.redAccent, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // On-screen controls at bottom
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left / Right buttons
                  Row(
                    children: [
                      _GameButton(
                        icon: Icons.arrow_left,
                        onPressed: () => game.setButtonLeft(true),
                        onReleased: () => game.setButtonLeft(false),
                      ),
                      const SizedBox(width: 12),
                      _GameButton(
                        icon: Icons.arrow_right,
                        onPressed: () => game.setButtonRight(true),
                        onReleased: () => game.setButtonRight(false),
                      ),
                    ],
                  ),
                  // Fire button
                  _GameButton(
                    label: 'X',
                    color: Colors.orangeAccent,
                    onPressed: () => game.setButtonFire(true),
                    onReleased: () => game.setButtonFire(false),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GameButton extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final Color color;
  final VoidCallback onPressed;
  final VoidCallback onReleased;

  const _GameButton({
    this.icon,
    this.label,
    this.color = Colors.cyanAccent,
    required this.onPressed,
    required this.onReleased,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onPressed(),
      onTapUp: (_) => onReleased(),
      onTapCancel: onReleased,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.8), width: 2),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: color, size: 36)
              : Text(
                  label!,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
