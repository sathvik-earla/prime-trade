import 'package:flutter/material.dart';
import '../asphalt_game.dart';
import '../car_data.dart';

class CarSelectOverlay extends StatefulWidget {
  final AsphaltGame game;
  const CarSelectOverlay({super.key, required this.game});

  @override
  State<CarSelectOverlay> createState() => _CarSelectOverlayState();
}

class _CarSelectOverlayState extends State<CarSelectOverlay> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Title
            const Text(
              'ASPHALT 7',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
              ),
            ),
            const Text(
              'SELECT YOUR CAR',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 28),
            // Car cards
            SizedBox(
              height: 220,
              child: PageView.builder(
                itemCount: CarData.all.length,
                controller: PageController(
                  viewportFraction: 0.78,
                  initialPage: _selected,
                ),
                onPageChanged: (i) => setState(() => _selected = i),
                itemBuilder: (context, i) {
                  final car = CarData.all[i];
                  final isSelected = i == _selected;
                  return AnimatedScale(
                    scale: isSelected ? 1.0 : 0.88,
                    duration: const Duration(milliseconds: 220),
                    child: _CarCard(car: car, selected: isSelected),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Stat bars
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: _StatBars(car: CarData.all[_selected]),
            ),
            const Spacer(),
            // Start button
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: GestureDetector(
                onTap: () => widget.game.startGame(CarData.all[_selected]),
                child: Container(
                  width: 220,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'START RACE',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarCard extends StatelessWidget {
  final CarData car;
  final bool selected;
  const _CarCard({required this.car, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? const Color(0xFFFFD700) : Colors.white12,
          width: selected ? 2 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: car.primaryColor.withOpacity(0.35),
                  blurRadius: 24,
                  spreadRadius: 4,
                )
              ]
            : [],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Car preview
          SizedBox(
            height: 110,
            child: CustomPaint(
              size: const Size(80, 110),
              painter: _CarPreviewPainter(car: car),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            car.name,
            style: TextStyle(
              color: selected ? const Color(0xFFFFD700) : Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            car.engineSpec,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${car.horsepower} HP',
                style: TextStyle(
                  color: car.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                car.topSpeed,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CarPreviewPainter extends CustomPainter {
  final CarData car;
  const _CarPreviewPainter({required this.car});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, h * 0.58), width: w * 0.82, height: h * 0.24),
      Paint()
        ..color = Colors.black54
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    switch (car.type) {
      case CarType.bugattiChiron:
        _drawChiron(canvas, w, h);
      case CarType.lamborghiniUrus:
        _drawUrus(canvas, w, h);
      case CarType.ferrariSF90:
        _drawFerrari(canvas, w, h);
    }
  }

  void _drawChiron(Canvas canvas, double w, double h) {
    final body = Path()
      ..moveTo(w * 0.5, h * 0.02)
      ..cubicTo(w * 0.85, h * 0.04, w * 0.96, h * 0.22, w * 0.96, h * 0.46)
      ..cubicTo(w * 0.96, h * 0.70, w * 0.84, h * 0.92, w * 0.5, h * 0.97)
      ..cubicTo(w * 0.16, h * 0.92, w * 0.04, h * 0.70, w * 0.04, h * 0.46)
      ..cubicTo(w * 0.04, h * 0.22, w * 0.15, h * 0.04, w * 0.5, h * 0.02)
      ..close();

    canvas.save();
    canvas.clipPath(body);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.54), Paint()..color = car.primaryColor);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.44, w, h * 0.56), Paint()..color = const Color(0xFF181818));
    canvas.restore();

    canvas.drawPath(body,
        Paint()..color = car.accentColor.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 1.2);

    // Windshield
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.28, h * 0.16)
        ..lineTo(w * 0.72, h * 0.16)
        ..lineTo(w * 0.68, h * 0.36)
        ..lineTo(w * 0.32, h * 0.36)
        ..close(),
      Paint()..color = const Color(0xAA5BA3D0),
    );
    // Headlights
    _glow(canvas, Offset(w * 0.24, h * 0.07), 5.5, const Color(0xFFFFFFDD));
    _glow(canvas, Offset(w * 0.76, h * 0.07), 5.5, const Color(0xFFFFFFDD));
    // Taillights
    canvas.drawOval(Rect.fromLTWH(w * 0.12, h * 0.88, w * 0.22, h * 0.04),
        Paint()..color = const Color(0xFFFF2200)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawOval(Rect.fromLTWH(w * 0.66, h * 0.88, w * 0.22, h * 0.04),
        Paint()..color = const Color(0xFFFF2200)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    _wheels(canvas, w, h);
  }

  void _drawUrus(Canvas canvas, double w, double h) {
    final body = Path()
      ..moveTo(w * 0.18, h * 0.04)
      ..lineTo(w * 0.82, h * 0.04)
      ..cubicTo(w * 0.96, h * 0.10, w * 0.98, h * 0.20, w * 0.97, h * 0.42)
      ..lineTo(w * 0.97, h * 0.74)
      ..cubicTo(w * 0.97, h * 0.88, w * 0.84, h * 0.97, w * 0.68, h * 0.98)
      ..lineTo(w * 0.32, h * 0.98)
      ..cubicTo(w * 0.16, h * 0.97, w * 0.03, h * 0.88, w * 0.03, h * 0.74)
      ..lineTo(w * 0.03, h * 0.42)
      ..cubicTo(w * 0.02, h * 0.20, w * 0.04, h * 0.10, w * 0.18, h * 0.04)
      ..close();

    canvas.drawPath(body, Paint()..color = car.primaryColor);
    canvas.save();
    canvas.clipPath(body);
    canvas.drawRect(Rect.fromLTWH(w * 0.16, h * 0.04, w * 0.68, h * 0.46),
        Paint()..color = const Color(0xFF111111));
    canvas.restore();
    canvas.drawPath(body,
        Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 0.8);

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.19, h * 0.07)
        ..lineTo(w * 0.81, h * 0.07)
        ..lineTo(w * 0.77, h * 0.32)
        ..lineTo(w * 0.23, h * 0.32)
        ..close(),
      Paint()..color = const Color(0xAA4A7090),
    );
    // Y headlights
    for (final lft in [true, false]) {
      final cx = lft ? w * 0.20 : w * 0.80;
      final p = Paint()..color = const Color(0xFFFFFFCC)..strokeWidth = 2.0..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cx, h * 0.065), Offset(cx, h * 0.038), p);
      final d = lft ? -1 : 1;
      canvas.drawLine(Offset(cx, h * 0.050), Offset(cx - d * w * 0.08, h * 0.027), p);
      canvas.drawLine(Offset(cx, h * 0.050), Offset(cx + d * w * 0.08, h * 0.027), p);
    }
    canvas.drawOval(Rect.fromLTWH(w * 0.08, h * 0.88, w * 0.28, h * 0.038),
        Paint()..color = const Color(0xFFFF2200)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawOval(Rect.fromLTWH(w * 0.64, h * 0.88, w * 0.28, h * 0.038),
        Paint()..color = const Color(0xFFFF2200)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    _wheels(canvas, w, h, r: 9.5);
  }

  void _drawFerrari(Canvas canvas, double w, double h) {
    final body = Path()
      ..moveTo(w * 0.5, h * 0.01)
      ..cubicTo(w * 0.72, h * 0.02, w * 0.94, h * 0.14, w * 0.94, h * 0.42)
      ..cubicTo(w * 0.94, h * 0.64, w * 0.86, h * 0.86, w * 0.5, h * 0.98)
      ..cubicTo(w * 0.14, h * 0.86, w * 0.06, h * 0.64, w * 0.06, h * 0.42)
      ..cubicTo(w * 0.06, h * 0.14, w * 0.28, h * 0.02, w * 0.5, h * 0.01)
      ..close();

    canvas.drawPath(body, Paint()..color = car.primaryColor);
    canvas.save();
    canvas.clipPath(body);
    canvas.drawRect(Rect.fromLTWH(w * 0.24, h * 0.14, w * 0.52, h * 0.42),
        Paint()..color = const Color(0xFF101010));
    canvas.restore();
    canvas.drawPath(body,
        Paint()..color = const Color(0xFF880000)..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // Gold stripe
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(w * 0.5, h * 0.5), width: 3, height: h * 0.58),
          const Radius.circular(2)),
      Paint()..color = const Color(0xFFD4AF37),
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.28, h * 0.15)
        ..lineTo(w * 0.72, h * 0.15)
        ..lineTo(w * 0.68, h * 0.36)
        ..lineTo(w * 0.32, h * 0.36)
        ..close(),
      Paint()..color = const Color(0xAA3D7DA8),
    );
    // Blade headlights
    for (final lft in [true, false]) {
      final cx = lft ? w * 0.27 : w * 0.73;
      final ox = lft ? w * 0.10 : w * 0.90;
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.5, h * 0.025)
          ..lineTo(cx, h * 0.07)
          ..lineTo(ox, h * 0.10)
          ..lineTo(ox, h * 0.065)
          ..close(),
        Paint()..color = const Color(0xFFFFFFDD)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
    for (final x in [w * 0.21, w * 0.33, w * 0.67, w * 0.79]) {
      _glow(canvas, Offset(x, h * 0.905), 3.5, const Color(0xFFFF2200));
    }
    _wheels(canvas, w, h);
  }

  void _glow(Canvas canvas, Offset c, double r, Color color) {
    canvas.drawCircle(c, r + 2,
        Paint()..color = color.withOpacity(0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawCircle(c, r, Paint()..color = color);
  }

  void _wheels(Canvas canvas, double w, double h, {double r = 8.5}) {
    for (final pos in [
      Offset(w * 0.10, h * 0.21),
      Offset(w * 0.90, h * 0.21),
      Offset(w * 0.10, h * 0.77),
      Offset(w * 0.90, h * 0.77),
    ]) {
      canvas.drawCircle(pos, r, Paint()..color = const Color(0xFF111111));
      canvas.drawCircle(pos, r * 0.58, Paint()..color = const Color(0xFF444444));
      canvas.drawCircle(pos, r * 0.24, Paint()..color = const Color(0xFF888888));
    }
  }

  @override
  bool shouldRepaint(_CarPreviewPainter old) => old.car != car;
}

class _StatBars extends StatelessWidget {
  final CarData car;
  const _StatBars({required this.car});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _bar('TOP SPEED', car.maxSpeed / 920, const Color(0xFF00E5FF)),
        const SizedBox(height: 8),
        _bar('ACCELERATION', car.acceleration / 78, const Color(0xFFFFD700)),
        const SizedBox(height: 8),
        _bar('HANDLING', car.handling / 100, const Color(0xFF76FF03)),
      ],
    );
  }

  Widget _bar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 11, letterSpacing: 1.5)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 7,
            ),
          ),
        ),
      ],
    );
  }
}
