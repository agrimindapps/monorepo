import 'package:flutter/foundation.dart';

class TasksProvider extends ChangeNotifier {
  List<dynamic> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<dynamic> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // TODO: Implement actual loading logic
      await Future.delayed(const Duration(seconds: 2));
      _tasks = [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}