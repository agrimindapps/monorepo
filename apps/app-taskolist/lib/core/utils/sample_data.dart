import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/tasks/domain/task_entity.dart';

class SampleData {
  static List<TaskEntity> getSampleTasks() {
    return [
      TaskEntity(
        id: FirebaseFirestore.instance.collection('_').doc().id,
        title: 'Implementar autenticação',
        description: 'Criar sistema de login e registro com Firebase Auth',
        listId: 'default',
        createdById: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        isStarred: true,
        position: 0,
        tags: const ['desenvolvimento', 'firebase'],
        notes: 'Lembrar de configurar variáveis de ambiente\nVerificar documentação do Firebase\nTeste com diferentes dispositivos',
      ),
      TaskEntity(
        id: FirebaseFirestore.instance.collection('_').doc().id,
        title: 'Configurar CI/CD',
        description: 'Configurar pipeline de deploy automático',
        listId: 'default',
        createdById: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
        isStarred: false,
        position: 1,
        tags: const ['devops'],
        dueDate: DateTime.now().add(const Duration(days: 3)),
      ),
      TaskEntity(
        id: FirebaseFirestore.instance.collection('_').doc().id,
        title: 'Revisar documentação',
        description: 'Atualizar README e documentação da API',
        listId: 'default',
        createdById: 'user1',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        status: TaskStatus.completed,
        priority: TaskPriority.low,
        isStarred: false,
        position: 2,
        tags: const ['documentação'],
      ),
      TaskEntity(
        id: FirebaseFirestore.instance.collection('_').doc().id,
        title: 'Testes unitários',
        description: 'Criar testes para use cases e repositories',
        listId: 'default',
        createdById: 'user1',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now(),
        status: TaskStatus.pending,
        priority: TaskPriority.high,
        isStarred: true,
        position: 3,
        tags: const ['testes', 'qualidade'],
        dueDate: DateTime.now().add(const Duration(days: 1)),
        reminderDate: DateTime.now().add(const Duration(hours: 8)),
        notes: 'Focar em:\n• Use cases críticos\n• Repository patterns\n• Error handling\n\nLinks úteis:\n- Testing docs: flutter.dev/testing\n- Best practices: medium.com/flutter-testing',
      ),
    ];
  }

  static Future<void> populateSampleData() async {
  }
}
