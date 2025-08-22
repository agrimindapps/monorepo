import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../../infrastructure/services/subscription_service.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';
import 'get_tasks.dart';

/// Use case para criar tarefa com verificação de limites premium
class CreateTaskWithLimits extends UseCaseWithParams<String, CreateTaskWithLimitsParams> {
  const CreateTaskWithLimits(
    this._taskRepository,
    this._subscriptionService,
    this._getTasks,
  );

  final TaskRepository _taskRepository;
  final TaskManagerSubscriptionService _subscriptionService;
  final GetTasks _getTasks;

  @override
  Future<Either<Failure, String>> call(CreateTaskWithLimitsParams params) async {
    try {
      // Verificar limites antes de criar
      final canCreate = await _canCreateTask();
      
      if (!canCreate) {
        return const Left(PremiumRequiredFailure(
          'Você atingiu o limite de tarefas gratuitas. Faça upgrade para Premium para criar tarefas ilimitadas.',
        ));
      }

      // Criar a tarefa se estiver dentro dos limites
      final result = await _taskRepository.createTask(params.task);
      
      return result.fold(
        (failure) => Left(failure),
        (taskId) {
          // Log analytics para criação de tarefa
          _logTaskCreation(params.task);
          return Right(taskId);
        },
      );
    } catch (e) {
      return const Left(UnexpectedFailure('Erro inesperado ao criar tarefa'));
    }
  }

  /// Verifica se pode criar mais tarefas
  Future<bool> _canCreateTask() async {
    try {
      // Obter total de tarefas atuais
      final tasksResult = await _getTasks(const GetTasksParams());
      
      return tasksResult.fold(
        (failure) => true, // Em caso de erro, permite criar
        (tasks) async {
          final currentTaskCount = tasks.length;
          return await _subscriptionService.canCreateMoreTasks(currentTaskCount);
        },
      );
    } catch (e) {
      // Em caso de erro, permite criar (fail open)
      return true;
    }
  }

  /// Log analytics para criação de tarefa
  void _logTaskCreation(TaskEntity task) {
    // Este método seria chamado pelo controller que usa o use case
    // Aqui apenas registramos os dados para analytics
  }
}

class CreateTaskWithLimitsParams extends Equatable {
  const CreateTaskWithLimitsParams({required this.task});

  final TaskEntity task;

  @override
  List<Object?> get props => [task];
}

/// Failure específico para quando requer premium
class PremiumRequiredFailure extends Failure {
  final String _message;
  
  const PremiumRequiredFailure(this._message);
  
  @override
  String get message => _message;
  
  @override
  List<Object> get props => [_message];
}