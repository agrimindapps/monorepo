import 'package:equatable/equatable.dart';

class PromoEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const PromoEntity({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        startDate,
        endDate,
        isActive,
      ];
}
