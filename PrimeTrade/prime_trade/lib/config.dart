// lib/config.dart
import 'package:flutter/material.dart';

class AppConfig {
  static const String appName = "PRIME TERMINAL";
  static const String secureNodeId = "NODE-SECURE-99X";

  // Luxury Institutional Dark Color Matrix
  static const Color backgroundObsidian =
      Color(0xFF07090E); // Matte Dark Canvas
  static const Color surfaceCardGlass =
      Color(0xFF111622); // Deep Container Card
  static const Color accentsChampagne =
      Color(0xFFD4AF37); // Luxury Brushed Gold
  static const Color neonEmerald = Color(0xFF00E676); // Bullish Market Gains
  static const Color crimsonRed = Color(0xFFFF5252); // Bearish Market Dips
  static const Color textPlatinum = Color(0xFFE2E8F0); // Off-White Premium Text

  // Supported Trading Assets Metadata Profile
  static const Map<String, Map<String, dynamic>> supportedAssets = {
    "PRIME/GOLD": {
      "name": "Spot Gold Bullion",
      "basePrice": 2420.50,
      "volatility": 0.001
    },
    "PRIME/US500": {
      "name": "Core Equity Composite",
      "basePrice": 5210.25,
      "volatility": 0.001
    },
    "XBT/USD": {
      "name": "Bitcoin Spot Liquidity",
      "basePrice": 68450.00,
      "volatility": 0.005
    },
    "EUR/USD": {
      "name": "Euro / US Dollar",
      "basePrice": 1.0845,
      "volatility": 0.0005
    },
  };
}
