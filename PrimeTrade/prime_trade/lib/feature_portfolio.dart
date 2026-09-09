// lib/feature_portfolio.dart
import 'package:flutter/material.dart';

class HoldingItemEntity {
  final String ticker;
  final int holdingQuantity;
  final double averageBuyPrice;
  final double lastTradedPrice;
  HoldingItemEntity(
      {required this.ticker,
      required this.holdingQuantity,
      required this.averageBuyPrice,
      required this.lastTradedPrice});
}

class PortfolioRepository {
  Future<List<HoldingItemEntity>> fetchActiveClientHoldings() async => [
        HoldingItemEntity(
            ticker: "PRIME_ALPHA",
            holdingQuantity: 1000,
            averageBuyPrice: 15.00,
            lastTradedPrice: 18.25)
      ];
}

class PortfolioViewModel extends ChangeNotifier {
  final PortfolioRepository r = PortfolioRepository();
  List<HoldingItemEntity> openBookPositions = [];
  Future<void> updateBookPositions() async {
    openBookPositions = await r.fetchActiveClientHoldings();
    notifyListeners();
  }
}
