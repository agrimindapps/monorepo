import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/legal_document_entity.dart';
import '../models/legal_document_model.dart';

abstract class ILegalLocalDataSource {
  Future<LegalDocumentModel> getCachedDocument(LegalDocumentType type);
  Future<void> cacheDocument(LegalDocumentModel document);
  Future<void> saveAcceptance(String documentId, String version);
  Future<String?> getAcceptedVersion(LegalDocumentType type);
}

class LegalLocalDataSource implements ILegalLocalDataSource {
  static const String _cachedDocPrefix = 'CACHED_LEGAL_DOC_';
  static const String _acceptedVersionPrefix = 'ACCEPTED_VERSION_';

  final SharedPreferences sharedPreferences;

  LegalLocalDataSource({required this.sharedPreferences});

  @override
  Future<LegalDocumentModel> getCachedDocument(LegalDocumentType type) async {
    final key = _cachedDocPrefix + _typeToString(type);
    final jsonString = sharedPreferences.getString(key);

    if (jsonString == null) {
      throw CacheException();
    }

    return LegalDocumentModel.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> cacheDocument(LegalDocumentModel document) async {
    final key = _cachedDocPrefix + _typeToString(document.type);
    await sharedPreferences.setString(
      key,
      json.encode(document.toJson()),
    );
  }

  @override
  Future<void> saveAcceptance(String documentId, String version) async {
    final key = _acceptedVersionPrefix + documentId;
    await sharedPreferences.setString(key, version);
  }

  @override
  Future<String?> getAcceptedVersion(LegalDocumentType type) async {
    final key = _acceptedVersionPrefix + _typeToString(type);
    return sharedPreferences.getString(key);
  }

  String _typeToString(LegalDocumentType type) {
    switch (type) {
      case LegalDocumentType.termsOfService:
        return 'terms_of_service';
      case LegalDocumentType.privacyPolicy:
        return 'privacy_policy';
      case LegalDocumentType.cookiePolicy:
        return 'cookie_policy';
      case LegalDocumentType.userAgreement:
        return 'user_agreement';
    }
  }
}

class CacheException implements Exception {}
