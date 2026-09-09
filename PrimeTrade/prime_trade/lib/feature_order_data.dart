// lib/feature_order_data.dart
class OrderRequestEntity {
  final String textSymbol;
  final int volumeSize;
  final double pricingTarget;
  final String targetSide;
  OrderRequestEntity(
      {required this.textSymbol,
      required this.volumeSize,
      required this.pricingTarget,
      required this.targetSide});
}

class OmsApiClient {
  Future<bool> executeNetworkTransaction(Map<String, dynamic> json) async =>
      true;
}

class OrderExecutionRepository {
  final OmsApiClient client = OmsApiClient();
  Future<bool> deployOrderToOms(OrderRequestEntity p) => client
      .executeNetworkTransaction({"sym": p.textSymbol, "qty": p.volumeSize});
}
