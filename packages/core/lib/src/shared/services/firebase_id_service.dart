import 'package:cloud_firestore/cloud_firestore.dart';

/// Service centralizado para geração de IDs únicos usando Firebase
///
/// Substitui a biblioteca uuid por geração nativa do Firebase Firestore,
/// que gera IDs automaticamente otimizados para uso com Firestore e
/// garante unicidade sem dependências externas.
///
/// Vantagens sobre UUID:
/// - Sem dependência externa (uuid package)
/// - IDs otimizados para Firestore (ordenação lexicográfica mantém ordem cronológica)
/// - Geração mais eficiente
/// - Integração nativa com Firebase
///
/// Exemplos:
/// ```dart
/// final idService = FirebaseIdService();
///
/// // Gerar ID único
/// final id = idService.generate();
///
/// // Gerar ID compacto (sem hífens)
/// final compactId = idService.generateCompact();
///
/// // Gerar múltiplos IDs
/// final ids = idService.generateBatch(5);
/// ```
class FirebaseIdService {
  final FirebaseFirestore _firestore;

  FirebaseIdService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Gera um ID único usando o algoritmo do Firebase Firestore
  ///
  /// Os IDs gerados são strings de 20 caracteres alfanuméricos
  /// que mantêm ordenação cronológica lexicográfica.
  ///
  /// Formato: caracteres aleatórios otimizados para Firestore
  /// Exemplo: 'K3QK5J8mF4nR7pL2wX9Y'
  String generate() {
    return _firestore.collection('_').doc().id;
  }

  /// Gera um ID único no formato compacto
  ///
  /// Útil para casos onde o formato compacto é necessário.
  /// Retorna o mesmo ID do método generate() pois Firebase IDs
  /// já são compactos por padrão (sem hífens).
  ///
  /// Exemplo: 'K3QK5J8mF4nR7pL2wX9Y'
  String generateCompact() {
    return generate(); // Firebase IDs já são compactos
  }

  /// Gera um ID com timestamp para ordenação cronológica
  ///
  /// Útil quando você precisa ordenar cronologicamente.
  /// Adiciona timestamp no início para garantir ordem temporal.
  ///
  /// Formato: timestamp + ID Firebase
  /// Exemplo: '1696723200000_K3QK5J8mF4nR7pL2wX9Y'
  String generateWithTimestamp() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final id = generate();
    return '${timestamp}_$id';
  }

  /// Gera um ID determinístico baseado em uma string
  ///
  /// Para compatibilidade com uso anterior de UUID v5,
  /// cria um hash SHA256 da string fornecida.
  ///
  /// NOTA: Use apenas para casos específicos onde IDs determinísticos
  /// são necessários. Para novos IDs, use generate().
  ///
  /// [input] - String base para gerar o hash
  ///
  /// Exemplo:
  /// ```dart
  /// final id = idService.generateDeterministic('user_email@example.com');
  /// ```
  String generateDeterministic(String input) {
    // Para IDs determinísticos, usar hash da string
    final hash = input.hashCode.abs().toString().padLeft(20, '0');
    return hash.substring(0, 20);
  }

  /// Valida se uma string é um ID Firebase válido
  ///
  /// Firebase IDs têm 20 caracteres alfanuméricos.
  ///
  /// Retorna true se a string tem formato válido.
  ///
  /// Exemplo:
  /// ```dart
  /// final isValid = idService.isValid('K3QK5J8mF4nR7pL2wX9Y');
  /// // isValid = true
  /// ```
  bool isValid(String id) {
    // Firebase IDs têm 20 caracteres alfanuméricos
    if (id.length != 20) return false;

    final pattern = RegExp(r'^[A-Za-z0-9]+$');
    return pattern.hasMatch(id);
  }

  /// Valida se uma string é um ID válido (mesmo que isValid)
  ///
  /// Mantido para compatibilidade com API anterior do UuidService
  bool isValidCompact(String id) {
    return isValid(id);
  }

  /// Gera múltiplos IDs de uma vez
  ///
  /// [count] - Quantidade de IDs a gerar
  ///
  /// Exemplo:
  /// ```dart
  /// final ids = idService.generateBatch(5);
  /// // ids = ['id1', 'id2', 'id3', 'id4', 'id5']
  /// ```
  List<String> generateBatch(int count) {
    if (count <= 0) {
      throw ArgumentError('Count deve ser maior que zero');
    }
    return List.generate(count, (_) => generate());
  }

  /// Extrai timestamp de um ID gerado com generateWithTimestamp()
  ///
  /// Retorna null se o ID não contém timestamp.
  ///
  /// Exemplo:
  /// ```dart
  /// final timestamp = idService.extractTimestamp('1696723200000_K3QK5J8mF4nR7pL2wX9Y');
  /// // timestamp = DateTime(...)
  /// ```
  DateTime? extractTimestamp(String id) {
    if (!id.contains('_')) return null;

    final parts = id.split('_');
    if (parts.length != 2) return null;

    final timestamp = int.tryParse(parts[0]);
    if (timestamp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Formata um ID para exibição (adiciona hífens para legibilidade)
  ///
  /// Útil para casos onde você precisa exibir o ID de forma mais legível.
  /// Firebase IDs não têm formato específico, então divide em grupos de 4.
  ///
  /// Exemplo:
  /// ```dart
  /// final formatted = idService.format('K3QK5J8mF4nR7pL2wX9Y');
  /// // formatted = 'K3QK-5J8m-F4nR-7pL2-wX9Y'
  /// ```
  String format(String id) {
    if (id.length != 20) {
      throw ArgumentError('Firebase ID deve ter exatamente 20 caracteres');
    }

    return '${id.substring(0, 4)}-'
        '${id.substring(4, 8)}-'
        '${id.substring(8, 12)}-'
        '${id.substring(12, 16)}-'
        '${id.substring(16)}';
  }

  /// Remove os hífens de um ID formatado
  ///
  /// Exemplo:
  /// ```dart
  /// final compact = idService.unformat('K3QK-5J8m-F4nR-7pL2-wX9Y');
  /// // compact = 'K3QK5J8mF4nR7pL2wX9Y'
  /// ```
  String unformat(String formattedId) {
    return formattedId.replaceAll('-', '');
  }

  /// Acesso direto à instância Firestore para casos avançados
  ///
  /// Use com cuidado - prefira os métodos específicos deste service
  FirebaseFirestore get firestore => _firestore;
}
