// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../models/16_vacina_model.dart';
import '../../controllers/vacina_page_controller.dart';
import '../styles/vacina_colors.dart';
import '../styles/vacina_constants.dart';

/// A reusable card widget for displaying individual vaccine information.
/// 
/// This widget encapsulates the display logic for a single vaccine record,
/// including status indicators, dates, and action buttons. It provides
/// consistent styling and behavior across the application.
/// 
/// Features:
/// - Status-based color coding
/// - Responsive design
/// - Action buttons for edit/delete
/// - Accessibility support
/// - Theme-aware styling
class VacinaCardWidget extends StatelessWidget {
  final VacinaVet vacina;
  final VacinaPageController controller;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const VacinaCardWidget({
    super.key,
    required this.vacina,
    required this.controller,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final dataAplicacao = controller.formatDateToString(vacina.dataAplicacao);
    final proximaAplicacao = controller.formatDateToString(vacina.proximaDose);
    final diasRestantes = controller.getDiasParaVencimento(vacina);

    return RepaintBoundary(
      child: Card(
        key: ValueKey('vacina_card_${vacina.id}'),
        margin: const EdgeInsets.symmetric(
          horizontal: VacinaConstants.espacamentoPadrao,
          vertical: VacinaConstants.espacamentoPadrao / 2,
        ),
        child: ListTile(
          leading: Icon(
          Icons.vaccines,
          color: _getVacinaIconColor(context),
          size: VacinaConstants.tamanhoIconeVacina,
        ),
        title: Text(
          vacina.nomeVacina,
          style: TextStyle(
            fontWeight: _getVacinaTextWeight(),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aplicação: $dataAplicacao'),
            Text(
              'Próxima: $proximaAplicacao',
              style: TextStyle(
                color: _getVacinaTextColor(context),
                fontWeight: _getVacinaTextWeight(),
              ),
            ),
            _buildStatusText(diasRestantes, context),
            if (vacina.observacoes != null && vacina.observacoes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: VacinaConstants.espacamentoMinimoTop),
                child: Text(
                  'Obs: ${vacina.observacoes}',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: VacinaColors.cinza(context),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        trailing: showActions ? _buildActionButtons(context) : null,
        ),
      ),
    );
  }

  /// Builds the status text showing days until/overdue.
  Widget _buildStatusText(int diasRestantes, BuildContext context) {
    if (diasRestantes >= 0) {
      return Text(
        'Faltam $diasRestantes dias',
        style: TextStyle(
          fontSize: 12,
          color: _getVacinaTextColor(context),
        ),
      );
    } else {
      return Text(
        'Atrasada há ${-diasRestantes} dias',
        style: TextStyle(
          color: VacinaColors.atrasada(context),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }
  }

  /// Builds the action buttons for edit and delete.
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onEdit,
          tooltip: 'Editar vacina',
          iconSize: 20,
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
          tooltip: 'Excluir vacina',
          iconSize: 20,
        ),
      ],
    );
  }

  /// Gets the appropriate icon color based on vaccine status.
  Color _getVacinaIconColor(BuildContext context) {
    if (controller.isVacinaAtrasada(vacina)) {
      return VacinaColors.atrasada(context);
    }
    if (controller.isVacinaProximaDoVencimento(vacina)) {
      return VacinaColors.proximaDoVencimento(context);
    }
    return VacinaColors.emDia(context);
  }

  /// Gets the appropriate text color based on vaccine status.
  Color _getVacinaTextColor(BuildContext context) {
    if (controller.isVacinaAtrasada(vacina)) {
      return VacinaColors.textoAtrasada(context);
    }
    if (controller.isVacinaProximaDoVencimento(vacina)) {
      return VacinaColors.textoProximaDoVencimento(context);
    }
    return VacinaColors.textoEmDia(context);
  }

  /// Gets the appropriate text weight based on vaccine status.
  FontWeight _getVacinaTextWeight() {
    if (controller.isVacinaAtrasada(vacina) ||
        controller.isVacinaProximaDoVencimento(vacina)) {
      return FontWeight.bold;
    }
    return FontWeight.normal;
  }
}
