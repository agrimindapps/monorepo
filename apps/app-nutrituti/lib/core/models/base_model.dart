import 'package:equatable/equatable.dart';

abstract class BaseModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BaseModel({
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap();

  @override
  List<Object?> get props => [id, createdAt, updatedAt];
}
