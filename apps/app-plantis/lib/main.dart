import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'presentation/pages/account_settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar dependency injection
  await InjectionContainer.init();
  
  runApp(const PlantisApp());
}

class PlantisApp extends StatelessWidget {
  const PlantisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plantis',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const PlantisHomePage(),
    );
  }
}

class PlantisHomePage extends StatefulWidget {
  const PlantisHomePage({super.key});

  @override
  State<PlantisHomePage> createState() => _PlantisHomePageState();
}

class _PlantisHomePageState extends State<PlantisHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        title: const Text('🌱 Plantis'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.eco,
                    size: 80,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Plantis',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gerenciamento de Plantas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.green.shade600,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Em Desenvolvimento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Sistema de cuidados e lembretes para suas plantas',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.green.shade700,
                  ),
            ),
            const SizedBox(height: 32),
            
            // Botão para acessar configurações
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AccountSettingsPage(),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text('Configurações'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botões de teste da integração
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Testes de Integração - Core Package',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _testAuthentication(context),
                        icon: const Icon(Icons.login, size: 16),
                        label: const Text('Auth Test'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _testStorage(context),
                        icon: const Icon(Icons.storage, size: 16),
                        label: const Text('Storage Test'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _testAnalytics(context),
                        icon: const Icon(Icons.analytics, size: 16),
                        label: const Text('Analytics Test'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Métodos de teste da integração
  void _testAuthentication(BuildContext context) async {
    if (!mounted) return;
    
    try {
      final loginUseCase = getIt<LoginUseCase>();
      
      // Teste com credenciais de exemplo (vai falhar propositalmente para testar error handling)
      final result = await loginUseCase(const LoginParams(
        email: 'test@example.com',
        password: 'password123',
      ));
      
      if (mounted) {
        result.fold(
          (failure) => _showTestResult(context, 'Autenticação', 'Erro esperado: ${failure.message}', false),
          (user) => _showTestResult(context, 'Autenticação', 'Login bem-sucedido: ${user.email}', true),
        );
      }
    } catch (e) {
      if (mounted) {
        _showTestResult(context, 'Autenticação', 'Erro: $e', false);
      }
    }
  }
  
  void _testStorage(BuildContext context) async {
    if (!mounted) return;
    
    try {
      final storageService = getIt<ILocalStorageRepository>();
      
      // Primeiro, inicializar o storage
      final initResult = await storageService.initialize();
      
      await initResult.fold(
        (failure) {
          if (mounted) {
            _showTestResult(context, 'Storage Local', 'Erro na inicialização: ${failure.message}', false);
          }
        },
        (_) async {
          // Teste de escrita e leitura
          final saveResult = await storageService.save<String>(
            key: 'test_key',
            data: 'test_value',
          );
          
          await saveResult.fold(
            (failure) {
              if (mounted) {
                _showTestResult(context, 'Storage Local', 'Erro ao salvar: ${failure.message}', false);
              }
            },
            (_) async {
              final getResult = await storageService.get<String>(key: 'test_key');
              
              getResult.fold(
                (failure) {
                  if (mounted) {
                    _showTestResult(context, 'Storage Local', 'Erro ao ler: ${failure.message}', false);
                  }
                },
                (result) {
                  if (mounted) {
                    if (result == 'test_value') {
                      _showTestResult(context, 'Storage Local', 'Hive funcionando corretamente!', true);
                    } else {
                      _showTestResult(context, 'Storage Local', 'Erro: valor não salvo corretamente', false);
                    }
                  }
                },
              );
            },
          );
        },
      );
    } catch (e) {
      if (mounted) {
        _showTestResult(context, 'Storage Local', 'Erro: $e', false);
      }
    }
  }
  
  void _testAnalytics(BuildContext context) async {
    if (!mounted) return;
    
    try {
      final analyticsService = getIt<IAnalyticsRepository>();
      
      // Teste de evento
      await analyticsService.logEvent('test_event', parameters: {
        'test_param': 'test_value',
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      if (mounted) {
        _showTestResult(context, 'Analytics', 'Evento enviado com sucesso!', true);
      }
    } catch (e) {
      if (mounted) {
        _showTestResult(context, 'Analytics', 'Erro: $e', false);
      }
    }
  }
  
  void _showTestResult(BuildContext context, String title, String message, bool success) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text('Teste: $title'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
