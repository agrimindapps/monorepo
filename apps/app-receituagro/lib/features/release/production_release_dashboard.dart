import 'package:flutter/material.dart';
import '../../core/services/beta_testing_service.dart';

/// Data class for beta feedback
class BetaFeedback {
  final String title;
  final String description;
  final String category;
  final DateTime createdAt;
  
  const BetaFeedback({
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
  });
  
  factory BetaFeedback.fromMap(Map<String, dynamic> map) {
    return BetaFeedback(
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      createdAt: map['createdAt'] as DateTime? ?? DateTime.now(),
    );
  }
}

/// Data class for beta tester
class BetaTester {
  final String id;
  final String name;
  final String email;
  final DateTime joinedAt;
  
  const BetaTester({
    required this.id,
    required this.name,
    required this.email,
    required this.joinedAt,
  });
  
  factory BetaTester.fromMap(Map<String, dynamic> map) {
    return BetaTester(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      joinedAt: map['joinedAt'] as DateTime? ?? DateTime.now(),
    );
  }
}

/// Production Release Dashboard for monitoring release readiness
class ProductionReleaseDashboard extends StatefulWidget {
  const ProductionReleaseDashboard({super.key});

  @override
  State<ProductionReleaseDashboard> createState() => _ProductionReleaseDashboardState();
}

