/// Enum para definir tipos de usuários
enum UserRole {
  /// Administrador com permissões completas
  admin('admin', 'Administrador'),
  
  /// Usuário regular com acesso read-only
  regular('regular', 'Usuário');

  const UserRole(this.value, this.displayName);
  
  final String value;
  final String displayName;
  
  bool get isAdmin => this == UserRole.admin;
  bool get isRegular => this == UserRole.regular;
}
