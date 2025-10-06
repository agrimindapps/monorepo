import 'package:core/core.dart';

/// Entidade base para todos os animais do sistema
/// Contém campos comuns entre bovinos e equinos
abstract class AnimalBaseEntity extends BaseEntity {
  const AnimalBaseEntity({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.isActive,
    required this.registrationId,
    required this.commonName,
    required this.originCountry,
    required this.imageUrls,
    this.thumbnailUrl,
  });

  /// Status ativo/inativo do animal
  final bool isActive;

  /// ID de registro personalizado/customizado
  final String registrationId;

  /// Nome comum da raça/animal
  final String commonName;

  /// País de origem da raça
  final String originCountry;

  /// Lista de URLs das imagens do animal
  final List<String> imageUrls;

  /// URL da imagem miniatura
  final String? thumbnailUrl;

  @override
  List<Object?> get props => [
        ...super.props,
        isActive,
        registrationId,
        commonName,
        originCountry,
        imageUrls,
        thumbnailUrl,
      ];
}
