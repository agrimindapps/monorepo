enum TipoValidacao { erro, aviso }

class ResultadoValidacao {
  final String mensagem;
  final TipoValidacao tipo;

  ResultadoValidacao({
    required this.mensagem,
    required this.tipo,
  });
}

class ValidacaoService {
  static const double MAX_PATRIMONIO = 1000000000.0; // 1 bilhão
  static const double MAX_DESPESAS = 1000000.0; // 1 milhão
  static const double MAX_APORTE = 1000000.0; // 1 milhão
  static const double MIN_RETORNO = 0.1; // 0.1%
  static const double MAX_RETORNO = 50.0; // 50%
  static const double MIN_TAXA_RETIRADA = 0.5; // 0.5%
  static const double MAX_TAXA_RETIRADA = 10.0; // 10%

  List<ResultadoValidacao> validarPatrimonioAtual(double valor) {
    List<ResultadoValidacao> resultados = [];

    if (valor.isNaN || valor.isInfinite) {
      resultados.add(ResultadoValidacao(
        mensagem: 'Valor inválido para o patrimônio',
        tipo: TipoValidacao.erro,
      ));
    } else if (valor < 0) {
      resultados.add(ResultadoValidacao(
        mensagem: 'O patrimônio atual não pode ser negativo',
        tipo: TipoValidacao.erro,
      ));
    } else if (valor == 0) {
      resultados.add(ResultadoValidacao(
        mensagem: 'O patrimônio atual não pode ser zero',
        tipo: TipoValidacao.aviso,
      ));
    } else if (valor > MAX_PATRIMONIO) {
      resultados.add(ResultadoValidacao(
        mensagem: 'Patrimônio muito alto. Considere consultar um especialista',
        tipo: TipoValidacao.aviso,
      ));
    }

    return resultados;
  }

  List<ResultadoValidacao> validarDespesasMensais(
      double valor, double patrimonioAtual) {
    List<ResultadoValidacao> resultados = [];

    if (valor.isNaN || valor.isInfinite) {
      resultados.add(ResultadoValidacao(
        mensagem: 'Valor inválido para despesas mensais',
        tipo: TipoValidacao.erro,
      ));
    } else if (valor < 0) {
      resultados.add(ResultadoValidacao(
        mensagem: 'As despesas mensais não podem ser negativas',
        tipo: TipoValidacao.erro,
      ));
    } else if (valor == 0) {
      resultados.add(ResultadoValidacao(
        mensagem: 'As despesas mensais não podem ser zero',
        tipo: TipoValidacao.erro,
      ));
    } else if (valor > MAX_DESPESAS) {
      resultados.add(ResultadoValidacao(
        mensagem: 'Despesas muito altas. Verifique se o valor está correto',
        tipo: TipoValidacao.aviso,
      ));
    } else if (valor > (patrimonioAtual * MAX_TAXA_RETIRADA / 100 / 12)) {
      resultados.add(ResultadoValidacao(
        mensagem: 'Com o patrimônio atual, suas despesas são insustentáveis',
        tipo: TipoValidacao.aviso,
      ));
    }

    return resultados;
  }

  List<ResultadoValidacao> validarAporteMensal(
      double valor, double despesasMensais) {
    List<ResultadoValidacao> resultados = [];

    if (valor.isNaN || valor.isInfinite) {
      resultados.add(ResultadoValidacao(
        mensagem: 'Valor inválido para aporte mensal',
        tipo: TipoValidacao.erro,
      ));
    } else if (valor < 0) {
      resultados.add(ResultadoValidacao(
        mensagem: 'O aporte mensal não pode ser negativo',
        tipo: TipoValidacao.erro,
      ));
    } else if (valor == 0) {
      resultados.add(ResultadoValidacao(
        mensagem:
            'Sem aportes mensais, será mais difícil atingir a independência',
        tipo: TipoValidacao.aviso,
      ));
    } else if (valor > MAX_APORTE) {
      resultados.add(ResultadoValidacao(
        mensagem: 'Aporte muito alto. Verifique se o valor está correto',
        tipo: TipoValidacao.aviso,
      ));
    } else if (valor > despesasMensais * 0.7) {
      resultados.add(ResultadoValidacao(
        mensagem: 'Aporte superior a 70% das despesas. Isso é sustentável?',
        tipo: TipoValidacao.aviso,
      ));
    }

    return resultados;
  }

