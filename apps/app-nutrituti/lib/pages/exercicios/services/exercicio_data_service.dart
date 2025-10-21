// Project imports:
import '../../../repository/atividade_fisica_repository.dart';
import '../constants/exercicio_constants.dart';
import 'exercicio_logger_service.dart';

/// Service seguro para gerenciar dados de exercícios e atividades físicas
/// Implementa validação, sanitização e fallbacks para repository externo
class ExercicioDataService {
  static const List<String> _categoriasPadrao = [
    'Aeróbico',
    'Musculação',
    'Flexibilidade',
    'Esporte',
    'Dança',
    'Luta',
    'Yoga',
    'Caminhada',
  ];

  static const List<Map<String, dynamic>> _exerciciosPadrao = [
    {
      'id': 1,
      'text': 'Caminhada',
      'value': 3.5,
      'categoria': 'Aeróbico',
    },
    {
      'id': 2,
      'text': 'Corrida',
      'value': 8.0,
      'categoria': 'Aeróbico',
    },
    {
      'id': 3,
      'text': 'Flexão',
      'value': 6.0,
      'categoria': 'Musculação',
    },
    {
      'id': 4,
      'text': 'Agachamento',
      'value': 5.0,
      'categoria': 'Musculação',
    },
    {
      'id': 5,
      'text': 'Alongamento',
      'value': 2.5,
      'categoria': 'Flexibilidade',
    },
  ];

  final AtividadeFisicaRepository? _repository;
  
  ExercicioDataService() : _repository = _initializeRepository();

  static AtividadeFisicaRepository? _initializeRepository() {
    try {
      return AtividadeFisicaRepository();
    } catch (e) {
      ExercicioLoggerService.e('Falha ao inicializar AtividadeFisicaRepository', 
        component: 'DataService', error: e);
      return null;
    }
  }

  /// Obtém todas as categorias disponíveis com fallback seguro
  List<String> get categorias {
    if (_repository == null) {
      return List.from(_categoriasPadrao);
    }

    try {
      final categoriasExternas = _repository.categorias;
      if (categoriasExternas.isEmpty) {
        return List.from(_categoriasPadrao);
      }
      
      // Validar e sanitizar categorias
      final categoriasValidadas = categoriasExternas
          .where((categoria) => _isValidCategoria(categoria))
          .toList();
      
      return categoriasValidadas.isNotEmpty 
          ? categoriasValidadas 
          : List.from(_categoriasPadrao);
    } catch (e) {
      ExercicioLoggerService.e('Erro ao obter categorias externas', 
        component: 'DataService', error: e);
      return List.from(_categoriasPadrao);
    }
  }

  /// Obtém exercícios por categoria com validação e sanitização
  List<Map<String, dynamic>> obterExerciciosPorCategoria(String categoria) {
    if (!_isValidCategoria(categoria)) {
      return _obterExerciciosPadraoPorCategoria(categoria);
    }

    if (_repository == null) {
      return _obterExerciciosPadraoPorCategoria(categoria);
    }

    try {
      final exerciciosExternos = 
          _repository.obterAtividadesPorCategoriaComoMap(categoria);
      
      if (exerciciosExternos.isEmpty) {
        return _obterExerciciosPadraoPorCategoria(categoria);
      }

      // Validar e sanitizar cada exercício
      final exerciciosValidados = exerciciosExternos
          .map((exercicio) => _validarExercicio(exercicio))
          .where((exercicio) => exercicio != null)
          .cast<Map<String, dynamic>>()
          .toList();

      return exerciciosValidados.isNotEmpty 
          ? exerciciosValidados
          : _obterExerciciosPadraoPorCategoria(categoria);
    } catch (e) {
      ExercicioLoggerService.e('Erro ao obter exercícios para categoria', 
        component: 'DataService', error: e, context: {'categoria': categoria});
      return _obterExerciciosPadraoPorCategoria(categoria);
    }
  }

