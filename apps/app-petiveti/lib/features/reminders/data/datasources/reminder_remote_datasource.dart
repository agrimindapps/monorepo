import '../../../../core/error/exceptions.dart';
import '../../../../core/network/firebase_service.dart';
import '../../domain/entities/reminder.dart';
import '../models/reminder_model.dart';

abstract class ReminderRemoteDataSource {
  Future<List<ReminderModel>> getReminders(String userId);
  Future<List<ReminderModel>> getTodayReminders(String userId);
  Future<List<ReminderModel>> getOverdueReminders(String userId);
  Future<ReminderModel?> getReminderById(String id);
  Future<String> addReminder(ReminderModel reminder, String userId);
  Future<void> updateReminder(ReminderModel reminder);
  Future<void> deleteReminder(String id);
  Stream<List<ReminderModel>> streamReminders(String userId);
  Stream<ReminderModel?> streamReminder(String id);
}

class ReminderRemoteDataSourceImpl implements ReminderRemoteDataSource {
  final FirebaseService _firebaseService;

  ReminderRemoteDataSourceImpl({
    FirebaseService? firebaseService,
  }) : _firebaseService = firebaseService ?? FirebaseService.instance;

  @override
  Future<List<ReminderModel>> getReminders(String userId) async {
    try {
      final reminders = await _firebaseService.getCollection<ReminderModel>(
        FirebaseCollections.reminders,
        where: [
          WhereCondition('userId', isEqualTo: userId),
        ],
        orderBy: [
          const OrderByCondition('dueDate'),
        ],
        fromMap: ReminderModel.fromMap,
      );
      
      return reminders;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao buscar lembretes do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ReminderModel>> getTodayReminders(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final reminders = await _firebaseService.getCollection<ReminderModel>(
        FirebaseCollections.reminders,
        where: [
          WhereCondition('userId', isEqualTo: userId),
          WhereCondition('dueDate', isGreaterThanOrEqualTo: startOfDay.toIso8601String()),
          WhereCondition('dueDate', isLessThanOrEqualTo: endOfDay.toIso8601String()),
          WhereCondition('status', isNotEqualTo: ReminderStatus.completed.name),
        ],
        orderBy: [
          const OrderByCondition('dueDate'),
        ],
        fromMap: ReminderModel.fromMap,
      );
      
      return reminders;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao buscar lembretes de hoje do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ReminderModel>> getOverdueReminders(String userId) async {
    try {
      final now = DateTime.now();

      final reminders = await _firebaseService.getCollection<ReminderModel>(
        FirebaseCollections.reminders,
        where: [
          WhereCondition('userId', isEqualTo: userId),
          WhereCondition('dueDate', isLessThan: now.toIso8601String()),
          WhereCondition('status', isNotEqualTo: ReminderStatus.completed.name),
        ],
        orderBy: [
          const OrderByCondition('dueDate'),
        ],
        fromMap: ReminderModel.fromMap,
      );
      
      return reminders;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao buscar lembretes atrasados do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<ReminderModel?> getReminderById(String id) async {
    try {
      final reminder = await _firebaseService.getDocument<ReminderModel>(
        FirebaseCollections.reminders,
        id,
        ReminderModel.fromMap,
      );
      
      return reminder;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao buscar lembrete do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<String> addReminder(ReminderModel reminder, String userId) async {
    try {
      final reminderData = reminder.copyWith(
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final id = await _firebaseService.addDocument<ReminderModel>(
        FirebaseCollections.reminders,
        reminderData,
        (reminder) => reminder.toMap(),
      );
      
      return id;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao adicionar lembrete no servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateReminder(ReminderModel reminder) async {
    try {
      final updatedReminder = reminder.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _firebaseService.setDocument<ReminderModel>(
        FirebaseCollections.reminders,
        reminder.id,
        updatedReminder,
        (reminder) => reminder.toMap(),
        merge: true,
      );
    } catch (e) {
      throw ServerException(
        message: 'Erro ao atualizar lembrete no servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteReminder(String id) async {
    try {
      await _firebaseService.deleteDocument(
        FirebaseCollections.reminders,
        id,
      );
    } catch (e) {
      throw ServerException(
        message: 'Erro ao deletar lembrete do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Stream<List<ReminderModel>> streamReminders(String userId) {
    try {
      return _firebaseService.streamCollection<ReminderModel>(
        FirebaseCollections.reminders,
        where: [
          WhereCondition('userId', isEqualTo: userId),
        ],
        orderBy: [
          const OrderByCondition('dueDate'),
        ],
        fromMap: ReminderModel.fromMap,
      );
    } catch (e) {
      throw ServerException(
        message: 'Erro ao escutar lembretes do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Stream<ReminderModel?> streamReminder(String id) {
    try {
      return _firebaseService.streamDocument<ReminderModel>(
        FirebaseCollections.reminders,
        id,
        ReminderModel.fromMap,
      );
    } catch (e) {
      throw ServerException(
        message: 'Erro ao escutar lembrete do servidor: ${e.toString()}',
      );
    }
  }
}
