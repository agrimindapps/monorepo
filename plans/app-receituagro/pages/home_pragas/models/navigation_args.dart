// Flutter imports:
import 'package:flutter/foundation.dart';

/// Base class for navigation arguments with validation
abstract class NavigationArgs {
  const NavigationArgs();
  
  /// Validates the arguments and throws exception if invalid
  void validate();
  
  /// Converts arguments to Map for GetX navigation
  Map<String, dynamic> toMap();
  
  /// Creates args from Map (used when receiving navigation arguments)
  static T fromMap<T extends NavigationArgs>(Map<String, dynamic>? map) {
    throw UnimplementedError('fromMap must be implemented by subclasses');
  }
  
  /// Logs navigation for debugging purposes
  void logNavigation(String routeName) {
    // Navigation logging removed for production
  }
}

/// Arguments for navigating to praga details page
class PragaDetailsArgs extends NavigationArgs {
  final String idReg;
  final String? source; // Optional: track where navigation came from
  
  const PragaDetailsArgs({
    required this.idReg,
    this.source,
  });
  
  @override
  void validate() {
    if (idReg.isEmpty) {
      throw ArgumentError('idReg cannot be empty');
    }
    
    // Validate ID format if needed
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(idReg)) {
      throw ArgumentError('idReg contains invalid characters: $idReg');
    }
  }
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'idReg': idReg,
      if (source != null) 'source': source,
    };
  }
  
  static PragaDetailsArgs fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      throw ArgumentError('Map cannot be null for PragaDetailsArgs');
    }
    
    final idReg = map['idReg']?.toString();
    if (idReg == null || idReg.isEmpty) {
      throw ArgumentError('idReg is required for PragaDetailsArgs');
    }
    
    return PragaDetailsArgs(
      idReg: idReg,
      source: map['source']?.toString(),
    );
  }
  
  @override
  String toString() => 'PragaDetailsArgs(idReg: $idReg, source: $source)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PragaDetailsArgs &&
        other.idReg == idReg &&
        other.source == source;
  }
  
  @override
  int get hashCode => Object.hash(idReg, source);
}

/// Arguments for navigating to pragas list page
class PragasListArgs extends NavigationArgs {
  final String tipoPraga;
  final String? filterCultura; // Optional: filter by cultura
  final String? searchTerm; // Optional: search term
  final String? source; // Optional: track where navigation came from
  
  const PragasListArgs({
    required this.tipoPraga,
    this.filterCultura,
    this.searchTerm,
    this.source,
  });
  
  @override
  void validate() {
    if (tipoPraga.isEmpty) {
      throw ArgumentError('tipoPraga cannot be empty');
    }
    
    // Validate tipoPraga values (1=Insetos, 2=Doenças, 3=Plantas Daninhas)
    if (!['1', '2', '3'].contains(tipoPraga)) {
      throw ArgumentError('tipoPraga must be 1, 2, or 3, got: $tipoPraga');
    }
  }
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'tipoPraga': tipoPraga,
      if (filterCultura != null) 'filterCultura': filterCultura,
      if (searchTerm != null) 'searchTerm': searchTerm,
      if (source != null) 'source': source,
    };
  }
  
  static PragasListArgs fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      throw ArgumentError('Map cannot be null for PragasListArgs');
    }
    
    final tipoPraga = map['tipoPraga']?.toString();
    if (tipoPraga == null || tipoPraga.isEmpty) {
      throw ArgumentError('tipoPraga is required for PragasListArgs');
    }
    
    return PragasListArgs(
      tipoPraga: tipoPraga,
      filterCultura: map['filterCultura']?.toString(),
      searchTerm: map['searchTerm']?.toString(),
      source: map['source']?.toString(),
    );
  }
  
  @override
  String toString() => 'PragasListArgs(tipoPraga: $tipoPraga, filterCultura: $filterCultura, searchTerm: $searchTerm, source: $source)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PragasListArgs &&
        other.tipoPraga == tipoPraga &&
        other.filterCultura == filterCultura &&
        other.searchTerm == searchTerm &&
        other.source == source;
  }
  
  @override
  int get hashCode => Object.hash(tipoPraga, filterCultura, searchTerm, source);
}

