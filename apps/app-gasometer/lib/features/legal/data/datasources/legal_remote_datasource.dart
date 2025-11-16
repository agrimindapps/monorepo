import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/legal_document_entity.dart';
import '../models/legal_document_model.dart';

abstract class ILegalRemoteDataSource {
  Future<LegalDocumentModel> getLegalDocument(LegalDocumentType type);
  Future<String> getLatestVersion(LegalDocumentType type);
}

class LegalRemoteDataSource implements ILegalRemoteDataSource {
  final FirebaseFirestore firestore;

  LegalRemoteDataSource({required this.firestore});

  @override
  Future<LegalDocumentModel> getLegalDocument(LegalDocumentType type) async {
    final typeStr = _typeToString(type);
    final doc = await firestore.collection('legal_documents').doc(typeStr).get();

    if (!doc.exists) {
      throw ServerException();
    }

    return LegalDocumentModel.fromJson(doc.data()!);
  }

  @override
  Future<String> getLatestVersion(LegalDocumentType type) async {
    final typeStr = _typeToString(type);
    final doc = await firestore.collection('legal_documents').doc(typeStr).get();

    if (!doc.exists) {
      throw ServerException();
    }

    return doc.data()!['version'] as String;
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

class ServerException implements Exception {}
