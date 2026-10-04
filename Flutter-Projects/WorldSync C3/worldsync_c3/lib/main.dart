/*
  ========================================================================================
  PROJECT: WorldSync C3 Enterprise Grand Core OS (Ultimate Unified Single Architecture)
  LANGUAGE: Dart / UI Framework: Flutter Cross-Platform Client Architecture Engine
  SPECIFICATION: Maximum Long-Form Single-File Standalone Production Source Code Manifest
  FEATURES ADDED:
    - Linear Regression Trend Trajectory Vector Calculation Engine
    - Multi-Node JSON Diagnostic Log Archive Pipeline Array Storage
    - Deep Real-Time Analytics Tab Dashboard Module Canvas Layout
  ========================================================================================
*/

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

// ========================================================================================
// STAGE 1: CENTRAL SYSTEM CONFIGURATIONS & ENUMERATIVE SCHEMAS
// ========================================================================================
class CoreSystemMetadata {
  static const String kernelName = "WorldSync C3 Grand Core Engine";
  static const String kernelVersion = "V7.2.5-ENTERPRISE";
  static const String frameworkTarget = "Flutter 3.x Custom Multithread Substrate";
  static const String developerSignature = "Silicon Embedded Labs International Inc.";
}

enum HardwareStatusVector {
  bootInitialising,
  networkSyncSearching,
  networkLinkStable,
  networkLinkSevered,
  apiTelemetryScraping,
  apiTelemetrySuccess,
  apiPayloadCorrupted,
  systemEmergencyFallback
}

enum ActiveConsoleTabWindow {
  dashboardPanel,
  historicalDataLogs,
  interactiveTerminalShell,
  firmwareSettingsConfig,
  deviceSystemLogs
}

// ========================================================================================
// STAGE 2: HIGH-PRECISION MATHEMATICAL TRENDING & ANALYTICS MODEL FRAMEWORKS
// ========================================================================================
class AdvancedTelemetryMathCalculators {
  static double calculateArithmeticMean(List<double> quantitativeBuffer) {
    if (quantitativeBuffer.isEmpty) return 0.0;
    double continuousSummation = 0.0;
    for (int i = 0; i < quantitativeBuffer.length; i++) {
      continuousSummation += quantitativeBuffer[i];
    }
    return continuousSummation / quantitativeBuffer.length;
  }

  static double calculateStatisticalVariance(List<double> quantitativeBuffer) {
    if (quantitativeBuffer.length < 2) return 0.0;
    double meanValue = calculateArithmeticMean(quantitativeBuffer);
    double accumulatedSquaredDifferences = 0.0;
    for (int i = 0; i < quantitativeBuffer.length; i++) {
      accumulatedSquaredDifferences += math.pow(quantitativeBuffer[i] - meanValue, 2);
    }
    return accumulatedSquaredDifferences / quantitativeBuffer.length;
  }

  static double calculateStandardDeviation(List<double> quantitativeBuffer) {
    return math.sqrt(calculateStatisticalVariance(quantitativeBuffer));
  }

  /// Calculates the mathematical slope vector line using high-precision linear regression formula calculations.
  /// This detects whether the ambient temperature measurements are rising (positive vector) or falling (negative vector).
  static double calculateLinearRegressionSlope(List<double> seriesDataY) {
    if (seriesDataY.length < 2) return 0.0;
    int datasetLengthN = seriesDataY.length;
    double summationX = 0.0;
    double summationY = 0.0;
    double summationXSquared = 0.0;
    double summationProductXY = 0.0;

    for (int i = 0; i < datasetLengthN; i++) {
      double coordinateX = i.toDouble();
      double coordinateY = seriesDataY[i];
      summationX += coordinateX;
      summationY += coordinateY;
      summationXSquared += coordinateX * coordinateX;
      summationProductXY += coordinateX * coordinateY;
    }

    double dynamicNumerator = (datasetLengthN * summationProductXY) - (summationX * summationY);
    double dynamicDenominator = (datasetLengthN * summationXSquared) - (summationX * summationX);
    
    if (dynamicDenominator == 0) return 0.0;
    return dynamicNumerator / dynamicDenominator;
  }
}

