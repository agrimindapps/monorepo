// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../core/services/info_device_service.dart';
import '../../services/premium_service.dart';
import '../../widgets/section_title_widget.dart';

class DesenvolvimentoSection extends StatefulWidget {
  const DesenvolvimentoSection({super.key});

  @override
  State<DesenvolvimentoSection> createState() => _DesenvolvimentoSectionState();
}

class _DesenvolvimentoSectionState extends State<DesenvolvimentoSection> {
  bool _isDevelopmentVersion = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkDevelopmentVersion();
  }

  Future<void> _checkDevelopmentVersion() async {
    final isDev = await InfoDeviceService.isDevelopmentVersion();
    if (mounted) {
      setState(() {
        _isDevelopmentVersion = isDev;
        _isLoading = false;
      });
    }
  }

  Future<void> _generateTestSubscription() async {
    try {
      // Gerar assinatura de teste real usando PremiumService
      final premiumService = Get.find<PremiumService>();
      await premiumService.generateTestSubscription();
      
      Get.snackbar(
        'Assinatura de Teste',
        'Assinatura local gerada com sucesso! Status premium ativo por 30 dias.',
        icon: const Icon(Icons.check_circle, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao gerar assinatura de teste: $e',
        icon: const Icon(Icons.error, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _removeTestSubscription() async {
    try {
      // Remover assinatura de teste real usando PremiumService
      final premiumService = Get.find<PremiumService>();
      await premiumService.removeTestSubscription();
      
      Get.snackbar(
        'Assinatura de Teste',
        'Assinatura local removida com sucesso! Status premium desativado.',
        icon: const Icon(Icons.check_circle, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao remover assinatura de teste: $e',
        icon: const Icon(Icons.error, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Só exibe a seção se for versão de desenvolvimento
    if (_isLoading) {
      return const SizedBox.shrink();
    }
    
    if (!_isDevelopmentVersion) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitleWidget(
          title: 'Desenvolvimento',
          icon: FontAwesome.code_solid,
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Opção para gerar assinatura de teste
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.verified_user,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Gerar Assinatura Local',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text(
                  'Cria uma assinatura local para testes',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: _generateTestSubscription,
                trailing: const Icon(Icons.chevron_right),
              ),
              
              const Divider(height: 1, indent: 16, endIndent: 16),
              
              // Opção para remover assinatura de teste
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.remove_circle,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Remover Assinatura Local',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text(
                  'Remove a assinatura local de testes',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: _removeTestSubscription,
                trailing: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
