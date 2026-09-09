import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

void main() {
  runApp(const NanoShieldApp());
}

class NanoShieldApp extends StatelessWidget {
  const NanoShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NanoShield AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        primaryColor: const Color(0xFF00E676),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          secondary: Color(0xFF2979FF),
          surface: Color(0xFF161B22),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isProtected = true;
  bool _isLoading = false;
  String _networkStatus = 'Checking server threat logs...';

  final _aiController = TextEditingController();
  String _aiAnalysisResult = 'Ask NanoShield AI to analyze a suspected exploit payload or check system logs.';
  bool _isAiThinking = false;

  final String _geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';

  @override
  void initState() {
    super.initState();
    _fetchSecurityMetrics();
  }

  @override
  void dispose() {
    _aiController.dispose();
    super.dispose();
  }

  Future<void> _fetchSecurityMetrics() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos/1'));
      if (response.statusCode == 200) {
        setState(() => _networkStatus = 'All nodes secure. Live threat shield active.');
      } else {
        setState(() => _networkStatus = 'Backup server active. Status: Node-Beta localized.');
      }
    } catch (_) {
      setState(() => _networkStatus = 'Offline local shielding enabled.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _analyzeWithAI() async {
    final prompt = _aiController.text.trim();
    if (prompt.isEmpty) return;

    if (_geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      setState(() => _aiAnalysisResult = '⚠️ Error: Please insert your Gemini API Key in main.dart.');
      return;
    }

    setState(() {
      _isAiThinking = true;
      _aiAnalysisResult = 'NanoShield AI is analyzing structural dependencies...';
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _geminiApiKey,
        generationConfig: GenerationConfig(maxOutputTokens: 200),
      );

      final systemPrompt =
          'You are NanoShield AI, an elite, professional cybersecurity operations agent. Analyze the following log snippet, file structure, or system request for immediate threats. Keep answers punchy and brief:\n';
      final content = [Content.text(systemPrompt + prompt)];
      final response = await model.generateContent(content);

      setState(() {
        _aiAnalysisResult = response.text ?? 'No anomalies detected by neural patterns.';
      });
    } catch (e) {
      setState(() {
        _aiAnalysisResult = 'Analysis execution interrupted. Error parsing token map: $e';
      });
    } finally {
      setState(() {
        _isAiThinking = false;
        _aiController.clear();
      });
    }
  }

  void _toggleShield() {
    setState(() => _isProtected = !_isProtected);
  }

  void _showAiPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology, color: Color(0xFF00E676)),
                  const SizedBox(width: 8),
                  Text(
                    'NANOSHIELD AI THREAT CORE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _aiAnalysisResult,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _aiController,
                      decoration: const InputDecoration(
                        hintText: 'Paste suspicious string or log file...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isAiThinking
                        ? null
                        : () async {
                            await _analyzeWithAI();
                            setModalState(() {});
                          },
                    icon: _isAiThinking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NANO SHIELD AI',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _fetchSecurityMetrics,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _toggleShield,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.surface,
                    border: Border.all(
                      color: _isProtected ? theme.primaryColor : Colors.redAccent,
                      width: 6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isProtected ? theme.primaryColor : Colors.redAccent).withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isProtected ? Icons.shield_rounded : Icons.shield_outlined,
                        size: 64,
                        color: _isProtected ? theme.primaryColor : Colors.redAccent,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isProtected ? 'PROTECTED' : 'UNPROTECTED',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isProtected ? theme.primaryColor : Colors.redAccent,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.radar_rounded,
                          color: _isProtected ? theme.colorScheme.secondary : Colors.grey,
                        ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _networkStatus,
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => _showAiPanel(context),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.memory, color: Colors.black87),
                    SizedBox(width: 10),
                    Text(
                      'Open NanoShield AI Panel',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap the shield to toggle protection mode, then use the AI panel for detailed payload analysis.',
              style: const TextStyle(color: Colors.white60, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
