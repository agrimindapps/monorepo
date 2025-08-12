// Dart imports:
import 'dart:async';

// Project imports:
import '../../../core/services/sync_firebase_service.dart';
import '../models/73_user.dart';

/// Repository para User usando SyncFirebaseService unificado
class UserRepository {
  late final SyncFirebaseService<User> _syncService;

  UserRepository() {
    _syncService = SyncFirebaseService.getInstance<User>(
      'users',
      User.fromMap,
      (user) => user.toMap(),
    );
  }

  /// Inicializar o repositório
  Future<void> initialize() async {
    await _syncService.initialize();
  }

  /// Stream de todos os usuários
  Stream<List<User>> get usersStream => _syncService.dataStream;

  /// Stream de status de sincronização
  Stream<SyncStatus> get syncStatusStream => _syncService.syncStatusStream;

  /// Stream de conectividade
  Stream<bool> get connectivityStream => _syncService.connectivityStream;

  /// Buscar todos os usuários
  Future<List<User>> findAll() => _syncService.findAll();

  /// Buscar usuário por ID
  Future<User?> findById(String id) => _syncService.findById(id);

  /// Criar novo usuário
  Future<String> create(User user) => _syncService.create(user);

  /// Atualizar usuário
  Future<void> update(String id, User user) => _syncService.update(id, user);

  /// Deletar usuário
  Future<void> delete(String id) => _syncService.delete(id);

  /// Limpar todos os usuários
  Future<void> clear() => _syncService.clear();

  /// Forçar sincronização
  Future<void> forceSync() => _syncService.forceSync();

  // Métodos específicos para User

  /// Stream do usuário atual por ID
  Stream<User?> watchUserById(String userId) {
    return usersStream.map((users) {
      try {
        return users.firstWhere((user) => user.id == userId);
      } catch (e) {
        return null;
      }
    });
  }

  /// Stream de usuários ativos
  Stream<List<User>> watchActiveUsers() {
    return usersStream.map((users) =>
        users.where((user) => user.isActive).toList()
          ..sort((a, b) => a.name.compareTo(b.name)));
  }

  /// Buscar usuário por email
  Future<User?> findByEmail(String email) async {
    final users = await findAll();
    try {
      return users.firstWhere(
          (user) => user.email.toLowerCase() == email.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  /// Buscar usuários por nome (busca parcial)
  Future<List<User>> searchByName(String name) async {
    final users = await findAll();
    final searchTerm = name.toLowerCase();
    return users
        .where((user) =>
            user.name.toLowerCase().contains(searchTerm) && user.isActive)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Buscar usuários por email (busca parcial)
  Future<List<User>> searchByEmail(String email) async {
    final users = await findAll();
    final searchTerm = email.toLowerCase();
    return users
        .where((user) =>
            user.email.toLowerCase().contains(searchTerm) && user.isActive)
        .toList()
      ..sort((a, b) => a.email.compareTo(b.email));
  }

  /// Atualizar nome do usuário
  Future<void> updateName(String userId, String newName) async {
    final user = await findById(userId);
    if (user != null) {
      final updatedUser = user.copyWith(name: newName);
      updatedUser.markAsModified();
      await update(userId, updatedUser);
    }
  }

  /// Atualizar email do usuário
  Future<void> updateEmail(String userId, String newEmail) async {
    final user = await findById(userId);
    if (user != null) {
      final updatedUser = user.copyWith(email: newEmail);
      updatedUser.markAsModified();
      await update(userId, updatedUser);
    }
  }

  /// Atualizar avatar do usuário
  Future<void> updateAvatar(String userId, String? avatarUrl) async {
    final user = await findById(userId);
    if (user != null) {
      final updatedUser = user.copyWith(avatarUrl: avatarUrl);
      updatedUser.markAsModified();
      await update(userId, updatedUser);
    }
  }

  /// Ativar usuário
  Future<void> activateUser(String userId) async {
    final user = await findById(userId);
    if (user != null) {
      final updatedUser = user.copyWith(isActive: true);
      updatedUser.markAsModified();
      await update(userId, updatedUser);
    }
  }

  /// Desativar usuário
  Future<void> deactivateUser(String userId) async {
    final user = await findById(userId);
    if (user != null) {
      final updatedUser = user.copyWith(isActive: false);
      updatedUser.markAsModified();
      await update(userId, updatedUser);
    }
  }

  /// Verificar se email já existe
  Future<bool> emailExists(String email) async {
    final user = await findByEmail(email);
    return user != null;
  }

  /// Criar ou atualizar usuário (upsert)
  Future<String> createOrUpdate(User user) async {
    final existingUser = await findById(user.id);

    if (existingUser != null) {
      // Atualizar usuário existente
      final updatedUser = existingUser.copyWith(
        name: user.name,
        email: user.email,
        avatarUrl: user.avatarUrl,
        isActive: user.isActive,
      );
      updatedUser.markAsModified();
      await update(user.id, updatedUser);
      return user.id;
    } else {
      // Criar novo usuário
      return await create(user);
    }
  }

  /// Obter estatísticas de usuários
  Future<Map<String, int>> getStats() async {
    final users = await findAll();

    return {
      'total': users.length,
      'active': users.where((user) => user.isActive).length,
      'inactive': users.where((user) => !user.isActive).length,
      'withAvatar': users.where((user) => user.avatarUrl != null).length,
    };
  }

  /// Obter informações de debug
  Map<String, dynamic> getDebugInfo() => _syncService.getDebugInfo();

  /// Limpar recursos
  void dispose() {
    _syncService.dispose();
  }
}
