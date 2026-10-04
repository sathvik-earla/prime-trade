import React, { useState } from 'react';
import { X, Copy, Check, FileCode, Download, Smartphone } from 'lucide-react';

interface FlutterCodeViewerProps {
  isOpen: boolean;
  onClose: () => void;
}

const FLUTTER_FILES: { path: string; language: string; content: string }[] = [
  {
    path: 'lib/main.dart',
    language: 'dart',
    content: `import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'screens/login_screen.dart';
import 'screens/library_screen.dart';
import 'screens/owner_portal_screen.dart';
import 'screens/reader_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => StorageService()),
      ],
      child: const FiveFriendsApp(),
    ),
  );
}

class FiveFriendsApp extends StatelessWidget {
  const FiveFriendsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Five Friends Series',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF59E0B),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF0F172A),
          onSurface: Color(0xFFF8FAFC),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

/// Authentication Gate: Compulsory login to enter the app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }
    return const HomeScreen();
  }
}`,
  },
  {
    path: 'lib/screens/login_screen.dart',
    language: 'dart',
    content: `// Compulsory Login Screen with Starting Publishing Helpline Banner
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/publishing_banner.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _readerNameController = TextEditingController();
  final _readerEmailController = TextEditingController();
  final _ownerPasswordController = TextEditingController();
  String _selectedOwnerEmail = 'earlasathvik.rs@gmail.com';
  bool _obscureOwnerPassword = true;
  String? _ownerError;

  // Features: Compulsory login, RTS590 owner unlock, and direct phone calling
  // Call +91 9398638545 Or +91 85905 63007 for publishing a book
  ...
}`,
  },
  {
    path: 'lib/services/auth_service.dart',
    language: 'dart',
    content: `import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_models.dart';

class AuthService extends ChangeNotifier {
  static const String masterPassword = 'RTS590';

  static const String publishingPhone1 = '+91 9398638545';
  static const String publishingPhone1Tel = '+919398638545';
  static const String publishingPhone2 = '+91 85905 63007';
  static const String publishingPhone2Tel = '+918590563007';

  static const String publishingHelplineText =
      'Call +91 9398638545 Or +91 85905 63007 for publishing a book';

  static final Map<String, OwnerUser> authorizedOwners = {
    'earlasathvik.rs@gmail.com': const OwnerUser(
      email: 'earlasathvik.rs@gmail.com',
      name: 'Earlasathvik R.S.',
      role: 'Primary Owner & Senior Story Author',
      avatarColor: '0xFFD97706',
    ),
    ...
  };
}`,
  },
  {
    path: 'pubspec.yaml',
    language: 'yaml',
    content: `name: the_five_friends_series
description: "The Five Friends Series - Illustrated Storybooks in Flutter Dart"
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  shared_preferences: ^2.2.2
  url_launcher: ^6.2.5
  provider: ^6.1.2`,
  },
];

export const FlutterCodeViewer: React.FC<FlutterCodeViewerProps> = ({ isOpen, onClose }) => {
  const [selectedFileIdx, setSelectedFileIdx] = useState(0);
  const [copied, setCopied] = useState(false);

  if (!isOpen) return null;

  const currentFile = FLUTTER_FILES[selectedFileIdx];

  const handleCopy = () => {
    navigator.clipboard.writeText(currentFile.content);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleDownloadFile = () => {
    const blob = new Blob([currentFile.content], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = currentFile.path.split('/').pop() || 'flutter_code.dart';
    a.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/90 p-4 backdrop-blur-md">
      <div className="flex h-[88vh] w-full max-w-5xl flex-col rounded-3xl border border-slate-800 bg-slate-900 shadow-2xl overflow-hidden">
        {/* Modal Header */}
        <div className="flex items-center justify-between border-b border-slate-800 px-6 py-4 bg-slate-950/60">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-amber-500/20 text-amber-400">
              <Smartphone className="h-5 w-5" />
            </div>
            <div>
              <h2 className="text-base font-bold text-white flex items-center gap-2">
                <span>The Five Friends Series — Flutter (Dart) Source</span>
                <span className="rounded-full bg-cyan-500/20 text-cyan-300 text-[10px] px-2 py-0.5 font-bold">
                  Flutter 3 &amp; Dart
                </span>
              </h2>
              <p className="text-xs text-slate-400">
                Created in <code className="text-amber-300">/flutter_project/</code> with main.dart, screens, models &amp; services
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="rounded-xl p-2 text-slate-400 hover:bg-slate-800 hover:text-white transition-colors"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* Body with Sidebar & Code Editor */}
        <div className="flex flex-1 overflow-hidden">
          {/* File Explorer Sidebar */}
          <div className="w-64 border-r border-slate-800 bg-slate-950/40 p-3 overflow-y-auto">
            <div className="text-[11px] font-bold text-slate-400 uppercase tracking-wider mb-2 px-2">
              Flutter Files
            </div>
            <div className="space-y-1">
              {FLUTTER_FILES.map((file, idx) => (
                <button
                  key={file.path}
                  onClick={() => setSelectedFileIdx(idx)}
                  className={`w-full flex items-center gap-2 rounded-xl px-3 py-2 text-xs font-medium text-left transition-colors ${
                    selectedFileIdx === idx
                      ? 'bg-amber-500/20 text-amber-300 border border-amber-500/30 font-bold'
                      : 'text-slate-400 hover:bg-slate-800/60 hover:text-slate-200'
                  }`}
                >
                  <FileCode className="h-4 w-4 shrink-0 text-cyan-400" />
                  <span className="truncate">{file.path}</span>
                </button>
              ))}
            </div>

            <div className="mt-6 rounded-2xl border border-slate-800 bg-slate-900/60 p-3 text-[11px] text-slate-400 leading-relaxed">
              <span className="font-bold text-amber-400 block mb-1">To Run in Terminal:</span>
              <code className="block bg-slate-950 p-2 rounded text-[10px] text-slate-300 font-mono">
                cd flutter_project<br />
                flutter pub get<br />
                flutter run
              </code>
            </div>
          </div>

          {/* Code Viewer */}
          <div className="flex flex-1 flex-col overflow-hidden bg-slate-950">
            <div className="flex items-center justify-between border-b border-slate-800/80 px-4 py-2.5 bg-slate-950/90 text-xs text-slate-400">
              <span className="font-mono text-slate-300 font-semibold">{currentFile.path}</span>
              <div className="flex items-center gap-2">
                <button
                  onClick={handleCopy}
                  className="flex items-center gap-1.5 rounded-lg border border-slate-700 bg-slate-800 px-3 py-1 text-slate-200 hover:bg-slate-700 transition-colors"
                >
                  {copied ? <Check className="h-3.5 w-3.5 text-emerald-400" /> : <Copy className="h-3.5 w-3.5" />}
                  <span>{copied ? 'Copied!' : 'Copy Code'}</span>
                </button>
                <button
                  onClick={handleDownloadFile}
                  className="flex items-center gap-1.5 rounded-lg border border-amber-500/40 bg-amber-500/20 px-3 py-1 text-amber-300 hover:bg-amber-500/30 transition-colors"
                >
                  <Download className="h-3.5 w-3.5" />
                  <span>Download File</span>
                </button>
              </div>
            </div>

            <pre className="flex-1 overflow-auto p-4 text-xs font-mono text-slate-200 leading-relaxed">
              <code>{currentFile.content}</code>
            </pre>
          </div>
        </div>
      </div>
    </div>
  );
};
