import 'package:equatable/equatable.dart';

/// Type of recent access item
enum RecentAccessType {
  defensivo,
  praga;

  String get storageKey {
    switch (this) {
      case RecentAccessType.defensivo:
        return 'recent_defensivos';
      case RecentAccessType.praga:
        return 'recent_pragas';
    }
  }
}

/// Entity representing a recent access entry
class RecentAccess extends Equatable {
  final String id;
  final String itemId;
  final RecentAccessType type;
  final DateTime accessedAt;
  final String? itemName;
  final String? itemSubtitle;
  final String? imageUrl;

  const RecentAccess({
    required this.id,
    required this.itemId,
    required this.type,
    required this.accessedAt,
    this.itemName,
    this.itemSubtitle,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        itemId,
        type,
        accessedAt,
        itemName,
        itemSubtitle,
        imageUrl,
      ];

  /// Create a copy with updated fields
  RecentAccess copyWith({
    String? id,
    String? itemId,
    RecentAccessType? type,
    DateTime? accessedAt,
    String? itemName,
    String? itemSubtitle,
    String? imageUrl,
  }) {
    return RecentAccess(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      type: type ?? this.type,
      accessedAt: accessedAt ?? this.accessedAt,
      itemName: itemName ?? this.itemName,
      itemSubtitle: itemSubtitle ?? this.itemSubtitle,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Create from JSON map
  factory RecentAccess.fromJson(Map<String, dynamic> json) {
    return RecentAccess(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      type: RecentAccessType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => RecentAccessType.defensivo,
      ),
      accessedAt: DateTime.parse(json['accessedAt'] as String),
      itemName: json['itemName'] as String?,
      itemSubtitle: json['itemSubtitle'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'type': type.name,
      'accessedAt': accessedAt.toIso8601String(),
      'itemName': itemName,
      'itemSubtitle': itemSubtitle,
      'imageUrl': imageUrl,
    };
  }

  /// Factory constructor for creating a defensivo access entry
  factory RecentAccess.forDefensivo({
    required String itemId,
    required String name,
    String? subtitle,
  }) {
    return RecentAccess(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemId: itemId,
      type: RecentAccessType.defensivo,
      accessedAt: DateTime.now(),
      itemName: name,
      itemSubtitle: subtitle,
    );
  }

  /// Factory constructor for creating a praga access entry
  factory RecentAccess.forPraga({
    required String itemId,
    required String name,
    String? subtitle,
    String? imageUrl,
  }) {
    return RecentAccess(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemId: itemId,
      type: RecentAccessType.praga,
      accessedAt: DateTime.now(),
      itemName: name,
      itemSubtitle: subtitle,
      imageUrl: imageUrl,
    );
  }
}
