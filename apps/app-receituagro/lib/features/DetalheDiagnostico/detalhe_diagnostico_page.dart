import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../../core/widgets/praga_image_widget.dart';
import '../../core/models/diagnostico_hive.dart';
import '../../core/repositories/diagnostico_hive_repository.dart';
import '../../core/repositories/favoritos_hive_repository.dart';
import '../../core/extensions/diagnostico_hive_extension.dart';
import '../../core/di/injection_container.dart';
import '../detalhes_diagnostico/interfaces/i_premium_service.dart';

class DetalheDiagnosticoPage extends StatefulWidget {
  final String diagnosticoId;
  final String nomeDefensivo;
  final String nomePraga;
  final String cultura;

  const DetalheDiagnosticoPage({
    super.key,
    required this.diagnosticoId,
    required this.nomeDefensivo,
    required this.nomePraga,
    required this.cultura,
  });

  @override
  State<DetalheDiagnosticoPage> createState() => _DetalheDiagnosticoPageState();
}

class _DetalheDiagnosticoPageState extends State<DetalheDiagnosticoPage> {
  final DiagnosticoHiveRepository _repository = sl<DiagnosticoHiveRepository>();
  final FavoritosHiveRepository _favoritosRepository = sl<FavoritosHiveRepository>();
  final IPremiumService _premiumService = sl<IPremiumService>();
  bool isFavorited = false;
  bool isLoading = false;
  bool hasError = false;
  bool isPremium = false; // Será carregado via PremiumService
  bool isTtsSpeaking = false;
  String? _errorMessage;
  
  // Dados do diagnóstico
  DiagnosticoHive? _diagnostico;
  Map<String, String> _diagnosticoData = {};

  @override
  void initState() {
    super.initState();
    _loadDiagnosticoData();
    _loadFavoritoState();
    _loadPremiumStatus();
  }

  void _loadFavoritoState() {
    setState(() {
      isFavorited = _favoritosRepository.isFavorito('diagnosticos', widget.diagnosticoId);
    });
  }

