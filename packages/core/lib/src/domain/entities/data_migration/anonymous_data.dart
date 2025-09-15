import '../user_entity.dart';

/// Abstract base class representing anonymous user data that needs to be migrated
/// 
/// This class provides a common interface for representing data from anonymous users
/// that may conflict with existing account data. Each app should extend this class
/// to represent their specific data types.
abstract class AnonymousData {
  const AnonymousData({
    required this.userId,
    required this.userInfo,
    required this.recordCount,
    required this.lastModified,
    this.dataType,
    this.additionalInfo = const {},
  });

  /// The anonymous user's ID
  final String userId;
  
  /// Basic information about the anonymous user
  final UserEntity userInfo;
  
  /// Total number of records/items in this data set
  final int recordCount;
  
  /// When this data was last modified
  final DateTime lastModified;
  
  /// Type of data (e.g., 'vehicles', 'fuel_records', 'maintenance')
  final String? dataType;
  
  /// Additional metadata about the data
  final Map<String, dynamic> additionalInfo;

  /// Get a summary of this data for display purposes
  String get summary;
  
  /// Get detailed breakdown of data for comparison
  Map<String, dynamic> get breakdown;
  
  /// Whether this data set is empty
  bool get isEmpty => recordCount == 0;
  
  /// Whether this data set has significant content
  bool get hasSignificantData => recordCount > 0;

  /// Convert to JSON for storage/transmission
  Map<String, dynamic> toJson();
  
  /// Create a copy with updated fields
  AnonymousData copyWith({
    String? userId,
    UserEntity? userInfo,
    int? recordCount,
    DateTime? lastModified,
    String? dataType,
    Map<String, dynamic>? additionalInfo,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnonymousData && 
           other.userId == userId &&
           other.dataType == dataType;
  }

  @override
  int get hashCode => userId.hashCode ^ dataType.hashCode;
}

/// Represents combined anonymous data from multiple data types
class CombinedAnonymousData extends AnonymousData {
  const CombinedAnonymousData({
    required super.userId,
    required super.userInfo,
    required super.recordCount,
    required super.lastModified,
    required this.dataItems,
    super.additionalInfo = const {},
  }) : super(dataType: 'combined');

  /// List of individual data items that make up this combined data
  final List<AnonymousData> dataItems;

  @override
  String get summary {
    if (dataItems.isEmpty) return 'Nenhum dado encontrado';
    
    final itemSummaries = dataItems.map((item) => item.summary).join(', ');
    return 'Total: $recordCount registros ($itemSummaries)';
  }

  @override
  Map<String, dynamic> get breakdown {
    return {
      'total_records': recordCount,
      'data_types': dataItems.length,
      'items': dataItems.map((item) => item.breakdown).toList(),
      'last_modified': lastModified.toIso8601String(),
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_info': userInfo.toJson(),
      'record_count': recordCount,
      'last_modified': lastModified.toIso8601String(),
      'data_type': dataType,
      'additional_info': additionalInfo,
      'data_items': dataItems.map((item) => item.toJson()).toList(),
    };
  }

  @override
  CombinedAnonymousData copyWith({
    String? userId,
    UserEntity? userInfo,
    int? recordCount,
    DateTime? lastModified,
    String? dataType,
    Map<String, dynamic>? additionalInfo,
    List<AnonymousData>? dataItems,
  }) {
    return CombinedAnonymousData(
      userId: userId ?? this.userId,
      userInfo: userInfo ?? this.userInfo,
      recordCount: recordCount ?? this.recordCount,
      lastModified: lastModified ?? this.lastModified,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      dataItems: dataItems ?? this.dataItems,
    );
  }

  /// Create from JSON
  factory CombinedAnonymousData.fromJson(Map<String, dynamic> json, 
      AnonymousData Function(Map<String, dynamic>) itemParser) {
    return CombinedAnonymousData(
      userId: json['user_id'] as String,
      userInfo: UserEntity.fromJson(json['user_info'] as Map<String, dynamic>),
      recordCount: json['record_count'] as int,
      lastModified: DateTime.parse(json['last_modified'] as String),
      additionalInfo: json['additional_info'] as Map<String, dynamic>? ?? const {},
      dataItems: (json['data_items'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(itemParser)
          .toList(),
    );
  }
}