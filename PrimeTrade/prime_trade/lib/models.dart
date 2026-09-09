// lib/models.dart
class MarketAsset {
  final String symbol;
  final String companyName;
  double ltp; // Last Traded Price
  double changePercent;

  MarketAsset({
    required this.symbol,
    required this.companyName,
    required this.ltp,
    required this.changePercent,
  });
}

class ExecutionReceipt {
  final bool isSuccess;
  final String message;
  final double updateCollateral;

  ExecutionReceipt({
    required this.isSuccess,
    required this.message,
    required this.updateCollateral,
  });
}
