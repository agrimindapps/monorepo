import 'package:flutter/foundation.dart';
import '../controller/favoritos_controller.dart';

class MockNavigationService implements INavigationService {
  @override
  void navigateToDefensivoDetails(String id) {
    debugPrint('Mock: Navigate to defensivo details: $id');
    // TODO: Implement actual navigation when routes are available
  }

  @override
  void navigateToPragaDetails(String id) {
    debugPrint('Mock: Navigate to praga details: $id');
    // TODO: Implement actual navigation when routes are available
  }

  @override
  void navigateToDiagnosticoDetails(String id) {
    debugPrint('Mock: Navigate to diagnostico details: $id');
    // TODO: Implement actual navigation when routes are available
  }
}