  /// Obtém todos os exercícios disponíveis
  List<Map<String, dynamic>> obterTodosExercicios() {
    if (_repository == null) {
      return List.from(_exerciciosPadrao);
    }

    try {
      final todosExercicios = _repository.obterTodasAtividadesComoMap();
      
      if (todosExercicios.isEmpty) {
        return List.from(_exerciciosPadrao);
      }

      // Validar todos os exercícios
      final exerciciosValidados = todosExercicios
          .map((exercicio) => _validarExercicio(exercicio))
          .where((exercicio) => exercicio != null)
          .cast<Map<String, dynamic>>()
          .toList();

      return exerciciosValidados.isNotEmpty 
          ? exerciciosValidados
          : List.from(_exerciciosPadrao);
    } catch (e) {
      ExercicioLoggerService.e('Erro ao obter todos os exercícios', 
        component: 'DataService', error: e);
      return List.from(_exerciciosPadrao);
    }
  }

  /// Busca exercício por nome com fallback
  Map<String, dynamic>? buscarExercicioPorNome(String nome) {
    if (nome.trim().isEmpty) return null;

    final nomeNormalizado = _sanitizarTexto(nome);
    final todosExercicios = obterTodosExercicios();

    // Busca exata primeiro
    var exercicio = todosExercicios.firstWhere(
      (e) => _sanitizarTexto(e['text'] ?? '') == nomeNormalizado,
      orElse: () => {},
    );

    if (exercicio.isNotEmpty) return exercicio;

    // Busca parcial se não encontrou exata
    exercicio = todosExercicios.firstWhere(
      (e) => _sanitizarTexto(e['text'] ?? '').contains(nomeNormalizado),
      orElse: () => {},
    );

    return exercicio.isNotEmpty ? exercicio : null;
  }

  /// Valida se uma categoria é segura
  bool _isValidCategoria(String categoria) {
    if (categoria.trim().isEmpty || categoria.length > 50) return false;
    
    // Verificar caracteres perigosos
    final caracteresProibidos = RegExp(r'[<>"' "'" r'\\\/]');
    return !caracteresProibidos.hasMatch(categoria);
  }

  /// Valida e sanitiza um exercício
  Map<String, dynamic>? _validarExercicio(Map<String, dynamic> exercicio) {
    try {
      // Verificar campos obrigatórios
      if (!exercicio.containsKey('text') || 
          !exercicio.containsKey('value') ||
          !exercicio.containsKey('categoria')) {
        return null;
      }

      final text = exercicio['text']?.toString().trim() ?? '';
      final categoria = exercicio['categoria']?.toString().trim() ?? '';
      
      // Validar texto do exercício
      if (text.isEmpty || text.length > ExercicioConstants.maxNomeLength) return null;
      if (!_isValidCategoria(categoria)) return null;

      // Validar valor calórico
      final value = _validarValorCalorico(exercicio['value']);
      if (value == null) return null;

      // Validar/sanitizar ID
      final id = _validarId(exercicio['id']);

      return {
        'id': id,
        'text': _sanitizarTexto(text),
        'value': value,
        'categoria': _sanitizarTexto(categoria),
      };
    } catch (e) {
      ExercicioLoggerService.e('Erro ao validar exercício', 
        component: 'DataService', error: e);
      return null;
    }
  }

  /// Valida valor calórico
  double? _validarValorCalorico(dynamic value) {
    try {
      double valorCalorico;
      
      if (value is num) {
        valorCalorico = value.toDouble();
      } else if (value is String) {
        valorCalorico = double.tryParse(value) ?? 0.0;
      } else {
        return null;
      }

      // Valor deve estar entre 0.1 e 20.0 kcal/min (razoável para exercícios)
      if (valorCalorico < 0.1 || valorCalorico > 20.0) {
        return null;
      }

      return valorCalorico;
    } catch (e) {
      return null;
    }
  }

  /// Valida ID do exercício
  int _validarId(dynamic id) {
    if (id is int && id > 0) return id;
    if (id is String) {
      final parsed = int.tryParse(id);
      if (parsed != null && parsed > 0) return parsed;
    }
    // Retorna ID negativo para indicar item customizado
    return DateTime.now().millisecondsSinceEpoch * -1;
  }

  /// Sanitiza texto removendo caracteres perigosos
  String _sanitizarTexto(String texto) {
    return texto
        .trim()
        .replaceAll(RegExp(r'[<>"' "'" r'\\\/]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Obtém exercícios padrão por categoria
  List<Map<String, dynamic>> _obterExerciciosPadraoPorCategoria(String categoria) {
    return _exerciciosPadrao
        .where((exercicio) => exercicio['categoria'] == categoria)
        .toList();
  }
}
