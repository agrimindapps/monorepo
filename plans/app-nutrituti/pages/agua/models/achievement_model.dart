// Package imports:
import 'package:get/get.dart';

class WaterAchievement {
  final String title;
  final String description;
  final RxBool _isUnlocked = false.obs;

  WaterAchievement({
    required this.title,
    required this.description,
    bool isUnlocked = false,
  }) {
    _isUnlocked.value = isUnlocked;
  }

  bool get isUnlocked => _isUnlocked.value;

  void unlock() {
    _isUnlocked.value = true;
  }
}
