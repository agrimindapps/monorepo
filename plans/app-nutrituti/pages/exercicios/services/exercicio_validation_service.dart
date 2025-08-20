// Project imports:
import '../constants/exercicio_constants.dart';
import '../models/exercicio_model.dart';
import 'exercicio_exception_service.dart';

// ExercicioValidationException movida para exercicio_exception_service.dart

/// Service centralizado para todas as validações de exercícios
class ExercicioValidationService {
  
  // Usando constantes centralizadas para manter consistência
  
  // Categorias válidas padrão (podem ser estendidas)
  static const Set<String> _categoriasValidas = {
    'Aeróbico',
    'Musculação',
    'Flexibilidade',
    'Esporte',
    'Dança',
    'Luta',
    'Yoga',
    'Caminhada',
    'Corrida',
    'Ciclismo',
    'Natação',
  };
  
  // ========================================================================
  // VALIDAÇÃO PRINCIPAL DE EXERCÍCIO
  // ========================================================================
  
  /// Valida um exercício completo com todas as regras de negócio
  static void validateExercicio(ExercicioModel exercicio) {
    _validateNome(exercicio.nome);
    _validateCategoria(exercicio.categoria);
    _validateDuracao(exercicio.duracao);
    _validateCaloriasQueimadas(exercicio.caloriasQueimadas);
    _validateDataRegistro(exercicio.dataRegistro);
    
    if (exercicio.observacoes != null) {
      _validateObservacoes(exercicio.observacoes!);
    }
    
    // Validações contextuais
    _validateConsistenciaCaloriasDuracao(exercicio.duracao, exercicio.caloriasQueimadas);
  }
  
  /// Valida exercício para criação (não permite ID)
  static void validateExercicioForCreation(ExercicioModel exercicio) {
    if (exercicio.id != null && exercicio.id!.isNotEmpty) {
      throw ExercicioValidationException(
        message: 'Novo exercício não deve ter ID', 
        field: 'id'
      );
    }
    validateExercicio(exercicio);
  }
  
  /// Valida exercício para atualização (requer ID)
  static void validateExercicioForUpdate(ExercicioModel exercicio) {
    if (exercicio.id == null || exercicio.id!.isEmpty) {
      throw ExercicioValidationException(
        message: 'Exercício para atualização deve ter ID válido', 
        field: 'id'
      );
    }
    validateExercicio(exercicio);
  }
  
  // ========================================================================
  // VALIDAÇÕES INDIVIDUAIS DE CAMPOS
  // ========================================================================
  
  /// Valida nome do exercício
  static void _validateNome(String nome) {
    final nomeClean = nome.trim();
    
    if (nomeClean.isEmpty) {
      throw ExercicioValidationException(
        message: 'Nome do exercício é obrigatório', 
        field: 'nome'
      );
    }
    
    if (nomeClean.length < ExercicioConstants.minNomeLength) {
      throw ExercicioValidationException(
        message: 'Nome deve ter pelo menos ${ExercicioConstants.minNomeLength} caracteres', 
        field: 'nome',
        value: nomeClean.length
      );
    }
    
    if (nomeClean.length > ExercicioConstants.maxNomeLength) {
      throw ExercicioValidationException(
        message: 'Nome não pode exceder ${ExercicioConstants.maxNomeLength} caracteres', 
        field: 'nome',
        value: nomeClean.length
      );
    }
    
    // Verificar caracteres especiais perigosos
    if (_containsDangerousChars(nomeClean)) {
      throw ExercicioValidationException(
        message: 'Nome contém caracteres não permitidos', 
        field: 'nome'
      );
    }
  }
  
  /// Valida categoria do exercício
  static void _validateCategoria(String categoria) {
    final categoriaClean = categoria.trim();
    
    if (categoriaClean.isEmpty) {
      throw ExercicioValidationException(
        message: 'Categoria é obrigatória', 
        field: 'categoria'
      );
    }
    
    if (categoriaClean.length > ExercicioConstants.maxCategoriaLength) {
      throw ExercicioValidationException(
        message: 'Categoria não pode exceder ${ExercicioConstants.maxCategoriaLength} caracteres', 
        field: 'categoria',
        value: categoriaClean.length
      );
    }
    
    // Verificar se é uma categoria válida (pode ser configurável no futuro)
    if (!_categoriasValidas.contains(categoriaClean)) {
      throw ExercicioValidationException(
        message: 'Categoria "$categoriaClean" não é válida', 
        field: 'categoria',
        value: categoriaClean
      );
    }
  }
  
