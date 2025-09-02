import 'package:flutter/material.dart';

/// Widget para exibir quando recursos premium são necessários
/// 
/// Responsabilidades:
/// - Informar sobre necessidade de premium
/// - Botão para upgrade
/// - Design atrativo para conversão
/// - Suporte a tema claro/escuro
class FavoritosPremiumRequiredWidget extends StatelessWidget {
  const FavoritosPremiumRequiredWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone de premium
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.diamond,
                size: 40,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Título
            Text(
              'Recurso Premium',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Descrição
            Text(
              'Os diagnósticos salvos são um recurso exclusivo para usuários Premium.\n\nFaça upgrade e tenha acesso a todos os recursos do app!',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Lista de benefícios
            _buildBenefitsList(isDark),
            
            const SizedBox(height: 32),
            
            // Botão de upgrade
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleUpgradePressed(context),
                icon: const Icon(Icons.diamond),
                label: const Text('Fazer Upgrade'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói lista de benefícios premium
  Widget _buildBenefitsList(bool isDark) {
    final benefits = [
      'Salvar diagnósticos ilimitados',
      'Histórico completo de consultas',
      'Suporte técnico prioritário',
      'Acesso antecipado a novidades',
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.orange.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Benefícios Premium:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          ...benefits.map((benefit) => _buildBenefitItem(benefit, isDark)),
        ],
      ),
    );
  }

  /// Constrói item de benefício
  Widget _buildBenefitItem(String benefit, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green.shade600,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              benefit,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Manipula ação de upgrade
  void _handleUpgradePressed(BuildContext context) {
    // TODO: Navegar para página de assinatura
    // Navigator.pushNamed(context, '/subscription');
  }
}