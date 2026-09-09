// lib/feature_dashboard.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'config.dart';

class IndexSummary {
  final String indexName;
  final double currentLevel;
  final double changePercent;
  IndexSummary(this.indexName, this.currentLevel, this.changePercent);
}

class DashboardRepository {
  // Stream.periodic cancels its timer automatically when the last
  // subscriber unsubscribes, unlike a hand-rolled async* + Future.delayed loop.
  Stream<List<IndexSummary>> fetchIndexTickerFeed() {
    final rand = Random();
    return Stream.periodic(const Duration(seconds: 1), (_) {
      return [
        IndexSummary("PRIME US 500", 5210.0 + rand.nextDouble() * 5, 0.12),
        IndexSummary("GLOBAL GLD INDEX", 2340.0 + rand.nextDouble() * 3, -0.04),
      ];
    });
  }
}

class IndexBanner extends StatelessWidget {
  const IndexBanner({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container(
      height: 40,
      color: AppConfig.surfaceCardGlass,
      child: const Center(
          child: Text("PRIME INDEX COMPONENT STREAMS ACTIVE",
              style: TextStyle(
                  color: AppConfig.accentsChampagne,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold))));
}