/// Arguments for navigating to culturas list page
class CulturasListArgs extends NavigationArgs {
  final String? searchTerm; // Optional: search term
  final String? source; // Optional: track where navigation came from
  
  const CulturasListArgs({
    this.searchTerm,
    this.source,
  });
  
  @override
  void validate() {
    // No required fields, so validation always passes
    // Could add search term validation if needed
  }
  
  @override
  Map<String, dynamic> toMap() {
    return {
      if (searchTerm != null) 'searchTerm': searchTerm,
      if (source != null) 'source': source,
    };
  }
  
  static CulturasListArgs fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const CulturasListArgs();
    }
    
    return CulturasListArgs(
      searchTerm: map['searchTerm']?.toString(),
      source: map['source']?.toString(),
    );
  }
  
  @override
  String toString() => 'CulturasListArgs(searchTerm: $searchTerm, source: $source)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CulturasListArgs &&
        other.searchTerm == searchTerm &&
        other.source == source;
  }
  
  @override
  int get hashCode => Object.hash(searchTerm, source);
}

/// Arguments for navigating to pragas por cultura page
class PragasPorCulturaArgs extends NavigationArgs {
  final String culturaId;
  final String culturaNome;
  final List<Map<String, dynamic>>? pragasList; // Optional: pre-loaded pragas data
  final String? source; // Optional: track where navigation came from
  
  const PragasPorCulturaArgs({
    required this.culturaId,
    required this.culturaNome,
    this.pragasList,
    this.source,
  });
  
  @override
  void validate() {
    if (culturaId.isEmpty) {
      throw ArgumentError('culturaId cannot be empty');
    }
    
    if (culturaNome.isEmpty) {
      throw ArgumentError('culturaNome cannot be empty');
    }
    
    // Validate ID format if needed
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(culturaId)) {
      throw ArgumentError('culturaId contains invalid characters: $culturaId');
    }
  }
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'culturaId': culturaId,
      'culturaNome': culturaNome,
      if (pragasList != null) 'pragasList': pragasList,
      if (source != null) 'source': source,
    };
  }
  
  static PragasPorCulturaArgs fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      throw ArgumentError('Map cannot be null for PragasPorCulturaArgs');
    }
    
    final culturaId = map['culturaId']?.toString();
    if (culturaId == null || culturaId.isEmpty) {
      throw ArgumentError('culturaId is required for PragasPorCulturaArgs');
    }
    
    final culturaNome = map['culturaNome']?.toString();
    if (culturaNome == null || culturaNome.isEmpty) {
      throw ArgumentError('culturaNome is required for PragasPorCulturaArgs');
    }
    
    return PragasPorCulturaArgs(
      culturaId: culturaId,
      culturaNome: culturaNome,
      pragasList: map['pragasList'] as List<Map<String, dynamic>>?,
      source: map['source']?.toString(),
    );
  }
  
  @override
  String toString() => 'PragasPorCulturaArgs(culturaId: $culturaId, culturaNome: $culturaNome, source: $source)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PragasPorCulturaArgs &&
        other.culturaId == culturaId &&
        other.culturaNome == culturaNome &&
        other.source == source;
  }
  
  @override
  int get hashCode => Object.hash(culturaId, culturaNome, source);
}

/// Utility class for navigation helpers
class NavigationHelper {
  /// Safely extracts arguments from GetX and validates them
  static T getArgs<T extends NavigationArgs>(
    Map<String, dynamic>? args,
    T Function(Map<String, dynamic>?) fromMapFunction,
    String routeName,
  ) {
    try {
      final navigationArgs = fromMapFunction(args);
      navigationArgs.validate();
      return navigationArgs;
    } catch (e) {
      if (kDebugMode) {
      }
      rethrow;
    }
  }
  
  /// Logs navigation attempts for debugging
  static void logNavigationAttempt(String routeName, NavigationArgs? args) {
    // Navigation logging removed for production
  }
  
  /// Validates navigation before attempting
  static bool validateNavigation(NavigationArgs? args, String routeName) {
    try {
      args?.validate();
      return true;
    } catch (e) {
      if (kDebugMode) {
      }
      return false;
    }
  }
}
