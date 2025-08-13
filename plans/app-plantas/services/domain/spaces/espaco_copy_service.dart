// Project imports:
import '../../../database/espaco_model.dart';
import '../../../repository/espaco_repository.dart';

/// Serviço para operações de cópia e duplicação de Espaços
/// Responsabilidade: Lógica de negócio para duplicação
class EspacoCopyService {
  static EspacoCopyService? _instance;
  static EspacoCopyService get instance => _instance ??= EspacoCopyService._();

  final EspacoRepository _repository = EspacoRepository.instance;

  EspacoCopyService._();

  /// Duplicar espaço com estratégia de nomeação personalizada
  Future<String> duplicateSpace(
    String espacoId, {
    String? customName,
    String? customDescription,
    bool setActive = true,
    DuplicationStrategy strategy = DuplicationStrategy.appendCopy,
  }) async {
    final originalEspaco = await _repository.findById(espacoId);
    if (originalEspaco == null) {
      throw EspacoNotFoundException('Espaço $espacoId não encontrado');
    }

    final newName = customName ?? _generateName(originalEspaco.nome, strategy);
    final newDescription = customDescription ?? originalEspaco.descricao;

    // Verificar se já existe espaço com o nome gerado
    if (await _repository.existeComNome(newName)) {
      throw DuplicateEspacoNameException(
          'Já existe um espaço com o nome "$newName"');
    }

    final duplicatedEspaco = _createDuplicatedEspaco(
      originalEspaco,
      newName,
      newDescription,
      setActive,
    );

    return await _repository.createLegacy(duplicatedEspaco);
  }

  /// Criar múltiplas cópias com numeração sequencial
  Future<List<String>> duplicateMultiple(
    String espacoId,
    int count, {
    String? baseNamePrefix,
    bool setActive = true,
  }) async {
    if (count <= 0) return <String>[];

    final originalEspaco = await _repository.findById(espacoId);
    if (originalEspaco == null) {
      throw EspacoNotFoundException('Espaço $espacoId não encontrado');
    }

    final ids = <String>[];
    final baseName = baseNamePrefix ?? originalEspaco.nome;

    for (int i = 1; i <= count; i++) {
      final copyName = '$baseName (cópia $i)';

      // Verificar se nome já existe
      if (await _repository.existeComNome(copyName)) {
        continue; // Pular se já existe
      }

      final duplicatedEspaco = _createDuplicatedEspaco(
        originalEspaco,
        copyName,
        originalEspaco.descricao,
        setActive,
      );

      final id = await _repository.createLegacy(duplicatedEspaco);
      ids.add(id);
    }

    return ids;
  }

  /// Criar template a partir de espaço existente
  Future<EspacoModel> createTemplate(String espacoId) async {
    final originalEspaco = await _repository.findById(espacoId);
    if (originalEspaco == null) {
      throw EspacoNotFoundException('Espaço $espacoId não encontrado');
    }

    return _createDuplicatedEspaco(
      originalEspaco,
      '${originalEspaco.nome} (Template)',
      'Template baseado em: ${originalEspaco.nome}',
      false, // Templates começam inativos
    );
  }

  // Métodos privados

  String _generateName(String originalName, DuplicationStrategy strategy) {
    switch (strategy) {
      case DuplicationStrategy.appendCopy:
        return '$originalName (cópia)';
      case DuplicationStrategy.appendNumber:
        return '$originalName 2';
      case DuplicationStrategy.prependCopy:
        return 'Cópia de $originalName';
      case DuplicationStrategy.withTimestamp:
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        return '$originalName ($timestamp)';
    }
  }

  EspacoModel _createDuplicatedEspaco(
    EspacoModel original,
    String newName,
    String? newDescription,
    bool setActive,
  ) {
    final now = DateTime.now();
    return EspacoModel(
      id: '', // Será gerado automaticamente
      createdAt: now.millisecondsSinceEpoch,
      updatedAt: now.millisecondsSinceEpoch,
      nome: newName,
      descricao: newDescription ?? original.descricao,
      ativo: setActive,
      dataCriacao: now,
    );
  }
}

/// Estratégias para nomeação na duplicação
enum DuplicationStrategy {
  appendCopy, // "Nome (cópia)"
  appendNumber, // "Nome 2"
  prependCopy, // "Cópia de Nome"
  withTimestamp, // "Nome (timestamp)"
}

/// Exceções específicas do serviço
class EspacoNotFoundException implements Exception {
  final String message;
  const EspacoNotFoundException(this.message);

  @override
  String toString() => 'EspacoNotFoundException: $message';
}

class DuplicateEspacoNameException implements Exception {
  final String message;
  const DuplicateEspacoNameException(this.message);

  @override
  String toString() => 'DuplicateEspacoNameException: $message';
}
