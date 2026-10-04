import 'dart:convert';
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
    'weakongames83@gmail.com': const OwnerUser(
      email: 'weakongames83@gmail.com',
      name: 'Weakon Games',
      role: 'Co-Owner & Creative Storybook Director',
      avatarColor: '0xFF0284C7',
    ),
    'sastva.book@gmail.com': const OwnerUser(
      email: 'sastva.book@gmail.com',
      name: 'Sastva Books',
      role: 'Co-Owner & Literary Publishing Partner',
      avatarColor: '0xFF059669',
    ),
    'randomuser1234@gmail.com': const OwnerUser(
      email: 'randomuser1234@gmail.com',
      name: 'Random User',
      role: 'Co-Owner & Publishing Associate',
      avatarColor: '0xFF9333EA',
    ),
  };

  ReaderUser? _currentReader;
  OwnerUser? _currentOwner;

  ReaderUser? get currentReader => _currentReader;
  OwnerUser? get currentOwner => _currentOwner;
  bool get isAuthenticated => _currentReader != null || _currentOwner != null;

  AuthService() {
    loadSessions();
  }

  Future<void> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    
    final readerJson = prefs.getString('flutter_reader_session');
    if (readerJson != null) {
      try {
        _currentReader = ReaderUser.fromJson(jsonDecode(readerJson));
      } catch (_) {}
    }

    final ownerJson = prefs.getString('flutter_owner_session');
    if (ownerJson != null) {
      try {
        _currentOwner = OwnerUser.fromJson(jsonDecode(ownerJson));
      } catch (_) {}
    }

    notifyListeners();
  }

  Future<void> loginReader(String name, String email) async {
    final cleanName = name.trim().isEmpty ? 'Story Explorer' : name.trim();
    final cleanEmail = email.trim().isEmpty ? 'reader@fivefriends.com' : email.trim().toLowerCase();

    _currentReader = ReaderUser(
      id: 'reader_${DateTime.now().millisecondsSinceEpoch}',
      name: cleanName,
      email: cleanEmail,
      loginTime: DateTime.now().toIso8601String(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('flutter_reader_session', jsonEncode(_currentReader!.toJson()));
    notifyListeners();
  }

  bool unlockOwner(String password, String ownerEmail) {
    if (password.trim() == masterPassword) {
      final owner = authorizedOwners[ownerEmail.toLowerCase()] ??
          authorizedOwners['earlasathvik.rs@gmail.com']!;
      _currentOwner = owner;

      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('flutter_owner_session', jsonEncode(owner.toJson()));
      });

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _currentReader = null;
    _currentOwner = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('flutter_reader_session');
    await prefs.remove('flutter_owner_session');
    notifyListeners();
  }

  static Future<void> callPhone(String tel) async {
    final Uri uri = Uri(scheme: 'tel', path: tel);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
