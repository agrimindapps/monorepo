// Project imports:
import 'package:app_calculei/constants/calculation_constants.dart';
import 'package:app_calculei/pages/calc/trabalhistas/seguro_desemprego/services/models/seguro_desemprego_model.dart';

class CalculationService {
  SeguroDesempregoModel calculate({
    required double salarioMedio,
    required int tempoTrabalho,
    required int vezesRecebidas,
    required DateTime dataDemissao,
  }) {
    // Verifica se tem direito ao seguro-desemprego
    final verificacaoDireito = _verificarDireito(tempoTrabalho, vezesRecebidas);
    
    if (!verificacaoDireito['temDireito']) {
      return _criarModeloSemDireito(
        salarioMedio,
        tempoTrabalho,
        vezesRecebidas,
        dataDemissao,
        verificacaoDireito['motivo'],
        verificacaoDireito['carencia'],
      );
    }
    
    // Calcula valor da parcela
    final valorParcela = _calcularValorParcela(salarioMedio);
    
    // Calcula quantidade de parcelas
    final quantidadeParcelas = _calcularQuantidadeParcelas(tempoTrabalho, vezesRecebidas);
    
    // Calcula valor total
    final valorTotal = valorParcela * quantidadeParcelas;
    
    // Calcula datas
    final prazoRequerer = dataDemissao.add(const Duration(days: CalculationConstants.prazoRequererDias));
    final inicioPagamento = dataDemissao.add(const Duration(days: 30)); // Aprox. 30 dias após demissão
    final fimPagamento = inicioPagamento.add(Duration(days: (quantidadeParcelas - 1) * CalculationConstants.intervaloParcelasDias));
    
    // Cria cronograma de pagamento
    final cronogramaPagamento = _criarCronogramaPagamento(inicioPagamento, quantidadeParcelas);
    
    return SeguroDesempregoModel(
      salarioMedio: salarioMedio,
      tempoTrabalho: tempoTrabalho,
      vezesRecebidas: vezesRecebidas,
      dataDemissao: dataDemissao,
      valorParcela: valorParcela,
      quantidadeParcelas: quantidadeParcelas,
      valorTotal: valorTotal,
      prazoRequerer: prazoRequerer,
      inicioPagamento: inicioPagamento,
      fimPagamento: fimPagamento,
      cronogramaPagamento: cronogramaPagamento,
      temDireito: true,
      motivoSemDireito: '',
      mesesCarencia: verificacaoDireito['carencia'],
      mesesDesdeUltimo: 0,
    );
  }
  
  Map<String, dynamic> _verificarDireito(int tempoTrabalho, int vezesRecebidas) {
    int carenciaNecessaria;
    
    // Define carência necessária baseada nas vezes que já recebeu
    switch (vezesRecebidas) {
      case 0:
        carenciaNecessaria = CalculationConstants.carenciaPrimeiraVez;
        break;
      case 1:
        carenciaNecessaria = CalculationConstants.carenciaSegundaVez;
        break;
      default:
        carenciaNecessaria = CalculationConstants.carenciaTerceiraVez;
        break;
    }
    
    if (tempoTrabalho < carenciaNecessaria) {
      return {
        'temDireito': false,
        'motivo': 'Tempo de trabalho insuficiente. Necessário: $carenciaNecessaria meses.',
        'carencia': carenciaNecessaria,
      };
    }
    
    return {
      'temDireito': true,
      'motivo': '',
      'carencia': carenciaNecessaria,
    };
  }
  
  double _calcularValorParcela(double salarioMedio) {
    for (final faixa in CalculationConstants.faixasSalario) {
      final min = faixa['min'] as double;
      final max = faixa['max'] as double;
      final multiplicador = faixa['multiplicador'] as double;
      final valorFixo = faixa['valorFixo'] as double;
      
      if (salarioMedio >= min && salarioMedio <= max) {
        final valor = (salarioMedio * multiplicador) + valorFixo;
        
        // Garante que não seja menor que o salário mínimo
        if (valor < CalculationConstants.valorMinimoParcela) {
          return CalculationConstants.valorMinimoParcela;
        }
        
        // Garante que não seja maior que o máximo
        if (valor > CalculationConstants.valorMaximoParcela) {
          return CalculationConstants.valorMaximoParcela;
        }
        
        return valor;
      }
    }
    
    return CalculationConstants.valorMinimoParcela;
  }
  
  int _calcularQuantidadeParcelas(int tempoTrabalho, int vezesRecebidas) {
    // Se nunca recebeu, usa tabela normal
    if (vezesRecebidas == 0) {
      for (final faixa in CalculationConstants.tabelaParcelas) {
        final mesesMin = faixa['mesesMin']!;
        final mesesMax = faixa['mesesMax']!;
        final parcelas = faixa['parcelas']!;
        
        if (tempoTrabalho >= mesesMin && tempoTrabalho <= mesesMax) {
          return parcelas;
        }
      }
    } else {
      // Se já recebeu, usa tabela específica
      for (final faixa in CalculationConstants.tabelaParcelasJaRecebeu) {
        final vezesNecessarias = faixa['vezesRecebidas'] as int;
        final mesesMin = faixa['mesesMin'] as int? ?? 0;
        final mesesMax = faixa['mesesMax'] as int;
        final parcelas = faixa['parcelas'] as int;
        
        if (vezesRecebidas == vezesNecessarias && 
            tempoTrabalho >= mesesMin && 
            tempoTrabalho <= mesesMax) {
          return parcelas;
        }
      }
    }
    
    return 0; // Sem direito
  }
  
  List<DateTime> _criarCronogramaPagamento(DateTime inicio, int quantidadeParcelas) {
    final List<DateTime> cronograma = [];
    
    for (int i = 0; i < quantidadeParcelas; i++) {
      cronograma.add(inicio.add(Duration(days: i * CalculationConstants.intervaloParcelasDias)));
    }
    
    return cronograma;
  }
  
  SeguroDesempregoModel _criarModeloSemDireito(
    double salarioMedio,
    int tempoTrabalho,
    int vezesRecebidas,
    DateTime dataDemissao,
    String motivo,
    int carencia,
  ) {
    return SeguroDesempregoModel(
      salarioMedio: salarioMedio,
      tempoTrabalho: tempoTrabalho,
      vezesRecebidas: vezesRecebidas,
      dataDemissao: dataDemissao,
      valorParcela: 0.0,
      quantidadeParcelas: 0,
      valorTotal: 0.0,
      prazoRequerer: dataDemissao,
      inicioPagamento: dataDemissao,
      fimPagamento: dataDemissao,
      cronogramaPagamento: [],
      temDireito: false,
      motivoSemDireito: motivo,
      mesesCarencia: carencia,
      mesesDesdeUltimo: 0,
    );
  }
  
  String obterDicaTempo(int tempoTrabalho, int vezesRecebidas) {
    final verificacao = _verificarDireito(tempoTrabalho, vezesRecebidas);
    
    if (verificacao['temDireito']) {
      final parcelas = _calcularQuantidadeParcelas(tempoTrabalho, vezesRecebidas);
      return 'Tem direito a $parcelas parcelas';
    } else {
      final carencia = verificacao['carencia'] as int;
      final faltam = carencia - tempoTrabalho;
      return 'Faltam $faltam meses para ter direito';
    }
  }
  
  double calcularPercentualSalario(double valorParcela, double salarioMedio) {
    if (salarioMedio == 0) return 0.0;
    return (valorParcela / salarioMedio) * 100;
  }
}
