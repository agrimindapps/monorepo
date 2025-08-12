// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../core/middleware/subscription_auth_middleware.dart';
import '../../core/premium_template/index.dart';
import '../models/72_task_list.dart';
import '../models/task_model.dart';
import '../pages/home_screen.dart';
import '../pages/login_screen.dart';
import '../pages/premium_page_template.dart';
import '../pages/settings_screen.dart';
import '../pages/task_detail_screen.dart';
import '../pages/task_list_screen.dart';
import '../services/id_generation_service.dart';

/// Configuração de rotas do TodoList com validação de assinatura
///
/// Este arquivo demonstra como aplicar o middleware de validação de assinatura
/// para proteger rotas específicas do TodoList quando acessadas via web.
class TodoistRoutes {
  static List<GetPage> get routes => [
        // Rotas públicas (sem proteção de assinatura)
        GetPage(
          name: '/todoist/login',
          page: () => const LoginScreen(),
        ),
        GetPage(
          name: '/todoist/premium',
          page: () => const TodoistPremiumPageTemplate(),
        ),

        // Rotas protegidas por assinatura (apenas no web)
        GetPage(
          name: '/todoist/home',
          page: () => const HomeScreen(),
          middlewares: [
            SubscriptionMiddlewareFactory.forTodoist(),
          ],
        ),
        GetPage(
          name: '/todoist/task-lists',
          page: () => TaskListScreen(
            taskList: TaskList(
              id: 'default',
              title: 'Lista Principal',
              description: 'Lista principal de tarefas',
              color: '#3A5998',
              ownerId: 'user123',
              memberIds: const [],
              isShared: false,
              isArchived: false,
              position: 0,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              updatedAt: DateTime.now().millisecondsSinceEpoch,
            ),
          ),
          middlewares: [
            SubscriptionMiddlewareFactory.forTodoist(),
          ],
        ),
        GetPage(
          name: '/todoist/task-detail/:taskId',
          page: () => TaskDetailScreen(
            task: Task(
              id: Get.parameters['taskId'] ?? 'task1',
              title: 'Tarefa de Exemplo',
              description: 'Descrição da tarefa',
              listId: 'default',
              createdById: 'user123',
              assignedToId: 'user123',
              priority: TaskPriority.medium,
              isCompleted: false,
              isStarred: false,
              dueDate: null,
              reminderDate: null,
              tags: const [],
              attachments: const [],
              comments: const [],
              parentTaskId: null,
              position: 0,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              updatedAt: DateTime.now().millisecondsSinceEpoch,
            ),
          ),
          middlewares: [
            SubscriptionMiddlewareFactory.forTodoist(),
          ],
        ),
        GetPage(
          name: '/todoist/settings',
          page: () => const SettingsScreen(),
          middlewares: [
            SubscriptionMiddlewareFactory.forTodoist(),
          ],
        ),

        // Rota com middleware customizado
        GetPage(
          name: '/todoist/advanced-features',
          page: () => const AdvancedFeaturesScreen(),
          middlewares: [
            SubscriptionMiddlewareFactory.forApp(
              appId: 'todoist',
              requireActiveSubscription: true,
              redirectRoute: '/todoist/premium',
            ),
          ],
        ),
      ];
}

/// Middleware específico do TodoList com configurações customizadas
class TodoistAuthMiddleware extends SubscriptionAuthMiddleware {
  TodoistAuthMiddleware()
      : super(
          appId: 'todoist',
          requireActiveSubscription: true,
          redirectRoute: '/todoist/premium',
        );

  // Método auxiliar para obter ID do usuário com geração segura
  Future<String?> _getCurrentUserId() async {
    // Implementar lógica específica do TodoList para obter userId
    // Usar IDGenerationService para geração segura
    final idService = IDGenerationService();
    return idService.generateUserId();
  }
}

