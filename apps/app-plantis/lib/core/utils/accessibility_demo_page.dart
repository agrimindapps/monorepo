import 'package:flutter/material.dart';

import '../../shared/widgets/accessible_components.dart';
import '../theme/accessibility_tokens.dart';
import 'accessibility_test_helper.dart';

/// Página de demonstração das funcionalidades de acessibilidade
/// Remover em produção - apenas para desenvolvimento e testes
class AccessibilityDemoPage extends StatefulWidget {
  const AccessibilityDemoPage({super.key});

  @override
  State<AccessibilityDemoPage> createState() => _AccessibilityDemoPageState();
}

class _AccessibilityDemoPageState extends State<AccessibilityDemoPage> 
    with AccessibilityFocusMixin {
  
  final _searchController = TextEditingController();
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _showDebugOverlay = false;

  @override
  Widget build(BuildContext context) {
    return AccessibilityDebugOverlay(
      showOverlay: _showDebugOverlay,
      child: Shortcuts(
        shortcuts: AccessibilityTestHelper.accessibilityShortcuts,
        child: Actions(
          actions: AccessibilityTestHelper.accessibilityActions,
          child: Scaffold(
            appBar: AccessibleAppBar(
              title: const Text('Demo de Acessibilidade'),
              actions: [
                Semantics(
                  label: _showDebugOverlay ? 'Ocultar overlay de debug' : 'Mostrar overlay de debug',
                  button: true,
                  child: IconButton(
                    icon: Icon(_showDebugOverlay ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _showDebugOverlay = !_showDebugOverlay;
                      });
                      AccessibilityTokens.performHapticFeedback('light');
                    },
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInstructionsCard(),
                  const SizedBox(height: 24),
                  _buildSearchDemo(),
                  const SizedBox(height: 24),
                  _buildPlantsDemo(),
                  const SizedBox(height: 24),
                  _buildSettingsDemo(),
                  const SizedBox(height: 24),
                  _buildAccessibilityReport(),
                ],
              ),
            ),
            floatingActionButton: AccessibleFAB(
              onPressed: _showAccessibilityTips,
              label: 'Dicas de Acessibilidade',
              icon: Icons.accessibility_new,
              tooltip: 'Ver dicas de acessibilidade',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                '🎯 Instruções de Teste',
                style: TextStyle(
                  fontSize: AccessibilityTokens.getAccessibleFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Como testar a acessibilidade:',
              style: TextStyle(
                fontSize: AccessibilityTokens.getAccessibleFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildInstructionItem('1. Use Tab para navegar entre elementos'),
            _buildInstructionItem('2. Space/Enter para ativar botões'),
            _buildInstructionItem('3. Ative TalkBack (Android) ou VoiceOver (iOS)'),
            _buildInstructionItem('4. Teste com texto ampliado nas configurações'),
            _buildInstructionItem('5. Use os atalhos: Alt+A, Alt+S, Alt+N'),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AccessibilityTokens.getAccessibleFontSize(context, 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            '🔍 Busca Acessível',
            style: TextStyle(
              fontSize: AccessibilityTokens.getAccessibleFontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        AccessibleSearchBar(
          controller: _searchController,
          focusNode: getFocusNode('search'),
          hintText: 'Buscar plantas...',
          onChanged: (value) {
            // Demo - não faz nada real
          },
          onClear: () {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildPlantsDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            '🌱 Cards de Plantas',
            style: TextStyle(
              fontSize: AccessibilityTokens.getAccessibleFontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        AccessiblePlantCard(
          plantName: 'Espada de São Jorge',
          plantType: 'Sansevieria trifasciata',
          lastWatered: DateTime.now().subtract(const Duration(days: 2)),
          nextTask: 'Rega em 5 dias',
          onTap: () {
            _showPlantDetails('Espada de São Jorge');
          },
          onLongPress: () {
            _showPlantOptions('Espada de São Jorge');
          },
        ),
        const SizedBox(height: 8),
        AccessiblePlantCard(
          plantName: 'Monstera Deliciosa',
          plantType: 'Monstera deliciosa',
          lastWatered: DateTime.now().subtract(const Duration(days: 8)),
          nextTask: 'Rega urgente!',
          onTap: () {
            _showPlantDetails('Monstera Deliciosa');
          },
          onLongPress: () {
            _showPlantOptions('Monstera Deliciosa');
          },
        ),
      ],
    );
  }

  Widget _buildSettingsDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            '⚙️ Configurações',
            style: TextStyle(
              fontSize: AccessibilityTokens.getAccessibleFontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              AccessibleSwitch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                label: 'Notificações',
                subtitle: 'Receber lembretes de cuidados com plantas',
              ),
              const Divider(height: 1),
              AccessibleSwitch(
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                },
                label: 'Modo escuro',
                subtitle: 'Usar tema escuro para economizar bateria',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccessibilityReport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            '📊 Relatório de Acessibilidade',
            style: TextStyle(
              fontSize: AccessibilityTokens.getAccessibleFontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Score: A (95/100)',
                      style: TextStyle(
                        fontSize: AccessibilityTokens.getAccessibleFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '✅ Touch targets ≥ 44dp\n'
                  '✅ Labels semânticas implementadas\n'
                  '✅ Navegação por teclado funcional\n'
                  '✅ Contraste adequado (WCAG AA)\n'
                  '✅ Suporte a text scaling\n'
                  '⚠️  Alguns elementos poderiam ter mais contexto',
                  style: TextStyle(
                    fontSize: AccessibilityTokens.getAccessibleFontSize(context, 14),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                AccessibleButton(
                  onPressed: _runFullAccessibilityTest,
                  semanticLabel: 'Executar teste completo de acessibilidade',
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow, size: 20),
                      SizedBox(width: 8),
                      Text('Executar Teste Completo'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPlantDetails(String plantName) {
    AccessibilityTokens.announceForAccessibility(
      context,
      'Abrindo detalhes da planta $plantName',
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detalhes de $plantName'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPlantOptions(String plantName) {
    AccessibilityTokens.announceForAccessibility(
      context,
      'Opções da planta $plantName',
    );

    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Semantics(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Opções para $plantName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  AccessibilityTokens.performHapticFeedback('light');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Excluir'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(plantName);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String plantName) {
    AccessibleConfirmDialog.show(
      context: context,
      title: 'Excluir Planta',
      content: 'Tem certeza que deseja excluir $plantName? Esta ação não pode ser desfeita.',
      confirmText: 'Excluir',
      cancelText: 'Cancelar',
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        AccessibilityTokens.announceForAccessibility(
          context,
          '$plantName foi excluída',
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$plantName foi excluída'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _showAccessibilityTips() {
    showDialog<void>(
      context: context,
      builder: (context) => Semantics(
        child: AlertDialog(
          title: Semantics(
            header: true,
            child: const Text('💡 Dicas de Acessibilidade'),
          ),
          content: SingleChildScrollView(
            child: Text(
              '🎯 Para usuários com deficiências visuais:\n'
              '• Use TalkBack (Android) ou VoiceOver (iOS)\n'
              '• Aumente o tamanho do texto nas configurações\n'
              '• Ative o alto contraste\n\n'
              
              '⌨️ Para usuários com mobilidade limitada:\n'
              '• Use teclado externo ou switch control\n'
              '• Navegue com Tab e Enter/Space\n'
              '• Ative as opções de acessibilidade do sistema\n\n'
              
              '👂 Para usuários com deficiências auditivas:\n'
              '• Ative legendas quando disponíveis\n'
              '• Use feedback visual/haptic\n\n'
              
              '🧠 Para usuários com deficiências cognitivas:\n'
              '• Reduza animações nas configurações\n'
              '• Use modo de foco quando disponível',
              style: TextStyle(
                fontSize: AccessibilityTokens.getAccessibleFontSize(context, 14),
                height: 1.5,
              ),
            ),
          ),
          actions: [
            AccessibleButton(
              onPressed: () => Navigator.of(context).pop(),
              semanticLabel: 'Fechar dicas',
              child: const Text('Entendi'),
            ),
          ],
        ),
      ),
    );
  }

  void _runFullAccessibilityTest() {
    AccessibilityTokens.performHapticFeedback('medium');
    
    // Simular teste em desenvolvimento
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Executando teste de acessibilidade...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Simular tempo de teste
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      
      Navigator.of(context).pop();
      
      final report = AccessibilityTestHelper.validatePage(context);
      
      showDialog<void>(
        context: context,
        builder: (context) => Semantics(
          child: AlertDialog(
            title: Semantics(
              header: true,
              child: Text('📊 Resultado do Teste (${report.grade})'),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Score: ${report.score.toStringAsFixed(0)}/100',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...report.suggestions.map((suggestion) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      suggestion,
                      style: TextStyle(
                        fontSize: AccessibilityTokens.getAccessibleFontSize(context, 14),
                      ),
                    ),
                  )),
                ],
              ),
            ),
            actions: [
              AccessibleButton(
                onPressed: () => Navigator.of(context).pop(),
                semanticLabel: 'Fechar relatório',
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );
    });
  }
}