// ========================================================================================
// STAGE 3: DATA RETRIEVAL ENTITY DEFINITIONS & RESPONSE DTO PROFILES
// ========================================================================================
class SystemNodeTelemetryRecord {
  final String focalCityString;
  final String focalCountryCode;
  final double currentMetricCelsius;
  final int currentMetricHumidity;
  final String explicitConditionLabel;
  final double networkLatencyMillis;
  final int structuralUptimeTicks;
  final int internalAvailableHeapBytes;

  SystemNodeTelemetryRecord({
    required this.focalCityString,
    required this.focalCountryCode,
    required this.currentMetricCelsius,
    required this.currentMetricHumidity,
    required this.explicitConditionLabel,
    required this.networkLatencyMillis,
    required this.structuralUptimeTicks,
    required this.internalAvailableHeapBytes,
  });

  factory SystemNodeTelemetryRecord.emptyStateMock() {
    return SystemNodeTelemetryRecord(
      focalCityString: "Node Offline",
      focalCountryCode: "--",
      currentMetricCelsius: 0.0,
      currentMetricHumidity: 0,
      explicitConditionLabel: "DISCONNECTED",
      networkLatencyMillis: 0.0,
      structuralUptimeTicks: 0,
      internalAvailableHeapBytes: 0,
    );
  }

  factory SystemNodeTelemetryRecord.fromMapParser(Map<String, dynamic> rawJsonTree) {
    return SystemNodeTelemetryRecord(
      focalCityString: rawJsonTree['city']?.toString() ?? 'Unknown Workspace',
      focalCountryCode: rawJsonTree['country']?.toString() ?? '??',
      currentMetricCelsius: (rawJsonTree['temp'] ?? 0.0).toDouble(),
      currentMetricHumidity: (rawJsonTree['humidity'] ?? 0).toInt(),
      explicitConditionLabel: rawJsonTree['condition']?.toString().toUpperCase() ?? 'UNKNOWN',
      networkLatencyMillis: (rawJsonTree['latency'] ?? 0.0).toDouble(),
      structuralUptimeTicks: (rawJsonTree['uptime'] ?? 0).toInt(),
      internalAvailableHeapBytes: (rawJsonTree['free_heap'] ?? 0).toInt(),
    );
  }
}

class TerminalShellMessageLine {
  final String textStringContent;
  final bool isInstructionInputType;
  final DateTime recordTimestamp;

  TerminalShellMessageLine({
    required this.textStringContent,
    required this.isInstructionInputType,
  }) : recordTimestamp = DateTime.now();
}

class DiagnosticSystemArchivedLog {
  final String moduleTag;
  final String severityLevel;
  final String systemLogPayloadMessage;
  final DateTime entryTimestamp;

  DiagnosticSystemArchivedLog({
    required this.moduleTag,
    required this.severityLevel,
    required this.systemLogPayloadMessage,
  }) : entryTimestamp = DateTime.now();
}

// ========================================================================================
// STAGE 4: MAIN SYSTEM ENTRY APPLICATION BOOTSTRAP POINT
// ========================================================================================
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (BuildContext frameworkContext) => OperationalKernelStateProvider()..initializeRuntimeDaemonPipelines(),
      child: const UnifiedEnterpriseApplicationCore(),
    ),
  );
}

class UnifiedEnterpriseApplicationCore extends StatelessWidget {
  const UnifiedEnterpriseApplicationCore({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorldSync C3 Multi-OS Framework Console',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xff22d3ee),
        scaffoldBackgroundColor: const Color(0xff090d16),
        cardColor: const Color(0xff111827),
        dividerColor: const Color(0xff1f2937),
        useMaterial3: true,
      ),
      home: const MainApplicationShellWindowFrame(),
    );
  }
}

// ========================================================================================
// STAGE 5: CENTRAL MONITOR STATE CONTROLLER PROVIDER (DAEMON REGS)
// ========================================================================================
class OperationalKernelStateProvider extends ChangeNotifier {
  String remoteHardwareIpTargetAddress = "192.168.1.100";
  HardwareStatusVector currentExecutionStatus = HardwareStatusVector.bootInitialising;
  ActiveConsoleTabWindow selectedTabSectionWindow = ActiveConsoleTabWindow.dashboardPanel;
  
  SystemNodeTelemetryRecord activeSystemMetricsData = SystemNodeTelemetryRecord.emptyStateMock();
  List<double> runningTemperatureRegistryBuffer = [];
  List<double> runningHumidityRegistryBuffer    = [];
  List<TerminalShellMessageLine> virtualConsoleShellLogs = [];
  List<DiagnosticSystemArchivedLog> coreSystemDiagnosticHardwareLogs = [];
  
