/// Exemplo de integração da sincronização automática no login do Gasometer
/// 
/// Este arquivo demonstra como utilizar a funcionalidade de sincronização
/// automática de dados automotivos implementada no app-gasometer.
/// 
/// **Funcionalidades implementadas:**
/// - SyncProgressOverlay com etapas específicas automotivas
/// - Integração com AuthProvider.loginAndSync()
/// - Tratamento de erros contextual para dados de veículos
/// - Fallback para modo offline
/// 
/// **Contexto Automotivo:**
/// - 🚗 Veículos: Sincronização de carros/motos cadastrados
/// - ⛽ Combustível: Histórico de abastecimentos e preços
/// - 🔧 Manutenções: Serviços programados e realizados
/// - 💰 Despesas: Gastos relacionados aos veículos
/// - 📊 Relatórios: Analytics e estatísticas de uso

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/controllers/login_controller.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../shared/widgets/sync/sync_progress_overlay.dart';
import '../error/sync_error_handler.dart';
import '../theme/gasometer_colors.dart';

/// Widget de exemplo que demonstra como integrar o login com sincronização
class GasometerLoginWithSyncExample extends StatefulWidget {
  const GasometerLoginWithSyncExample({super.key});

  @override
  State<GasometerLoginWithSyncExample> createState() => _GasometerLoginWithSyncExampleState();
}

class _GasometerLoginWithSyncExampleState extends State<GasometerLoginWithSyncExample> {
  late LoginController _loginController;
  OverlayEntry? _syncOverlayEntry;

  @override
  void initState() {
    super.initState();
    
    // Inicializar controller com dependências necessárias
    final authProvider = context.read<AuthProvider>();
    _loginController = LoginController(
      authProvider: authProvider,
    );
  }

