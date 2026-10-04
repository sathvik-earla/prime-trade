import 'package:flutter/material.dart';
import 'config.dart';
import 'models.dart';
import 'trade_controller.dart';
import 'market_engine.dart';
import 'core_system.dart';
import 'feature_dashboard.dart';

void main() => runApp(const PrimeTradeFramework());

class PrimeTradeFramework extends StatelessWidget {
  const PrimeTradeFramework({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppConfig.backgroundObsidian,
        primaryColor: AppConfig.accentsChampagne,
      ),
      home: const PrimeTerminalWorkspace(),
    );
  }
}

class PrimeTerminalWorkspace extends StatefulWidget {
  const PrimeTerminalWorkspace({Key? key}) : super(key: key);

  @override
  State<PrimeTerminalWorkspace> createState() => _PrimeTerminalWorkspaceState();
}

class _PrimeTerminalWorkspaceState extends State<PrimeTerminalWorkspace> {
  final TradeController _tradeController = TradeController();
  final InstitutionalMarketEngine _marketEngine = InstitutionalMarketEngine();

  void _executeOrder(MarketAsset asset, String actionSide) {
    final receipt = _tradeController.executeTerminalOrder(asset, actionSide);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(receipt.message, style: const TextStyle(fontSize: 12)),
      backgroundColor:
          receipt.isSuccess ? AppConfig.surfaceCardGlass : AppConfig.crimsonRed,
      behavior: SnackBarBehavior.floating,
    ));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConfig.appName, style: AppTypography.headerStyle),
        backgroundColor: AppConfig.surfaceCardGlass,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text("SECURE ID: ${AppConfig.secureNodeId}",
                  style: AppTypography.subheaderStyle),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const IndexBanner(),
          Expanded(
            child: StreamBuilder<List<MarketAsset>>(
              stream: _marketEngine.streamLiveTerminalTicks(),
              builder: (context, snapshot) {
                final assets = snapshot.data ?? [];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: AppConfig.surfaceCardGlass,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color:
                                  AppConfig.accentsChampagne.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                                "AVAILABLE INSTITUTIONAL COLLATERAL (USD)",
                                style: TextStyle(
                                    color: Colors.white30,
                                    fontSize: 10,
                                    letterSpacing: 1)),
                            const SizedBox(height: 6),
                            Text(
                                "\$${_tradeController.availableCollateral.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text("LIVE ASSET MATRIX",
                          style: TextStyle(
                              color: AppConfig.accentsChampagne,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: assets.isEmpty
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: AppConfig.accentsChampagne))
                            : ListView.builder(
                                itemCount: assets.length,
                                itemBuilder: (context, index) {
                                  final asset = assets[index];
                                  final increment = asset.changePercent >= 0;
                                  return Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                        color: AppConfig.surfaceCardGlass,
                                        borderRadius: BorderRadius.circular(6)),
                                    child: ListTile(
                                      title: Text(asset.symbol,
                                          style: AppTypography.boldTicker),
                                      subtitle: Text(asset.companyName,
                                          style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 11)),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                  asset.ltp.toStringAsFixed(
                                                      asset.ltp < 5 ? 4 : 2),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      fontFamily: 'monospace')),
                                              Text(
                                                  "${increment ? '+' : ''}${asset.changePercent.toStringAsFixed(2)}%",
                                                  style: TextStyle(
                                                      color: increment
                                                          ? AppConfig
                                                              .neonEmerald
                                                          : AppConfig
                                                              .crimsonRed,
                                                      fontSize: 11)),
                                            ],
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                              icon: const Icon(
                                                  Icons.trending_up,
                                                  color: AppConfig.neonEmerald,
                                                  size: 20),
                                              onPressed: () =>
                                                  _executeOrder(asset, "LONG")),
                                          IconButton(
                                              icon: const Icon(
                                                  Icons.trending_down,
                                                  color: AppConfig.crimsonRed,
                                                  size: 20),
                                              onPressed: () => _executeOrder(
                                                  asset, "SHORT")),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
