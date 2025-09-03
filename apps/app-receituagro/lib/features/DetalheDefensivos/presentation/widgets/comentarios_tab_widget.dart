import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/detalhe_defensivo_provider.dart';

/// Widget para tab de comentários com restrição premium
class ComentariosTabWidget extends StatefulWidget {
  final String defensivoName;

  const ComentariosTabWidget({
    super.key,
    required this.defensivoName,
  });

  @override
  State<ComentariosTabWidget> createState() => _ComentariosTabWidgetState();
}

class _ComentariosTabWidgetState extends State<ComentariosTabWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DetalheDefensivoProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Debug info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status Premium: ${provider.isPremium}', 
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Loading: ${provider.isLoadingComments}'),
                    Text('Comments: ${provider.comentarios.length}'),
                    Text('Defensivo: ${provider.defensivoData?.nomeComum ?? 'null'}'),
                  ],
                ),
              ),
              
              // Content
              provider.isPremium 
                ? _buildPremiumContent(provider)
                : _buildFreeContent(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumContent(DetalheDefensivoProvider provider) {
    if (provider.isLoadingComments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.comentarios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.comment_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Nenhum comentário ainda',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Seja o primeiro a comentar sobre ${widget.defensivoName}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.comentarios.length,
      itemBuilder: (context, index) {
        final comentario = provider.comentarios[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(comentario.titulo.isNotEmpty ? comentario.titulo : 'Usuário'),
            subtitle: Text(comentario.conteudo),
            trailing: Text(
              comentario.createdAt.toLocal().toString().split(' ')[0],
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFreeContent() {
    return Center(
      child: Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.diamond, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                'Comentários Premium',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Acesse comentários da comunidade e compartilhe suas experiências',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to subscription
                },
                child: const Text('Upgrade para Premium'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}