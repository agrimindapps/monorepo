import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/bovine_entity.dart';
import '../../domain/entities/equine_entity.dart';
import '../models/bovine_model.dart';
import '../models/equine_model.dart';

/// Metadata do catálogo armazenado no Storage
class CatalogMetadata {
  final DateTime lastUpdated;
  final int bovinesCount;
  final int equinesCount;
  final String version;
  
  CatalogMetadata({
    required this.lastUpdated,
    required this.bovinesCount,
    required this.equinesCount,
    required this.version,
  });
  
  factory CatalogMetadata.fromJson(Map<String, dynamic> json) {
    return CatalogMetadata(
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      bovinesCount: json['bovines_count'] as int,
      equinesCount: json['equines_count'] as int,
      version: json['version'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'last_updated': lastUpdated.toIso8601String(),
      'bovines_count': bovinesCount,
      'equines_count': equinesCount,
      'version': version,
    };
  }
  
  factory CatalogMetadata.empty() {
    return CatalogMetadata(
      lastUpdated: DateTime(2020),
      bovinesCount: 0,
      equinesCount: 0,
      version: '0.0.0',
    );
  }
}

/// DataSource para Firebase Storage
/// Responsável por download/upload de catálogos JSON
class LivestockStorageDataSource {
  final FirebaseStorage _storage;
  
  LivestockStorageDataSource(this._storage);
  
  static const _bovinesCatalogPath = 'livestock/bovines_catalog.json';
  static const _equinesCatalogPath = 'livestock/equines_catalog.json';
  static const _metadataPath = 'livestock/metadata.json';
  
  // ========== DOWNLOAD (Usuários) ==========
  
