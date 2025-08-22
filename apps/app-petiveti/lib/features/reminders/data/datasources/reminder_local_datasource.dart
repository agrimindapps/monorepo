import '../models/reminder_model.dart';

abstract class ReminderLocalDataSource {
  Future<List<ReminderModel>> getReminders(String userId);
  Future<List<ReminderModel>> getRemindersByAnimal(String animalId);
  Future<List<ReminderModel>> getTodayReminders(String userId);
  Future<List<ReminderModel>> getOverdueReminders(String userId);
  Future<List<ReminderModel>> getUpcomingReminders(String userId, int days);
  Future<void> addReminder(ReminderModel reminder);
  Future<void> updateReminder(ReminderModel reminder);
  Future<void> deleteReminder(String reminderId);
  Future<void> cacheReminders(List<ReminderModel> reminders);
}

class ReminderLocalDataSourceImpl implements ReminderLocalDataSource {
  static const String _boxName = 'reminders';
  final Map<String, ReminderModel> _cache = {};

  @override
  Future<List<ReminderModel>> getReminders(String userId) async {
    return _cache.values
        .where((reminder) => reminder.userId == userId)
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  @override
  Future<List<ReminderModel>> getRemindersByAnimal(String animalId) async {
    return _cache.values
        .where((reminder) => reminder.animalId == animalId)
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  @override
  Future<List<ReminderModel>> getTodayReminders(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _cache.values
        .where((reminder) => 
            reminder.userId == userId &&
            reminder.scheduledDate.isAfter(today.subtract(const Duration(milliseconds: 1))) &&
            reminder.scheduledDate.isBefore(tomorrow))
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  @override
  Future<List<ReminderModel>> getOverdueReminders(String userId) async {
    final now = DateTime.now();
    
    return _cache.values
        .where((reminder) => 
            reminder.userId == userId &&
            reminder.status.toString().split('.').last == 'active' &&
            reminder.scheduledDate.isBefore(now))
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  @override
  Future<List<ReminderModel>> getUpcomingReminders(String userId, int days) async {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));

    return _cache.values
        .where((reminder) => 
            reminder.userId == userId &&
            reminder.status.toString().split('.').last == 'active' &&
            reminder.scheduledDate.isAfter(now) &&
            reminder.scheduledDate.isBefore(futureDate))
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  @override
  Future<void> addReminder(ReminderModel reminder) async {
    _cache[reminder.id] = reminder;
  }

  @override
  Future<void> updateReminder(ReminderModel reminder) async {
    _cache[reminder.id] = reminder;
  }

  @override
  Future<void> deleteReminder(String reminderId) async {
    _cache.remove(reminderId);
  }

  @override
  Future<void> cacheReminders(List<ReminderModel> reminders) async {
    for (final reminder in reminders) {
      _cache[reminder.id] = reminder;
    }
  }
}