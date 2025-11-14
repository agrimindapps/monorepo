import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../database/petiveti_database.dart';
import '../models/reminder_model.dart';

abstract class ReminderLocalDataSource {
  Future<List<ReminderModel>> getReminders(String userId);
  Future<List<ReminderModel>> getRemindersByAnimalId(int animalId);
  Future<List<ReminderModel>> getActiveReminders(String userId);
  Future<List<ReminderModel>> getUpcomingReminders(String userId);
  Future<ReminderModel?> getReminderById(int id);
  Future<int> addReminder(ReminderModel reminder);
  Future<bool> updateReminder(ReminderModel reminder);
  Future<bool> deleteReminder(int id);
  Future<bool> markAsCompleted(int id);
  Stream<List<ReminderModel>> watchRemindersByAnimalId(int animalId);
}

@LazySingleton(as: ReminderLocalDataSource)
class ReminderLocalDataSourceImpl implements ReminderLocalDataSource {
  final PetivetiDatabase _database;

  ReminderLocalDataSourceImpl(this._database);

  @override
  Future<List<ReminderModel>> getReminders(String userId) async {
    final reminders = await _database.reminderDao.getAllReminders(userId);
    return reminders.map(_toModel).toList();
  }

  @override
  Future<List<ReminderModel>> getRemindersByAnimalId(int animalId) async {
    final reminders = await _database.reminderDao.getRemindersByAnimal(animalId);
    return reminders.map(_toModel).toList();
  }

  @override
  Future<List<ReminderModel>> getActiveReminders(String userId) async {
    final reminders = await _database.reminderDao.getActiveReminders(userId);
    return reminders.map(_toModel).toList();
  }

  @override
  Future<List<ReminderModel>> getUpcomingReminders(String userId) async {
    final reminders = await _database.reminderDao.getUpcomingReminders(userId);
    return reminders.map(_toModel).toList();
  }

  @override
  Future<ReminderModel?> getReminderById(int id) async {
    final reminder = await _database.reminderDao.getReminderById(id);
    return reminder != null ? _toModel(reminder) : null;
  }

  @override
  Future<int> addReminder(ReminderModel reminder) async {
    final companion = _toCompanion(reminder);
    return await _database.reminderDao.createReminder(companion);
  }

  @override
  Future<bool> updateReminder(ReminderModel reminder) async {
    if (reminder.id == null) return false;
    final companion = _toCompanion(reminder, forUpdate: true);
    return await _database.reminderDao.updateReminder(reminder.id!, companion);
  }

  @override
  Future<bool> deleteReminder(int id) async {
    return await _database.reminderDao.deleteReminder(id);
  }

  @override
  Future<bool> markAsCompleted(int id) async {
    return await _database.reminderDao.markAsCompleted(id);
  }

  @override
  Stream<List<ReminderModel>> watchRemindersByAnimalId(int animalId) {
    return _database.reminderDao.watchRemindersByAnimal(animalId)
        .map((reminders) => reminders.map(_toModel).toList());
  }

  ReminderModel _toModel(Reminder reminder) {
    return ReminderModel(
      id: reminder.id,
      animalId: reminder.animalId,
      title: reminder.title,
      description: reminder.description,
      dateTime: reminder.reminderDateTime,
      frequency: reminder.frequency,
      isCompleted: reminder.isCompleted,
      notificationEnabled: reminder.notificationEnabled,
      userId: reminder.userId,
      createdAt: reminder.createdAt,
      isDeleted: reminder.isDeleted,
    );
  }

  RemindersCompanion _toCompanion(ReminderModel model, {bool forUpdate = false}) {
    if (forUpdate) {
      return RemindersCompanion(
        id: model.id != null ? Value(model.id!) : const Value.absent(),
        animalId: model.animalId != null ? Value(model.animalId) : const Value.absent(),
        title: Value(model.title),
        description: Value.ofNullable(model.description),
        reminderDateTime: Value(model.dateTime),
        frequency: Value.ofNullable(model.frequency),
        isCompleted: Value(model.isCompleted),
        notificationEnabled: Value(model.notificationEnabled),
        userId: Value(model.userId),
      );
    }

    return RemindersCompanion.insert(
      animalId: model.animalId != null ? Value(model.animalId) : const Value.absent(),
      title: model.title,
      description: Value.ofNullable(model.description),
      reminderDateTime: model.dateTime,
      frequency: Value.ofNullable(model.frequency),
      isCompleted: Value(model.isCompleted),
      notificationEnabled: Value(model.notificationEnabled),
      userId: model.userId,
      createdAt: Value(model.createdAt),
    );
  }
}
