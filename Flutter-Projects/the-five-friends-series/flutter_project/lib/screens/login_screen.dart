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

  // Reader Form
  final _readerNameController = TextEditingController();
  final _readerEmailController = TextEditingController();

  // Owner Form
  final _ownerPasswordController = TextEditingController();
  String _selectedOwnerEmail = 'earlasathvik.rs@gmail.com';
  bool _obscureOwnerPassword = true;
  String? _ownerError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _readerNameController.dispose();
    _readerEmailController.dispose();
    _ownerPasswordController.dispose();
    super.dispose();
  }

  void _handleReaderLogin() {
    final name = _readerNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }
    context.read<AuthService>().loginReader(name, _readerEmailController.text.trim());
  }

  void _handleOwnerLogin() {
    setState(() => _ownerError = null);
    final success = context.read<AuthService>().unlockOwner(
          _ownerPasswordController.text,
          _selectedOwnerEmail,
        );
    if (!success) {
      setState(() {
        _ownerError = 'Incorrect password. Owner access is locked with RTS590.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // App Logo & Wordmark
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFF59E0B), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.menu_book_rounded, size: 48, color: Color(0xFFD97706)),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'THE FIVE FRIENDS',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'SERIES BOOKSTORE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(height: 18),

              // Starting Banner with Phone Numbers
              const PublishingBanner(),
              const SizedBox(height: 16),

              // Compulsory Notice
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock, size: 16, color: Color(0xFFF59E0B)),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Login is compulsory to access stories, library & bookstore',
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Login Tabs
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: const Color(0xFF020617),
                  unselectedLabelColor: const Color(0xFF94A3B8),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: const [
                    Tab(icon: Icon(Icons.person, size: 18), text: 'Reader Sign-In'),
                    Tab(icon: Icon(Icons.admin_panel_settings, size: 18), text: 'Owner / Publisher'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tab Views
              SizedBox(
                height: 380,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Reader Form
                    _buildReaderForm(),
                    // Tab 2: Owner Form
                    _buildOwnerForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReaderForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _readerNameController,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            labelText: 'Full Name / Nickname *',
            labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFF59E0B)),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _readerEmailController,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email Address (optional)',
            labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFFF59E0B)),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _handleReaderLogin,
          icon: const Icon(Icons.auto_stories, color: Color(0xFF020617)),
          label: const Text(
            'Login to Enter Library',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF020617)),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF59E0B),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Or quick entry as guest:',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  context.read<AuthService>().loginReader('Book Explorer', 'explorer@fivefriends.com');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF334155)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('📖 Explorer', style: TextStyle(color: Color(0xFFFCD34D), fontSize: 12)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  context.read<AuthService>().loginReader('Story Lover', 'lover@fivefriends.com');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF334155)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('✨ Story Lover', style: TextStyle(color: Color(0xFF6EE7B7), fontSize: 12)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOwnerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_ownerError != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade900.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.shade700),
            ),
            child: Text(
              _ownerError!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
        ],
        DropdownButtonFormField<String>(
          value: _selectedOwnerEmail,
          dropdownColor: const Color(0xFF0F172A),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            labelText: 'Owner Profile',
            labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
          ),
          items: AuthService.authorizedOwners.values.map((owner) {
            return DropdownMenuItem(
              value: owner.email,
              child: Text('${owner.name} (${owner.role})'),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedOwnerEmail = val);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _ownerPasswordController,
          obscureText: _obscureOwnerPassword,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            labelText: 'Password (RTS590)',
            labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            prefixIcon: const Icon(Icons.key, color: Color(0xFFF59E0B)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureOwnerPassword ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF94A3B8),
              ),
              onPressed: () => setState(() => _obscureOwnerPassword = !_obscureOwnerPassword),
            ),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _handleOwnerLogin,
          icon: const Icon(Icons.verified_user, color: Color(0xFF020617)),
          label: const Text(
            'Unlock Owner Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF020617)),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF59E0B),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }
}
