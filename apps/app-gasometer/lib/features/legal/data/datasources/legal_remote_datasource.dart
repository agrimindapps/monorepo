import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/legal_document_entity.dart';
import '../models/legal_document_model.dart';

abstract class ILegalRemoteDataSource {
  Future<LegalDocumentModel> getLegalDocument(LegalDocumentType type);
  Future<String> getLatestVersion(LegalDocumentType type);
}

class LegalRemoteDataSource implements ILegalRemoteDataSource {

  LegalRemoteDataSource({required this.firestore});
  final FirebaseFirestore firestore;

  @override
  Future<LegalDocumentModel> getLegalDocument(LegalDocumentType type) async {
    final typeStr = _typeToString(type);
    final doc = await firestore.collection('legal_documents').doc(typeStr).get();

    if (!doc.exists) {
      throw const ServerException('Document not found');
    }

    return LegalDocumentModel.fromJson(doc.data()!);
  }

  @override
  Future<String> getLatestVersion(LegalDocumentType type) async {
    final typeStr = _typeToString(type);
    final doc = await firestore.collection('legal_documents').doc(typeStr).get();

    if (!doc.exists) {
      throw const ServerException('Version not found');
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
