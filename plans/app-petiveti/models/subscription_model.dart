enum SubscriptionStatus {
  free,
  active,
  expired,
  canceled,
}

enum SubscriptionPlan {
  monthly,
  yearly,
}

class SubscriptionModel {
  final String? id;
  final SubscriptionStatus status;
  final SubscriptionPlan? plan;
  final DateTime? inicioEm;
  final DateTime? terminaEm;
  final DateTime? proximaCobranca;
  final double? preco;
  final String? moeda;
  final bool autoRenovacao;

  SubscriptionModel({
    this.id,
    this.status = SubscriptionStatus.free,
    this.plan,
    this.inicioEm,
    this.terminaEm,
    this.proximaCobranca,
    this.preco,
    this.moeda = 'BRL',
    this.autoRenovacao = true,
  });

  SubscriptionModel copyWith({
    String? id,
    SubscriptionStatus? status,
    SubscriptionPlan? plan,
    DateTime? inicioEm,
    DateTime? terminaEm,
    DateTime? proximaCobranca,
    double? preco,
    String? moeda,
    bool? autoRenovacao,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      status: status ?? this.status,
      plan: plan ?? this.plan,
      inicioEm: inicioEm ?? this.inicioEm,
      terminaEm: terminaEm ?? this.terminaEm,
      proximaCobranca: proximaCobranca ?? this.proximaCobranca,
      preco: preco ?? this.preco,
      moeda: moeda ?? this.moeda,
      autoRenovacao: autoRenovacao ?? this.autoRenovacao,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'plan': plan?.name,
      'inicioEm': inicioEm?.millisecondsSinceEpoch,
      'terminaEm': terminaEm?.millisecondsSinceEpoch,
      'proximaCobranca': proximaCobranca?.millisecondsSinceEpoch,
      'preco': preco,
      'moeda': moeda,
      'autoRenovacao': autoRenovacao,
    };
  }

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.free,
      ),
      plan: json['plan'] != null
          ? SubscriptionPlan.values.firstWhere(
              (e) => e.name == json['plan'],
              orElse: () => SubscriptionPlan.monthly,
            )
          : null,
      inicioEm: json['inicioEm'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['inicioEm'])
          : null,
      terminaEm: json['terminaEm'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['terminaEm'])
          : null,
      proximaCobranca: json['proximaCobranca'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['proximaCobranca'])
          : null,
      preco: json['preco']?.toDouble(),
      moeda: json['moeda'] ?? 'BRL',
      autoRenovacao: json['autoRenovacao'] ?? true,
    );
  }

  bool get isPremium => 
      status == SubscriptionStatus.active && 
      (terminaEm == null || terminaEm!.isAfter(DateTime.now()));

  String get statusTexto {
    switch (status) {
      case SubscriptionStatus.free:
        return 'Gratuito';
      case SubscriptionStatus.active:
        return 'Ativo';
      case SubscriptionStatus.expired:
        return 'Expirado';
      case SubscriptionStatus.canceled:
        return 'Cancelado';
    }
  }

  String get planTexto {
    if (plan == null) return '';
    switch (plan!) {
      case SubscriptionPlan.monthly:
        return 'Mensal';
      case SubscriptionPlan.yearly:
        return 'Anual';
    }
  }

  String get precoFormatado {
    if (preco == null) return '';
    return 'R\$ ${preco!.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  int get diasRestantes {
    if (terminaEm == null) return 0;
    final agora = DateTime.now();
    final diferenca = terminaEm!.difference(agora);
    return diferenca.inDays > 0 ? diferenca.inDays : 0;
  }

  static List<String> get beneficiosPremium => [
    'Pets ilimitados',
    'Backup automático na nuvem',
    'Relatórios veterinários avançados',
    'Lembretes personalizados',
    'Histórico médico completo',
    'Controle de vacinas avançado',
    'Sem anúncios',
    'Suporte prioritário',
  ];
}