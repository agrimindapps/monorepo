import 'package:flutter/material.dart';

import '../widgets/premium_benefits_widget.dart';
import '../widgets/premium_plans_widget.dart';

/// Página de subscription premium para NebulaList
///
/// Responsabilidades:
/// - Apresentar planos de assinatura com design atraente
/// - Permitir seleção de planos (mockado)
/// - Simular processo de compra com SnackBars
/// - Design moderno com gradiente Deep Purple → Indigo
///
/// Estrutura:
/// - Header com gradiente e botão de fechar
/// - Título hero centralizado
/// - Seção de planos (3 cards lado a lado)
/// - Seção de benefícios (8 items)
/// - Botões de ação (Começar Agora, Restaurar)
/// - Footer com links de termos e privacidade
class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  String? _selectedPlanId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF673AB7), // Deep Purple
              Color(0xFF5E35B1), // Deep Purple 600
              Color(0xFF3F51B5), // Indigo
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header com botão de fechar
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'NebulaList Premium',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// Conteúdo principal scrollável
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildHeroTitle(),
          const SizedBox(height: 32),
          _buildPlansSection(),
          const SizedBox(height: 40),
          const PremiumBenefitsWidget(),
          const SizedBox(height: 40),
          _buildActionButtons(),
          const SizedBox(height: 24),
          _buildFooterLinks(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Título hero centralizado
  Widget _buildHeroTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'Organize sua vida\nsem limites',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
      ),
    );
  }

  /// Seção de planos
  Widget _buildPlansSection() {
    return PremiumPlansWidget(
      selectedPlanId: _selectedPlanId,
      onPlanSelected: (planId) {
        setState(() {
          _selectedPlanId = planId;
        });
      },
    );
  }

  /// Botões de ação
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Botão principal - Começar Agora
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _onStartNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Começar Agora',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Botão secundário - Restaurar Compras
          TextButton(
            onPressed: _onRestorePurchases,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              'Restaurar Compras',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Footer com links
  Widget _buildFooterLinks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: _onTermsOfService,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white.withValues(alpha: 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text(
              'Termos',
              style: TextStyle(fontSize: 12),
            ),
          ),
          Text(
            '•',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          TextButton(
            onPressed: _onPrivacyPolicy,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white.withValues(alpha: 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text(
              'Privacidade',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Handler para começar agora
  void _onStartNow() {
    if (_selectedPlanId == null) {
      _showSnackBar('Selecione um plano primeiro', Colors.orange);
      return;
    }

    _showSnackBar(
      'Compra em desenvolvimento - Plano selecionado: $_selectedPlanId',
      Colors.blue,
    );
  }

  /// Handler para restaurar compras
  void _onRestorePurchases() {
    _showSnackBar(
      'Restauração em desenvolvimento',
      Colors.blue,
    );
  }

  /// Handler para termos de serviço
  void _onTermsOfService() {
    _showSnackBar(
      'Termos de Serviço - Em breve',
      Colors.blue,
    );
  }

  /// Handler para política de privacidade
  void _onPrivacyPolicy() {
    _showSnackBar(
      'Política de Privacidade - Em breve',
      Colors.blue,
    );
  }

  /// Exibe SnackBar com mensagem
  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
