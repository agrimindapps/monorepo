// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../database/planta_config_model.dart';
import '../../../database/planta_model.dart';
import '../../../database/tarefa_model.dart';
import '../../../repository/planta_config_repository.dart';
import '../../../repository/planta_repository.dart';
import '../controller/nova_tarefas_controller.dart';
import '../services/care_type_service.dart';
import '../services/date_formatting_service.dart';

class TarefaDetailsDialog extends StatefulWidget {
  final TarefaModel tarefa;
  final NovaTarefasController controller;

  const TarefaDetailsDialog({
    super.key,
    required this.tarefa,
    required this.controller,
  });

  @override
  State<TarefaDetailsDialog> createState() => _TarefaDetailsDialogState();
}

class _TarefaDetailsDialogState extends State<TarefaDetailsDialog> {
  PlantaModel? planta;
  PlantaConfigModel? plantaConfig;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  DateTime dataConclusao = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadPlantaInfo();
  }

  Future<void> _loadPlantaInfo() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
    });

    try {
      final plantaRepo = PlantaRepository.instance;
      final configRepo = PlantaConfigRepository.instance;

      await plantaRepo.initialize();
      await configRepo.initialize();

      final plantaData = await Future.any([
        plantaRepo.findById(widget.tarefa.plantaId),
        Future.delayed(const Duration(seconds: 10),
            () => throw TimeoutException('Timeout'))
      ]);

      final configData = await Future.any([
        configRepo.findByPlantaId(widget.tarefa.plantaId),
        Future.delayed(const Duration(seconds: 10),
            () => throw TimeoutException('Timeout'))
      ]);

      if (mounted) {
        setState(() {
          planta = plantaData;
          plantaConfig = configData;
          isLoading = false;
          hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = _getErrorMessage(e);
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('Timeout')) {
      return 'Tempo limite excedido ao carregar dados';
    } else if (error.toString().contains('Database')) {
      return 'Erro no banco de dados';
    } else if (error.toString().contains('Connection')) {
      return 'Erro de conexão';
    } else {
      return 'Erro ao carregar informações da planta';
    }
  }

  int _getIntervalo(String tipoCuidado) {
    if (plantaConfig == null) {
      // Valores padrão se não encontrar configuração
      switch (tipoCuidado) {
        case 'agua':
          return 3;
        case 'adubo':
          return 15;
        case 'banho_sol':
          return 7;
        case 'inspecao_pragas':
          return 15;
        case 'poda':
          return 30;
        case 'replantar':
          return 180;
        default:
          return 7;
      }
    }
    return plantaConfig!.getIntervalForCareType(tipoCuidado);
  }

  DateTime _calcularProximoVencimento() {
    final intervalo = _getIntervalo(widget.tarefa.tipoCuidado);
    return DateTime.now().add(Duration(days: intervalo));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32);
    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final cardColor =
        isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF8F9FA);
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white60 : Colors.black54;
    const lightTextColor = Colors.white;

    if (isLoading) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          color: backgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
              const SizedBox(height: 16),
              Text(
                'Carregando informações da planta...',
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (hasError) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          color: backgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar dados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? 'Ocorreu um erro inesperado',
                style: TextStyle(
                  fontSize: 16,
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: secondaryTextColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Fechar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _loadPlantaInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: lightTextColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Tentar novamente',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final cor = widget.controller
        .getCorParaTipoCuidado(widget.tarefa.tipoCuidado, context);
    final icone =
        widget.controller.getIconeParaTipoCuidado(widget.tarefa.tipoCuidado);
    final proximoVencimento = _calcularProximoVencimento();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        color: backgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com ícone e título
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icone,
                    color: cor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CareTypeService.getName(widget.tarefa.tipoCuidado),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      if (planta != null)
                        Text(
                          planta!.nome ?? 'Planta sem nome',
                          style: TextStyle(
                            fontSize: 16,
                            color: secondaryTextColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Informações da tarefa
            _buildInfoCard(
              'Data de vencimento',
              DateFormattingService.formatRelative(widget.tarefa.dataExecucao),
              Icons.calendar_today,
              _isOverdue() ? Theme.of(context).colorScheme.error : cor,
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              'Próximo vencimento',
              DateFormattingService.formatRelative(proximoVencimento),
              Icons.schedule,
              primaryColor,
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              'Intervalo',
              '${_getIntervalo(widget.tarefa.tipoCuidado)} dias',
              Icons.repeat,
              secondaryTextColor,
            ),

            const SizedBox(height: 24),

            // Campo de seleção de data
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: secondaryTextColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event,
                    color: primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data de conclusão',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: _selecionarDataConclusao,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: primaryColor,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormattingService.formatSelection(
                                      dataConclusao),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: secondaryTextColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Voltar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _concluirTarefa,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: lightTextColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Concluir',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String label, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF8F9FA);
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white60 : Colors.black54;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: secondaryTextColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isOverdue() {
    final hoje = DateTime.now();
    final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);
    final tarefaDate = DateTime(
      widget.tarefa.dataExecucao.year,
      widget.tarefa.dataExecucao.month,
      widget.tarefa.dataExecucao.day,
    );
    return tarefaDate.isBefore(hojeDate);
  }

  Future<void> _selecionarDataConclusao() async {
    // Obter locale do sistema ou usar fallback
    final systemLocale = Localizations.localeOf(context);
    final locale = systemLocale.languageCode == 'pt'
        ? systemLocale
        : const Locale('pt', 'BR');

    final dataEscolhida = await showDatePicker(
      context: context,
      initialDate: dataConclusao,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: 'Selecionar data de conclusão',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      locale: locale,
    );

    if (dataEscolhida != null) {
      setState(() {
        dataConclusao = dataEscolhida;
      });
    }
  }

  Future<void> _concluirTarefa() async {
    Navigator.of(context).pop();

    final intervalo = _getIntervalo(widget.tarefa.tipoCuidado);
    await widget.controller
        .marcarTarefaConcluidaComData(widget.tarefa, intervalo, dataConclusao);
  }
}
