import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class PublishingBanner extends StatelessWidget {
  final bool isCompact;

  const PublishingBanner({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD97706), Color(0xFFF59E0B), Color(0xFFD97706)],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone_in_talk, size: 16, color: Color(0xFF0F172A)),
            const SizedBox(width: 8),
            Flexible(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  const Text(
                    'Call',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  InkWell(
                    onTap: () => AuthService.callPhone(AuthService.publishingPhone1Tel),
                    child: const Text(
                      AuthService.publishingPhone1,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const Text(
                    'Or',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  InkWell(
                    onTap: () => AuthService.callPhone(AuthService.publishingPhone2Tel),
                    child: const Text(
                      AuthService.publishingPhone2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const Text(
                    'for publishing a book',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Card style banner (for Login & Library Hero)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.phone_in_talk, size: 18, color: Color(0xFFFBBF24)),
              SizedBox(width: 8),
              Text(
                'PUBLISH YOUR BOOK WITH US',
                style: TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              const Text(
                'Call',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              InkWell(
                onTap: () => AuthService.callPhone(AuthService.publishingPhone1Tel),
                child: const Text(
                  AuthService.publishingPhone1,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFBBF24),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Text(
                'Or',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              InkWell(
                onTap: () => AuthService.callPhone(AuthService.publishingPhone2Tel),
                child: const Text(
                  AuthService.publishingPhone2,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFBBF24),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Text(
                'for publishing a book',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Open 7 days a week · Direct line to story publishers & editorial team',
            style: TextStyle(color: Colors.amber.shade200.withOpacity(0.7), fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
