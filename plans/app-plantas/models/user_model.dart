class UserModel {
  final String? id;
  final String? nome;
  final String? email;
  final String? avatarUrl;
  final DateTime? criadoEm;
  final bool isPremium;

  UserModel({
    this.id,
    this.nome,
    this.email,
    this.avatarUrl,
    this.criadoEm,
    this.isPremium = false,
  });

  UserModel copyWith({
    String? id,
    String? nome,
    String? email,
    String? avatarUrl,
    DateTime? criadoEm,
    bool? isPremium,
  }) {
    return UserModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      criadoEm: criadoEm ?? this.criadoEm,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'avatarUrl': avatarUrl,
      'criadoEm': criadoEm?.millisecondsSinceEpoch,
      'isPremium': isPremium,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      criadoEm: json['criadoEm'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['criadoEm'])
          : null,
      isPremium: json['isPremium'] ?? false,
    );
  }

  bool get isLoggedIn => id != null && email != null;

  String get nomeExibicao => nome ?? email?.split('@').first ?? 'Usuário';

  String get iniciais {
    if (nome != null && nome!.length >= 2) {
      final palavras = nome!.split(' ');
      if (palavras.length >= 2) {
        return (palavras[0][0] + palavras[1][0]).toUpperCase();
      }
      return nome!.substring(0, 2).toUpperCase();
    }
    if (email != null && email!.isNotEmpty) {
      return email!.substring(0, 2).toUpperCase();
    }
    return 'US';
  }
}
