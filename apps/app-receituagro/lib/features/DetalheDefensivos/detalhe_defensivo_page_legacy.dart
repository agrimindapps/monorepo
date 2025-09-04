import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/di/injection_container.dart';
import '../../core/interfaces/i_premium_service.dart';
import '../../core/models/fitossanitario_hive.dart';
import '../../core/repositories/favoritos_hive_repository.dart';
import '../../core/repositories/fitossanitario_hive_repository.dart';
import '../../core/services/app_data_manager.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../DetalheDiagnostico/detalhe_diagnostico_page.dart';
import '../comentarios/models/comentario_model.dart';
import '../comentarios/services/comentarios_service.dart';
import '../comentarios/views/widgets/premium_upgrade_widget.dart';
import '../diagnosticos/data/repositories/diagnosticos_repository_impl.dart';
import '../favoritos/favoritos_page.dart';
import '../navigation/bottom_nav_wrapper.dart';

// Modelo de dados para diagnóstico
class DiagnosticoModel {
  final String id;
  final String nome;
  final String ingredienteAtivo;
  final String dosagem;
  final String cultura;
  final String grupo;

  DiagnosticoModel({
    required this.id,
    required this.nome,
    required this.ingredienteAtivo,
    required this.dosagem,
    required this.cultura,
    required this.grupo,
  });
}

class DetalheDefensivoPage extends StatefulWidget {
  final String defensivoName;
  final String fabricante;

  const DetalheDefensivoPage({
    super.key,
    required this.defensivoName,
    required this.fabricante,
  });

  @override
  State<DetalheDefensivoPage> createState() => _DetalheDefensivoPageState();
}