  void _loadPremiumStatus() async {
    try {
      final premium = await _premiumService.isPremiumUser();
      if (mounted) {
        setState(() {
          isPremium = premium;
        });
      }
    } catch (e) {
      // Em caso de erro, manter como não premium
      if (mounted) {
        setState(() {
          isPremium = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadDiagnosticoData() async {
    setState(() {
      isLoading = true;
      hasError = false;
      _errorMessage = null;
    });
    
    try {
      // Busca diagnóstico por ID
      final diagnostico = _repository.getById(widget.diagnosticoId);
      
      if (mounted) {
        setState(() {
          isLoading = false;
          if (diagnostico != null) {
            _diagnostico = diagnostico;
            _diagnosticoData = diagnostico.toDataMap();
          } else {
            hasError = true;
            _errorMessage = 'Diagnóstico não encontrado';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          _errorMessage = 'Erro ao carregar diagnóstico: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              children: [
                _buildModernHeader(isDark),
                Expanded(
                  child: isLoading
                      ? _buildLoadingState()
                      : hasError
                          ? _buildErrorState()
                          : isPremium
                              ? _buildContent()
                              : _buildPremiumGate(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(bool isDark) {
    return ModernHeaderWidget(
      title: 'Diagnóstico',
      subtitle: 'Detalhes do diagnóstico',
      leftIcon: Icons.medical_services_outlined,
      rightIcon: isFavorited ? Icons.favorite : Icons.favorite_border,
      isDark: isDark,
      showBackButton: true,
      showActions: isPremium,
      onBackPressed: () => Navigator.of(context).pop(),
      onRightIconPressed: () {
        _toggleFavorito();
      },
      additionalActions: isPremium ? [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: _compartilhar,
        ),
      ] : null,
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Carregando diagnóstico...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aguarde enquanto buscamos as informações',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Erro ao carregar diagnóstico',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Verifique sua conexão e tente novamente',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadDiagnosticoData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumGate() {
    final theme = Theme.of(context);
    
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade300, Colors.amber.shade600],
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
            Text(
              'Conteúdo Premium',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Este diagnóstico está disponível apenas para usuários premium',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _showPremiumDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Assinar Premium'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seção de Imagem
          _buildImageSection(),
          const SizedBox(height: 24),
          
          // Seção de Informações
          _buildInfoSection(),
          const SizedBox(height: 24),
          
          // Seção de Diagnóstico
          _buildDiagnosticoSection(),
          const SizedBox(height: 24),
          
          // Seção de Aplicação
          _buildAplicacaoSection(),
          const SizedBox(height: 80), // Espaço para bottom navigation
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagem do Diagnóstico',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              PragaImageWidget(
                nomeCientifico: widget.nomePraga,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(12),
                errorWidget: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    FontAwesomeIcons.image,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.nomePraga,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.nomeDefensivo} - ${widget.cultura}',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informações Gerais',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCards(),
      ],
    );
  }

  Widget _buildInfoCards() {
    final infoItems = [
      {'label': 'Ingrediente Ativo', 'value': _diagnosticoData['ingredienteAtivo'] ?? 'N/A', 'icon': Icons.science},
      {'label': 'Classificação Toxicológica', 'value': _diagnosticoData['toxico'] ?? 'N/A', 'icon': Icons.warning},
      {'label': 'Classificação Ambiental', 'value': _diagnosticoData['classAmbiental'] ?? 'N/A', 'icon': Icons.eco},
      {'label': 'Classe Agronômica', 'value': _diagnosticoData['classeAgronomica'] ?? 'N/A', 'icon': Icons.agriculture},
    ];

    return Column(
      children: infoItems.map((item) => _buildInfoCard(
        item['label'] as String,
        item['value'] as String,
        item['icon'] as IconData,
      )).toList(),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticoSection() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalhes do Diagnóstico',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildDiagnosticoCards(),
      ],
    );
  }

  Widget _buildDiagnosticoCards() {
    final diagnosticoItems = [
      {'label': 'Formulação', 'value': _diagnosticoData['formulacao'] ?? 'N/A', 'icon': Icons.science_outlined},
      {'label': 'Modo de Ação', 'value': _diagnosticoData['modoAcao'] ?? 'N/A', 'icon': Icons.bolt},
      {'label': 'Registro MAPA', 'value': _diagnosticoData['mapa'] ?? 'N/A', 'icon': Icons.verified},
    ];

    return Column(
      children: diagnosticoItems.map((item) => _buildInfoCard(
        item['label'] as String,
        item['value'] as String,
        item['icon'] as IconData,
      )).toList(),
    );
  }

  Widget _buildAplicacaoSection() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Instruções de Aplicação',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildAplicacaoCards(),
      ],
    );
  }

  Widget _buildAplicacaoCards() {
    final aplicacaoItems = [
      {'label': 'Dosagem', 'value': _diagnosticoData['dosagem'] ?? 'N/A', 'icon': Icons.medication},
      {'label': 'Vazão Terrestre', 'value': _diagnosticoData['vazaoTerrestre'] ?? 'N/A', 'icon': Icons.agriculture},
      {'label': 'Vazão Aérea', 'value': _diagnosticoData['vazaoAerea'] ?? 'N/A', 'icon': Icons.flight},
      {'label': 'Intervalo de Aplicação', 'value': _diagnosticoData['intervaloAplicacao'] ?? 'N/A', 'icon': Icons.schedule},
      {'label': 'Intervalo de Segurança', 'value': _diagnosticoData['intervaloSeguranca'] ?? 'N/A', 'icon': Icons.shield},
    ];

    return Column(
      children: [
        ...aplicacaoItems.map((item) => _buildInfoCard(
          item['label'] as String,
          item['value'] as String,
          item['icon'] as IconData,
        )),
        if (_diagnosticoData['tecnologia']?.isNotEmpty ?? false) ...[
          const SizedBox(height: 16),
          _buildTecnologiaCard(),
        ],
      ],
    );
  }

  Widget _buildTecnologiaCard() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.psychology,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Tecnologia de Aplicação',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _diagnosticoData['tecnologia'] ?? '',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _compartilhar() {
    // Implementar funcionalidade de compartilhamento
  }

  void _toggleFavorito() async {
    final wasAlreadyFavorited = isFavorited;
    final itemData = {
      'id': widget.diagnosticoId,
      'nomeDefensivo': widget.nomeDefensivo,
      'nomePraga': widget.nomePraga,
      'cultura': widget.cultura,
    };

    setState(() {
      isFavorited = !wasAlreadyFavorited;
    });

    final success = wasAlreadyFavorited
        ? await _favoritosRepository.removeFavorito('diagnosticos', widget.diagnosticoId)
        : await _favoritosRepository.addFavorito('diagnosticos', widget.diagnosticoId, itemData);

    if (!success) {
      // Reverter estado em caso de falha
      setState(() {
        isFavorited = wasAlreadyFavorited;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Diagnóstico ${isFavorited ? 'adicionado' : 'removido'} dos favoritos'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showPremiumDialog() {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogTheme.backgroundColor ?? theme.cardColor,
        title: Text(
          'Funcionalidade Premium',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          'Este diagnóstico está disponível apenas para usuários premium. '
          'Assine agora para ter acesso completo.',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Assinar'),
          ),
        ],
      ),
    );
  }
}