  /// Valida duração do exercício
  static void _validateDuracao(int duracao) {
    if (duracao < ExercicioConstants.minDuracaoMinutos) {
      throw ExercicioValidationException(
        message: 'Duração deve ser de pelo menos ${ExercicioConstants.minDuracaoMinutos} minuto(s)', 
        field: 'duracao',
        value: duracao
      );
    }
    
    if (duracao > ExercicioConstants.maxDuracaoMinutos) {
      throw ExercicioValidationException(
        message: 'Duração não pode exceder ${ExercicioConstants.maxDuracaoMinutos} minutos (12 horas)', 
        field: 'duracao',
        value: duracao
      );
    }
  }
  
  /// Valida calorias queimadas
  static void _validateCaloriasQueimadas(int calorias) {
    if (calorias < 0) {
      throw ExercicioValidationException(
        message: 'Calorias queimadas não pode ser negativo', 
        field: 'caloriasQueimadas',
        value: calorias
      );
    }
    
    if (calorias > ExercicioConstants.maxCaloriasQueimadas) {
      throw ExercicioValidationException(
        message: 'Valor de calorias muito alto (máximo ${ExercicioConstants.maxCaloriasQueimadas})', 
        field: 'caloriasQueimadas',
        value: calorias
      );
    }
  }
  
  /// Valida data de registro
  static void _validateDataRegistro(int timestamp) {
    DateTime dataRegistro;
    
    try {
      dataRegistro = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      throw ExercicioValidationException(
        message: 'Data de registro inválida', 
        field: 'dataRegistro',
        value: timestamp
      );
    }
    
    final agora = DateTime.now();
    
    // Não pode ser no futuro
    if (dataRegistro.isAfter(agora)) {
      throw ExercicioValidationException(
        message: 'Data de registro não pode ser no futuro', 
        field: 'dataRegistro'
      );
    }
    
    // Não pode ser muito antiga
    final limitePassado = agora.subtract(const Duration(days: 365 * ExercicioConstants.maxIdadeRegistroAnos));
    if (dataRegistro.isBefore(limitePassado)) {
      throw ExercicioValidationException(
        message: 'Data de registro muito antiga (máximo ${ExercicioConstants.maxIdadeRegistroAnos} anos)', 
        field: 'dataRegistro'
      );
    }
  }
  
  /// Valida observações
  static void _validateObservacoes(String observacoes) {
    final observacoesClean = observacoes.trim();
    
    if (observacoesClean.length > ExercicioConstants.maxObservacoesLength) {
      throw ExercicioValidationException(
        message: 'Observações não podem exceder ${ExercicioConstants.maxObservacoesLength} caracteres', 
        field: 'observacoes',
        value: observacoesClean.length
      );
    }
    
    // Verificar caracteres especiais perigosos
    if (_containsDangerousChars(observacoesClean)) {
      throw ExercicioValidationException(
        message: 'Observações contêm caracteres não permitidos', 
        field: 'observacoes'
      );
    }
  }
  
  // ========================================================================
  // VALIDAÇÕES CONTEXTUAIS E DE NEGÓCIO
  // ========================================================================
  
  /// Valida consistência entre duração e calorias
  static void _validateConsistenciaCaloriasDuracao(int duracao, int calorias) {
    // Regra: não pode queimar mais calorias que o limite por minuto
    final maxCaloriasEsperadas = duracao * ExercicioConstants.maxCaloriasPorMinuto;
    
    if (calorias > maxCaloriasEsperadas) {
      throw ExercicioValidationException(
        message: 'Calorias muito altas para a duração informada (máximo $maxCaloriasEsperadas para $duracao min)', 
        field: 'caloriasQueimadas',
        value: calorias
      );
    }
  }
  
  // ========================================================================
  // VALIDAÇÕES DE METAS
  // ========================================================================
  
  /// Valida metas de exercícios
  static void validateMetas(double metaMinutos, double metaCalorias) {
    _validateMetaMinutos(metaMinutos);
    _validateMetaCalorias(metaCalorias);
  }
  
  /// Valida meta de minutos semanais
  static void _validateMetaMinutos(double metaMinutos) {
    if (metaMinutos < 0) {
      throw ExercicioValidationException(
        message: 'Meta de minutos não pode ser negativa', 
        field: 'metaMinutos'
      );
    }
    
    if (metaMinutos > ExercicioConstants.maxMetaMinutosSemanal) {
      throw ExercicioValidationException(
        message: 'Meta de minutos não pode exceder uma semana completa (${ExercicioConstants.maxMetaMinutosSemanal} minutos)', 
        field: 'metaMinutos',
        value: metaMinutos
      );
    }
  }
  