  /// Baixa catálogo de bovinos do Storage
  Future<List<BovineModel>> fetchBovinesCatalog() async {
    try {
      final ref = _storage.ref(_bovinesCatalogPath);
      
      // Download do arquivo JSON
      final bytes = await ref.getData();
      if (bytes == null) {
        throw Exception('Failed to download bovines catalog');
      }
      
      // Parse JSON
      final jsonString = utf8.decode(bytes);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Converter para models
      final bovinesList = (jsonData['bovines'] as List)
          .map((json) => BovineModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      debugPrint('📥 Downloaded ${bovinesList.length} bovines from Storage');
      return bovinesList;
      
    } catch (e) {
      debugPrint('❌ Error fetching bovines catalog: $e');
      rethrow;
    }
  }
  
  /// Baixa catálogo de equinos do Storage
  Future<List<EquineModel>> fetchEquinesCatalog() async {
    try {
      final ref = _storage.ref(_equinesCatalogPath);
      final bytes = await ref.getData();
      if (bytes == null) {
        throw Exception('Failed to download equines catalog');
      }
      
      final jsonString = utf8.decode(bytes);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      final equinesList = (jsonData['equines'] as List)
          .map((json) => EquineModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      debugPrint('📥 Downloaded ${equinesList.length} equines from Storage');
      return equinesList;
      
    } catch (e) {
      debugPrint('❌ Error fetching equines catalog: $e');
      rethrow;
    }
  }
  
  /// Baixa metadata do catálogo
  Future<CatalogMetadata> fetchMetadata() async {
    try {
      final ref = _storage.ref(_metadataPath);
      final bytes = await ref.getData();
      if (bytes == null) {
        debugPrint('⚠️ Metadata not found, returning empty');
        return CatalogMetadata.empty();
      }
      
      final jsonString = utf8.decode(bytes);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      return CatalogMetadata.fromJson(jsonData);
      
    } catch (e) {
      debugPrint('⚠️ Error fetching metadata: $e');
      return CatalogMetadata.empty();
    }
  }
  
  /// Verifica se há atualização disponível
  Future<bool> needsUpdate({required DateTime lastLocalUpdate}) async {
    try {
      final metadata = await fetchMetadata();
      final needsUpdate = metadata.lastUpdated.isAfter(lastLocalUpdate);
      
      debugPrint(
        '🔍 Checking updates: Local=${lastLocalUpdate.toIso8601String()}, '
        'Remote=${metadata.lastUpdated.toIso8601String()}, '
        'NeedsUpdate=$needsUpdate'
      );
      
      return needsUpdate;
      
    } catch (e) {
      debugPrint('⚠️ Error checking updates: $e');
      return false;
    }
  }
  
  // ========== UPLOAD (Admin) ==========
  
  /// Upload do catálogo de bovinos (admin only)
  Future<void> uploadBovinesCatalog(List<BovineEntity> bovines) async {
    try {
      final activeBovines = bovines.where((b) => b.isActive).toList();
      
      final catalogJson = {
        'bovines': activeBovines.map(_bovineToJson).toList(),
        'generated_at': DateTime.now().toIso8601String(),
        'count': activeBovines.length,
        'version': '1.0.0',
      };
      
      final jsonString = jsonEncode(catalogJson);
      final ref = _storage.ref(_bovinesCatalogPath);
      
      await ref.putString(
        jsonString,
        metadata: SettableMetadata(
          contentType: 'application/json',
          cacheControl: 'public, max-age=3600',
        ),
      );
      
      debugPrint('📤 Uploaded bovines catalog: ${activeBovines.length} items');
      
    } catch (e) {
      debugPrint('❌ Error uploading bovines catalog: $e');
      rethrow;
    }
  }
  
  /// Upload do catálogo de equinos (admin only)
  Future<void> uploadEquinesCatalog(List<EquineEntity> equines) async {
    try {
      final activeEquines = equines.where((e) => e.isActive).toList();
      
      final catalogJson = {
        'equines': activeEquines.map(_equineToJson).toList(),
        'generated_at': DateTime.now().toIso8601String(),
        'count': activeEquines.length,
        'version': '1.0.0',
      };
      
      final jsonString = jsonEncode(catalogJson);
      final ref = _storage.ref(_equinesCatalogPath);
      
      await ref.putString(
        jsonString,
        metadata: SettableMetadata(
          contentType: 'application/json',
          cacheControl: 'public, max-age=3600',
        ),
      );
      
      debugPrint('📤 Uploaded equines catalog: ${activeEquines.length} items');
      
    } catch (e) {
      debugPrint('❌ Error uploading equines catalog: $e');
      rethrow;
    }
  }
  
  /// Upload da metadata (admin only)
  Future<void> uploadMetadata(CatalogMetadata metadata) async {
    try {
      final jsonString = jsonEncode(metadata.toJson());
      final ref = _storage.ref(_metadataPath);
      
      await ref.putString(
        jsonString,
        metadata: SettableMetadata(
          contentType: 'application/json',
          cacheControl: 'public, max-age=300', // 5 min (metadata muda mais)
        ),
      );
      
      debugPrint('📤 Uploaded metadata: ${metadata.toJson()}');
      
    } catch (e) {
      debugPrint('❌ Error uploading metadata: $e');
      rethrow;
    }
  }
  
  // ========== Helpers ==========
  
  Map<String, dynamic> _bovineToJson(BovineEntity bovine) {
    return {
      'id': bovine.id,
      'registration_id': bovine.registrationId,
      'common_name': bovine.commonName,
      'origin_country': bovine.originCountry,
      'image_urls': bovine.imageUrls,
      'thumbnail_url': bovine.thumbnailUrl,
      'animal_type': bovine.animalType,
      'origin': bovine.origin,
      'characteristics': bovine.characteristics,
      'breed': bovine.breed,
      'aptitude': bovine.aptitude.name,
      'tags': bovine.tags,
      'breeding_system': bovine.breedingSystem.name,
      'purpose': bovine.purpose,
      'notes': bovine.notes,
    };
  }
  
  Map<String, dynamic> _equineToJson(EquineEntity equine) {
    return {
      'id': equine.id,
      'registration_id': equine.registrationId,
      'common_name': equine.commonName,
      'origin_country': equine.originCountry,
      'image_urls': equine.imageUrls,
      'thumbnail_url': equine.thumbnailUrl,
      'history': equine.history,
      'temperament': equine.temperament.name,
      'coat': equine.coat.name,
      'primary_use': equine.primaryUse.name,
      'genetic_influences': equine.geneticInfluences,
      'height': equine.height,
      'weight': equine.weight,
    };
  }
}
