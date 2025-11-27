import 'package:equatable/equatable.dart';

/// Custom cup entity for quick-add buttons
class WaterCustomCupEntity extends Equatable {
  final String id;
  final String name;
  final int amountMl;
  final String? iconName;
  final int sortOrder;
  final bool isDefault;
  final DateTime createdAt;

  const WaterCustomCupEntity({
    required this.id,
    required this.name,
    required this.amountMl,
    this.iconName,
    this.sortOrder = 0,
    this.isDefault = false,
    required this.createdAt,
  });

  WaterCustomCupEntity copyWith({
    String? id,
    String? name,
    int? amountMl,
    String? iconName,
    int? sortOrder,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return WaterCustomCupEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      amountMl: amountMl ?? this.amountMl,
      iconName: iconName ?? this.iconName,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        amountMl,
        iconName,
        sortOrder,
        isDefault,
        createdAt,
      ];
}
