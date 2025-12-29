import 'package:equatable/equatable.dart';

/// Parameters for fetching recent records
class GetRecentParams with EquatableMixin {
  const GetRecentParams({
    required this.vehicleId,
    this.limit = 3,
  });

  final String vehicleId;
  final int limit;

  @override
  List<Object> get props => [vehicleId, limit];
}
