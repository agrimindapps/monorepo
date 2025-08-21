import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/pages/task_detail_page.dart';
import '../../presentation/pages/home_page.dart';
import '../providers/service_providers.dart';

/// Serviço de navegação para gerenciar deep linking e navegação por notificações
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  /// Referência ao ProviderContainer para acessar providers durante navegação
  static late ProviderContainer _container;
  
  static void initialize(ProviderContainer container) {
    _container = container;
  }
  
  /// Navegação principal para diferentes tipos de payloads
  static Future<void> navigateFromNotification(String payload) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    try {
      if (payload.startsWith('task_reminder:')) {
        final taskId = payload.split(':')[1];
        await _navigateToTask(context, taskId, TaskDetailFocus.general);
      } else if (payload.startsWith('task_deadline:')) {
        final taskId = payload.split(':')[1];
        await _navigateToTask(context, taskId, TaskDetailFocus.deadline);
      } else if (payload == 'weekly_review') {
        await _navigateToWeeklyReview(context);
      } else if (payload == 'daily_productivity') {
        await _navigateToProductivityView(context);
      }
    } catch (e) {
      debugPrint('❌ Error navigating from notification: $e');
      // Fallback para página principal
      if (context.mounted) {
        _navigateToHome(context);
      }
    }
  }
  
  /// Navegar para tarefa específica com foco
  static Future<void> _navigateToTask(
    BuildContext context, 
    String taskId, 
    TaskDetailFocus focus
  ) async {
    try {
      // Buscar task no provider
      final taskProviderFuture = _container.read(tasksProvider.future);
      
      try {
        final tasks = await taskProviderFuture;
        final task = tasks.firstWhere(
          (t) => t.id == taskId,
          orElse: () => throw TaskNotFoundException(taskId),
        );
        
        // Navegar para página de detalhes
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TaskDetailPage(
                task: task,
                initialFocus: focus,
              ),
            ),
          );
        }
      } on TaskNotFoundException {
        debugPrint('❌ Task $taskId not found');
        if (context.mounted) {
          _navigateToHome(context);
          
          // Mostrar snackbar informando que task não foi encontrada
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tarefa não encontrada: $taskId'),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
        }
      } catch (error) {
        debugPrint('❌ Error loading task $taskId: $error');
        if (context.mounted) {
          _navigateToHome(context);
          _showErrorSnackBar(context, 'Erro ao carregar tarefa');
        }
      }
    } catch (e) {
      debugPrint('❌ Error navigating to task $taskId: $e');
      if (context.mounted) {
        _navigateToHome(context);
      }
    }
  }
  
  /// Navegar para revisão semanal (placeholder para futura implementação)
  static Future<void> _navigateToWeeklyReview(BuildContext context) async {
    // TODO: Implementar página de revisão semanal
    _navigateToHome(context);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📊 Revisão Semanal - Em desenvolvimento'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
  
  /// Navegar para view de produtividade (placeholder para futura implementação)  
  static Future<void> _navigateToProductivityView(BuildContext context) async {
    // TODO: Implementar página de produtividade diária
    _navigateToHome(context);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎯 Produtividade Diária - Em desenvolvimento'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  /// Navegar para página principal
  static void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
  }
  
  /// Navegar para task específica (método público para uso externo)
  static Future<void> navigateToTask(String taskId) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    
    await _navigateToTask(context, taskId, TaskDetailFocus.general);
  }
  
  /// Navegar para home (método público)
  static void navigateToHome() {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    
    _navigateToHome(context);
  }
  
  /// Helper para mostrar SnackBar de erro
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}

/// Enum para definir o foco inicial na página de detalhes
enum TaskDetailFocus {
  general,
  deadline,
  reminder,
  notes,
}

/// Exception para task não encontrada
class TaskNotFoundException implements Exception {
  final String taskId;
  const TaskNotFoundException(this.taskId);
  
  @override
  String toString() => 'Task not found: $taskId';
}

