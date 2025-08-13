// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:purchases_flutter/purchases_flutter.dart';

/// Widget que exibe os planos de assinatura disponíveis
class SubscriptionPlansWidget extends StatefulWidget {
  final List<Package> packages;
  final bool isPremium;
  final Function(Package) onPurchase;
  final VoidCallback onRestore;
  final VoidCallback onManage;

  const SubscriptionPlansWidget({
    super.key,
    required this.packages,
    required this.isPremium,
    required this.onPurchase,
    required this.onRestore,
    required this.onManage,
  });

  @override
  State<SubscriptionPlansWidget> createState() => _SubscriptionPlansWidgetState();
}

class _SubscriptionPlansWidgetState extends State<SubscriptionPlansWidget> {
  Package? selectedPackage;

  @override
  void initState() {
    super.initState();
    // Seleciona o primeiro pacote por padrão se houver pacotes disponíveis
    if (widget.packages.isNotEmpty) {
      selectedPackage = widget.packages.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPremium) {
      return _buildCurrentSubscriptionCard(context);
    }

    if (widget.packages.isEmpty) {
      return _buildNoPlansAvailable(context);
    }

    return _buildAvailablePlans(context);
  }

  /// Mostra card da assinatura atual
  Widget _buildCurrentSubscriptionCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade600,
            Colors.green.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assinatura Ativa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Aproveite todos os benefícios premium',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Gerenciar',
                  Icons.settings,
                  Colors.white,
                  Colors.green.shade600,
                  widget.onManage,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Restaurar',
                  Icons.refresh,
                  Colors.green.shade600,
                  Colors.white,
                  widget.onRestore,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Mostra planos disponíveis
  Widget _buildAvailablePlans(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Escolha seu Plano',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Desbloqueie todo o potencial do ReceitaAgro',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          
          const SizedBox(height: 20),
          
          ...widget.packages.map((package) {
            final isSelected = selectedPackage == package;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPlanCard(context, package, isSelected),
            );
          }),
          
          const SizedBox(height: 20),
          
          // Botão único de assinatura
          _buildSubscribeButton(context),
          
          const SizedBox(height: 16),
          
          _buildRestoreButton(context),
        ],
      ),
    );
  }

  /// Mostra card individual do plano
  Widget _buildPlanCard(BuildContext context, Package package, bool isSelected) {
    final storeProduct = package.storeProduct;
    final isAnnual = storeProduct.identifier.toLowerCase().contains('annual') ||
                     storeProduct.identifier.toLowerCase().contains('ano');
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPackage = package;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Colors.green.shade400 
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Radio button
              Radio<Package>(
                value: package,
                groupValue: selectedPackage,
                onChanged: (Package? value) {
                  setState(() {
                    selectedPackage = value;
                  });
                },
                activeColor: Colors.green.shade600,
              ),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPlanTitle(storeProduct),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPlanDescription(isAnnual),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '3 dias grátis, depois ${storeProduct.priceString}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'GRÁTIS',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade600,
                    ),
                  ),
                  Text(
                    '3 dias',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isAnnual)
                    Text(
                      'Economize 30%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w500,
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

  /// Botão único de assinatura
  Widget _buildSubscribeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: selectedPackage != null 
            ? () => widget.onPurchase(selectedPackage!)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: const Text(
          'Assinar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Botão para restaurar compras
  Widget _buildRestoreButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: widget.onRestore,
        icon: Icon(Icons.refresh, color: Colors.grey.shade600),
        label: Text(
          'Restaurar Compras',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  /// Mostra mensagem quando não há planos disponíveis
  Widget _buildNoPlansAvailable(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Planos Indisponíveis',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Não foi possível carregar os planos de assinatura. Verifique sua conexão e tente novamente.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: widget.onRestore,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  /// Cria botão de ação personalizado
  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );
  }

  /// Retorna título do plano baseado no produto
  String _getPlanTitle(StoreProduct product) {
    final id = product.identifier.toLowerCase();
    
    if (id.contains('annual') || id.contains('ano')) {
      return 'Plano Anual';
    } else if (id.contains('monthly') || id.contains('mensal')) {
      return 'Plano Mensal';
    } else if (id.contains('trimestral') || id.contains('quarterly')) {
      return 'Plano Trimestral';
    }
    
    return product.title;
  }

  /// Retorna descrição do plano
  String _getPlanDescription(bool isAnnual) {
    if (isAnnual) {
      return 'Melhor custo-benefício • Renovação automática';
    }
    return 'Flexibilidade mensal • Renovação automática';
  }
}
