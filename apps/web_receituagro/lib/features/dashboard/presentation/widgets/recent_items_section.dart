import 'package:flutter/material.dart';

import '../../../defensivos/domain/entities/defensivo.dart';
import '../../../pragas/domain/entities/praga.dart';

/// Section widget for displaying recent items (pragas or defensivos)
/// Based on Vue.js ReceituagroCadastro-master home page design
class RecentItemsSection<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final MaterialColor color;
  final List<T> items;
  final String Function(T) getName;
  final String? Function(T)? getSubtitle;
  final String? Function(T)? getImageUrl;
  final void Function(T)? onItemTap;
  final VoidCallback? onViewAll;

  const RecentItemsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    required this.getName,
    this.getSubtitle,
    this.getImageUrl,
    this.onItemTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('Ver todos'),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Items
        if (items.isEmpty)
          _buildEmptyState(context)
        else
          _buildItemsList(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'Nenhum item recente',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length > 10 ? 10 : items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildItemCard(context, item);
        },
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, T item) {
    final name = getName(item);
    final subtitle = getSubtitle?.call(item);
    final imageUrl = getImageUrl?.call(item);

    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => onItemTap?.call(item),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon or image
                Row(
                  children: [
                    if (imageUrl != null && imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          imageUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                        ),
                      )
                    else
                      _buildDefaultAvatar(),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                  ],
                ),
                const Spacer(),
                // Name
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.shade100,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color.shade700, size: 20),
    );
  }
}

/// Widget for displaying recent pragas as circular avatars
/// Based on Vue.js design (últimas pragas acessadas)
class RecentPragasAvatars extends StatelessWidget {
  final List<Praga> pragas;
  final void Function(Praga)? onPragaTap;
  final VoidCallback? onViewAll;

  const RecentPragasAvatars({
    super.key,
    required this.pragas,
    this.onPragaTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.history, color: Colors.orange.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Últimas Pragas Acessadas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('Ver todas'),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Avatars
        if (pragas.isEmpty)
          _buildEmptyState(context)
        else
          _buildAvatarsList(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.history, size: 32, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'Nenhuma praga acessada recentemente',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarsList(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: pragas.length > 8 ? 8 : pragas.length,
        itemBuilder: (context, index) {
          final praga = pragas[index];
          return _buildAvatarItem(context, praga);
        },
      ),
    );
  }

  Widget _buildAvatarItem(BuildContext context, Praga praga) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () => onPragaTap?.call(praga),
        borderRadius: BorderRadius.circular(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.shade100,
                border: Border.all(
                  color: Colors.orange.shade300,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: praga.imageUrl != null && praga.imageUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        praga.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.bug_report,
                          color: Colors.orange.shade700,
                          size: 28,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.bug_report,
                      color: Colors.orange.shade700,
                      size: 28,
                    ),
            ),
            const SizedBox(height: 8),
            // Name
            Text(
              praga.nomeComum,
              style: const TextStyle(fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying recent defensivos as a list
/// Based on Vue.js design (últimos defensivos acessados)
class RecentDefensivosList extends StatelessWidget {
  final List<Defensivo> defensivos;
  final void Function(Defensivo)? onDefensivoTap;
  final VoidCallback? onViewAll;

  const RecentDefensivosList({
    super.key,
    required this.defensivos,
    this.onDefensivoTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.history, color: Colors.green.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Últimos Defensivos Acessados',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('Ver todos'),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // List
        if (defensivos.isEmpty)
          _buildEmptyState(context)
        else
          _buildList(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.agriculture, size: 32, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'Nenhum defensivo acessado recentemente',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final displayCount = defensivos.length > 5 ? 5 : defensivos.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayCount,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final defensivo = defensivos[index];
          return _buildListItem(context, defensivo);
        },
      ),
    );
  }

  Widget _buildListItem(BuildContext context, Defensivo defensivo) {
    return ListTile(
      onTap: () => onDefensivoTap?.call(defensivo),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.agriculture,
          color: Colors.green.shade700,
          size: 20,
        ),
      ),
      title: Text(
        defensivo.nomeComum,
        style: const TextStyle(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        defensivo.fabricante.isNotEmpty ? defensivo.fabricante : 'Sem fabricante',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
      ),
    );
  }
}

/// Widget for displaying new products section
class NewProductsSection extends StatelessWidget {
  final List<Defensivo> defensivos;
  final void Function(Defensivo)? onDefensivoTap;
  final VoidCallback? onViewAll;

  const NewProductsSection({
    super.key,
    required this.defensivos,
    this.onDefensivoTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return RecentItemsSection<Defensivo>(
      title: 'Novos Produtos',
      icon: Icons.new_releases,
      color: Colors.green,
      items: defensivos,
      getName: (d) => d.nomeComum,
      getSubtitle: (d) => d.fabricante.isNotEmpty ? d.fabricante : null,
      onItemTap: onDefensivoTap,
      onViewAll: onViewAll,
    );
  }
}
