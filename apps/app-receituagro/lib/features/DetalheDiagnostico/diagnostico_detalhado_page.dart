import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../../core/services/diagnostico_integration_service.dart';
import '../../core/extensions/diagnostico_detalhado_extension.dart';
import '../../core/di/injection_container.dart';
import 'widgets/diagnostico_relacional_card_widget.dart';
import 'widgets/seguranca_info_widget.dart';
import 'widgets/dados_tecnicos_widget.dart';
import 'widgets/relacionamentos_widget.dart';

/// Página de diagnóstico que integra dados de múltiplas HiveBoxes
/// Mostra informações completas relacionais entre DiagnosticoHive, 
/// FitossanitarioHive, CulturaHive e PragasHive
class DiagnosticoDetalhadoPage extends StatefulWidget {
  final String diagnosticoId;

  const DiagnosticoDetalhadoPage({
    super.key,
    required this.diagnosticoId,
  });

  @override
  State<DiagnosticoDetalhadoPage> createState() => _DiagnosticoDetalhadoPageState();
}

class _DiagnosticoDetalhadoPageState extends State<DiagnosticoDetalhadoPage> {
  final DiagnosticoIntegrationService _integrationService = sl<DiagnosticoIntegrationService>();
  
  bool isFavorited = false;
  bool isLoading = false;
  bool hasError = false;
  bool isPremium = true; // Mock - assumindo usuário premium
  String? _errorMessage;
  
  // Dados relacionais do diagnóstico
  DiagnosticoDetalhado? _diagnosticoDetalhado;

  @override
  void initState() {
    super.initState();
    _loadDiagnosticoCompleto();
  }

  void _loadDiagnosticoCompleto() async {
    setState(() {
      isLoading = true;
      hasError = false;
      _errorMessage = null;
    });
    
    try {
      // Busca diagnóstico completo com dados relacionais
      final diagnosticoCompleto = await _integrationService.getDiagnosticoCompleto(widget.diagnosticoId);
      
      if (mounted) {
        setState(() {
          isLoading = false;
          if (diagnosticoCompleto != null) {
            _diagnosticoDetalhado = diagnosticoCompleto;
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
    final titulo = _diagnosticoDetalhado?.descricaoResumida ?? 'Diagnóstico Detalhado';
    final subtitulo = _diagnosticoDetalhado?.hasInfoCompleta == true 
        ? 'Informações relacionais completas'
        : 'Carregando informações...';

    return ModernHeaderWidget(
      title: titulo,
      subtitle: subtitulo,
      leftIcon: Icons.medical_services_outlined,
      rightIcon: isFavorited ? Icons.favorite : Icons.favorite_border,
      isDark: isDark,
      showBackButton: true,
      showActions: isPremium,
      onBackPressed: () => Navigator.of(context).pop(),
      onRightIconPressed: () {
        setState(() {
          isFavorited = !isFavorited;
        });
      },
      additionalActions: isPremium ? [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: _compartilhar,
        ),
        if (_diagnosticoDetalhado?.isCritico == true)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.warning, color: Colors.red, size: 16),
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
              'Integrando dados relacionais...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Buscando informações de múltiplas bases de dados',
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
              _errorMessage ?? 'Verifique sua conexão e tente novamente',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadDiagnosticoCompleto(),
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
              'Diagnósticos Relacionais Premium',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Este diagnóstico detalhado com dados relacionais está disponível apenas para usuários premium',
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
    if (_diagnosticoDetalhado == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card principal com informações relacionais
          DiagnosticoRelacionalCardWidget(
            diagnosticoDetalhado: _diagnosticoDetalhado!,
          ),
          const SizedBox(height: 24),
          
          // Seção de informações de segurança
          if (_diagnosticoDetalhado!.informacoesSeguranca.isNotEmpty) ...[
            SegurancaInfoWidget(
              informacoesSeguranca: _diagnosticoDetalhado!.informacoesSeguranca,
              isCritico: _diagnosticoDetalhado!.isCritico,
            ),
            const SizedBox(height: 24),
          ],
          
          // Seção de dados técnicos
          DadosTecnicosWidget(
            dadosTecnicos: _diagnosticoDetalhado!.dadosTecnicos,
            temAplicacaoTerrestre: _diagnosticoDetalhado!.temAplicacaoTerrestre,
            temAplicacaoAerea: _diagnosticoDetalhado!.temAplicacaoAerea,
            aplicacaoTerrestre: _diagnosticoDetalhado!.aplicacaoTerrestre,
            aplicacaoAerea: _diagnosticoDetalhado!.aplicacaoAerea,
          ),
          const SizedBox(height: 24),
          
          // Seção de relacionamentos
          RelacionamentosWidget(
            diagnosticoDetalhado: _diagnosticoDetalhado!,
            onCulturaPressed: _verOutrasPragasDaCultura,
            onPragaPressed: _verOutrosDefensivosDaPraga,
            onDefensivoPressed: _verOutrosUsosDoDDefensivo,
          ),
          
          const SizedBox(height: 80), // Espaço para bottom navigation
        ],
      ),
    );
  }

  void _compartilhar() {
    if (_diagnosticoDetalhado == null) return;
    
    final texto = '''
${_diagnosticoDetalhado!.descricaoResumida}

Dosagem: ${_diagnosticoDetalhado!.dosagem}
Fabricante: ${_diagnosticoDetalhado!.fabricante}
Classe Agronômica: ${_diagnosticoDetalhado!.classeAgronomica}
Modo de Ação: ${_diagnosticoDetalhado!.modoAcao}

Dados integrados do ReceitAgro
''';
    
    // Implementar funcionalidade de compartilhamento
    print('Compartilhando: $texto');
  }

  void _verOutrasPragasDaCultura() async {
    if (_diagnosticoDetalhado?.cultura == null) return;
    
    // Navegar para lista de pragas da cultura
    final culturaId = _diagnosticoDetalhado!.diagnostico.fkIdCultura;
    // Navigator.pushNamed(context, '/pragas-por-cultura', arguments: culturaId);
    print('Ver outras pragas da cultura: $culturaId');
  }

  void _verOutrosDefensivosDaPraga() async {
    if (_diagnosticoDetalhado?.praga == null) return;
    
    // Navegar para lista de defensivos da praga
    final pragaId = _diagnosticoDetalhado!.diagnostico.fkIdPraga;
    // Navigator.pushNamed(context, '/defensivos-por-praga', arguments: pragaId);
    print('Ver outros defensivos da praga: $pragaId');
  }

  void _verOutrosUsosDoDDefensivo() async {
    if (_diagnosticoDetalhado?.defensivo == null) return;
    
    // Navegar para lista de usos do defensivo
    final defensivoId = _diagnosticoDetalhado!.diagnostico.fkIdDefensivo;
    // Navigator.pushNamed(context, '/usos-defensivo', arguments: defensivoId);
    print('Ver outros usos do defensivo: $defensivoId');
  }

  void _showPremiumDialog() {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogTheme.backgroundColor ?? theme.cardColor,
        title: Text(
          'Diagnósticos Relacionais Premium',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Com o Premium você tem acesso a:',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            ...const [
              '✓ Dados relacionais entre defensivos, culturas e pragas',
              '✓ Informações completas de segurança',
              '✓ Navegação entre entidades relacionadas',
              '✓ Cache otimizado para performance',
              '✓ Análises de criticidade',
            ].map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            )),
          ],
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
            child: const Text('Assinar Premium'),
          ),
        ],
      ),
    );
  }
}