  bool isLocalSystemSimulationModeActive = true;
  int mockEngineExecutionStateCounter    = 0;
  Timer? coreIntervalPollingDaemonTimer;

  int thresholdAlertMaxCelsiusSetting = 45;
  int dynamicTelemetryCycleTickCounter = 0;
  double activeCalculatedThermalTrajectoryVector = 0.0;

  void initializeRuntimeDaemonPipelines() {
    pushLogToShellTerminalRegistry("Initializing Enterprise Core Kernel Subsystems...", false);
    pushDiagnosticLogEntryArchive("KERNEL", "INFO", "Core Micro-OS Scheduler system structures successfully built.");
    
    currentExecutionStatus = HardwareStatusVector.networkSyncSearching;
    notifyListeners();
    engageActiveDataPollingLoopChannel();
  }

  void switchActiveNavigationSubPanel(ActiveConsoleTabWindow requestedSubTabWindow) {
    selectedTabSectionWindow = requestedSubTabWindow;
    notifyListeners();
  }

  void modifyTargetDeviceIpAddressSpace(String newlyAssignedIpInputString) {
    remoteHardwareIpTargetAddress = newlyAssignedIpInputString;
    pushLogToShellTerminalRegistry("Target hardware IP address reassigned to $newlyAssignedIpInputString", false);
    pushDiagnosticLogEntryArchive("NETWORK", "INFO", "Remote node address space updated by operator.");
    notifyListeners();
  }

  void pushLogToShellTerminalRegistry(String textStringContent, bool isInstructionInputType) {
    virtualConsoleShellLogs.add(
      TerminalShellMessageLine(
        textStringContent: textStringContent,
        isInstructionInputType: isInstructionInputType,
      ),
    );
    if (virtualConsoleShellLogs.length > 200) {
      virtualConsoleShellLogs.removeAt(0);
    }
    notifyListeners();
  }

  void pushDiagnosticLogEntryArchive(String moduleTag, String severityLevel, String systemLogPayloadMessage) {
    coreSystemDiagnosticHardwareLogs.add(
      DiagnosticSystemArchivedLog(
        moduleTag: moduleTag,
        severityLevel: severityLevel,
        systemLogPayloadMessage: systemLogPayloadMessage,
      ),
    );
    if (coreSystemDiagnosticHardwareLogs.length > 200) {
      coreSystemDiagnosticHardwareLogs.removeAt(0);
    }
    notifyListeners();
  }

  void engageActiveDataPollingLoopChannel() {
    coreIntervalPollingDaemonTimer?.cancel();
    coreIntervalPollingDaemonTimer = Timer.periodic(const Duration(seconds: 3), (Timer pollTimer) {
      dynamicTelemetryCycleTickCounter++;
      if (isLocalSystemSimulationModeActive) {
        _executeLocalSimulationTelemetryCycle();
      } else {
        _executeRemoteHardwareTelemetryFetchCycle();
      }
    });
  }

  void _executeLocalSimulationTelemetryCycle() {
    mockEngineExecutionStateCounter++;
    final math.Random simulationEntropySource = math.Random();
    final double simulatedCelsius = 22.0 + simulationEntropySource.nextDouble() * 10.0;
    final int simulatedHumidity = 40 + simulationEntropySource.nextInt(30);

    activeSystemMetricsData = SystemNodeTelemetryRecord(
      focalCityString: "Simulated Node",
      focalCountryCode: "SIM",
      currentMetricCelsius: simulatedCelsius,
      currentMetricHumidity: simulatedHumidity,
      explicitConditionLabel: "SIMULATED",
      networkLatencyMillis: 5.0 + simulationEntropySource.nextDouble() * 15.0,
      structuralUptimeTicks: mockEngineExecutionStateCounter,
      internalAvailableHeapBytes: 40000 + simulationEntropySource.nextInt(10000),
    );

    _recordTelemetrySampleAndRecalculateTrajectory(simulatedCelsius, simulatedHumidity.toDouble());
    currentExecutionStatus = HardwareStatusVector.apiTelemetrySuccess;
    notifyListeners();
  }

