import 'package:core/core.dart';

/// Provider to manage the selected plan in the subscription UI
final selectedPlanProvider = NotifierProvider<SelectedPlanNotifier, String>(
  SelectedPlanNotifier.new,
);

class SelectedPlanNotifier extends Notifier<String> {
  @override
  String build() {
    return 'yearly';
  }

  void set(String value) {
    state = value;
  }
}
