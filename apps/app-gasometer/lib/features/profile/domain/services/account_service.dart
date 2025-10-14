import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/notifiers/notifiers.dart';

/// Serviço responsável por operações relacionadas à conta do usuário
abstract class AccountService {
  /// Realiza logout do usuário
  Future<void> logout(WidgetRef ref);

  /// Remove o avatar do usuário
  Future<bool> removeAvatar(WidgetRef ref);

  /// Atualiza o avatar do usuário
  Future<bool> updateAvatar(WidgetRef ref, String base64Image);

  /// Exclui permanentemente a conta do usuário
  Future<bool> deleteAccount(WidgetRef ref);
}

/// Implementação do serviço de conta
class AccountServiceImpl implements AccountService {
  @override
  Future<void> logout(WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();
  }

  @override
  Future<bool> removeAvatar(WidgetRef ref) async {
    return await ref.read(profileProvider.notifier).removeAvatar();
  }

  @override
  Future<bool> updateAvatar(WidgetRef ref, String base64Image) async {
    return await ref.read(profileProvider.notifier).updateAvatar(base64Image);
  }

  @override
  Future<bool> deleteAccount(WidgetRef ref) async {
    // TODO: Implementar exclusão de conta quando disponível na API
    throw UnimplementedError('Account deletion not yet implemented');
  }
}
