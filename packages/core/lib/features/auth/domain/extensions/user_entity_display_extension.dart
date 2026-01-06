import 'package:core/src/domain/entities/user_entity.dart';

/// Extension para garantir valores seguros de exibição do UserEntity
extension UserEntityDisplayExtension on UserEntity {
  /// Retorna displayName seguro (nunca null/empty)
  /// 
  /// Ordem de fallback:
  /// 1. displayName (se não vazio)
  /// 2. Parte local do email (antes do @)
  /// 3. "Usuário"
  String get safeDisplayName {
    if (displayName.trim().isNotEmpty) {
      return displayName.trim();
    }
    
    if (email.isNotEmpty) {
      final emailParts = email.split('@');
      if (emailParts.isNotEmpty && emailParts.first.isNotEmpty) {
        return emailParts.first;
      }
    }
    
    return 'Usuário';
  }
  
  /// Retorna email seguro
  String get safeEmail {
    if (email.trim().isNotEmpty) {
      return email.trim();
    }
    return 'Sem email';
  }
  
  /// Retorna iniciais do nome para avatar
  String get initials {
    final name = safeDisplayName;
    if (name.isEmpty || name == 'Usuário') return 'U';
    
    final words = name.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return 'U';
    
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
  }
}
