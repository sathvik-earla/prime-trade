import 'package:flutter/material.dart';
import '../asphalt_game.dart';
import '../level_theme.dart';

class HudOverlay extends StatelessWidget {
  final AsphaltGame game;
  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(milliseconds: 80)),
      builder: (context, _) {
        return Stack(
          children: [
            // ── Top bar ──────────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Panel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('SCORE',
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 9,
                                    letterSpacing: 2)),
                            Text(
                              game.score.toInt().toString().padLeft(6, '0'),
                              style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2),
                            ),
                          ],
                        ),
                      ),
                      _Panel(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${game.speedKmh.toInt()}',
                              style: const TextStyle(
                                  color: Color(0xFF00E5FF),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900),
                            ),
                            const Text('km/h',
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 9,
                                    letterSpacing: 2)),
                          ],
                        ),
                      ),
                      _Panel(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            3,
                            (i) => Padding(
                              padding: const EdgeInsets.only(left: 3),
                              child: Icon(
                                i < game.lives ? Icons.favorite : Icons.favorite_border,
                                color: i < game.lives
                                    ? Colors.redAccent
                                    : Colors.white24,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Level indicator (below top bar) ──────────────────────
            Positioned(
              top: 90,
              left: 14,
              right: 14,
              child: Row(
                children: [
                  _LevelBadge(
                    level: game.currentLevel,
                    theme: game.currentTheme,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _NitroBar(
                        nitro: game.nitro, active: game.isNitroActive),
                  ),
                ],
              ),
            ),

            // ── Level transition banner ───────────────────────────────
            if (game.levelBannerTimer > 0)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: _LevelBanner(
                  text: game.levelBannerText,
                  timer: game.levelBannerTimer,
                  theme: game.currentTheme,
                ),
              ),

            // ── Mobile controls ──────────────────────────────────────
            Positioned(
              bottom: 28,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left / Right
                  Row(children: [
                    _ControlBtn(
                      icon: Icons.chevron_left_rounded,
                      onPressed: () => game.playerCar?.moveLeft(),
                    ),
                    const SizedBox(width: 10),
                    _ControlBtn(
                      icon: Icons.chevron_right_rounded,
                      onPressed: () => game.playerCar?.moveRight(),
                    ),
                  ]),
                  // Nitro
                  _NitroBtn(
                    active: game.isNitroActive,
                    onPressed: () => game.activateNitro(),
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

class _Panel extends StatelessWidget {
  final Widget child;
  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }
}

class _NitroBar extends StatelessWidget {
  final double nitro;
  final bool active;
  const _NitroBar({required this.nitro, required this.active});

  @override
  Widget build(BuildContext context) {
    final pct = (nitro / AsphaltGame.maxNitro).clamp(0.0, 1.0);
    final color = active ? const Color(0xFF00E5FF) : const Color(0xFF0080FF);
    return Row(
      children: [
        const Text('NITRO',
            style: TextStyle(
                color: Colors.white38, fontSize: 9, letterSpacing: 2)),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: active
                          ? [const Color(0xFF00E5FF), const Color(0xFF80FFFF)]
                          : [const Color(0xFF0050CC), color],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: active
                        ? [BoxShadow(color: color.withOpacity(0.7), blurRadius: 6)]
                        : [],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _ControlBtn({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        child: Icon(icon, color: Colors.white, size: 38),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;
  final LevelTheme theme;
  const _LevelBadge({required this.level, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.kerbA.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            theme.emoji,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            'LV $level',
            style: TextStyle(
              color: theme.kerbA,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelBanner extends StatelessWidget {
  final String text;
  final double timer;
  final LevelTheme theme;
  const _LevelBanner(
      {required this.text, required this.timer, required this.theme});

  @override
  Widget build(BuildContext context) {
    // Fade in over first 0.4s, hold, fade out over last 0.5s
    double opacity = 1.0;
    if (timer > 2.6) {
      opacity = (3.0 - timer) / 0.4;
    } else if (timer < 0.5) {
      opacity = timer / 0.5;
    }

    return IgnorePointer(
      child: Center(
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Horizontal rule above
              Container(
                height: 1.5,
                width: 220,
                color: theme.kerbA.withOpacity(0.7),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: theme.kerbA.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: theme.kerbA.withOpacity(0.25),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'NOW ENTERING',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      text,
                      style: TextStyle(
                        color: theme.kerbA,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 1.5,
                width: 220,
                color: theme.kerbA.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NitroBtn extends StatelessWidget {
  final bool active;
  final VoidCallback onPressed;
  const _NitroBtn({required this.active, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: active
                ? [const Color(0xFF00E5FF), const Color(0xFF005F80)]
                : [const Color(0xFF003A5C), const Color(0xFF001A2E)],
          ),
          border: Border.all(
            color: active ? const Color(0xFF00E5FF) : Colors.white24,
            width: active ? 2.5 : 1.5,
          ),
          boxShadow: active
              ? [const BoxShadow(color: Color(0x8000E5FF), blurRadius: 16)]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt,
                color: active ? Colors.white : Colors.white54, size: 26),
            Text('NITRO',
                style: TextStyle(
                    color: active ? Colors.white : Colors.white38,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}
