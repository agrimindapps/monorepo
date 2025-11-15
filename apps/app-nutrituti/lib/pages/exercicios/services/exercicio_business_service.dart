// Package imports:
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../drift_database/nutrituti_database.dart';
import '../../../core/di/injection.dart';
import '../models/exercicio_model.dart';
import '../repository/exercicio_repository.dart';
import 'exercicio_drift_adapter.dart';
import 'exercicio_exception_service.dart';
import 'exercicio_validation_service.dart';

/// Service responsável pela lógica de negócio de exercícios
class ExercicioBusinessService {
  final ExercicioRepository _repository = ExercicioRepository();
  late final NutritutiDatabase _database;
  final _uuid = const Uuid();

  ExercicioBusinessService() {
    _database = getIt<NutritutiDatabase>();
  }

  /// Inicializa o serviço (não necessário mais com Drift)
  Future<void> initialize() async {
    // Drift database já é inicializado pelo DI container
  }

  /// Salva um exercício com validações de negócio
  Future<ExercicioModel> salvarExercicio(ExercicioModel exercicio) async {
    try {
      // Usar validação centralizada
      if (exercicio.id == null || exercicio.id!.isEmpty) {
        ExercicioValidationService.validateExercicioForCreation(exercicio);
        
        // Gerar ID se não existir
        final novoExercicio = exercicio.copyWith(id: _uuid.v4());
        
        // Salvar com Drift
        await _database.exercicioDao.addExercicio(
          novoExercicio.toCompanion(),
        );
        
        return novoExercicio;
      } else {
        ExercicioValidationService.validateExercicioForUpdate(exercicio);
        
        // Atualizar com Drift (precisa passar ID separadamente)
        await _database.exercicioDao.updateExercicio(
          exercicio.id!,
          exercicio.toUpdateCompanion(),
        );
        
        return exercicio;
      }
    } on ExercicioValidationException catch (e) {
      throw Exception('Validação falhou: ${e.message}');
    } catch (e) {
      throw Exception('Falha ao salvar exercício: $e');
    }
  }

  /// Exclui um exercício
  Future<void> excluirExercicio(String exercicioId) async {
    try {
      // Usar validação centralizada
      ExercicioValidationService.validateExercicioId(exercicioId);
      
      // Deletar com Drift
      await _database.exercicioDao.deleteExercicio(exercicioId);
    } on ExercicioValidationException catch (e) {
      throw Exception('Validação falhou: ${e.message}');
    } catch (e) {
      throw Exception('Falha ao excluir exercício: $e');
    }
  }

  /// Carrega todos os exercícios
  Future<List<ExercicioModel>> carregarExercicios() async {
    try {
      // Carregar com Drift e converter para model
      final exercicios = await _database.exercicioDao.getAllExercicios();
      return exercicios.map((e) => e.toModel()).toList();
    } catch (e) {
      throw Exception('Falha ao carregar exercícios: $e');
    }
  }

  /// Salva metas de exercícios
  Future<void> salvarMetas(double metaMinutos, double metaCalorias) async {
    try {
      // Usar validação centralizada
      ExercicioValidationService.validateMetas(metaMinutos, metaCalorias);
      
      await _repository.saveMetasExercicios({
        'minutosSemanal': metaMinutos,
        'caloriasSemanal': metaCalorias,
      });
    } on ExercicioValidationException catch (e) {
      throw Exception('Validação falhou: ${e.message}');
    } catch (e) {
      throw Exception('Falha ao salvar metas: $e');
    }
  }

  /// Carrega metas de exercícios
  Future<Map<String, double>> carregarMetas() async {
    try {
      final metas = await _repository.getMetasExercicios();
      return {
        'minutos': ((metas['minutosSemanal'] as num?) ?? 0).toDouble(),
        'calorias': ((metas['caloriasSemanal'] as num?) ?? 0).toDouble(),
      };
    } catch (e) {
      throw Exception('Falha ao carregar metas: $e');
    }
  }


  /// Valida parâmetros de busca por período
  void validarPeriodo(DateTime inicio, DateTime fim) {
    try {
      ExercicioValidationService.validatePeriodo(inicio, fim);
    } on ExercicioValidationException catch (e) {
      throw Exception('Validação falhou: ${e.message}');
    }
  }

  /// Calcula estimativa de calorias baseada no tipo de exercício e duração
  int calcularCaloriasEstimadas(String categoria, int duracaoMinutos, {double peso = 70.0}) {
    // Valores aproximados de MET (Metabolic Equivalent of Task)
    final Map<String, double> metValues = {
      'Aeróbico': 6.0,
      'Musculação': 4.5,
      'Flexibilidade': 2.5,
      'Esporte': 7.0,
      'Dança': 5.0,
      'Luta': 8.0,
      'Yoga': 3.0,
      'Caminhada': 3.5,
    };

    final met = metValues[categoria] ?? 4.0; // Valor padrão
    
    // Fórmula: Calorias = MET × peso(kg) × tempo(horas)
    final calorias = met * peso * (duracaoMinutos / 60.0);
    
    return calorias.round();
  }

  /// Sugere duração baseada no nível de condicionamento
  Map<String, int> sugerirDuracao(String categoria, String nivelCondicionamento) {
    final Map<String, Map<String, int>> sugestoes = {
      'Aeróbico': {
        'iniciante': 15,
        'intermediario': 30,
        'avancado': 45,
      },
      'Musculação': {
        'iniciante': 30,
        'intermediario': 45,
        'avancado': 60,
      },
      'Flexibilidade': {
        'iniciante': 10,
        'intermediario': 15,
        'avancado': 20,
      },
      'Esporte': {
        'iniciante': 20,
        'intermediario': 45,
        'avancado': 60,
      },
    };

    return sugestoes[categoria] ?? {
      'iniciante': 15,
      'intermediario': 30,
      'avancado': 45,
    };
  }

  /// Verifica se o usuário está dentro dos limites saudáveis de exercício
  Map<String, dynamic> verificarLimitesSaudaveis(List<ExercicioModel> registros) {
    final agora = DateTime.now();
    final ultimaSemana = agora.subtract(const Duration(days: 7));
    
    int minutosUltimaSemana = 0;
    int sessoesUltimaSemana = 0;
    
    for (var registro in registros) {
      try {
        final dataRegistro = DateTime.fromMillisecondsSinceEpoch(registro.dataRegistro);
        if (dataRegistro.isAfter(ultimaSemana)) {
          minutosUltimaSemana += registro.duracao;
          sessoesUltimaSemana++;
        }
      } catch (e) {
        continue;
      }
    }

    final alertas = <String>[];
    
    // Verificar se está exercitando demais (mais de 14 horas por semana)
    if (minutosUltimaSemana > 840) {
      alertas.add('Você pode estar se exercitando demais. Considere dar descanso ao corpo.');
    }
    
    // Verificar se está exercitando muito pouco (menos de 75 minutos por semana)
    if (minutosUltimaSemana < 75) {
      alertas.add('Tente aumentar gradualmente o tempo de exercício semanal.');
    }
    
    // Verificar frequência
    if (sessoesUltimaSemana > 14) {
      alertas.add('Muitas sessões por semana. Lembre-se da importância do descanso.');
    }

    return {
      'minutosUltimaSemana': minutosUltimaSemana,
      'sessoesUltimaSemana': sessoesUltimaSemana,
      'alertas': alertas,
      'dentroLimitesSaudaveis': alertas.isEmpty,
    };
  }
}