  /// Valida meta de calorias semanais
  static void _validateMetaCalorias(double metaCalorias) {
    if (metaCalorias < 0) {
      throw ExercicioValidationException(
        message: 'Meta de calorias não pode ser negativa', 
        field: 'metaCalorias'
      );
    }
    
    if (metaCalorias > ExercicioConstants.maxMetaCaloriasSemanal) {
      throw ExercicioValidationException(
        message: 'Meta de calorias muito alta para ser saudável (máximo ${ExercicioConstants.maxMetaCaloriasSemanal})', 
        field: 'metaCalorias',
        value: metaCalorias
      );
    }
  }
  
  // ========================================================================
  // VALIDAÇÕES DE PARÂMETROS DE CONSULTA
  // ========================================================================
  
  /// Valida período para consultas
  static void validatePeriodo(DateTime inicio, DateTime fim) {
    if (inicio.isAfter(fim)) {
      throw ExercicioValidationException(
        message: 'Data de início não pode ser após data de fim', 
        field: 'periodo'
      );
    }
    
    final agora = DateTime.now();
    if (inicio.isAfter(agora)) {
      throw ExercicioValidationException(
        message: 'Data de início não pode ser no futuro', 
        field: 'dataInicio'
      );
    }
    
    final diferenca = fim.difference(inicio).inDays;
    if (diferenca > 365 * 2) { // 2 anos
      throw ExercicioValidationException(
        message: 'Período muito longo (máximo 2 anos)', 
        field: 'periodo'
      );
    }
  }
  
  /// Valida ID de exercício
  static void validateExercicioId(String? id) {
    if (id == null || id.trim().isEmpty) {
      throw ExercicioValidationException(
        message: 'ID do exercício é obrigatório', 
        field: 'id'
      );
    }
    
    final idClean = id.trim();
    if (idClean.length < 3) {
      throw ExercicioValidationException(
        message: 'ID do exercício muito curto', 
        field: 'id'
      );
    }
    
    if (idClean.length > ExercicioConstants.maxNomeLength) {
      throw ExercicioValidationException(
        message: 'ID do exercício muito longo', 
        field: 'id'
      );
    }
  }
  
  // ========================================================================
  // VALIDAÇÕES DE ENTRADA DE FORMULÁRIO
  // ========================================================================
  
  /// Valida entrada de texto para nome (para uso em forms)
  static String? validateNomeInput(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome do exercício é obrigatório';
    }
    
    try {
      _validateNome(value);
      return null;
    } on ExercicioValidationException catch (e) {
      return e.message;
    }
  }
  
  /// Valida entrada de texto para duração (para uso em forms)
  static String? validateDuracaoInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Duração é obrigatória';
    }
    
    final duracao = int.tryParse(value);
    if (duracao == null) {
      return 'Duração deve ser um número válido';
    }
    
    try {
      _validateDuracao(duracao);
      return null;
    } on ExercicioValidationException catch (e) {
      return e.message;
    }
  }
  
  /// Valida entrada de texto para calorias (para uso em forms)
  static String? validateCaloriasInput(String? value) {
    if (value != null && value.isNotEmpty) {
      final calorias = int.tryParse(value);
      if (calorias == null) {
        return 'Calorias deve ser um número válido';
      }
      
      try {
        _validateCaloriasQueimadas(calorias);
        return null;
      } on ExercicioValidationException catch (e) {
        return e.message;
      }
    }
    return null;
  }
  
  /// Valida entrada de texto para observações (para uso em forms)
  static String? validateObservacoesInput(String? value) {
    if (value != null && value.isNotEmpty) {
      try {
        _validateObservacoes(value);
        return null;
      } on ExercicioValidationException catch (e) {
        return e.message;
      }
    }
    return null;
  }
  
  // ========================================================================
  // MÉTODOS AUXILIARES
  // ========================================================================
  
  /// Verifica se o texto contém caracteres perigosos
  static bool _containsDangerousChars(String text) {
    // Caracteres que podem ser perigosos em contextos de segurança
    final dangerousPattern = RegExp(r'[<>"' "'" r'\\\/\u0000-\u001f\u007f-\u009f]');
    return dangerousPattern.hasMatch(text);
  }
  
  /// Obtém todas as categorias válidas
  static Set<String> getCategoriasValidas() {
    return Set.from(_categoriasValidas);
  }
  
  /// Adiciona uma nova categoria válida (para extensibilidade futura)
  static void adicionarCategoriaValida(String categoria) {
    if (categoria.trim().isNotEmpty && categoria.trim().length <= ExercicioConstants.maxCategoriaLength) {
      // Note: _categoriasValidas é const, então this would need to be refactored
      // to use a non-const set for runtime modification
      // For now, this is a placeholder for future enhancement
    }
  }
  
  /// Obtém limites de validação para uso em UI
  static Map<String, dynamic> getLimites() {
    return ExercicioConstants.getAllConstants();
  }
}