  Future<void> _executeRemoteHardwareTelemetryFetchCycle() async {
    currentExecutionStatus = HardwareStatusVector.apiTelemetryScraping;
    notifyListeners();
    try {
      final http.Response httpResponsePayload = await http
          .get(Uri.parse('http://$remoteHardwareIpTargetAddress/telemetry'))
          .timeout(const Duration(seconds: 5));

      if (httpResponsePayload.statusCode == 200) {
        final Map<String, dynamic> decodedJsonTree = jsonDecode(httpResponsePayload.body) as Map<String, dynamic>;
        activeSystemMetricsData = SystemNodeTelemetryRecord.fromMapParser(decodedJsonTree);
        _recordTelemetrySampleAndRecalculateTrajectory(
          activeSystemMetricsData.currentMetricCelsius,
          activeSystemMetricsData.currentMetricHumidity.toDouble(),
        );
        currentExecutionStatus = HardwareStatusVector.apiTelemetrySuccess;
        currentExecutionStatus = HardwareStatusVector.networkLinkStable;
      } else {
        currentExecutionStatus = HardwareStatusVector.apiPayloadCorrupted;
        pushDiagnosticLogEntryArchive("NETWORK", "WARN", "Node responded with status ${httpResponsePayload.statusCode}.");
      }
    } catch (thrownException) {
      currentExecutionStatus = HardwareStatusVector.networkLinkSevered;
      pushDiagnosticLogEntryArchive("NETWORK", "ERROR", "Telemetry fetch failed: $thrownException");
    }
    notifyListeners();
  }

  void _recordTelemetrySampleAndRecalculateTrajectory(double celsiusSample, double humiditySample) {
    runningTemperatureRegistryBuffer.add(celsiusSample);
    runningHumidityRegistryBuffer.add(humiditySample);
    if (runningTemperatureRegistryBuffer.length > 50) {
      runningTemperatureRegistryBuffer.removeAt(0);
    }
    if (runningHumidityRegistryBuffer.length > 50) {
      runningHumidityRegistryBuffer.removeAt(0);
    }
    activeCalculatedThermalTrajectoryVector =
        AdvancedTelemetryMathCalculators.calculateLinearRegressionSlope(runningTemperatureRegistryBuffer);

    if (celsiusSample >= thresholdAlertMaxCelsiusSetting) {
      pushDiagnosticLogEntryArchive(
        "THERMAL",
        "ALERT",
        "Temperature ${celsiusSample.toStringAsFixed(1)}°C exceeds configured threshold of $thresholdAlertMaxCelsiusSetting°C.",
      );
    }
  }

  void toggleLocalSimulationModeActiveState(bool newActiveState) {
    isLocalSystemSimulationModeActive = newActiveState;
    pushLogToShellTerminalRegistry(
      newActiveState ? "Switched to local simulation mode." : "Switched to live hardware polling mode.",
      false,
    );
    notifyListeners();
  }

  void updateThermalAlertThresholdSetting(int newThresholdCelsius) {
    thresholdAlertMaxCelsiusSetting = newThresholdCelsius;
    pushDiagnosticLogEntryArchive("CONFIG", "INFO", "Thermal alert threshold updated to $newThresholdCelsius°C.");
    notifyListeners();
  }

  void submitTerminalShellInstruction(String instructionText) {
    if (instructionText.trim().isEmpty) return;
    pushLogToShellTerminalRegistry(instructionText, true);
    pushLogToShellTerminalRegistry("Command '$instructionText' acknowledged by kernel.", false);
  }

  @override
  void dispose() {
    coreIntervalPollingDaemonTimer?.cancel();
    super.dispose();
  }
}

// ========================================================================================
// STAGE 6: MAIN APPLICATION SHELL WINDOW FRAME & NAVIGATION SCAFFOLD
// ========================================================================================
class MainApplicationShellWindowFrame extends StatelessWidget {
  const MainApplicationShellWindowFrame({super.key});

  String _navLabelForTab(ActiveConsoleTabWindow tabWindow) {
    switch (tabWindow) {
      case ActiveConsoleTabWindow.dashboardPanel:
        return "Dashboard";
      case ActiveConsoleTabWindow.historicalDataLogs:
        return "History";
      case ActiveConsoleTabWindow.interactiveTerminalShell:
        return "Terminal";
      case ActiveConsoleTabWindow.firmwareSettingsConfig:
        return "Settings";
      case ActiveConsoleTabWindow.deviceSystemLogs:
        return "Logs";
    }
  }

