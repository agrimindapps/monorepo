// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/pages/calc/financeiro/independencia_financeira/widgets/models/independencia_financeira_model.dart';
import 'package:app_calculei/services/sharing_service.dart';

class SharingWidget extends StatefulWidget {
  final IndependenciaFinanceiraModel modelo;
  final VoidCallback? onCompartilhado;

  const SharingWidget({
    super.key,
    required this.modelo,
    this.onCompartilhado,
  });

  @override
  State<SharingWidget> createState() => _SharingWidgetState();
}

class _SharingWidgetState extends State<SharingWidget> {
  final _sharingService = SharingService();
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Compartilhar Resultado',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Preview do texto
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preview:',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _sharingService.gerarTextoResumo(widget.modelo),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Botões de compartilhamento
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSharing ? null : () => _compartilharTexto(),
                  icon: const Icon(Icons.share),
                  label: const Text('Compartilhar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSharing ? null : () => _copiarTexto(),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copiar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Botão de personalização
          TextButton.icon(
            onPressed: _isSharing ? null : () => _mostrarOpcoesPersonalizadas(),
            icon: const Icon(Icons.tune),
            label: const Text('Personalizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _compartilharTexto() async {
    if (_isSharing) return;
    
    setState(() => _isSharing = true);
    
    try {
      await _sharingService.compartilharTexto(widget.modelo);
      
      if (mounted) {
        _mostrarSucesso('Compartilhado com sucesso!');
        widget.onCompartilhado?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _mostrarErro('Erro ao compartilhar: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _copiarTexto() async {
    if (_isSharing) return;
    
    setState(() => _isSharing = true);
    
    try {
      await _sharingService.copiarParaClipboard(widget.modelo);
      
      if (mounted) {
        _mostrarSucesso('Copiado para a área de transferência!');
        widget.onCompartilhado?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _mostrarErro('Erro ao copiar: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  void _mostrarOpcoesPersonalizadas() {
    showDialog(
      context: context,
      builder: (context) => _PersonalizacaoDialog(
        modelo: widget.modelo,
        onCompartilhado: widget.onCompartilhado,
      ),
    );
  }

  void _mostrarSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _PersonalizacaoDialog extends StatefulWidget {
  final IndependenciaFinanceiraModel modelo;
  final VoidCallback? onCompartilhado;

  const _PersonalizacaoDialog({
    required this.modelo,
    this.onCompartilhado,
  });

  @override
  State<_PersonalizacaoDialog> createState() => _PersonalizacaoDialogState();
}

class _PersonalizacaoDialogState extends State<_PersonalizacaoDialog> {
  final _sharingService = SharingService();
  final _mensagemController = TextEditingController();
  
  bool _incluirDetalhes = true;
  bool _incluirDicas = true;
  bool _isSharing = false;

  @override
  void dispose() {
    _mensagemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Personalizar Compartilhamento'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mensagem personalizada
            TextField(
              controller: _mensagemController,
              decoration: const InputDecoration(
                labelText: 'Mensagem personalizada (opcional)',
                hintText: 'Adicione uma mensagem pessoal...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            // Opções de conteúdo
            Text(
              'Incluir no compartilhamento:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            
            CheckboxListTile(
              title: const Text('Detalhes da simulação'),
              subtitle: const Text('Patrimônio, gastos, aportes, etc.'),
              value: _incluirDetalhes,
              onChanged: (value) {
                setState(() => _incluirDetalhes = value ?? true);
              },
            ),
            
            CheckboxListTile(
              title: const Text('Dicas personalizadas'),
              subtitle: const Text('Sugestões baseadas no resultado'),
              value: _incluirDicas,
              onChanged: (value) {
                setState(() => _incluirDicas = value ?? true);
              },
            ),
            
            const SizedBox(height: 16),
            
            // Preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview:',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _sharingService.gerarTextoPersonalizado(
                      widget.modelo,
                      incluirDetalhes: _incluirDetalhes,
                      incluirDicas: _incluirDicas,
                      mensagemPersonalizada: _mensagemController.text.isNotEmpty 
                          ? _mensagemController.text 
                          : null,
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 8,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSharing ? null : _compartilharPersonalizado,
          child: _isSharing 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Compartilhar'),
        ),
      ],
    );
  }

  Future<void> _compartilharPersonalizado() async {
    if (_isSharing) return;
    
    setState(() => _isSharing = true);
    
    try {
      await _sharingService.compartilharComOpcoes(
        widget.modelo,
        incluirDetalhes: _incluirDetalhes,
        incluirDicas: _incluirDicas,
        mensagemPersonalizada: _mensagemController.text.isNotEmpty 
            ? _mensagemController.text 
            : null,
      );
      
      if (mounted) {
        widget.onCompartilhado?.call();
        Navigator.of(context).pop(); // Fecha o dialog
        Navigator.of(context).pop(); // Fecha o bottom sheet
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compartilhado com sucesso!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }
}
