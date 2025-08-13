class MinhaContaModel {
  final String? nomeUsuario;
  final String? emailUsuario;
  final String? fotoPerfilUrl;
  final bool isLoggedIn;
  final bool isPremium;
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final Map<String, bool> configuracoes;

  const MinhaContaModel({
    this.nomeUsuario,
    this.emailUsuario,
    this.fotoPerfilUrl,
    this.isLoggedIn = false,
    this.isPremium = false,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = '',
    this.configuracoes = const {},
  });

  MinhaContaModel copyWith({
    String? nomeUsuario,
    String? emailUsuario,
    String? fotoPerfilUrl,
    bool? isLoggedIn,
    bool? isPremium,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    Map<String, bool>? configuracoes,
  }) {
    return MinhaContaModel(
      nomeUsuario: nomeUsuario ?? this.nomeUsuario,
      emailUsuario: emailUsuario ?? this.emailUsuario,
      fotoPerfilUrl: fotoPerfilUrl ?? this.fotoPerfilUrl,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      configuracoes: configuracoes ?? this.configuracoes,
    );
  }

  // Getters de conveniência
  String get nomeExibicao => nomeUsuario ?? 'Usuário Anônimo';
  String get emailExibicao => emailUsuario ?? '';
  bool get temFotoPerfil => fotoPerfilUrl?.isNotEmpty == true;
  bool get temDadosCompletos =>
      nomeUsuario?.isNotEmpty == true && emailUsuario?.isNotEmpty == true;

  // Status do usuário
  String get statusUsuario {
    if (!isLoggedIn) return 'Não autenticado';
    if (isPremium) return 'Premium';
    return 'Usuário padrão';
  }

  // Configurações específicas
  bool getConfiguracao(String chave) => configuracoes[chave] ?? false;
  bool get notificacoesAtivas => getConfiguracao('notificacoes');
  bool get backupAutomatico => getConfiguracao('backup');
  bool get modoEscuro => getConfiguracao('tema_escuro');
  bool get sincronizacaoNuvem => getConfiguracao('sincronizacao');

  // Validações
  bool get podeUsarRecursosPremium => isPremium;
  bool get precisaLogin => !isLoggedIn;
  bool get podeExportarDados => isLoggedIn;

  @override
  String toString() {
    return 'MinhaContaModel(nome: $nomeUsuario, loggedIn: $isLoggedIn, premium: $isPremium)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MinhaContaModel &&
        other.nomeUsuario == nomeUsuario &&
        other.emailUsuario == emailUsuario &&
        other.fotoPerfilUrl == fotoPerfilUrl &&
        other.isLoggedIn == isLoggedIn &&
        other.isPremium == isPremium &&
        other.isLoading == isLoading &&
        other.hasError == hasError &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      nomeUsuario,
      emailUsuario,
      fotoPerfilUrl,
      isLoggedIn,
      isPremium,
      isLoading,
      hasError,
      errorMessage,
    );
  }
}

// Modelo para configurações do usuário
class UserPreferences {
  final bool notificacoes;
  final bool backupAutomatico;
  final bool modoEscuro;
  final bool sincronizacaoNuvem;
  final String idioma;
  final String tema;

  const UserPreferences({
    this.notificacoes = true,
    this.backupAutomatico = false,
    this.modoEscuro = false,
    this.sincronizacaoNuvem = false,
    this.idioma = 'pt',
    this.tema = 'claro',
  });

  UserPreferences copyWith({
    bool? notificacoes,
    bool? backupAutomatico,
    bool? modoEscuro,
    bool? sincronizacaoNuvem,
    String? idioma,
    String? tema,
  }) {
    return UserPreferences(
      notificacoes: notificacoes ?? this.notificacoes,
      backupAutomatico: backupAutomatico ?? this.backupAutomatico,
      modoEscuro: modoEscuro ?? this.modoEscuro,
      sincronizacaoNuvem: sincronizacaoNuvem ?? this.sincronizacaoNuvem,
      idioma: idioma ?? this.idioma,
      tema: tema ?? this.tema,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificacoes': notificacoes,
      'backupAutomatico': backupAutomatico,
      'modoEscuro': modoEscuro,
      'sincronizacaoNuvem': sincronizacaoNuvem,
      'idioma': idioma,
      'tema': tema,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      notificacoes: map['notificacoes'] ?? true,
      backupAutomatico: map['backupAutomatico'] ?? false,
      modoEscuro: map['modoEscuro'] ?? false,
      sincronizacaoNuvem: map['sincronizacaoNuvem'] ?? false,
      idioma: map['idioma'] ?? 'pt',
      tema: map['tema'] ?? 'claro',
    );
  }
}

// Modelo para dados do perfil do usuário
class UserProfile {
  final String? nome;
  final String? email;
  final String? telefone;
  final String? fotoUrl;
  final DateTime? dataCadastro;
  final DateTime? ultimoLogin;

  const UserProfile({
    this.nome,
    this.email,
    this.telefone,
    this.fotoUrl,
    this.dataCadastro,
    this.ultimoLogin,
  });

  UserProfile copyWith({
    String? nome,
    String? email,
    String? telefone,
    String? fotoUrl,
    DateTime? dataCadastro,
    DateTime? ultimoLogin,
  }) {
    return UserProfile(
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      ultimoLogin: ultimoLogin ?? this.ultimoLogin,
    );
  }

  bool get isComplete => nome?.isNotEmpty == true && email?.isNotEmpty == true;
  String get nomeExibicao => nome ?? 'Usuário';
  String get emailExibicao => email ?? '';
  bool get temFoto => fotoUrl?.isNotEmpty == true;
}
