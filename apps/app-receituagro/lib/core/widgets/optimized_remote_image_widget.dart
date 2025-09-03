import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/remote_asset_service.dart';

/// Widget otimizado para exibir imagens remotas com fallback local
/// Substitui assets locais por downloads sob demanda para reduzir tamanho do APK
/// 
/// Funcionalidades:
/// - Assets remotos com cache persistente
/// - Fallback automático para assets locais
/// - Lazy loading otimizado
/// - Placeholder elegante
/// - Compressão automática
/// - Error handling robusto
class OptimizedRemoteImageWidget extends StatefulWidget {
  final String? nomeCientifico;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enablePreloading;
  final Duration animationDuration;

  const OptimizedRemoteImageWidget({
    super.key,
    required this.nomeCientifico,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.enablePreloading = false,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<OptimizedRemoteImageWidget> createState() => _OptimizedRemoteImageWidgetState();
}

class _OptimizedRemoteImageWidgetState extends State<OptimizedRemoteImageWidget>
    with AutomaticKeepAliveClientMixin {
  
  final RemoteAssetService _assetService = RemoteAssetService();
  late String _imageName;
  Uint8List? _imageData;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isRemoteAsset = false;

  @override
  bool get wantKeepAlive => _imageData != null; // Mantém estado se imagem carregada

  @override
  void initState() {
    super.initState();
    _imageName = _buildImageName(widget.nomeCientifico);
    _checkAssetType();
    _loadImage();
  }

  @override
  void didUpdateWidget(OptimizedRemoteImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nomeCientifico != widget.nomeCientifico) {
      final newName = _buildImageName(widget.nomeCientifico);
      if (_imageName != newName) {
        setState(() {
          _imageName = newName;
          _imageData = null;
          _hasError = false;
          _errorMessage = null;
        });
        _checkAssetType();
        _loadImage();
      }
    }
  }

  /// Constrói o nome da imagem baseado no nome científico
  String _buildImageName(String? nomeCientifico) {
    if (nomeCientifico == null || nomeCientifico.isEmpty) {
      return 'a.jpg'; // Imagem padrão
    }
    
    // Remove caracteres especiais e formata o nome científico
    final cleanName = nomeCientifico.trim();
    return '$cleanName.jpg';
  }

  /// Verifica se é asset remoto ou local
  void _checkAssetType() {
    _isRemoteAsset = !_assetService.isAssetLocal(_imageName);
  }

  /// Carrega a imagem usando o serviço de assets remotos
  Future<void> _loadImage() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final imageData = await _assetService.getImage(_imageName);
      
      if (mounted) {
        setState(() {
          _imageData = imageData;
          _isLoading = false;
          _hasError = imageData == null;
          if (imageData == null) {
            _errorMessage = 'Imagem não encontrada';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Erro ao carregar: ${e.toString()}';
        });
      }
    }
  }

  /// Widget de placeholder elegante
  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade100,
            Colors.grey.shade200,
            Colors.grey.shade100,
          ],
        ),
        borderRadius: widget.borderRadius,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shimmer effect
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(-1.0, -0.3),
                end: const Alignment(1.0, 0.3),
                colors: [
                  Colors.grey.shade200,
                  Colors.white.withValues(alpha: 0.8),
                  Colors.grey.shade200,
                ],
              ),
              borderRadius: widget.borderRadius,
            ),
          ),
          // Loading indicator
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.green.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isRemoteAsset) ...[
                    Icon(
                      Icons.cloud_download,
                      size: 12,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    _isRemoteAsset ? 'Baixando...' : 'Carregando...',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget de erro elegante
  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    final isSmall = widget.width != null && widget.width! < 100;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: widget.borderRadius,
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bug_report_outlined,
            color: Colors.grey.shade400,
            size: isSmall ? 20 : 40,
          ),
          const SizedBox(height: 4),
          Text(
            'Praga',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: isSmall ? 9 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!isSmall && _errorMessage != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _isRemoteAsset ? 'Offline' : 'Erro',
                style: TextStyle(
                  color: _isRemoteAsset ? Colors.orange.shade400 : Colors.red.shade400,
                  fontSize: 8,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Widget de badge indicando tipo de asset
  Widget _buildAssetTypeBadge() {
    if (!_isRemoteAsset) return const SizedBox.shrink();

    return Positioned(
      top: 4,
      right: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.shade600.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_done,
              size: 8,
              color: Colors.white,
            ),
            SizedBox(width: 2),
            Text(
              'WEB',
              style: TextStyle(
                color: Colors.white,
                fontSize: 6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: Stack(
        children: [
          _buildImageWidget(),
          _buildAssetTypeBadge(),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    if (_isLoading) {
      return _buildPlaceholder();
    }

    if (_hasError || _imageData == null) {
      return _buildErrorWidget();
    }

    return AnimatedSwitcher(
      duration: widget.animationDuration,
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: Image.memory(
        _imageData!,
        key: ValueKey(_imageName),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_hasError && mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = 'Erro na renderização';
              });
            }
          });
          return _buildErrorWidget();
        },
      ),
    );
  }

  @override
  void dispose() {
    // Não precisamos limpar cache aqui, é gerenciado globalmente
    super.dispose();
  }
}

/// Widget de estatísticas para debug do sistema de assets remotos
class RemoteAssetStatsWidget extends StatelessWidget {
  const RemoteAssetStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final assetService = RemoteAssetService();
    
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_queue, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text(
                  'Assets Remotos - Estatísticas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: _buildStatsData(assetService),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stats = snapshot.data!;
                return Column(
                  children: [
                    ...stats.entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatStatKey(entry.key),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            entry.value.toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _getStatColor(entry.key, entry.value),
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await assetService.clearCache();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cache de assets remotos limpo!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Limpar Cache'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.orange.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              assetService.syncAssetsInBackground();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sincronização iniciada!'),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            },
                            icon: const Icon(Icons.sync),
                            label: const Text('Sincronizar'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _buildStatsData(RemoteAssetService service) async {
    final stats = service.getStats();
    final cacheInfo = await service.getCacheInfo();
    
    return {
      ...stats,
      'Cache Files': cacheInfo['files'] ?? 0,
      'Cache Size': '${cacheInfo['totalSizeMB'] ?? '0.0'} MB',
    };
  }

  String _formatStatKey(String key) {
    switch (key) {
      case 'downloads': return 'Downloads';
      case 'cacheHits': return 'Cache Hits';
      case 'downloadErrors': return 'Erros';
      case 'totalBytesDownloadedMB': return 'Total Baixado';
      case 'failedAssets': return 'Assets Falharam';
      case 'totalRemoteAssets': return 'Assets Remotos';
      case 'criticalLocalAssets': return 'Assets Locais';
      case 'Cache Files': return 'Arquivos Cache';
      case 'Cache Size': return 'Tamanho Cache';
      default: return key;
    }
  }

  Color _getStatColor(String key, dynamic value) {
    switch (key) {
      case 'downloadErrors':
      case 'failedAssets':
        final intValue = int.tryParse(value.toString()) ?? 0;
        return intValue > 0 ? Colors.red.shade600 : Colors.green.shade600;
      case 'cacheHits':
      case 'downloads':
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade700;
    }
  }
}