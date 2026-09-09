// lib/feature_kyc.dart
import 'package:flutter/material.dart';

class KycProfileEntity {
  final String identityNumber;
  final String routingVaultToken;
  KycProfileEntity(
      {required this.identityNumber, required this.routingVaultToken});
}

class KycPipelineRepository {
  Future<bool> transmitKycProfileToGovtServers(KycProfileEntity m) async =>
      true;
}

class KycWorkflowViewModel extends ChangeNotifier {
  final KycPipelineRepository repo = KycPipelineRepository();
  Future<bool> dispatchOnboardingTrack(String id, String token) =>
      repo.transmitKycProfileToGovtServers(
          KycProfileEntity(identityNumber: id, routingVaultToken: token));
}
