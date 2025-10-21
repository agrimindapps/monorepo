class ReservaEmergenciaModel {
  final double despesasMensais;
  final double despesasExtras;
  final int mesesDesejados;
  final double valorTotalReserva;

  ReservaEmergenciaModel({
    required this.despesasMensais,
    required this.despesasExtras,
    required this.mesesDesejados,
    required this.valorTotalReserva,
  });

  // Retorna o total de despesas mensais (fixas + extras)
  double get totalMensal => despesasMensais + despesasExtras;

  // Classifica a reserva em categorias
  String get categoriaReserva {
    if (mesesDesejados < 3) {
      return 'Mínima';
    } else if (mesesDesejados >= 3 && mesesDesejados < 6) {
      return 'Básica';
    } else if (mesesDesejados >= 6 && mesesDesejados < 12) {
      return 'Confortável';
    } else {
      return 'Robusta';
    }
  }

  // Retorna descrição da categoria
  String get descricaoCategoria {
    switch (categoriaReserva) {
      case 'Mínima':
        return 'Cobertura apenas para emergências imediatas e muito básicas.';
      case 'Básica':
        return 'Nível recomendado para pessoas com emprego estável e sem dependentes.';
      case 'Confortável':
        return 'Ideal para quem tem família ou trabalha como autônomo/freelancer.';
      case 'Robusta':
        return 'Reserva sólida para longos períodos ou grandes imprevistos.';
      default:
        return '';
    }
  }

  // Cria um modelo vazio para inicialização
  factory ReservaEmergenciaModel.empty() {
    return ReservaEmergenciaModel(
      despesasMensais: 0,
      despesasExtras: 0,
      mesesDesejados: 0,
      valorTotalReserva: 0,
    );
  }
}