  List<ResultadoValidacao> validarRetornoAnual(double valor) {
    List<ResultadoValidacao> resultados = [];

    if (valor.isNaN || valor.isInfinite) {
      resultados.add(ResultadoValidacao(
        mensagem: 'Valor inválido para retorno anual',
        tipo: TipoValidacao.erro,
      ));
    } else if (valor < MIN_RETORNO) {
      resultados.add(ResultadoValidacao(
        mensagem:
            'O retorno anual deve ser pelo menos ${MIN_RETORNO.toString()}%',
        tipo: TipoValidacao.erro,
      ));
    } else if (valor > MAX_RETORNO) {
      resultados.add(ResultadoValidacao(
        mensagem: 'O retorno anual não deve exceder ${MAX_RETORNO.toString()}%',
        tipo: TipoValidacao.erro,
      ));
    } else if (valor > 15) {
      resultados.add(ResultadoValidacao(
        mensagem:
            'Retorno muito otimista. Considere reduzir para maior segurança',
        tipo: TipoValidacao.aviso,
      ));
    }

    return resultados;
  }

  List<ResultadoValidacao> validarTaxaRetirada(double valor) {
    List<ResultadoValidacao> resultados = [];

    if (valor.isNaN || valor.isInfinite) {
      resultados.add(ResultadoValidacao(
        mensagem: 'Valor inválido para taxa de retirada',
        tipo: TipoValidacao.erro,
      ));
    } else if (valor < MIN_TAXA_RETIRADA) {
      resultados.add(ResultadoValidacao(
        mensagem:
            'A taxa de retirada deve ser pelo menos ${MIN_TAXA_RETIRADA.toString()}%',
        tipo: TipoValidacao.erro,
      ));
    } else if (valor > MAX_TAXA_RETIRADA) {
      resultados.add(ResultadoValidacao(
        mensagem:
            'A taxa de retirada não deve exceder ${MAX_TAXA_RETIRADA.toString()}%',
        tipo: TipoValidacao.erro,
      ));
    } else if (valor > 4) {
      resultados.add(ResultadoValidacao(
        mensagem: 'Taxa acima de 4% pode comprometer a sustentabilidade',
        tipo: TipoValidacao.aviso,
      ));
    }

    return resultados;
  }
  
  /// Valida se os valores combinados podem causar overflow nos cálculos
  List<ResultadoValidacao> validarCombinacaoParametros({
    required double patrimonioAtual,
    required double despesasMensais,
    required double aporteMensal,
    required double retornoAnual,
    required double taxaRetirada,
  }) {
    List<ResultadoValidacao> resultados = [];
    
    try {
      // Testa se a combinação pode causar overflow
      double patrimonioNecessario = (despesasMensais * 12) / taxaRetirada;
      
      if (patrimonioNecessario > MAX_PATRIMONIO) {
        resultados.add(ResultadoValidacao(
          mensagem: 'Combinação de parâmetros resulta em cálculos extremos',
          tipo: TipoValidacao.erro,
        ));
        return resultados;
      }
      
      // Verifica se o tempo de cálculo seria muito alto
      if (patrimonioAtual < patrimonioNecessario) {
        double diferenca = patrimonioNecessario - patrimonioAtual;
        if (aporteMensal > 0 && diferenca / aporteMensal > (200 * 12)) {
          resultados.add(ResultadoValidacao(
            mensagem: 'Com esses parâmetros, o cálculo levaria mais de 200 anos',
            tipo: TipoValidacao.aviso,
          ));
        }
      }
      
      // Verifica cenário matematicamente impossível
      if (aporteMensal == 0 && patrimonioAtual < patrimonioNecessario && retornoAnual <= 0) {
        resultados.add(ResultadoValidacao(
          mensagem: 'Sem aportes e sem retorno positivo, a independência é impossível',
          tipo: TipoValidacao.erro,
        ));
      }
      
    } catch (e) {
      resultados.add(ResultadoValidacao(
        mensagem: 'Erro ao validar combinação de parâmetros',
        tipo: TipoValidacao.erro,
      ));
    }
    
    return resultados;
  }
  
  /// Sanitiza valores de entrada para prevenir ataques
  static double sanitizarValor(double valor) {
    if (valor.isNaN || valor.isInfinite) {
      return 0.0;
    }
    
    // Limita valores extremos
    if (valor < -MAX_PATRIMONIO) {
      return -MAX_PATRIMONIO;
    }
    
    if (valor > MAX_PATRIMONIO) {
      return MAX_PATRIMONIO;
    }
    
    return valor;
  }
}
