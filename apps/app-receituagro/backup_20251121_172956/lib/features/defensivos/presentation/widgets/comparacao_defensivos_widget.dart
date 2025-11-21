import 'package:flutter/material.dart';

import '../../domain/entities/defensivo_entity.dart';

/// Widget especializado para comparar múltiplos defensivos
/// Mostra uma tabela comparativa side-by-side
/// Migrado e adaptado de defensivos_agrupados para nova arquitetura SOLID
class ComparacaoDefensivosWidget extends StatelessWidget {
  final List<DefensivoEntity> defensivos;
  final VoidCallback onFechar;

  const ComparacaoDefensivosWidget({
    super.key,
    required this.defensivos,
    required this.onFechar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildComparacaoContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.compare_arrows, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            'Comparar ${defensivos.length} Defensivos',
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const Spacer(),
          IconButton(
            onPressed: onFechar,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildComparacaoContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoBasica(),
          const SizedBox(height: 16),
          _buildInfoDetalhada(),
          const SizedBox(height: 16),
          _buildInfoAdicional(),
        ],
      ),
    );
  }

  Widget _buildInfoBasica() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações Básicas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildComparacaoRow('Nome', defensivos.map((d) => d.displayName).toList()),
            _buildComparacaoRow('Ingrediente Ativo', defensivos.map((d) => d.displayIngredient).toList()),
            _buildComparacaoRow('Fabricante', defensivos.map((d) => d.displayFabricante).toList()),
            _buildComparacaoRow('Classe Agronômica', defensivos.map((d) => d.displayClass).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoDetalhada() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações Detalhadas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildComparacaoRow('Modo de Ação', defensivos.map((d) => d.displayModoAcao).toList()),
            _buildComparacaoRow('Toxicidade', defensivos.map((d) => d.displayToxico).toList()),
            _buildComparacaoRow('Categoria', defensivos.map((d) => d.displayCategoria).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoAdicional() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações Adicionais',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildComparacaoRow('Comercializado', defensivos.map((d) => d.isComercializado ? 'Sim' : 'Não').toList()),
            _buildComparacaoRow('Elegível', defensivos.map((d) => d.isElegivel ? 'Sim' : 'Não').toList()),
            _buildComparacaoRow('Usos Relacionados', defensivos.map((d) => '${d.quantidadeDiagnosticos ?? 0}').toList()),
            _buildComparacaoRow('Prioridade', defensivos.map((d) => '${d.nivelPrioridade ?? 0}').toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildComparacaoRow(String label, List<String> valores) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: valores.map((valor) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  valor,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
