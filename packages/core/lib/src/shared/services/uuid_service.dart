import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

/// Service centralizado para geração de UUIDs
///
/// Encapsula a biblioteca uuid e fornece métodos convenientes
/// para geração de identificadores únicos em diferentes formatos
///
/// Exemplos:
/// ```dart
/// final uuidService = getIt<UuidService>();
///
/// // UUID v4 (aleatório)
/// final id = uuidService.generate();
///
/// // UUID v1 (baseado em timestamp)
/// final timestampId = uuidService.generateV1();
///
/// // UUID v5 (baseado em namespace e nome)
/// final namespaceId = uuidService.generateV5(
///   namespace: Uuid.NAMESPACE_URL,
///   name: 'example.com',
/// );
/// ```
@lazySingleton
class UuidService {
  final Uuid _uuid;

  UuidService() : _uuid = const Uuid();

  /// Gera um UUID v4 (aleatório)
  ///
  /// Retorna uma string no formato: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
  ///
  /// Exemplo: '550e8400-e29b-41d4-a716-446655440000'
  String generate() {
    return _uuid.v4();
  }

  /// Gera um UUID v4 sem hífens
  ///
  /// Útil para casos onde o formato compacto é necessário
  /// Exemplo: '550e8400e29b41d4a716446655440000'
  String generateCompact() {
    return _uuid.v4().replaceAll('-', '');
  }

  /// Gera um UUID v1 (baseado em timestamp e MAC address)
  ///
  /// Útil quando você precisa ordenar cronologicamente
  /// ou garantir unicidade através de múltiplas máquinas
  ///
  /// Exemplo: '6fa459ea-ee8a-11eb-9a03-0242ac130003'
  String generateV1() {
    return _uuid.v1();
  }

  /// Gera um UUID v5 (baseado em namespace e nome)
  ///
  /// Útil para gerar IDs determinísticos baseados em um namespace e nome
  /// O mesmo namespace + nome sempre gera o mesmo UUID
  ///
  /// [namespace] - UUID do namespace (use Uuid.NAMESPACE_*)
  /// [name] - Nome para gerar o hash
  ///
  /// Namespaces disponíveis:
  /// - Uuid.NAMESPACE_DNS
  /// - Uuid.NAMESPACE_URL
  /// - Uuid.NAMESPACE_OID
  /// - Uuid.NAMESPACE_X500
  ///
  /// Exemplo:
  /// ```dart
  /// final id = uuidService.generateV5(
  ///   namespace: Uuid.NAMESPACE_URL,
  ///   name: 'https://example.com',
  /// );
  /// ```
  String generateV5({required String namespace, required String name}) {
    return _uuid.v5(namespace, name);
  }

  /// Valida se uma string é um UUID válido
  ///
  /// Retorna true se a string estiver no formato UUID correto
  ///
  /// Exemplo:
  /// ```dart
  /// final isValid = uuidService.isValid('550e8400-e29b-41d4-a716-446655440000');
  /// // isValid = true
  /// ```
  bool isValid(String uuid) {
    final uuidPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidPattern.hasMatch(uuid);
  }

  /// Valida se uma string é um UUID válido (formato compacto sem hífens)
  ///
  /// Exemplo:
  /// ```dart
  /// final isValid = uuidService.isValidCompact('550e8400e29b41d4a716446655440000');
  /// // isValid = true
  /// ```
  bool isValidCompact(String uuid) {
    final uuidPattern = RegExp(r'^[0-9a-f]{32}$', caseSensitive: false);
    return uuidPattern.hasMatch(uuid);
  }

  /// Formata um UUID compacto para o formato padrão com hífens
  ///
  /// Exemplo:
  /// ```dart
  /// final formatted = uuidService.format('550e8400e29b41d4a716446655440000');
  /// // formatted = '550e8400-e29b-41d4-a716-446655440000'
  /// ```
  String format(String compactUuid) {
    if (compactUuid.length != 32) {
      throw ArgumentError('UUID compacto deve ter exatamente 32 caracteres');
    }

    return '${compactUuid.substring(0, 8)}-'
        '${compactUuid.substring(8, 12)}-'
        '${compactUuid.substring(12, 16)}-'
        '${compactUuid.substring(16, 20)}-'
        '${compactUuid.substring(20)}';
  }

  /// Remove os hífens de um UUID formatado
  ///
  /// Exemplo:
  /// ```dart
  /// final compact = uuidService.unformat('550e8400-e29b-41d4-a716-446655440000');
  /// // compact = '550e8400e29b41d4a716446655440000'
  /// ```
  String unformat(String formattedUuid) {
    return formattedUuid.replaceAll('-', '');
  }

  /// Gera múltiplos UUIDs de uma vez
  ///
  /// [count] - Quantidade de UUIDs a gerar
  ///
  /// Exemplo:
  /// ```dart
  /// final ids = uuidService.generateBatch(5);
  /// // ids = ['uuid1', 'uuid2', 'uuid3', 'uuid4', 'uuid5']
  /// ```
  List<String> generateBatch(int count) {
    if (count <= 0) {
      throw ArgumentError('Count deve ser maior que zero');
    }
    return List.generate(count, (_) => generate());
  }

  /// Acesso direto à instância Uuid para casos avançados
  ///
  /// Use com cuidado - prefira os métodos específicos deste service
  Uuid get uuid => _uuid;
}
