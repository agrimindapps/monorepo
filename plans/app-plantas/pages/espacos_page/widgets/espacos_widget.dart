// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/espacos_controller.dart';

class EspacosWidget extends GetView<EspacosController> {
  const EspacosWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading) {
        return _buildLoadingState(context);
      }

      if (controller.displayedEspacos.isEmpty) {
        return _buildEmptyState(context);
      }

      return _buildEspacosList(context);
    });
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32);
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white60 : Colors.black54;
    const lightTextColor = Colors.white;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.space_dashboard_outlined,
            size: 64.0,
            color: secondaryTextColor,
          ),
          const SizedBox(height: 16.0),
          Text(
            'espacos.nenhum_espaco'.tr,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'espacos.descricao_vazio'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 32.0),
          ElevatedButton.icon(
            onPressed: controller.showNovoEspacoDialog,
            icon: const Icon(Icons.add),
            label: Text('espacos.criar_primeiro'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: lightTextColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEspacosList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: controller.displayedEspacos.length,
      itemBuilder: (context, index) {
        final espaco = controller.displayedEspacos[index];
        return _buildEspacoCard(context, espaco);
      },
    );
  }

  Widget _buildEspacoCard(BuildContext context, espaco) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32);
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white60 : Colors.black54;
    final errorColor = isDark ? Colors.redAccent : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          backgroundColor: primaryColor.withValues(alpha: 0.1),
          child: Icon(
            Icons.space_dashboard,
            color: primaryColor,
          ),
        ),
        title: Text(
          espaco.nome,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        subtitle: Text(
          '0 ${'espacos.planta_plural'.tr}', // TODO: Implementar contagem
          style: TextStyle(
            fontSize: 14.0,
            color: secondaryTextColor,
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: secondaryTextColor,
          ),
          color: isDark ? const Color(0xFF2E2E2E) : Colors.white,
          surfaceTintColor:
              isDark ? const Color(0xFF3E3E3E) : const Color(0xFFF5F5F5),
          shadowColor:
              isDark ? Colors.black26 : Colors.grey.withValues(alpha: 0.2),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) => _handleMenuAction(value, espaco),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: textColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'espacos.editar'.tr,
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20, color: errorColor),
                  const SizedBox(width: 8),
                  Text('espacos.remover'.tr,
                      style: TextStyle(color: errorColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, espaco) {
    switch (action) {
      case 'edit':
        controller.showEditarEspacoDialog(espaco);
        break;
      case 'delete':
        _showDeleteConfirmation(espaco);
        break;
    }
  }

  void _showDeleteConfirmation(espaco) {
    final context = Get.context;
    if (context == null) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorColor = isDark ? Colors.redAccent : Colors.red;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: Text('espacos.confirmar_remocao'.tr),
        content:
            Text('espacos.mensagem_remocao'.trParams({'nome': espaco.nome})),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('espacos.cancelar'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removerEspaco(espaco);
            },
            style: TextButton.styleFrom(
              foregroundColor: errorColor,
            ),
            child: Text('espacos.confirmar'.tr),
          ),
        ],
      ),
    );
  }
}