/// Tela de recursos avançados (exemplo de funcionalidade premium)
class AdvancedFeaturesScreen extends StatelessWidget {
  const AdvancedFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recursos Avançados'),
        backgroundColor: AppThemeConfig.forTodoist().primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppThemeConfig.forTodoist().primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Recursos Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Você está acessando recursos avançados disponíveis apenas para usuários Premium.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Funcionalidades Disponíveis:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildFeaturesList(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeaturesList() {
    final features = [
      {
        'icon': Icons.sync,
        'title': 'Sincronização Avançada',
        'description':
            'Sincronize suas tarefas em tempo real entre todos os dispositivos'
      },
      {
        'icon': Icons.backup,
        'title': 'Backup Automático',
        'description':
            'Backup seguro e automático de todas as suas listas e tarefas'
      },
      {
        'icon': Icons.analytics,
        'title': 'Relatórios Detalhados',
        'description':
            'Visualize estatísticas avançadas sobre sua produtividade'
      },
      {
        'icon': Icons.palette,
        'title': 'Temas Personalizados',
        'description': 'Acesso completo a todos os temas e personalizações'
      },
      {
        'icon': Icons.notifications_active,
        'title': 'Notificações Inteligentes',
        'description': 'Lembretes avançados com IA para otimizar sua agenda'
      },
    ];

    return features
        .map((feature) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppThemeConfig.forTodoist()
                        .primaryColor
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: AppThemeConfig.forTodoist().primaryColor,
                  ),
                ),
                title: Text(
                  feature['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(feature['description'] as String),
                trailing: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            ))
        .toList();
  }
}

/// Exemplo de como integrar validação de assinatura manualmente
class TodoistWithValidationExample extends StatefulWidget {
  const TodoistWithValidationExample({super.key});

  @override
  State<TodoistWithValidationExample> createState() =>
      _TodoistWithValidationExampleState();
}

class _TodoistWithValidationExampleState
    extends State<TodoistWithValidationExample>
    with SubscriptionValidationMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TodoList com Validação'),
      ),
      body: Column(
        children: [
          // Botão para funcionalidade premium
          ElevatedButton(
            onPressed: () => _accessPremiumFeature(),
            child: const Text('Acessar Funcionalidade Premium'),
          ),

          // Lista de tarefas (exemplo)
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) => ListTile(
                leading: Checkbox(
                  value: false,
                  onChanged: (value) => _toggleTask(index),
                ),
                title: Text('Tarefa ${index + 1}'),
                subtitle: const Text('Descrição da tarefa'),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showTaskOptions(index),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _accessPremiumFeature() async {
    // Validar assinatura antes de executar funcionalidade premium
    final isValid = await validateSubscriptionBeforeAction(appId: 'todoist');

    if (isValid) {
      // Executar funcionalidade premium
      _showDialog(
          'Funcionalidade Premium', 'Você tem acesso a esta funcionalidade!');
    }
    // Se não válida, o mixin já mostra o dialog de assinatura necessária
  }

  void _toggleTask(int index) {
    // Funcionalidade básica - sem validação necessária
    setState(() {
      // Implementar toggle da tarefa
    });
  }

  Future<void> _showTaskOptions(int index) async {
    // Funcionalidade avançada - validar assinatura
    final isValid = await validateSubscriptionBeforeAction(appId: 'todoist');

    if (isValid && mounted) {
      // Mostrar opções avançadas
      _showBottomSheet(context, index);
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context, int taskIndex) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Opções da Tarefa ${taskIndex + 1}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicar'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Compartilhar'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Excluir'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Como usar nas rotas principais do aplicativo:
///
/// No seu arquivo main.dart ou routes.dart principal:
///
/// ```dart
/// GetMaterialApp(
///   initialRoute: '/',
///   getPages: [
///     // Suas rotas existentes
///     ...existingRoutes,
///
///     // Adicionar rotas do TodoList
///     ...TodoistRoutes.routes,
///   ],
/// )
/// ```
