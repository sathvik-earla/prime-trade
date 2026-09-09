// lib/market_engine.dart
import 'dart:async';
import 'dart:math';
import 'config.dart';
import 'models.dart';

class InstitutionalMarketEngine {
  final List<MarketAsset> _activeRegistry = [];
  final _random = Random();

  InstitutionalMarketEngine() {
    AppConfig.supportedAssets.forEach((symbol, specs) {
      _activeRegistry.add(MarketAsset(
        symbol: symbol,
        companyName: specs["name"],
        ltp: specs["basePrice"],
        changePercent: 0.00,
      ));
    });
  }

  /// Indefinite data stream broadcaster delivering rapid random walk changes.
  /// Built on Stream.periodic so the underlying timer is cancelled
  /// automatically when the last subscriber unsubscribes.
  Stream<List<MarketAsset>> streamLiveTerminalTicks() {
    return Stream.periodic(const Duration(milliseconds: 800), (_) {
      for (var asset in _activeRegistry) {
        double volatility =
            AppConfig.supportedAssets[asset.symbol]?["volatility"] ?? 0.001;
        double swing = asset.ltp * volatility * (_random.nextDouble() * 2 - 1);

        // Formats pricing based on macro or micro asset valuations
        asset.ltp = double.parse(
            (asset.ltp + swing).toStringAsFixed(asset.ltp < 5 ? 4 : 2));
        asset.changePercent = double.parse(
            ((_random.nextDouble() * 2 - 1) * 1.5).toStringAsFixed(2));
      }

      return List<MarketAsset>.from(_activeRegistry);
    });
  }
}
