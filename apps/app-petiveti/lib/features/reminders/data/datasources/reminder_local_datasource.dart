import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../database/petiveti_database.dart' as db;
import '../../domain/entities/reminder.dart';
import '../models/reminder_model.dart';

abstract class ReminderLocalDataSource {
  Future<List<ReminderModel>> getReminders(String userId);
  Future<List<ReminderModel>> getRemindersByAnimalId(String animalId);
  Future<List<ReminderModel>> getActiveReminders(String userId);
  Future<List<ReminderModel>> getUpcomingReminders(String userId);
  Future<ReminderModel?> getReminderById(int id);
  Future<int> addReminder(ReminderModel reminder);
  Future<bool> updateReminder(ReminderModel reminder);
  Future<bool> deleteReminder(int id);
  Future<bool> markAsCompleted(int id);
  Stream<List<ReminderModel>> watchRemindersByAnimalId(int animalId);
  Future<List<ReminderModel>> getTodayReminders(String userId);
  Future<List<ReminderModel>> getOverdueReminders(String userId);
}

@LazySingleton(as: ReminderLocalDataSource)
class ReminderLocalDataSourceImpl implements ReminderLocalDataSource {
  final db.PetivetiDatabase _database;

  ReminderLocalDataSourceImpl(this._database);

  @override
  Future<List<ReminderModel>> getReminders(String userId) async {
    final reminders = await _database.reminderDao.getAllReminders(userId);
    return reminders.map(_toModel).toList();
  }

  @override
  Future<List<ReminderModel>> getRemindersByAnimalId(String animalId) async {
    final intId = int.tryParse(animalId) ?? 0;
    final reminders = await _database.reminderDao.getRemindersByAnimal(
      intId,
    );
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
    final id = int.tryParse(reminder.id) ?? 0;
    final companion = _toCompanion(reminder, forUpdate: true);
    return await _database.reminderDao.updateReminder(id, companion);
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
    return _database.reminderDao
        .watchRemindersByAnimal(animalId)
        .map((reminders) => reminders.map(_toModel).toList());
  }

  ReminderModel _toModel(db.Reminder reminder) {
    return ReminderModel(
      id: reminder.id.toString(),
      animalId: reminder.animalId?.toString() ?? '',
      title: reminder.title,
      description: reminder.description ?? '',
      scheduledDate: reminder.reminderDateTime,
      type: ReminderType.general,
      priority: ReminderPriority.medium,
      status: reminder.isCompleted
          ? ReminderStatus.completed
          : ReminderStatus.active,
      isRecurring: reminder.frequency != null && reminder.frequency != 'once',
      recurringDays: null,
      userId: reminder.userId,
      createdAt: reminder.createdAt,
      updatedAt: reminder.createdAt,
    );
  }

  db.RemindersCompanion _toCompanion(
    ReminderModel model, {
    bool forUpdate = false,
  }) {
    if (forUpdate) {
      return db.RemindersCompanion(
        id: Value(int.tryParse(model.id) ?? 0),
        animalId: Value(int.tryParse(model.animalId) ?? 0),
        title: Value(model.title),
        description: Value.ofNullable(model.description),
        reminderDateTime: Value(model.scheduledDate),
        frequency: Value('once'),
        isCompleted: Value(model.status == ReminderStatus.completed),
        notificationEnabled: Value(true),
        userId: Value(model.userId),
      );
    }

    return db.RemindersCompanion.insert(
      animalId: Value(int.tryParse(model.animalId) ?? 0),
      title: model.title,
      description: Value.ofNullable(model.description),
      reminderDateTime: model.scheduledDate,
      frequency: Value('once'),
      isCompleted: Value(model.status == ReminderStatus.completed),
      notificationEnabled: Value(true),
      userId: model.userId,
      createdAt: Value(model.createdAt),
    );
  }

  @override
  Future<List<ReminderModel>> getTodayReminders(String userId) {
    // TODO: implement getTodayReminders
    throw UnimplementedError();
  }

  @override
  Future<List<ReminderModel>> getOverdueReminders(String userId) {
    // TODO: implement getOverdueReminders
    throw UnimplementedError();
  }
}