  IconData _navIconForTab(ActiveConsoleTabWindow tabWindow) {
    switch (tabWindow) {
      case ActiveConsoleTabWindow.dashboardPanel:
        return Icons.dashboard_rounded;
      case ActiveConsoleTabWindow.historicalDataLogs:
        return Icons.show_chart_rounded;
      case ActiveConsoleTabWindow.interactiveTerminalShell:
        return Icons.terminal_rounded;
      case ActiveConsoleTabWindow.firmwareSettingsConfig:
        return Icons.settings_rounded;
      case ActiveConsoleTabWindow.deviceSystemLogs:
        return Icons.receipt_long_rounded;
    }
  }

  Widget _buildActivePanelForTab(ActiveConsoleTabWindow tabWindow) {
    switch (tabWindow) {
      case ActiveConsoleTabWindow.dashboardPanel:
        return const DashboardMetricsPanelView();
      case ActiveConsoleTabWindow.historicalDataLogs:
        return const HistoricalTrendChartPanelView();
      case ActiveConsoleTabWindow.interactiveTerminalShell:
        return const InteractiveTerminalShellPanelView();
      case ActiveConsoleTabWindow.firmwareSettingsConfig:
        return const FirmwareSettingsConfigPanelView();
      case ActiveConsoleTabWindow.deviceSystemLogs:
        return const DeviceSystemLogsPanelView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final OperationalKernelStateProvider kernelState = context.watch<OperationalKernelStateProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(CoreSystemMetadata.kernelName),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                kernelState.currentExecutionStatus.name,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: _buildActivePanelForTab(kernelState.selectedTabSectionWindow),
      bottomNavigationBar: NavigationBar(
        selectedIndex: ActiveConsoleTabWindow.values.indexOf(kernelState.selectedTabSectionWindow),
        onDestinationSelected: (int selectedIndex) {
          kernelState.switchActiveNavigationSubPanel(ActiveConsoleTabWindow.values[selectedIndex]);
        },
        destinations: ActiveConsoleTabWindow.values.map((ActiveConsoleTabWindow tabWindow) {
          return NavigationDestination(
            icon: Icon(_navIconForTab(tabWindow)),
            label: _navLabelForTab(tabWindow),
          );
        }).toList(),
      ),
    );
  }
}

// ========================================================================================
// STAGE 7: DASHBOARD METRICS PANEL VIEW
// ========================================================================================
class DashboardMetricsPanelView extends StatelessWidget {
  const DashboardMetricsPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    final OperationalKernelStateProvider kernelState = context.watch<OperationalKernelStateProvider>();
    final SystemNodeTelemetryRecord metrics = kernelState.activeSystemMetricsData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${metrics.focalCityString} (${metrics.focalCountryCode})",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricStatCard(
                  label: "Temperature",
                  value: "${metrics.currentMetricCelsius.toStringAsFixed(1)}°C",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricStatCard(
                  label: "Humidity",
                  value: "${metrics.currentMetricHumidity}%",
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricStatCard(
                  label: "Latency",
                  value: "${metrics.networkLatencyMillis.toStringAsFixed(0)} ms",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricStatCard(
                  label: "Trend Vector",
                  value: kernelState.activeCalculatedThermalTrajectoryVector.toStringAsFixed(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MetricStatCard(
            label: "Condition",
            value: metrics.explicitConditionLabel,
          ),
        ],
      ),
    );
  }
}

class _MetricStatCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricStatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

// ========================================================================================
// STAGE 8: HISTORICAL TREND CHART PANEL VIEW
// ========================================================================================
class HistoricalTrendChartPanelView extends StatelessWidget {
  const HistoricalTrendChartPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    final OperationalKernelStateProvider kernelState = context.watch<OperationalKernelStateProvider>();
    final List<double> tempBuffer = kernelState.runningTemperatureRegistryBuffer;

    if (tempBuffer.isEmpty) {
      return const Center(child: Text("No historical data recorded yet."));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: const FlTitlesData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (int i = 0; i < tempBuffer.length; i++) FlSpot(i.toDouble(), tempBuffer[i]),
              ],
              isCurved: true,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================================================================
// STAGE 9: INTERACTIVE TERMINAL SHELL PANEL VIEW
// ========================================================================================
class InteractiveTerminalShellPanelView extends StatefulWidget {
  const InteractiveTerminalShellPanelView({super.key});

