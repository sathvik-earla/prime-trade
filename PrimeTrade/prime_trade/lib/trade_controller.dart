// lib/trade_controller.dart
import 'models.dart';

class TradeController {
  double availableCollateral =
      500000.00; // Starting institutional liquidity fund

  ExecutionReceipt executeTerminalOrder(MarketAsset asset, String actionSide) {
    double contractCost = asset.ltp;

    if (actionSide == "LONG") {
      if (availableCollateral < contractCost) {
        return ExecutionReceipt(
            isSuccess: false,
            message: "Transaction Rejected: Margin Limit Reached.",
            updateCollateral: availableCollateral);
      }
      availableCollateral -= contractCost;
      return ExecutionReceipt(
          isSuccess: true,
          message: "Order Filled: LONG 1 Unit of ${asset.symbol}.",
          updateCollateral: availableCollateral);
    } else {
      availableCollateral += contractCost;
      return ExecutionReceipt(
          isSuccess: true,
          message: "Order Filled: SHORT 1 Unit of ${asset.symbol}.",
          updateCollateral: availableCollateral);
    }
  }
}
