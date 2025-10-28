/// User roles for authorization
enum UserRole {
  admin('admin', 'Administrador'),
  editor('editor', 'Editor'),
  viewer('viewer', 'Visualizador');

  final String value;
  final String displayName;

  const UserRole(this.value, this.displayName);

  /// Check if role has write permissions
  bool get canWrite => this == admin || this == editor;

  /// Check if role has delete permissions
  bool get canDelete => this == admin;

  /// Check if role has admin permissions
  bool get isAdmin => this == admin;

  /// Parse from string value
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value.toLowerCase(),
      orElse: () => UserRole.viewer,
    );
  }
}