  @override
  State<InteractiveTerminalShellPanelView> createState() => _InteractiveTerminalShellPanelViewState();
}

class _InteractiveTerminalShellPanelViewState extends State<InteractiveTerminalShellPanelView> {
  final TextEditingController _instructionInputController = TextEditingController();

  @override
  void dispose() {
    _instructionInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final OperationalKernelStateProvider kernelState = context.watch<OperationalKernelStateProvider>();
    final List<TerminalShellMessageLine> shellLogs = kernelState.virtualConsoleShellLogs;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: shellLogs.length,
            itemBuilder: (BuildContext context, int index) {
              final TerminalShellMessageLine line = shellLogs[index];
              return Text(
                "${line.isInstructionInputType ? '>' : '#'} ${line.textStringContent}",
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: line.isInstructionInputType ? Colors.cyanAccent : Colors.white70,
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _instructionInputController,
                  decoration: const InputDecoration(
                    hintText: "Enter command...",
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (String value) {
                    kernelState.submitTerminalShellInstruction(value);
                    _instructionInputController.clear();
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send_rounded),
                onPressed: () {
                  kernelState.submitTerminalShellInstruction(_instructionInputController.text);
                  _instructionInputController.clear();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ========================================================================================
// STAGE 10: FIRMWARE SETTINGS CONFIG PANEL VIEW
// ========================================================================================
class FirmwareSettingsConfigPanelView extends StatefulWidget {
  const FirmwareSettingsConfigPanelView({super.key});

  @override
  State<FirmwareSettingsConfigPanelView> createState() => _FirmwareSettingsConfigPanelViewState();
}

class _FirmwareSettingsConfigPanelViewState extends State<FirmwareSettingsConfigPanelView> {
  late final TextEditingController _ipAddressController;

  @override
  void initState() {
    super.initState();
    final OperationalKernelStateProvider kernelState = context.read<OperationalKernelStateProvider>();
    _ipAddressController = TextEditingController(text: kernelState.remoteHardwareIpTargetAddress);
  }

  @override
  void dispose() {
    _ipAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final OperationalKernelStateProvider kernelState = context.watch<OperationalKernelStateProvider>();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text("Target Hardware IP Address", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _ipAddressController,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onSubmitted: kernelState.modifyTargetDeviceIpAddressSpace,
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text("Local Simulation Mode"),
          value: kernelState.isLocalSystemSimulationModeActive,
          onChanged: kernelState.toggleLocalSimulationModeActiveState,
        ),
        const SizedBox(height: 24),
        Text("Thermal Alert Threshold (°C)", style: Theme.of(context).textTheme.titleMedium),
        Slider(
          value: kernelState.thresholdAlertMaxCelsiusSetting.toDouble(),
          min: 20,
          max: 90,
          divisions: 70,
          label: "${kernelState.thresholdAlertMaxCelsiusSetting}°C",
          onChanged: (double value) {
            kernelState.updateThermalAlertThresholdSetting(value.round());
          },
        ),
        const SizedBox(height: 24),
        Text("${CoreSystemMetadata.kernelVersion} • ${CoreSystemMetadata.developerSignature}",
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// ========================================================================================
// STAGE 11: DEVICE SYSTEM LOGS PANEL VIEW
// ========================================================================================
class DeviceSystemLogsPanelView extends StatelessWidget {
  const DeviceSystemLogsPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    final OperationalKernelStateProvider kernelState = context.watch<OperationalKernelStateProvider>();
    final List<DiagnosticSystemArchivedLog> logs = kernelState.coreSystemDiagnosticHardwareLogs;

    if (logs.isEmpty) {
      return const Center(child: Text("No diagnostic log entries recorded yet."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: logs.length,
      itemBuilder: (BuildContext context, int index) {
        final DiagnosticSystemArchivedLog log = logs[logs.length - 1 - index];
        return ListTile(
          dense: true,
          leading: Text(log.severityLevel, style: const TextStyle(fontSize: 11)),
          title: Text(log.systemLogPayloadMessage),
          subtitle: Text("${log.moduleTag} • ${log.entryTimestamp}"),
        );
      },
    );
  }
}
