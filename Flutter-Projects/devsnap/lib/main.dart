// ignore_for_file: unused_field

import 'package:flutter/material.dart';

void main() {
  runApp(const DevSnapTwoApp());
}

class DevSnapTwoApp extends StatelessWidget {
  const DevSnapTwoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevSnap 2.0',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F19), // Deep Cyber Dark
        primaryColor: const Color(0xFF3B82F6), // Neon blue highlight
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF10B981), // Emerald green success
          error: Color(0xFFEF4444), // Bright error red
          surface: Color(0xFF1E293B), // Slate container fill
        ),
      ),
      home: const MainRoadmapLayout(),
    );
  }
}

class MainRoadmapLayout extends StatefulWidget {
  const MainRoadmapLayout({super.key});

  @override
  State<MainRoadmapLayout> createState() => _MainRoadmapLayoutState();
}

class _MainRoadmapLayoutState extends State<MainRoadmapLayout> {
  int _currentViewIndex = 0;
  
  // App Global States
  int _heartsCount = 5;
  int _coinsWallet = 150;
  int _streakActiveDays = 14;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentViewIndex == 0 
          ? PuzzleSandboxView(
              hearts: _heartsCount,
              coins: _coinsWallet,
              streak: _streakActiveDays,
              onStatsUpdated: (newHearts, newCoins, newStreak) {
                setState(() {
                  _heartsCount = newHearts;
                  _coinsWallet = newCoins;
                  _streakActiveDays = newStreak;
                });
              },
              onNavigateToMap: () => setState(() => _currentViewIndex = 1),
            )
          : CreatorPlatformMapView(
              hearts: _heartsCount,
              coins: _coinsWallet,
              streak: _streakActiveDays,
              onBackToPuzzle: () => setState(() => _currentViewIndex = 0),
            ),
    );
  }
}

// --- PUZZLE INTERACTIVE ENGINE VIEW ---
class PuzzleSandboxView extends StatefulWidget {
  final int hearts;
  final int coins;
  final int streak;
  final Function(int, int, int) onStatsUpdated;
  final VoidCallback onNavigateToMap;

  const PuzzleSandboxView({
    super.key,
    required this.hearts,
    required this.coins,
    required this.streak,
    required this.onStatsUpdated,
    required this.onNavigateToMap,
  });

  @override
  State<PuzzleSandboxView> createState() => _PuzzleSandboxViewState();
}

class _PuzzleSandboxViewState extends State<PuzzleSandboxView> {
  String? _pickedOption;
  bool _evaluated = false;
  bool _isSuccess = false;
  double _completionPercent = 0.20;

  final String _targetCommand = "print";
  final List<String> _choiceTokens = ["speak", "print", "write"];

  void _processEvaluation() {
    if (_pickedOption == null) return;

    setState(() {
      _evaluated = true;
      if (_pickedOption == _targetCommand) {
        _isSuccess = true;
        _completionPercent = 0.50;
        widget.onStatsUpdated(widget.hearts, widget.coins + 15, widget.streak);
      } else {
        _isSuccess = false;
        int remainingHearts = widget.hearts > 0 ? widget.hearts - 1 : 0;
        widget.onStatsUpdated(remainingHearts, widget.coins, widget.streak);
      }
    });
  }

  void _advanceNextLesson() {
    setState(() {
      _pickedOption = null;
      _evaluated = false;
      _isSuccess = false;
    });
    widget.onNavigateToMap();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Navigation Dashboard Info Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Color(0xFFEF4444), size: 26),
                    const SizedBox(width: 4),
                    Text('${widget.hearts}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Color(0xFFF59E0B), size: 26),
                    const SizedBox(width: 4),
                    Text('${widget.streak} 🔥', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.circle, color: Color(0xFFFFD700), size: 24),
                    const SizedBox(width: 4),
                    Text('${widget.coins}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          // Linear Smooth Track Progression Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _completionPercent,
                minHeight: 10,
                backgroundColor: const Color(0xFF1E293B),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Avatar Bot Presentation Core Component
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
                  ),
                  child: const Icon(Icons.adb_rounded, size: 48, color: Color(0xFF60A5FA)),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    "Hey! Help me display text correctly to the system screen by fixing this broken syntax line.",
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15, height: 1.4),
                  ),
                )
              ],
            ),
          ),
          const Spacer(),

          // The Terminal/Code Workspace Dynamic Display Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _evaluated
                      ? (_isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                      : const Color(0xFF334155),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _pickedOption != null ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF3B82F6), width: 1),
                    ),
                    child: Text(
                      _pickedOption ?? "_______",
                      style: const TextStyle(fontFamily: 'Courier', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '("Hello, World!")',
                    style: TextStyle(fontFamily: 'Courier', fontSize: 22, color: Color(0xFFF3F4F6), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),

          // Interaction Selector Layout Track
          if (!_evaluated)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _choiceTokens.map((item) {
                  final activeSelection = _pickedOption == item;
                  return InkWell(
                    onTap: () => setState(() => _pickedOption = item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: activeSelection ? const Color(0xFF3B82F6) : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: activeSelection ? Colors.white70 : const Color(0xFF475569)),
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          if (!_evaluated) const SizedBox(height: 20),

          // Check Answer Trigger Button
          if (!_evaluated)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _pickedOption == null ? null : _processEvaluation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    disabledBackgroundColor: const Color(0xFF1E293B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CHECK',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ),
              ),
            ),

          // Bottom Validation Feedback Context Drawer
          if (_evaluated)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isSuccess ? Icons.check_circle : Icons.cancel,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isSuccess ? 'Correct!' : 'Not quite — try the next one!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _advanceNextLesson,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0B0F19),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'CONTINUE',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- CREATOR PLATFORM ROADMAP MAP VIEW ---
class CreatorPlatformMapView extends StatelessWidget {
  final int hearts;
  final int coins;
  final int streak;
  final VoidCallback onBackToPuzzle;

  const CreatorPlatformMapView({
    super.key,
    required this.hearts,
    required this.coins,
    required this.streak,
    required this.onBackToPuzzle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBackToPuzzle,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Roadmap',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map, size: 64, color: Color(0xFF3B82F6)),
                    const SizedBox(height: 16),
                    const Text(
                      'More lessons coming soon!',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: onBackToPuzzle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back to Lesson'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}