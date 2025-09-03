import 'package:flutter/material.dart';

/// Widget para estado de erro de favoritos
/// 
/// Responsabilidades:
/// - Exibir mensagem de erro
/// - Botão de retry
/// - Design consistente com tema
/// - Estados de loading do retry
class FavoritosErrorStateWidget extends StatefulWidget {
  final String? errorMessage;
  final VoidCallback onRetry;
  final bool isDark;

  const FavoritosErrorStateWidget({
    super.key,
    this.errorMessage,
    required this.onRetry,
    required this.isDark,
  });

  @override
  State<FavoritosErrorStateWidget> createState() => _FavoritosErrorStateWidgetState();
}

class _FavoritosErrorStateWidgetState extends State<FavoritosErrorStateWidget> {
  bool _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone de erro
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red.shade600,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Título do erro
            Text(
              'Erro ao carregar favoritos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Mensagem de erro detalhada
            if (widget.errorMessage != null) ...[
              Text(
                widget.errorMessage!,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ] else ...[
              Text(
                'Houve um problema ao carregar seus favoritos.\nVerifique sua conexão e tente novamente.',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
            
            // Botão de retry
            ElevatedButton.icon(
              onPressed: _isRetrying ? null : _handleRetry,
              icon: _isRetrying 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.refresh),
              label: Text(_isRetrying ? 'Tentando...' : 'Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Manipula ação de retry
  Future<void> _handleRetry() async {
    if (_isRetrying) return;
    
    setState(() => _isRetrying = true);
    
    try {
      widget.onRetry();
      // Aguardar um pouco para mostrar o feedback visual
      await Future<void>.delayed(const Duration(milliseconds: 500));
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }
}