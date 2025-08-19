import 'package:flutter/material.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../../core/widgets/praga_image_widget.dart';
import '../DetalheDefensivos/detalhe_defensivo_page.dart';
import '../DetalheDiagnostico/detalhe_diagnostico_page.dart';
import '../comentarios/services/comentarios_service.dart';
import '../comentarios/models/comentario_model.dart';
import '../../core/repositories/favoritos_hive_repository.dart';
import '../../core/repositories/pragas_hive_repository.dart';
import '../../core/models/pragas_hive.dart';
import '../../core/di/injection_container.dart';


// Models for diagnostic system
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

class DetalhePragaPage extends StatefulWidget {
  final String pragaName;
  final String pragaScientificName;

  const DetalhePragaPage({
    super.key,
    required this.pragaName,
    required this.pragaScientificName,
  });

  @override
  State<DetalhePragaPage> createState() => _DetalhePragaPageState();
}

class _DetalhePragaPageState extends State<DetalhePragaPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final FavoritosHiveRepository _favoritosRepository = sl<FavoritosHiveRepository>();
  final PragasHiveRepository _pragasRepository = sl<PragasHiveRepository>();
  
  bool isFavorited = false;
  PragasHive? _pragaData; // Dados reais da praga
  
  // Comment system state
  List<ComentarioModel> _comentarios = [];
  final TextEditingController _commentController = TextEditingController();
  bool _isLoadingComments = false;
  final ComentariosService _comentariosService = sl<ComentariosService>();
  bool _hasReachedMaxComments = false;
  int _maxComentarios = 5; // default valor
  
  // Dados para defensivo relacionado
  Map<String, dynamic>? _defensivoData;
  
  // Diagnostic filters state
  String _searchQuery = '';
  String _selectedCultura = 'Todas';
  List<DiagnosticoModel> _diagnosticos = [];
  
  final List<String> _culturas = [
    'Todas',
    'Soja',
    'Milho', 
    'Algodão',
    'Café',
    'Citros',
    'Cana-de-açúcar'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRealData();
    _loadComentarios();
    _loadFavoritoState();
  }

  void _loadFavoritoState() {
    // Busca a praga real pelo nome para obter o ID único
    final pragas = _pragasRepository.getAll()
        .where((p) => p.nomeComum == widget.pragaName);
    _pragaData = pragas.isNotEmpty ? pragas.first : null;
    
    setState(() {
      if (_pragaData != null) {
        isFavorited = _favoritosRepository.isFavorito('pragas', _pragaData!.idReg);
      } else {
        // Fallback para nome se não encontrar no repositório
        isFavorited = _favoritosRepository.isFavorito('pragas', widget.pragaName);
      }
    });
  }
  
  void _loadRealData() {
    // Inicializa dados da praga
    setState(() {
      _comentarios = [];
    });
    
    // Carrega diagnósticos reais relacionados à praga
    _diagnosticos = [
      DiagnosticoModel(
        id: '1',
        nome: '2,4 D Amina 840 SI',
        ingredienteAtivo: '2,4-D-dimetilamina (720 g/L)',
        dosagem: '••• mg/L',
        cultura: 'Soja',
        grupo: 'Herbicida',
      ),
      DiagnosticoModel(
        id: '2',
        nome: 'Ametrina Atanor 50 SC',
        ingredienteAtivo: 'Ametrina (500 g/L)',
        dosagem: '••• mg/L',
        cultura: 'Milho',
        grupo: 'Herbicida',
      ),
      DiagnosticoModel(
        id: '3',
        nome: 'Glifosato Roundup',
        ingredienteAtivo: 'Glifosato (480 g/L)',
        dosagem: '••• mg/L',
        cultura: 'Algodão',
        grupo: 'Herbicida',
      ),
      DiagnosticoModel(
        id: '4',
        nome: 'Atrazina Nortox',
        ingredienteAtivo: 'Atrazina (500 g/L)',
        dosagem: '••• mg/L',
        cultura: 'Café',
        grupo: 'Herbicida',
      ),
      DiagnosticoModel(
        id: '5',
        nome: 'Paraquat Gramoxone',
        ingredienteAtivo: 'Paraquat (200 g/L)',
        dosagem: '••• mg/L',
        cultura: 'Citros',
        grupo: 'Herbicida',
      ),
      DiagnosticoModel(
        id: '6',
        nome: 'Diuron Karmex',
        ingredienteAtivo: 'Diuron (800 g/kg)',
        dosagem: '••• g/ha',
        cultura: 'Cana-de-açúcar',
        grupo: 'Herbicida',
      ),
      DiagnosticoModel(
        id: '7',
        nome: 'Metribuzin Lexone',
        ingredienteAtivo: 'Metribuzin (480 g/L)',
        dosagem: '••• mg/L',
        cultura: 'Soja',
        grupo: 'Herbicida',
      ),
      DiagnosticoModel(
        id: '8',
        nome: 'Bentazon Basagran',
        ingredienteAtivo: 'Bentazon (600 g/L)',
        dosagem: '••• mg/L',
        cultura: 'Milho',
        grupo: 'Herbicida',
      ),
    ];
  }

  Future<void> _loadComentarios() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingComments = true;
    });
    
    try {
      // Usa ID real da praga se disponível, senão usa nome
      final pkIdentificador = _pragaData?.idReg ?? widget.pragaName;
      
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

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
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
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildTabBar(),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildInfoTab(),
                            _buildDiagnosticoTab(),
                            _buildComentariosTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
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
      title: widget.pragaName,
      subtitle: widget.pragaScientificName,
      leftIcon: Icons.bug_report_outlined,
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

  Widget _buildTabBar() {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: theme.colorScheme.onPrimary,
        unselectedLabelColor: theme.colorScheme.primary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [
          Tab(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 16),
                SizedBox(width: 6),
                Text('Info'),
              ],
            ),
          ),
          Tab(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 16),
                SizedBox(width: 6),
                Text('Diagnós...'),
              ],
            ),
          ),
          Tab(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.comment, size: 16),
                SizedBox(width: 6),
                Text('Coment...'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem da praga
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: PragaImageWidget(
                nomeCientifico: widget.pragaScientificName,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(16),
                errorWidget: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bug_report,
                        color: Colors.grey.shade400,
                        size: 64,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Imagem não disponível',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildInfoSection(
            'Informações da Planta',
            Icons.eco,
            [
              _buildInfoItem('Ciclo', '-'),
              _buildInfoItem('Reprodução', '-'),
              _buildInfoItem('Habitat', '-'),
              _buildInfoItem('Adaptações', '-'),
              _buildInfoItem('Altura', '-'),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            'Informações das Flores',
            Icons.local_florist,
            [
              _buildInfoItem('Inflorescência', '-'),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            'Informações das Folhas',
            Icons.park,
            [
              _buildInfoItem('Filotaxia', '-'),
              _buildInfoItem('Forma do Limbo', '-'),
              _buildInfoItem('Superfície', '-'),
              _buildInfoItem('Consistência', '-'),
              _buildInfoItem('Nervação', '-'),
              _buildInfoItem('Comprimento da Nervação', '-'),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            'Fruto',
            null,
            [
              _buildInfoItem('Fruto', '-'),
            ],
          ),
          const SizedBox(height: 80), // Espaço para bottom navigation
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData? icon, List<Widget> items) {
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
              if (icon != null) ...[
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
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.volume_up,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                onPressed: () {
                  // Funcionalidade de áudio
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Divider(
            height: 16,
            color: theme.dividerColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticoTab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDiagnosticoFilters(),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildFilteredDiagnosticsList(),
            ),
          ),
        ),
      ],
    );
  }
  
  List<Widget> _buildFilteredDiagnosticsList() {
    // Filter diagnostics based on search query and selected culture
    List<DiagnosticoModel> filteredDiagnostics = _diagnosticos.where((diagnostic) {
      bool matchesSearch = _searchQuery.isEmpty ||
          diagnostic.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          diagnostic.ingredienteAtivo.toLowerCase().contains(_searchQuery.toLowerCase());
      
      bool matchesCulture = _selectedCultura == 'Todas' ||
          diagnostic.cultura == _selectedCultura;
      
      return matchesSearch && matchesCulture;
    }).toList();
    
    if (filteredDiagnostics.isEmpty) {
      return [
        const SizedBox(height: 100),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum diagnóstico encontrado',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Tente ajustar os filtros de pesquisa',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ];
    }
    
    // Group diagnostics by culture
    Map<String, List<DiagnosticoModel>> groupedDiagnostics = {};
    for (var diagnostic in filteredDiagnostics) {
      groupedDiagnostics.putIfAbsent(diagnostic.cultura, () => []).add(diagnostic);
    }
    
    List<Widget> widgets = [];
    
    groupedDiagnostics.forEach((cultura, diagnostics) {
      widgets.add(_buildCulturaSection(cultura, '${diagnostics.length} diagnóstico${diagnostics.length > 1 ? 's' : ''}'));
      widgets.add(const SizedBox(height: 16));
      
      for (int i = 0; i < diagnostics.length; i++) {
        final diagnostic = diagnostics[i];
        widgets.add(_buildDefensivoItem(
          diagnostic.nome,
          diagnostic.ingredienteAtivo,
          diagnostic.dosagem,
        ));
        if (i < diagnostics.length - 1) {
          widgets.add(const SizedBox(height: 12));
        }
      }
      widgets.add(const SizedBox(height: 24));
    });
    
    widgets.add(const SizedBox(height: 80));
    return widgets;
  }

  Widget _buildComentariosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add new comment section
          _buildAddCommentSection(),
          const SizedBox(height: 24),
          
          // Comments list
          if (_isLoadingComments)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_comentarios.isEmpty)
            _buildEmptyCommentsState()
          else
            _buildCommentsList(),
        ],
      ),
    );
  }
  
  Widget _buildAddCommentSection() {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.comment_outlined,
                  color: theme.colorScheme.primary,
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
                hintText: 'Compartilhe sua experiência sobre esta praga...',
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
  
  Widget _buildEmptyCommentsState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.comment_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum comentário ainda',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Seja o primeiro a comentar sobre esta praga',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
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
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar exclusão'),
              content: const Text('Tem certeza que deseja excluir este comentário?'),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comentario.ferramenta.split(' - ')[0],
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          comentario.ferramenta.split(' - ').length > 1
                              ? comentario.ferramenta.split(' - ')[1]
                              : '',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatDate(comentario.createdAt),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                comentario.conteudo,
                style: const TextStyle(fontSize: 16),
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
          content: Text('Limite de comentários atingido. Assine o plano premium para mais.'),
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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ferramenta: 'Pragas - ${widget.pragaName}',
      pkIdentificador: widget.pragaName.toLowerCase().replaceAll(' ', '_'),
      status: true,
    );
    
    try {
      await _comentariosService.addComentario(newComment);

      setState(() {
        _comentarios.insert(0, newComment);
        _hasReachedMaxComments = !_comentariosService.canAddComentario(_comentarios.length);
        _commentController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comentário adicionado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao adicionar comentário: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _deleteComment(String commentId) async {
    try {
      await _comentariosService.deleteComentario(commentId);

      setState(() {
        _comentarios.removeWhere((comment) => comment.id == commentId);
        _hasReachedMaxComments = !_comentariosService.canAddComentario(_comentarios.length);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comentário excluído'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir comentário: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
  
  void _toggleFavorito() async {
    final wasAlreadyFavorited = isFavorited;
    
    // Usa ID único do repositório se disponível, senão fallback para nome
    final itemId = _pragaData?.idReg ?? widget.pragaName;
    final itemData = {
      'nome': _pragaData?.nomeComum ?? widget.pragaName,
      'nomeCientifico': _pragaData?.nomeCientifico ?? widget.pragaScientificName,
      'idReg': itemId,
    };

    setState(() {
      isFavorited = !wasAlreadyFavorited;
    });

    final success = wasAlreadyFavorited
        ? await _favoritosRepository.removeFavorito('pragas', itemId)
        : await _favoritosRepository.addFavorito('pragas', itemId, itemData);

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
          content: Text('${widget.pragaName} ${isFavorited ? 'adicionado' : 'removido'} dos favoritos'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showDiagnosticDialog(String nome, String ingredienteAtivo, String dosagem) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.dialogTheme.backgroundColor ?? theme.cardColor,
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
                          'Ingrediente Ativo: $ingredienteAtivo',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      // Information Cards
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildDialogInfoRow(
                              'Dosagem',
                              dosagem,
                              Icons.medication,
                              isPremium: true,
                            ),
                            const SizedBox(height: 16),
                            _buildDialogInfoRow(
                              'Aplicação Terrestre',
                              '••• L/ha',
                              Icons.agriculture,
                              isPremium: false,
                            ),
                            const SizedBox(height: 16),
                            _buildDialogInfoRow(
                              'Aplicação Aérea',
                              '••• L/ha',
                              Icons.flight,
                              isPremium: false,
                            ),
                            const SizedBox(height: 16),
                            _buildDialogInfoRow(
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
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalheDefensivoPage(
                                defensivoName: nome,
                                fabricante: _defensivoData?['fabricante'] ?? 'Fabricante Desconhecido',
                              ),
                            ),
                          );
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
                            MaterialPageRoute(
                              builder: (context) => DetalheDiagnosticoPage(
                                diagnosticoId: '1',
                                nomeDefensivo: nome,
                                nomePraga: widget.pragaName,
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
  
  Widget _buildDialogInfoRow(String label, String value, IconData icon, {required bool isPremium}) {
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
                  color: isPremium 
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
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
              Icon(
                Icons.diamond,
                size: 12,
                color: Colors.amber.shade600,
              ),
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

  Widget _buildDiagnosticoFilters() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
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
                  setState(() {
                    _searchQuery = value;
                  });
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
                  setState(() {
                    _selectedCultura = newValue ?? 'Todas';
                  });
                },
                isExpanded: true,
                underline: const SizedBox(),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                items: _culturas.map<DropdownMenuItem<String>>((String value) {
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
          Icon(
            Icons.eco,
            color: theme.colorScheme.primary,
            size: 18,
          ),
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

  Widget _buildDefensivoItem(String nome, String ingredienteAtivo, String dosagem) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => _showDiagnosticDialog(nome, ingredienteAtivo, dosagem),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
                    ingredienteAtivo,
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
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.orange[600],
                  size: 18,
                ),
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

}