  @override
  void dispose() {
    _removeSyncOverlay();
    _loginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Gasometer com Sync'),
        backgroundColor: GasometerColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildLoginForm(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
            _buildSyncStatusCard(),
          ],
        ),
      ),
    );
  }

  /// Card informativo sobre a funcionalidade
  Widget _buildInfoCard() {
    return Card(
      color: GasometerColors.primary.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: GasometerColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sincronização Automática',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: GasometerColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Após o login, seus dados automotivos serão sincronizados automaticamente:\n'
              '• 🚗 Veículos cadastrados\n'
              '• ⛽ Histórico de abastecimentos\n'
              '• 🔧 Manutenções programadas\n'
              '• 💰 Despesas registradas\n'
              '• 📊 Relatórios e estatísticas',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  /// Formulário de login
  Widget _buildLoginForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _loginController.emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _loginController.passwordController,
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _loginController.obscurePassword 
                        ? Icons.visibility 
                        : Icons.visibility_off,
                  ),
                  onPressed: _loginController.togglePasswordVisibility,
                ),
              ),
              obscureText: _loginController.obscurePassword,
            ),
          ],
        ),
      ),
    );
  }

  /// Botões de ação
  Widget _buildActionButtons() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          children: [
            // Botão de login com sincronização (padrão)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: authProvider.isLoading ? null : _loginWithSync,
                icon: authProvider.isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: Text(
                  authProvider.isLoading 
                      ? 'Fazendo login...' 
                      : 'Login com Sincronização',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GasometerColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Botão de login sem overlay (background)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: authProvider.isLoading ? null : _loginWithBackgroundSync,
                icon: const Icon(Icons.login),
                label: const Text('Login (Sync em Background)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: GasometerColors.primary,
                  side: const BorderSide(color: GasometerColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Botão de login tradicional (sem sync)
            TextButton(
              onPressed: authProvider.isLoading ? null : _traditionalLogin,
              child: const Text('Login Tradicional (Sem Sync)'),
            ),
          ],
        );
      },
    );
  }

  /// Card de status da sincronização
  Widget _buildSyncStatusCard() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final syncController = authProvider.syncProgressController;
        if (syncController == null) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status da Sincronização',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Status atual
                StreamBuilder<SyncProgressState>(
                  stream: syncController.stateStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    
                    final state = snapshot.data!;
                    return Row(
                      children: [
                        _getStateIcon(state),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getStateText(state),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Progresso
                StreamBuilder<double>(
                  stream: syncController.progressStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    
                    final progress = snapshot.data!;
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Progresso:'),
                            Text('${(progress * 100).toInt()}%'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            GasometerColors.primary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Ações
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: _showSyncOverlay,
                      icon: const Icon(Icons.visibility),
                      label: const Text('Ver Progresso'),
                    ),
                    TextButton.icon(
                      onPressed: _loginController.clearSyncProgress,
                      icon: const Icon(Icons.clear),
                      label: const Text('Limpar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Ícone do estado de sincronização
  Widget _getStateIcon(SyncProgressState state) {
    switch (state) {
      case SyncProgressState.preparing:
        return const Icon(Icons.settings, color: Colors.blue);
      case SyncProgressState.syncing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncProgressState.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case SyncProgressState.error:
        return const Icon(Icons.error, color: Colors.red);
      default:
        return const Icon(Icons.sync, color: Colors.grey);
    }
  }

  /// Texto do estado de sincronização
  String _getStateText(SyncProgressState state) {
    switch (state) {
      case SyncProgressState.preparing:
        return 'Preparando sincronização...';
      case SyncProgressState.syncing:
        return 'Sincronizando dados automotivos...';
      case SyncProgressState.completed:
        return 'Sincronização concluída!';
      case SyncProgressState.error:
        return 'Erro na sincronização';
      default:
        return 'Aguardando...';
    }
  }

  /// Login com sincronização e overlay
  Future<void> _loginWithSync() async {
    final success = await _loginController.signInWithEmailAndSync(
      showSyncOverlay: true,
    );
    
    if (success) {
      _showSyncOverlay();
      _showSuccessMessage('Login realizado com sucesso! Dados sincronizados.');
    } else {
      _showErrorMessage(_loginController.errorMessage ?? 'Erro no login');
    }
  }

  /// Login com sincronização em background
  Future<void> _loginWithBackgroundSync() async {
    final success = await _loginController.signInWithEmailAndSync(
      showSyncOverlay: false,
    );
    
    if (success) {
      _showSuccessMessage('Login realizado! Sincronização em background.');
    } else {
      _showErrorMessage(_loginController.errorMessage ?? 'Erro no login');
    }
  }

  /// Login tradicional sem sincronização
  Future<void> _traditionalLogin() async {
    await _loginController.signInWithEmail();
    
    if (_loginController.isAuthenticated) {
      _showSuccessMessage('Login tradicional realizado com sucesso!');
    } else {
      _showErrorMessage(_loginController.errorMessage ?? 'Erro no login');
    }
  }

  /// Mostra o overlay de sincronização
  void _showSyncOverlay() {
    final authProvider = context.read<AuthProvider>();
    final syncController = authProvider.syncProgressController;
    
    if (syncController == null) return;
    
    _removeSyncOverlay();
    
    _syncOverlayEntry = OverlayEntry(
      builder: (context) => SyncProgressOverlay(
        controller: syncController,
        onContinueInBackground: _removeSyncOverlay,
        onClose: _removeSyncOverlay,
        onRetry: () async {
          // Em caso de erro, tentar novamente
          await _loginWithSync();
        },
        showContinueOption: true,
        showCloseButton: true,
      ),
    );
    
    Overlay.of(context).insert(_syncOverlayEntry!);
  }

  /// Remove o overlay de sincronização
  void _removeSyncOverlay() {
    _syncOverlayEntry?.remove();
    _syncOverlayEntry = null;
  }

  /// Mostra mensagem de sucesso
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: GasometerColors.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Mostra mensagem de erro
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// =============================================================================
// EXEMPLOS DE USO EM DIFERENTES CENÁRIOS
// =============================================================================

/// Exemplo 1: Uso simples em uma página de login
class SimpleGasometerLogin extends StatelessWidget {
  final LoginController controller;
  
  const SimpleGasometerLogin({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Uso mais simples: login com sync automático
        final success = await controller.signInWithEmailAndSync();
        if (success) {
          // Navegar para tela principal
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      child: const Text('Entrar'),
    );
  }
}

/// Exemplo 2: Login customizado com controle de overlay
class CustomSyncLoginExample extends StatefulWidget {
  const CustomSyncLoginExample({super.key});

  @override
  State<CustomSyncLoginExample> createState() => _CustomSyncLoginExampleState();
}

class _CustomSyncLoginExampleState extends State<CustomSyncLoginExample> {
  bool _showSyncProgress = true;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Mostrar progresso de sincronização'),
          subtitle: const Text('Exibir overlay com etapas detalhadas'),
          value: _showSyncProgress,
          onChanged: (value) => setState(() => _showSyncProgress = value),
          activeColor: GasometerColors.primary,
        ),
        
        ElevatedButton(
          onPressed: () async {
            final controller = context.read<LoginController>();
            
            // Login com controle personalizado do overlay
            await controller.signInWithEmailAndSync(
              showSyncOverlay: _showSyncProgress,
            );
          },
          child: const Text('Login Personalizado'),
        ),
      ],
    );
  }
}

/// Exemplo 3: Tratamento de erros específicos do Gasometer
class GasometerErrorHandlingExample extends StatefulWidget {
  const GasometerErrorHandlingExample({super.key});

  @override
  State<GasometerErrorHandlingExample> createState() => _GasometerErrorHandlingExampleState();
}

class _GasometerErrorHandlingExampleState extends State<GasometerErrorHandlingExample> {
  // final GasometerSyncErrorHandler _errorHandler = GasometerSyncErrorHandler(
  //   sl<AnalyticsService>(), // Deve ser injetado via service locator
  // );

  @override
  void initState() {
    super.initState();
    // _setupErrorListening(); // Comentado para exemplo
  }

  // void _setupErrorListening() {
  //   _errorHandler.errorStream.listen((error) {
  //     _showErrorDialog(error);
  //   });
  // }

  void _showErrorDialog(GasometerSyncError error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getIconData(error.iconName),
              color: Color(int.parse(error.colorHex.replaceFirst('#', '0xFF'))),
            ),
            const SizedBox(width: 8),
            const Text('Erro na Sincronização'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error.userMessage),
            if (error.fallbackData != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Modo de fallback ativado:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                error.fallbackData!.keys.join(', '),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          // Mostrar ações de recuperação específicas
          ...error.recoveryActions.map((action) => TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleRecoveryAction(action, error);
            },
            child: Text(
              action.title,
              style: TextStyle(
                fontWeight: action.isRecommended ? FontWeight.bold : FontWeight.normal,
                color: action.isRecommended ? GasometerColors.primary : null,
              ),
            ),
          )),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    // Mapear nomes de ícones para IconData
    switch (iconName) {
      case 'directions_car': return Icons.directions_car;
      case 'local_gas_station': return Icons.local_gas_station;
      case 'build': return Icons.build;
      case 'attach_money': return Icons.attach_money;
      case 'speed': return Icons.speed;
      case 'analytics': return Icons.analytics;
      case 'wifi_off': return Icons.wifi_off;
      case 'star': return Icons.star;
      case 'warning': return Icons.warning;
      default: return Icons.error;
    }
  }

  void _handleRecoveryAction(GasometerRecoveryAction action, GasometerSyncError error) {
    // Implementar ações de recuperação específicas
    switch (action.id) {
      case 'retry':
        _retrySync();
        break;
      case 'fix_data':
        _navigateToDataFix(error.modelType);
        break;
      case 'upgrade_premium':
        _navigateToPremium();
        break;
      // ... outras ações
    }
  }

  void _retrySync() {
    final controller = context.read<LoginController>();
    controller.signInWithEmailAndSync();
  }

  void _navigateToDataFix(String? modelType) {
    // Navegar para tela de correção de dados específica
    switch (modelType) {
      case 'fuel':
        Navigator.pushNamed(context, '/fuel/fix');
        break;
      case 'vehicle':
        Navigator.pushNamed(context, '/vehicle/fix');
        break;
      // ... outros casos
    }
  }

  void _navigateToPremium() {
    Navigator.pushNamed(context, '/premium');
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder(child: Text('Error handling example'));
  }

  @override
  void dispose() {
    // _errorHandler.dispose(); // Comentado para exemplo
    super.dispose();
  }
}

// =============================================================================
// DOCUMENTAÇÃO DE INTEGRAÇÃO
// =============================================================================

/// ## Como integrar a sincronização automática no seu app Gasometer
/// 
/// ### 1. Configuração básica
/// 
/// ```dart
/// // No seu login page ou widget
/// final loginController = LoginController(
///   authProvider: context.read<AuthProvider>(),
/// );
/// 
/// // Login com sincronização automática
/// final success = await loginController.signInWithEmailAndSync();
/// ```
/// 
/// ### 2. Customização do overlay
/// 
/// ```dart
/// // Controlar se mostra o overlay ou não
/// await loginController.signInWithEmailAndSync(
///   showSyncOverlay: false, // true para mostrar, false para background
/// );
/// ```
/// 
/// ### 3. Monitoramento do progresso
/// 
/// ```dart
/// // Ouvir mudanças no progresso
/// final authProvider = context.watch<AuthProvider>();
/// final syncController = authProvider.syncProgressController;
/// 
/// if (syncController != null) {
///   StreamBuilder<SyncProgressState>(
///     stream: syncController.stateStream,
///     builder: (context, snapshot) {
///       // Mostrar status atual
///     },
///   );
/// }
/// ```
/// 
/// ### 4. Tratamento de erros
/// 
/// ```dart
/// // Configurar handler de erros
/// final errorHandler = GasometerSyncErrorHandler(analyticsService);
/// 
/// errorHandler.errorStream.listen((error) {
///   // Mostrar diálogo com ações de recuperação
///   showGasometerErrorDialog(context, error);
/// });
/// ```
/// 
/// ### 5. Integração com navigation
/// 
/// ```dart
/// if (await loginController.signInWithEmailAndSync()) {
///   // Login e sync bem-sucedidos
///   Navigator.pushReplacementNamed(context, '/home');
/// } else {
///   // Tratar erro
///   showErrorSnackBar(loginController.errorMessage);
/// }
/// ```

class AnalyticsService {
  // Placeholder para o AnalyticsService real
}