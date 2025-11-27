import 'package:equatable/equatable.dart';

/// Time of day for weight records
enum WeightTimeOfDay {
  morning('morning'),
  afternoon('afternoon'),
  evening('evening');

  final String value;
  const WeightTimeOfDay(this.value);

  static WeightTimeOfDay fromString(String value) {
    return WeightTimeOfDay.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WeightTimeOfDay.morning,
    );
  }

  String get displayName {
    switch (this) {
      case WeightTimeOfDay.morning:
        return 'Manhã';
      case WeightTimeOfDay.afternoon:
        return 'Tarde';
      case WeightTimeOfDay.evening:
        return 'Noite';
    }
  }

  String get emoji {
    switch (this) {
      case WeightTimeOfDay.morning:
        return '🌅';
      case WeightTimeOfDay.afternoon:
        return '☀️';
      case WeightTimeOfDay.evening:
        return '🌙';
    }
  }
}

/// Weight Record entity - individual weight records
class WeightRecordEntity extends Equatable {
  final String id;
  final double weightKg;
  final DateTime timestamp;
  final String? note;
  final WeightTimeOfDay timeOfDay;

  const WeightRecordEntity({
    required this.id,
    required this.weightKg,
    required this.timestamp,
    this.note,
    this.timeOfDay = WeightTimeOfDay.morning,
  });

  WeightRecordEntity copyWith({
    String? id,
    double? weightKg,
    DateTime? timestamp,
    String? note,
    WeightTimeOfDay? timeOfDay,
  }) {
    return WeightRecordEntity(
      id: id ?? this.id,
      weightKg: weightKg ?? this.weightKg,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      timeOfDay: timeOfDay ?? this.timeOfDay,
    );
  }

  @override
  List<Object?> get props => [id, weightKg, timestamp, note, timeOfDay];
}
