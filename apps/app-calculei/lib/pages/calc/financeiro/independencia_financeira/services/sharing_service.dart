// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:app_calculei/pages/calc/financeiro/independencia_financeira/services/models/independencia_financeira_model.dart';
import 'package:app_calculei/services/formatting_service.dart';

class SharingService {
  static final SharingService _instance = SharingService._internal();
  factory SharingService() => _instance;
  SharingService._internal();

  final _formattingService = FormattingService();

  /// Compartilha resultado como texto
  Future<void> compartilharTexto(IndependenciaFinanceiraModel modelo) async {
    try {
      final texto = _gerarTextoCompartilhamento(modelo);
      await Share.share(texto);
    } catch (e) {
      throw Exception('Erro ao compartilhar: $e');
    }
  }

  /// Compartilha resultado com opções personalizadas
  Future<void> compartilharComOpcoes(
    IndependenciaFinanceiraModel modelo, {
    bool incluirDetalhes = true,
    bool incluirDicas = true,
    String? mensagemPersonalizada,
  }) async {
    try {
      final texto = gerarTextoPersonalizado(
        modelo,
        incluirDetalhes: incluirDetalhes,
        incluirDicas: incluirDicas,
        mensagemPersonalizada: mensagemPersonalizada,
      );
      
      await Share.share(texto);
    } catch (e) {
      throw Exception('Erro ao compartilhar: $e');
    }
  }

  /// Copia resultado para clipboard
  Future<void> copiarParaClipboard(IndependenciaFinanceiraModel modelo) async {
    try {
      final texto = _gerarTextoCompartilhamento(modelo);
      await Clipboard.setData(ClipboardData(text: texto));
    } catch (e) {
      throw Exception('Erro ao copiar: $e');
    }
  }

  /// Gera preview do texto de compartilhamento
  String gerarPreview(IndependenciaFinanceiraModel modelo) {
    return _gerarTextoCompartilhamento(modelo);
  }

  /// Gera texto básico para compartilhamento
  String _gerarTextoCompartilhamento(IndependenciaFinanceiraModel modelo) {
    final buffer = StringBuffer();
    
    buffer.writeln('🎯 INDEPENDÊNCIA FINANCEIRA');
    buffer.writeln('');
    buffer.writeln('📊 RESULTADOS DA SIMULAÇÃO:');
    buffer.writeln('');
    
    // Dados principais
    buffer.writeln('💰 Patrimônio Atual: ${_formattingService.formatarMoeda(modelo.patrimonioAtual)}');
    buffer.writeln('🎯 Patrimônio Necessário: ${_formattingService.formatarMoeda(modelo.patrimonioNecessario)}');
    buffer.writeln('💸 Despesas Mensais: ${_formattingService.formatarMoeda(modelo.despesasMensais)}');
    buffer.writeln('📈 Aporte Mensal: ${_formattingService.formatarMoeda(modelo.aporteMensal)}');
    buffer.writeln('');
    
    // Resultado principal
    if (modelo.anosParaIndependencia == 0) {
      buffer.writeln('🎉 PARABÉNS! Você já atingiu a independência financeira!');
      buffer.writeln('💰 Renda Mensal Atual: ${_formattingService.formatarMoeda(modelo.rendaMensalAtual)}');
    } else {
      buffer.writeln('⏱️ Tempo para Independência: ${_formattingService.formatarAnos(modelo.anosParaIndependencia)}');
      buffer.writeln('💰 Renda Mensal Futura: ${_formattingService.formatarMoeda(modelo.despesasMensais)}');
    }
    
    buffer.writeln('');
    buffer.writeln('📱 Calculado com o app Calculei');
    buffer.writeln('💡 Planeje seu futuro financeiro!');
    
    return buffer.toString();
  }