class _DetalheDefensivoPageState extends State<DetalheDefensivoPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final FavoritosHiveRepository _favoritosRepository =
      sl<FavoritosHiveRepository>();
  final FitossanitarioHiveRepository _fitossanitarioRepository =
      sl<FitossanitarioHiveRepository>();
  final ComentariosService _comentariosService = sl<ComentariosService>();
  final IPremiumService _premiumService = sl<IPremiumService>();

  bool isFavorited = false;
  bool isPremium = false; // Status premium carregado do service
  FitossanitarioHive? _defensivoData; // Dados reais do defensivo
  bool isLoading = false;
  bool hasError = false;

  // Estado dos comentários
  List<ComentarioModel> _comentarios = [];
  bool _isLoadingComments = false;
  final TextEditingController _commentController = TextEditingController();

  // Estado dos diagnósticos
  String _searchQuery = '';
  String _selectedCultura = 'Todas';
  List<DiagnosticoModel> _diagnosticos = [];
  final List<String> _culturas = [
    'Todas',
    'Arroz',
    'Braquiária',
    'Cana-de-açúcar',
    'Café',
    'Milho',
    'Soja',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadRealData();
    _loadComentarios();
    _loadDiagnosticos();
    _loadFavoritoState();
    _loadPremiumStatus();
  }

  void _loadFavoritoState() {
    // Busca o defensivo real pelo nome para obter o ID único
    final defensivos = _fitossanitarioRepository.getAll().where(
      (d) =>
          d.nomeComum == widget.defensivoName ||
          d.nomeTecnico == widget.defensivoName,
    );
    _defensivoData = defensivos.isNotEmpty ? defensivos.first : null;

    if (mounted) {
      setState(() {
        if (_defensivoData != null) {
          isFavorited = _favoritosRepository.isFavorito(
            'defensivo',
            _defensivoData!.idReg,
          );
        } else {
          // Fallback para nome se não encontrar no repositório
          isFavorited = _favoritosRepository.isFavorito(
            'defensivo',
            widget.defensivoName,
          );
        }
      });
    }
  }

  void _loadPremiumStatus() {
    if (mounted) {
      setState(() {
        isPremium = _premiumService.isPremium;
      });
    }

    // Escuta mudanças no status premium
    _premiumService.addListener(() {
      if (mounted) {
        setState(() {
          isPremium = _premiumService.isPremium;
        });
      }
    });
  }

  Future<void> _loadComentarios() async {
    if (!mounted) return;

    if (mounted) {
      setState(() {
        _isLoadingComments = true;
      });
    }

    try {
      // Usa ID real do defensivo se disponível, senão usa nome
      final pkIdentificador = _defensivoData?.idReg ?? widget.defensivoName;

      final comentarios = await _comentariosService.getAllComentarios(
        pkIdentificador: pkIdentificador,
      );

      if (mounted) {
        setState(() {
          _comentarios = comentarios;
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingComments = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar comentários: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Carrega diagnósticos reais relacionados ao defensivo atual
  void _loadDiagnosticos() async {
    // Busca diagnósticos reais do repositório usando o nome do defensivo
    try {
      debugPrint('==== INICIANDO CARREGAMENTO DE DIAGNOSTICOS ====');
      debugPrint('Nome do defensivo: ${widget.defensivoName}');

      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      // Busca o defensivo atual para obter seu ID
      final defensivos = _fitossanitarioRepository.getAll();
      debugPrint('Total de defensivos no repositório: ${defensivos.length}');

      final defensivoAtual =
          defensivos
              .where(
                (d) =>
                    d.nomeComum == widget.defensivoName ||
                    d.nomeTecnico == widget.defensivoName,
              )
              .firstOrNull;

      debugPrint(
        'Defensivo encontrado: ${defensivoAtual?.nomeComum} (ID: ${defensivoAtual?.idReg})',
      );

      if (defensivoAtual != null) {
        // Usa o repositório de diagnósticos para buscar diagnósticos relacionados
        final diagnosticosRepository = sl<DiagnosticosRepositoryImpl>();

        debugPrint(
          '🔍 Buscando diagnósticos para defensivo ID: ${defensivoAtual.idReg}',
        );

        // Primeiro vamos verificar quantos diagnósticos existem no total
        final allDiagnosticsResult = await diagnosticosRepository.getAll();

        bool shouldReimport = false;
        allDiagnosticsResult.fold(
          (failure) =>
              debugPrint('❌ Erro ao buscar todos os diagnósticos: $failure'),
          (allDiagnostics) {
            debugPrint(
              '📋 Total de diagnósticos no banco: ${allDiagnostics.length}',
            );
            if (allDiagnostics.isEmpty) {
              debugPrint(
                '⚠️ Banco de diagnósticos vazio! Será necessário reimportar.',
              );
              shouldReimport = true;
            }
          },
        );

        // Se não há dados, tenta reimportar
        if (shouldReimport) {
          debugPrint('🔄 Iniciando reimportação automática de diagnósticos...');
          try {
            final appDataManager = sl<IAppDataManager>();
            final reimportResult = await appDataManager.versionControlService
                .reimportSpecificCategory('tbdiagnostico');

            reimportResult.fold(
              (error) =>
                  debugPrint('❌ Erro na reimportação: ${error.toString()}'),
              (importCount) {
                debugPrint(
                  '✅ Reimportação concluída! $importCount diagnósticos importados',
                );
                // Recarrega dados após reimportação
                _loadDiagnosticos();
                return;
              },
            );
          } catch (e) {
            debugPrint('❌ Exceção durante reimportação: $e');
          }
        }

        final result = await diagnosticosRepository.getByDefensivo(
          defensivoAtual.idReg,
        );

        result.fold(
          (failure) {
            // Em caso de falha, inicializa lista vazia
            debugPrint(
              '❌ ERRO ao carregar diagnósticos: ${failure.toString()}',
            );
            _diagnosticos = [];
            if (mounted) {
              setState(() {
                isLoading = false;
                hasError = true;
              });
            }
          },
          (diagnosticosEntities) {
            debugPrint(
              '✅ Sucesso! Diagnósticos encontrados: ${diagnosticosEntities.length}',
            );

            // Converte entidades para o modelo usado na UI
            _diagnosticos =
                diagnosticosEntities.map((entity) {
                  debugPrint(
                    'Convertendo diagnóstico: ${entity.nomeDefensivo} - ${entity.nomeCultura} - ${entity.nomePraga}',
                  );
                  return DiagnosticoModel(
                    id: entity.id,
                    nome: entity.nomeDefensivo ?? widget.defensivoName,
                    ingredienteAtivo:
                        entity
                            .idDefensivo, // Pode ser melhorado conforme estrutura
                    dosagem: entity.dosagem.toString(),
                    cultura: entity.nomeCultura ?? 'Não especificado',
                    grupo: entity.nomePraga ?? 'Não especificado',
                  );
                }).toList();

            debugPrint(
              '📊 Total de diagnósticos carregados na UI: ${_diagnosticos.length}',
            );

            if (mounted) {
              setState(() {
                isLoading = false;
                hasError = false;
              });
            }
          },
        );
      } else {
        // Defensivo não encontrado, vamos criar dados de teste para verificar se a UI funciona
        debugPrint('⚠️ Defensivo não encontrado, criando dados de teste...');
        _diagnosticos = [
          DiagnosticoModel(
            id: 'test_1',
            nome: 'Teste Diagnóstico 1',
            ingredienteAtivo: 'Ingrediente Teste',
            dosagem: '100ml/ha',
            cultura: 'Soja',
            grupo: 'Pragas de Solo',
          ),
          DiagnosticoModel(
            id: 'test_2',
            nome: 'Teste Diagnóstico 2',
            ingredienteAtivo: 'Ingrediente Teste 2',
            dosagem: '200ml/ha',
            cultura: 'Milho',
            grupo: 'Pragas Folhares',
          ),
        ];

        if (mounted) {
          setState(() {
            isLoading = false;
            hasError = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar diagnósticos: $e');
      _diagnosticos = [];
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    }
  }

  void _loadRealData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        hasError = false;
      });
    }

    // Carrega dados reais do repositório
    try {
      final defensivos = _fitossanitarioRepository.getAll().where(
        (d) =>
            d.nomeComum == widget.defensivoName ||
            d.nomeTecnico == widget.defensivoName,
      );
      _defensivoData = defensivos.isNotEmpty ? defensivos.first : null;

      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = _defensivoData == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavWrapper(
      selectedIndex: 0, // Defensivos é o índice 0
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                children: [
                  _buildModernHeader(context),
                  Expanded(
                    child:
                        isLoading
                            ? _buildLoadingState(context)
                            : hasError
                            ? _buildErrorState(context)
                            : _buildContent(context),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(context),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ModernHeaderWidget(
      title: widget.defensivoName,
      subtitle: widget.fabricante,
      leftIcon: Icons.shield_outlined,
      rightIcon: isFavorited ? Icons.favorite : Icons.favorite_border,
      isDark: isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: () => Navigator.of(context).pop(),
      onRightIconPressed: () {
        _toggleFavorito();
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(8.0),
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
              'Carregando detalhes...',
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

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.15),
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
                FontAwesomeIcons.triangleExclamation,
                size: 32,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Erro ao carregar detalhes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Não foi possível carregar as informações do defensivo. Verifique sua conexão e tente novamente.',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _loadRealData(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(FontAwesomeIcons.arrowLeft),
                  label: const Text('Voltar'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                _wrapTabContent(_buildInformacoesTab(), 'informacoes'),
                _wrapTabContent(_buildDiagnosticoTab(), 'diagnostico'),
                _wrapTabContent(_buildTecnologiaTab(), 'tecnologia'),
                _wrapTabContent(_buildComentariosTab(), 'comentarios'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _wrapTabContent(Widget content, String type) {
    return Container(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            key: ValueKey('$type-content'),
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: content,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 8, bottom: 4, left: 8, right: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade100, Colors.green.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200.withValues(alpha: 0.5),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        tabs: _buildTabsWithIcons(),
        indicator: BoxDecoration(
          color: Colors.green.shade700,
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.green.shade800,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  List<Widget> _buildTabsWithIcons() {
    final tabData = [
      {'icon': FontAwesomeIcons.info, 'text': 'Informações'},
      {'icon': FontAwesomeIcons.magnifyingGlass, 'text': 'Diagnóstico'},
      {'icon': FontAwesomeIcons.gear, 'text': 'Tecnologia'},
      {'icon': FontAwesomeIcons.comment, 'text': 'Comentários'},
    ];

    return tabData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      return Tab(
        child: AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            final isActive = _tabController.index == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? null : 40,
              child: Row(
                mainAxisSize: isActive ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(data['icon'] as IconData, size: isActive ? 18 : 16),
                  if (isActive) ...[
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        data['text'] as String,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _buildInformacoesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCardWidget(),
          const SizedBox(height: 16),
          _buildClassificacaoCardWidget(),
          const SizedBox(height: 80), // Espaço para bottom navigation
        ],
      ),
    );
  }

  Widget _buildInfoCardWidget() {
    final theme = Theme.of(context);

    // Dados reais do defensivo carregados do repositório
    final caracteristicas = {
      'ingredienteAtivo':
          _defensivoData?.ingredienteAtivo ?? 'Glifosato 480g/L',
      'nomeTecnico': _defensivoData?.nomeTecnico ?? '2,4-D-dimetilamina',
      'toxico': _defensivoData?.toxico ?? 'Classe III - Medianamente tóxico',
      'inflamavel': _defensivoData?.inflamavel ?? 'Não inflamável',
      'corrosivo': _defensivoData?.corrosivo ?? 'Não corrosivo',
    };

    return DecoratedBox(
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
          // Header do card
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4CAF50).withValues(alpha: 0.8),
                  const Color(0xFF4CAF50).withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.info,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Informações Técnicas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Conteúdo do card
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoItem(
                  'Ingrediente Ativo',
                  caracteristicas['ingredienteAtivo']!,
                  FontAwesomeIcons.flask,
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  'Nome Técnico',
                  caracteristicas['nomeTecnico']!,
                  FontAwesomeIcons.tag,
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  'Toxicologia',
                  caracteristicas['toxico']!,
                  FontAwesomeIcons.skull,
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  'Inflamável',
                  caracteristicas['inflamavel']!,
                  FontAwesomeIcons.fire,
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  'Corrosivo',
                  caracteristicas['corrosivo']!,
                  FontAwesomeIcons.droplet,
                  const Color(0xFF4CAF50),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassificacaoCardWidget() {
    final theme = Theme.of(context);

    // Dados reais do defensivo carregados do repositório
    final caracteristicas = {
      'modoAcao': _defensivoData?.modoAcao ?? 'Sistêmico',
      'classeAgronomica': _defensivoData?.classeAgronomica ?? 'Herbicida',
      'classAmbiental':
          _defensivoData?.classAmbiental ?? 'Classe II - Muito perigoso',
      'formulacao': _defensivoData?.formulacao ?? 'Suspensão concentrada',
      'mapa': _defensivoData?.idReg ?? '12345-67',
    };

    return DecoratedBox(
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
          // Header do card
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4CAF50).withValues(alpha: 0.8),
                  const Color(0xFF4CAF50).withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.layerGroup,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Classificação',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Conteúdo do card
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoItem(
                  'Modo de Ação',
                  caracteristicas['modoAcao']!,
                  FontAwesomeIcons.gear,
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  'Classe Agronômica',
                  caracteristicas['classeAgronomica']!,
                  FontAwesomeIcons.seedling,
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  'Classe Ambiental',
                  caracteristicas['classAmbiental']!,
                  FontAwesomeIcons.leaf,
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  'Formulação',
                  caracteristicas['formulacao']!,
                  FontAwesomeIcons.flask,
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  'Registro MAPA',
                  caracteristicas['mapa']!,
                  FontAwesomeIcons.map,
                  const Color(0xFF4CAF50),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.15),
                  accentColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: accentColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTecnologiaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildApplicationInfoSection(
            'Tecnologia',
            _getTecnologiaContent(),
            Icons.precision_manufacturing_outlined,
          ),
          const SizedBox(height: 24),
          _buildApplicationInfoSection(
            'Embalagens',
            _getEmbalagensContent(),
            Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 24),
          _buildApplicationInfoSection(
            'Manejo Integrado',
            _getManejoIntegradoContent(),
            Icons.integration_instructions_outlined,
          ),
          const SizedBox(height: 24),
          _buildApplicationInfoSection(
            'Manejo de Resistência',
            _getManejoResistenciaContent(),
            Icons.shield_outlined,
          ),
          const SizedBox(height: 24),
          _buildApplicationInfoSection(
            'Precauções Humanas',
            _getPrecaucoesHumanasContent(),
            Icons.person_outlined,
          ),
          const SizedBox(height: 24),
          _buildApplicationInfoSection(
            'Precauções Ambientais',
            _getPrecaucoesAmbientaisContent(),
            Icons.nature_outlined,
          ),
          const SizedBox(height: 24),
          _buildApplicationInfoSection(
            'Compatibilidade',
            _getCompatibilidadeContent(),
            Icons.compare_arrows_outlined,
          ),
          const SizedBox(height: 80), // Espaço para bottom navigation
        ],
      ),
    );
  }

  Widget _buildApplicationInfoSection(
    String title,
    String content,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    if (content.isEmpty) {
      return const SizedBox.shrink();
    }

    const accentColor = Color(0xFF4CAF50); // Verde padrão do app

    return DecoratedBox(
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
          // Header da seção
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.8),
                  accentColor.withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.volume_up,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () {
                      // Implementar TTS aqui
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Lendo: $title')));
                    },
                    tooltip: 'Ouvir texto',
                  ),
                ),
              ],
            ),
          ),

          // Conteúdo da seção
          Container(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText(
              content,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticoTab() {
    final filteredDiagnosticos = _getFilteredDiagnosticos();
    final groupedDiagnosticos = _groupDiagnosticosByCultura(
      filteredDiagnosticos,
    );

    // Debug logs
    debugPrint('==== DEBUG DIAGNOSTICOS ====');
    debugPrint('Total diagnósticos carregados: ${_diagnosticos.length}');
    debugPrint('Diagnósticos após filtros: ${filteredDiagnosticos.length}');
    debugPrint('Culturas agrupadas: ${groupedDiagnosticos.keys.toList()}');
    debugPrint('Query de busca: $_searchQuery');
    debugPrint('Cultura selecionada: $_selectedCultura');
    debugPrint('isLoading: $isLoading, hasError: $hasError');
    debugPrint('=============================');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDiagnosticoFilters(),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (filteredDiagnosticos.isEmpty)
                  _buildNoDiagnosticosFound()
                else
                  ...groupedDiagnosticos.entries.map((entry) {
                    final cultura = entry.key;
                    final diagnosticos = entry.value;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCulturaSection(
                          cultura,
                          '${diagnosticos.length} diagnóstico${diagnosticos.length != 1 ? 's' : ''}',
                        ),
                        const SizedBox(height: 16),
                        ...diagnosticos.map(
                          (diagnostico) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildDiagnosticoItem(
                              diagnostico.nome,
                              diagnostico.ingredienteAtivo,
                              diagnostico.dosagem,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  }),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosticoFilters() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Campo de pesquisa (metade esquerda)
          Expanded(
            flex: 1,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: TextField(
                onChanged: (value) {
                  if (mounted) {
                    setState(() {
                      _searchQuery = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Pesquisar diagnósticos...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Seletor de cultura (metade direita)
          Expanded(
            flex: 1,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: DropdownButton<String>(
                value: _selectedCultura,
                onChanged: (String? newValue) {
                  if (mounted) {
                    setState(() {
                      _selectedCultura = newValue ?? 'Todas';
                    });
                  }
                },
                isExpanded: true,
                underline: const SizedBox(),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                items:
                    _culturas.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDiagnosticosFound() {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum diagnóstico encontrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tente buscar por outros termos ou altere o filtro de cultura'
                  : 'Não há diagnósticos para a cultura selecionada',
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

  List<DiagnosticoModel> _getFilteredDiagnosticos() {
    List<DiagnosticoModel> filtered = _diagnosticos;

    // Filtrar por cultura
    if (_selectedCultura != 'Todas') {
      filtered = filtered.where((d) => d.cultura == _selectedCultura).toList();
    }

    // Filtrar por pesquisa
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered =
          filtered
              .where(
                (d) =>
                    d.nome.toLowerCase().contains(query) ||
                    d.ingredienteAtivo.toLowerCase().contains(query) ||
                    d.cultura.toLowerCase().contains(query),
              )
              .toList();
    }

    return filtered;
  }

  Map<String, List<DiagnosticoModel>> _groupDiagnosticosByCultura(
    List<DiagnosticoModel> diagnosticos,
  ) {
    final Map<String, List<DiagnosticoModel>> grouped = {};

    for (final diagnostico in diagnosticos) {
      if (!grouped.containsKey(diagnostico.cultura)) {
        grouped[diagnostico.cultura] = [];
      }
      grouped[diagnostico.cultura]!.add(diagnostico);
    }

    // Ordenar as culturas alfabeticamente
    final sortedKeys = grouped.keys.toList()..sort();
    final Map<String, List<DiagnosticoModel>> sortedGrouped = {};

    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }

  Widget _buildCulturaSection(String cultura, String diagnosticos) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.eco, color: theme.colorScheme.primary, size: 18),
          const SizedBox(width: 12),
          Text(
            '$cultura ($diagnosticos)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticoItem(String nome, String principio, String dosagem) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _showDiagnosticDialog(nome, principio, dosagem),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8.0),
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.agriculture,
                color: theme.colorScheme.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    principio,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dosagem: $dosagem',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[600], size: 18),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComentariosTab() {
    final isPremium = _premiumService.isPremium;

    // Para usuários free, mostra apenas o card premium centralizado
    if (!isPremium) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: _buildAddCommentSection(), // Card premium
              ),
            ),
          ),
          const SizedBox(height: 80), // Espaço para bottom navigation
        ],
      );
    }

    // Para usuários premium, mostra campo de comentário + lista
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add new comment section (campo de cadastro)
          _buildAddCommentSection(),
          const SizedBox(height: 24),

          // Comments list (sem estado vazio)
          if (_isLoadingComments)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_comentarios.isNotEmpty)
            _buildCommentsList(),

          const SizedBox(height: 80), // Espaço para bottom navigation
        ],
      ),
    );
  }

  Widget _buildAddCommentSection() {
    final theme = Theme.of(context);

    // Verificar se o usuário é premium usando o service real
    final isPremium = _premiumService.isPremium;

    if (!isPremium) {
      return PremiumUpgradeWidget.noPermission(
        onUpgrade: () => _premiumService.navigateToPremium(),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.comment_outlined,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Adicionar comentário',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 300,
              decoration: InputDecoration(
                hintText: 'Compartilhe sua experiência sobre este defensivo...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _commentController.clear();
                  },
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addComment,
                  child: const Text('Adicionar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _comentarios.length,
      itemBuilder: (context, index) {
        final comentario = _comentarios[index];
        return _buildCommentCard(comentario);
      },
    );
  }

  Widget _buildCommentCard(ComentarioModel comentario) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(comentario.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar exclusão'),
              content: const Text(
                'Tem certeza que deseja excluir este comentário?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Excluir'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _deleteComment(comentario.id);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Anônimo',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(comentario.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                comentario.conteudo,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addComment() async {
    final content = _commentController.text.trim();

    if (!_comentariosService.isValidContent(content)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_comentariosService.getValidationErrorMessage()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_comentariosService.canAddComentario(_comentarios.length)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Limite de comentários atingido. Assine o plano premium para mais.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final newComment = ComentarioModel(
      id: _comentariosService.generateId(),
      idReg: _comentariosService.generateIdReg(),
      titulo: '',
      conteudo: content,
      ferramenta: 'defensivos',
      pkIdentificador: _defensivoData?.idReg ?? widget.defensivoName,
      status: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await _comentariosService.addComentario(newComment);

      if (mounted) {
        setState(() {
          _comentarios.add(newComment);
          _commentController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comentário adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _deleteComment(String commentId) async {
    try {
      await _comentariosService.deleteComentario(commentId);

      if (mounted) {
        setState(() {
          _comentarios.removeWhere((comment) => comment.id == commentId);
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Comentário excluído')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir comentário: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getTecnologiaContent() {
    return 'MINISTÉRIO DA AGRICULTURA, PECUÁRIA E ABASTECIMENTO - MAPA\n\nINSTRUÇÕES DE USO:\n\n${widget.defensivoName} é um herbicida à base do ingrediente ativo Indaziflam, indicado para o controle pré-emergente das plantas daninhas nas culturas da cana-de-açúcar (cana planta e cana soca), café e citros.\n\nMODO DE APLICAÇÃO:\nAplicar via pulverização foliar, preferencialmente no início da manhã ou final da tarde. Utilizar equipamentos de proteção individual adequados.\n\nNÚMERO, ÉPOCA E INTERVALO DE APLICAÇÃO:\nCana-de-açúcar: O produto deve ser pulverizado sobre o solo úmido, bem preparado e livre de torrões, em cana-planta e na cana-soca, na pré-emergência da cultura e das plantas daninhas. Aplicar somente em solo médio e pesado.\n\nCafé: o produto deve ser aplicado em pulverização sobre o solo úmido, nas entre fileiras da cultura, na pré-emergência das plantas daninhas.';
  }

  String _getEmbalagensContent() {
    return 'EMBALAGENS DISPONÍVEIS:\n\n• Frasco plástico de 1 litro\n• Bombona plástica de 5 litros\n• Bombona plástica de 20 litros\n• Tambor plástico de 200 litros\n\nDESTINAÇÃO ADEQUADA DAS EMBALAGENS:\nApós o uso correto deste produto, as embalagens devem ser:\n• Lavadas três vezes (tríplice lavagem)\n• Armazenadas em local adequado\n• Devolvidas ao estabelecimento comercial ou posto de recebimento\n\nNÃO REUTILIZAR EMBALAGENS VAZIAS.\nEsta embalagem deve ser reciclada em instalação autorizada.';
  }

  String _getManejoIntegradoContent() {
    return 'MANEJO INTEGRADO DE PRAGAS (MIP):\n\nO ${widget.defensivoName} deve ser utilizado dentro de um programa de Manejo Integrado de Pragas, que inclui:\n\n• Monitoramento regular da cultura\n• Uso de métodos de controle biológico quando possível\n• Rotação de produtos com diferentes modos de ação\n• Preservação de inimigos naturais\n• Práticas culturais adequadas\n\nRESISTÊNCIA:\nPara evitar o desenvolvimento de populações resistentes, recomenda-se:\n• Não repetir aplicações do mesmo produto\n• Alternar com produtos de diferentes grupos químicos\n• Respeitar intervalos de aplicação\n• Monitorar a eficácia do controle';
  }

  String _getManejoResistenciaContent() {
    return 'ESTRATÉGIAS DE MANEJO DE RESISTÊNCIA:\n\n1. ROTAÇÃO DE MECANISMOS DE AÇÃO:\n• Alternar produtos com diferentes modos de ação\n• Não utilizar o mesmo produto consecutivamente\n• Respeitar janela de aplicação\n\n2. MONITORAMENTO:\n• Avaliar eficácia após aplicações\n• Identificar sinais de perda de eficiência\n• Comunicar suspeitas de resistência\n\n3. BOAS PRÁTICAS:\n• Usar doses recomendadas\n• Calibrar equipamentos adequadamente\n• Aplicar em condições climáticas favoráveis\n• Manter registros de aplicações\n\n4. MEDIDAS PREVENTIVAS:\n• Limpeza de equipamentos\n• Controle de plantas daninhas resistentes\n• Integração com métodos não químicos';
  }

  String _getPrecaucoesHumanasContent() {
    return 'PRECAUÇÕES DE USO E ADVERTÊNCIAS:\n\nEQUIPAMENTOS DE PROTEÇÃO INDIVIDUAL (EPI):\n• Macacão com mangas compridas\n• Luvas impermeáveis\n• Botas impermeáveis\n• Máscara facial ou respirador\n• Óculos de proteção\n\nPRECAUÇÕES DURANTE A APLICAÇÃO:\n• Não comer, beber ou fumar durante o manuseio\n• Aplicar somente em ausência de ventos fortes\n• Evitar aplicação em condições de alta temperatura\n• Manter pessoas e animais afastados da área tratada\n\nPRIMEIROS SOCORROS:\n• Em caso de intoxicação, procurar atendimento médico imediato\n• Levar a embalagem ou rótulo do produto\n• Centro de Intoxicações: 0800-722-6001\n\nSINTOMAS DE INTOXICAÇÃO:\nNáuseas, vômitos, dor de cabeça, tontura.';
  }

  String _getPrecaucoesAmbientaisContent() {
    return 'PRECAUÇÕES AMBIENTAIS:\n\nPROTEÇÃO DO MEIO AMBIENTE:\n• Este produto é tóxico para organismos aquáticos\n• Não contaminar córregos, lagos, açudes, poços e nascentes\n• Não aplicar em dias de vento forte\n• Manter distância mínima de 30 metros de corpos d\'água\n\nDESTINO ADEQUADO DE RESTOS:\n• Não descartar em esgotos ou corpos d\'água\n• Não enterrar embalagens ou restos do produto\n• Utilizar sobras do produto conforme recomendações\n\nPROTEÇÃO DA FAUNA:\n• Produto tóxico para abelhas\n• Não aplicar durante floração\n• Evitar deriva para vegetação nativa\n• Proteger organismos benéficos\n\nRESTRIÇÕES:\n• Uso restrito a aplicadores treinados\n• Venda sob receituário agronômico\n• Registro no MAPA sob número 12345-67';
  }

  String _getCompatibilidadeContent() {
    return 'COMPATIBILIDADE E MISTURAS:\n\nCOMPATIBILIDADE QUÍMICA:\nO ${widget.defensivoName} é compatível com:\n• Adjuvantes recomendados pelo fabricante\n• Fertilizantes foliares específicos\n• Outros herbicidas quando recomendado\n\nINCOMPATIBILIDADES:\n• Produtos alcalinos (pH > 8,0)\n• Fertilizantes com cálcio em alta concentração\n• Produtos à base de cobre\n• Óleos minerais ou vegetais\n\nTESTE DE COMPATIBILIDADE:\nAntes de fazer misturas:\n1. Preparar pequena quantidade da mistura\n2. Observar por 30 minutos\n3. Verificar formação de precipitados ou separação de fases\n4. Não utilizar em caso de incompatibilidade\n\nRECOMENDAÇÕES:\n• Sempre consultar engenheiro agrônomo\n• Realizar teste prévio em pequena área\n• Preparar mistura apenas para uso imediato\n• Agitar constantemente durante aplicação';
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    // Só mostra o FAB se estiver na aba de comentários (agora é a quarta aba, índice 3)
    if (_tabController.index != 3) {
      return null;
    }

    return FloatingActionButton(
      onPressed: () => _showCommentDialog(),
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      tooltip: 'Adicionar comentário',
      child: const Icon(Icons.add),
    );
  }

  void _showAddCommentDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Adicionar Comentário'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Defensivos - ${widget.defensivoName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText:
                        'Compartilhe sua experiência com este defensivo...',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  maxLines: 4,
                  maxLength: 300,
                  autofocus: true,
                ),
                const SizedBox(height: 8),
                Text(
                  'Mínimo 5 caracteres, máximo 300 caracteres',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final content = controller.text.trim();
                  if (_validateComment(content)) {
                    _commentController.text = content;
                    _addComment();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
    );
  }

  bool _validateComment(String content) {
    if (content.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O comentário deve ter pelo menos 5 caracteres'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (content.length > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O comentário não pode ter mais que 300 caracteres'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m atrás';
    } else {
      return 'Agora';
    }
  }

  void _showDiagnosticDialog(String nome, String principio, String dosagem) {
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: theme.dialogTheme.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                maxWidth: MediaQuery.of(context).size.width - 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            nome,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ingrediente Ativo
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(
                              'Ingrediente Ativo: $principio',
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          // Information Cards
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                _buildInfoRow(
                                  'Dosagem',
                                  dosagem,
                                  Icons.medication,
                                  isPremium: isPremium,
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  'Aplicação Terrestre',
                                  '••• L/ha',
                                  Icons.agriculture,
                                  isPremium: false,
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  'Aplicação Aérea',
                                  '••• L/ha',
                                  Icons.flight,
                                  isPremium: false,
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  'Intervalo de Aplicação',
                                  '••• dias',
                                  Icons.schedule,
                                  isPremium: false,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  // Actions
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Stay on current defensivo page (already here)
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Defensivo'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder:
                                      (context) => DetalheDiagnosticoPage(
                                        diagnosticoId: '1',
                                        nomeDefensivo: widget.defensivoName,
                                        nomePraga: nome,
                                        cultura: 'Soja',
                                      ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Diagnóstico'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    required bool isPremium,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
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
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isPremium ? FontWeight.w600 : FontWeight.w300,
                  color:
                      isPremium
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                ),
              ),
            ],
          ),
        ),
        if (!isPremium) ...[
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.diamond, size: 12, color: Colors.amber.shade600),
              const SizedBox(width: 4),
              Text(
                'Premium',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.amber.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _showCommentDialog() {
    _showAddCommentDialog();
  }

  void _toggleFavorito() async {
    final wasAlreadyFavorited = isFavorited;

    // Usa ID único do repositório se disponível, senão fallback para nome
    final itemId = _defensivoData?.idReg ?? widget.defensivoName;
    final itemData = {
      'nome': _defensivoData?.nomeComum ?? widget.defensivoName,
      'fabricante': _defensivoData?.fabricante ?? widget.fabricante,
      'idReg': itemId,
    };

    if (mounted) {
      setState(() {
        isFavorited = !wasAlreadyFavorited;
      });
    }

    final success =
        wasAlreadyFavorited
            ? await _favoritosRepository.removeFavorito('defensivo', itemId)
            : await _favoritosRepository.addFavorito(
              'defensivo',
              itemId,
              itemData,
            );

    if (!success) {
      // Reverter estado em caso de falha
      if (mounted) {
        setState(() {
          isFavorited = wasAlreadyFavorited;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao ${wasAlreadyFavorited ? 'remover' : 'adicionar'} favorito',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Notifica a página de favoritos sobre a mudança
      FavoritosPage.reloadIfActive();
    }
  }
}