class _ProductionReleaseDashboardState extends State<ProductionReleaseDashboard>
    with TickerProviderStateMixin {
  late BetaTestingService _betaTestingService;
  late TabController _tabController;

  List<ReleaseChecklistItem> _checklist = [];
  double _readinessScore = 0.0;
  bool _isReadyForProduction = false;
  Map<String, dynamic>? _releaseReport;
  bool _isLoading = true;
  List<BetaTester> _betaTesters = [];
  List<BetaFeedback> _betaFeedback = [];

  @override
  void initState() {
    super.initState();
    _betaTestingService = BetaTestingService.instance;
    _tabController = TabController(length: 4, vsync: this);
    _loadReleaseData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReleaseData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _checklist = await _betaTestingService.getReleaseChecklist();
      _readinessScore = await _betaTestingService.getReleaseReadinessScore();
      _isReadyForProduction = await _betaTestingService.isReadyForProduction();
      _releaseReport = await _betaTestingService.generateReleaseReport();
      
      // Load beta testing data
      final testersData = await _betaTestingService.getBetaTesters();
      final feedbackData = await _betaTestingService.getBetaFeedback();
      
      _betaTesters = testersData.map((data) => BetaTester.fromMap(data)).toList();
      _betaFeedback = feedbackData.map((data) => BetaFeedback.fromMap(data)).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeChecklistItem(String itemId) async {
    try {
      await _betaTestingService.completeChecklistItem(itemId);
      await _loadReleaseData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item marcado como concluído'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao marcar item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportReleaseReport() async {
    try {
      await _betaTestingService.exportBetaData();
      
      // In production, this would export to a file or share
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Relatório exportado com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar relatório: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Release'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Checklist'),
            Tab(text: 'Beta Testing'),
            Tab(text: 'Relatórios'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReleaseData,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportReleaseReport,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildChecklistTab(),
                _buildBetaTestingTab(),
                _buildReportsTab(),
              ],
            ),
      floatingActionButton: _isReadyForProduction
          ? FloatingActionButton.extended(
              onPressed: () => _showReleaseConfirmation(),
              icon: const Icon(Icons.rocket_launch),
              label: const Text('Lançar em Produção'),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReadinessCard(),
          const SizedBox(height: 16),
          _buildQuickStatsCard(),
          const SizedBox(height: 16),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildReadinessCard() {
    Color scoreColor;
    String scoreLabel;
    
    if (_readinessScore >= 90) {
      scoreColor = Colors.green;
      scoreLabel = 'Pronto para Produção';
    } else if (_readinessScore >= 70) {
      scoreColor = Colors.orange;
      scoreLabel = 'Quase Pronto';
    } else {
      scoreColor = Colors.red;
      scoreLabel = 'Necessita Trabalho';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prontidão para Release',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scoreColor.withAlpha((255 * 0.1).round()),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    scoreLabel,
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: _readinessScore / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_readinessScore.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: scoreColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isReadyForProduction
                            ? 'Todos os itens obrigatórios foram concluídos'
                            : 'Alguns itens obrigatórios ainda precisam ser concluídos',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard() {
    final completedItems = _checklist.where((item) => item.isCompleted).length;
    final requiredItems = _checklist.where((item) => item.isRequired).length;
    final completedRequired = _checklist
        .where((item) => item.isRequired && item.isCompleted)
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas Rápidas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Itens Concluídos',
                    '$completedItems / ${_checklist.length}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Itens Obrigatórios',
                    '$completedRequired / $requiredItems',
                    Icons.priority_high,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Fase Beta',
                    _betaTestingService.getCurrentPhase().value.toUpperCase(),
                    Icons.science,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Beta Testers',
                    '${_betaTesters.length}',
                    Icons.people,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final recentItems = _checklist
        .where((item) => item.isCompleted && item.completedAt != null)
        .toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Atividade Recente',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (recentItems.isEmpty)
              const Text('Nenhuma atividade recente')
            else
              ...recentItems.take(5).map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          _formatDate(item.completedAt!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistTab() {
    final categories = <String, List<ReleaseChecklistItem>>{};
    for (final item in _checklist) {
      categories.putIfAbsent(item.category, () => []).add(item);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: categories.entries.map((entry) {
          return _buildCategorySection(entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  Widget _buildCategorySection(String category, List<ReleaseChecklistItem> items) {
    final completedCount = items.where((item) => item.isCompleted).length;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(_formatCategoryName(category)),
        subtitle: Text('$completedCount / ${items.length} concluídos'),
        trailing: CircularProgressIndicator(
          value: items.isNotEmpty ? completedCount / items.length : 0,
          strokeWidth: 3,
        ),
        children: items.map((item) => _buildChecklistItem(item)).toList(),
      ),
    );
  }

  Widget _buildChecklistItem(ReleaseChecklistItem item) {
    return ListTile(
      leading: Checkbox(
        value: item.isCompleted,
        onChanged: item.isCompleted
            ? null
            : (value) {
                if (value == true) {
                  _completeChecklistItem(item.id);
                }
              },
      ),
      title: Text(
        item.title,
        style: TextStyle(
          decoration: item.isCompleted ? TextDecoration.lineThrough : null,
          color: item.isCompleted ? Colors.grey[600] : null,
        ),
      ),
      subtitle: Text(item.description),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.isRequired)
            const Icon(Icons.priority_high, color: Colors.red, size: 16),
          if (item.completedAt != null)
            Text(
              _formatDate(item.completedAt!),
              style: const TextStyle(fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildBetaTestingTab() {
    final testers = _betaTesters;
    final feedback = _betaFeedback;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status do Beta Testing',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.people, size: 40, color: Colors.blue),
                        const SizedBox(height: 8),
                        Text(
                          '${testers.length}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const Text('Beta Testers'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.feedback, size: 40, color: Colors.orange),
                        const SizedBox(height: 8),
                        Text(
                          '${feedback.length}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const Text('Feedbacks'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (feedback.isNotEmpty) ...[
            Text(
              'Feedback Recente',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...feedback.take(5).map((BetaFeedback f) => Card(
                  child: ListTile(
                    title: Text(f.title),
                    subtitle: Text(f.description),
                    trailing: Chip(
                      label: Text(f.category),
                      backgroundColor: _getCategoryColor(f.category),
                    ),
                  ),
                )),
          ] else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Nenhum feedback de beta testing ainda'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Relatórios de Release',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (_releaseReport != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Relatório Completo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text('Dados atualizados em: ${_formatDate(DateTime.now())}'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Dados do relatório disponíveis via exportação',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _exportReleaseReport,
            icon: const Icon(Icons.download),
            label: const Text('Exportar Relatório Completo'),
          ),
        ],
      ),
    );
  }

  void _showReleaseConfirmation() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Lançamento'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tem certeza que deseja lançar em produção?'),
            SizedBox(height: 16),
            Text(
              'Esta ação irá:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Mover da fase beta para produção'),
            Text('• Disponibilizar o app para todos os usuários'),
            Text('• Ativar monitoramento de produção'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _launchProduction();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirmar Lançamento'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchProduction() async {
    try {
      await _betaTestingService.setBetaPhase(BetaPhase.production);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🚀 App lançado em produção com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      }

      await _loadReleaseData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao lançar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatCategoryName(String category) {
    switch (category) {
      case 'development':
        return 'Desenvolvimento';
      case 'qa':
        return 'Qualidade';
      case 'security':
        return 'Segurança';
      case 'infrastructure':
        return 'Infraestrutura';
      case 'release':
        return 'Release';
      case 'post_release':
        return 'Pós-Release';
      default:
        return category.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'bug':
        return Colors.red[100]!;
      case 'feature':
        return Colors.blue[100]!;
      case 'improvement':
        return Colors.green[100]!;
      case 'ui':
        return Colors.purple[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
}