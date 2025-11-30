import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {

  const UserProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.lastModified,
  });
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastModified;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        photoUrl,
        createdAt,
        lastModified,
      ];
}
