import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import 'my_day_task_entity.dart';

/// Repository para gerenciar tarefas do "Meu Dia"
abstract class MyDayRepository {
  /// Adiciona tarefa ao Meu Dia
  Future<Either<Failure, MyDayTaskEntity>> add(MyDayTaskEntity myDayTask);
  
  /// Atualiza registro do Meu Dia
  Future<Either<Failure, void>> update(MyDayTaskEntity myDayTask);
  
  /// Busca tarefas ativas de uma data específica
  Future<Either<Failure, List<MyDayTaskEntity>>> getActiveByDate(DateTime date);
  
  /// Busca registro específico por tarefa e data
  Future<MyDayTaskEntity?> getByTaskAndDate(String taskId, DateTime date);
  
  /// Arquiva tarefas de dias passados
  Future<Either<Failure, void>> archiveOldTasks();
  
  /// Busca histórico de um dia específico (para estatísticas futuras)
  Future<Either<Failure, List<MyDayTaskEntity>>> getHistoryByDate(DateTime date);
  
  /// Remove tarefa do Meu Dia (marca como removida)
  Future<Either<Failure, void>> remove(String taskId, DateTime date);
}