  /// Gera texto personalizado para compartilhamento
  String gerarTextoPersonalizado(
    IndependenciaFinanceiraModel modelo, {
    bool incluirDetalhes = true,
    bool incluirDicas = true,
    String? mensagemPersonalizada,
  }) {
    final buffer = StringBuffer();
    
    // Mensagem personalizada
    if (mensagemPersonalizada != null && mensagemPersonalizada.isNotEmpty) {
      buffer.writeln(mensagemPersonalizada);
      buffer.writeln('');
    }
    
    buffer.writeln('🎯 MINHA SIMULAÇÃO DE INDEPENDÊNCIA FINANCEIRA');
    buffer.writeln('');
    
    // Resultado principal destacado
    if (modelo.anosParaIndependencia == 0) {
      buffer.writeln('🎉 JÁ CONQUISTEI A INDEPENDÊNCIA FINANCEIRA!');
      buffer.writeln('');
      buffer.writeln('💰 Posso retirar mensalmente: ${_formattingService.formatarMoeda(modelo.rendaMensalAtual)}');
    } else {
      buffer.writeln('⏱️ Faltam ${_formattingService.formatarAnos(modelo.anosParaIndependencia)} para minha independência!');
      buffer.writeln('');
      buffer.writeln('🎯 Meta: ${_formattingService.formatarMoeda(modelo.patrimonioNecessario)}');
    }
    
    if (incluirDetalhes) {
      buffer.writeln('');
      buffer.writeln('📊 DETALHES DA SIMULAÇÃO:');
      buffer.writeln('• Patrimônio atual: ${_formattingService.formatarMoeda(modelo.patrimonioAtual)}');
      buffer.writeln('• Gastos mensais: ${_formattingService.formatarMoeda(modelo.despesasMensais)}');
      buffer.writeln('• Investimento mensal: ${_formattingService.formatarMoeda(modelo.aporteMensal)}');
      buffer.writeln('• Retorno esperado: ${_formattingService.formatarPercentual(modelo.retornoAnual * 100)} ao ano');
      buffer.writeln('• Taxa de retirada: ${_formattingService.formatarPercentual(modelo.taxaRetirada * 100)} ao ano');
    }
    
    if (incluirDicas) {
      buffer.writeln('');
      buffer.writeln('💡 DICAS PARA ACELERAR SUA INDEPENDÊNCIA:');
      
      if (modelo.anosParaIndependencia > 20) {
        buffer.writeln('• Considere aumentar seus aportes mensais');
        buffer.writeln('• Revise seus gastos para reduzir despesas');
        buffer.writeln('• Busque formas de aumentar sua renda');
      } else if (modelo.anosParaIndependencia > 10) {
        buffer.writeln('• Você está no caminho certo!');
        buffer.writeln('• Mantenha a disciplina nos investimentos');
        buffer.writeln('• Revise periodicamente seus objetivos');
      } else {
        buffer.writeln('• Excelente planejamento!');
        buffer.writeln('• Continue focado em seus objetivos');
        buffer.writeln('• Considere diversificar seus investimentos');
      }
    }
    
    buffer.writeln('');
    buffer.writeln('📱 Simule você também no app Calculei');
    buffer.writeln('#IndependenciaFinanceira #InvestimentosPessoais #PlanejamentoFinanceiro');
    
    return buffer.toString();
  }

  /// Gera texto resumido para redes sociais
  String gerarTextoResumo(IndependenciaFinanceiraModel modelo) {
    final buffer = StringBuffer();
    
    if (modelo.anosParaIndependencia == 0) {
      buffer.writeln('🎉 INDEPENDÊNCIA FINANCEIRA CONQUISTADA!');
      buffer.writeln('');
      buffer.writeln('💰 Renda passiva mensal: ${_formattingService.formatarMoedaCompacta(modelo.rendaMensalAtual)}');
    } else {
      buffer.writeln('🎯 Minha meta de independência financeira:');
      buffer.writeln('');
      buffer.writeln('⏱️ ${_formattingService.formatarAnos(modelo.anosParaIndependencia)}');
      buffer.writeln('💰 ${_formattingService.formatarMoedaCompacta(modelo.patrimonioNecessario)}');
    }
    
    buffer.writeln('');
    buffer.writeln('📱 Calculado no app Calculei');
    buffer.writeln('#IndependenciaFinanceira #Investimentos');
    
    return buffer.toString();
  }

  /// Verifica se o compartilhamento está disponível
  static Future<bool> isCompartilhamentoDisponivel() async {
    try {
      // Assume que o compartilhamento está sempre disponível
      return true;
    } catch (e) {
      return false;
    }
  }
}
