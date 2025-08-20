// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../consulta_cadastro/consulta_form_view.dart';
import '../../../consulta_cadastro/index.dart';
import '../../index.dart';

class ConsultaList extends StatelessWidget {
  final ConsultaPageController controller;

  const ConsultaList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final consultas = controller.filteredConsultas;

      if (consultas.isEmpty) {
        return const SizedBox.shrink();
      }

      return ListView.builder(
        padding: ConsultaPageStyles.pagePadding,
        itemCount: consultas.length,
        itemBuilder: (context, index) {
          final consulta = consultas[index];
          return _buildConsultaCard(context, consulta, index);
        },
      );
    });
  }

  Widget _buildConsultaCard(BuildContext context, consulta, int index) {
    final date = DateTime.fromMillisecondsSinceEpoch(consulta.dataConsulta);
    final motivoColor = ConsultaUtils.getMotivoColor(consulta.motivo);
    final motivoIcon = ConsultaUtils.getMotivoIcon(consulta.motivo);

    return Card(
      elevation: ConsultaPageStyles.cardElevation,
      shape: ConsultaPageStyles.cardShape,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _onConsultaTap(context, consulta),
        borderRadius: BorderRadius.circular(ConsultaPageStyles.borderRadius),
        child: Padding(
          padding: ConsultaPageStyles.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: motivoColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      motivoIcon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          consulta.motivo,
                          style: ConsultaPageStyles.subtitleStyle.copyWith(
                            color: motivoColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dr(a). ${consulta.veterinario}',
                          style: ConsultaPageStyles.bodyStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        ConsultaUtils.formatDate(date),
                        style: ConsultaPageStyles.captionStyle.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ConsultaUtils.getRelativeTime(date),
                        style: ConsultaPageStyles.captionStyle,
                      ),
                    ],
                  ),
                ],
              ),
              if (consulta.diagnostico.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ConsultaPageStyles.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Diagnóstico',
                        style: ConsultaPageStyles.captionStyle.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        consulta.diagnostico,
                        style: ConsultaPageStyles.bodyStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
              if (consulta.observacoes?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ConsultaPageStyles.primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Observações',
                        style: ConsultaPageStyles.captionStyle.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ConsultaPageStyles.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        consulta.observacoes,
                        style: ConsultaPageStyles.bodyStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (ConsultaUtils.isToday(date))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ConsultaPageStyles.successColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Hoje',
                        style: ConsultaPageStyles.captionStyle.copyWith(
                          color: ConsultaPageStyles.successColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (ConsultaUtils.isThisWeek(date) && !ConsultaUtils.isToday(date))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ConsultaPageStyles.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Esta semana',
                        style: ConsultaPageStyles.captionStyle.copyWith(
                          color: ConsultaPageStyles.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) => _onMenuSelected(context, value, consulta),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: ListTile(
                          leading: Icon(Icons.visibility),
                          title: Text('Visualizar'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Editar'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: ListTile(
                          leading: Icon(Icons.copy),
                          title: Text('Duplicar'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Excluir', style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    child: const Icon(
                      Icons.more_vert,
                      color: ConsultaPageStyles.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onConsultaTap(BuildContext context, consulta) {
    // Navigate to view consulta details using the existing form in view mode
    consultaCadastro(context, consulta);
  }

  void _onMenuSelected(BuildContext context, String value, consulta) {
    switch (value) {
      case 'view':
        _onConsultaTap(context, consulta);
        break;
      case 'edit':
        consultaCadastro(context, consulta);
        break;
      case 'duplicate':
        _showDuplicateDialog(context, consulta);
        break;
      case 'delete':
        _showDeleteDialog(context, consulta);
        break;
    }
  }

  void _showDuplicateDialog(BuildContext context, consulta) {
    Get.dialog(
      AlertDialog(
        title: const Text('Duplicar consulta'),
        content: const Text(
          'Deseja criar uma nova consulta baseada nesta?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Implement duplicate logic
              consultaCadastro(context, consulta);
            },
            style: ConsultaPageStyles.primaryButtonStyle,
            child: const Text('Duplicar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, consulta) {
    Get.dialog(
      AlertDialog(
        title: const Text('Excluir consulta'),
        content: const Text(
          'Tem certeza que deseja excluir esta consulta? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteConsulta(consulta);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ConsultaPageStyles.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
