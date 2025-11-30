import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/promo_model.dart';

abstract class IPromoRemoteDataSource {
  Future<List<PromoModel>> getActivePromos();
  Future<PromoModel> getPromoById(String id);
}

class PromoRemoteDataSource implements IPromoRemoteDataSource {

  PromoRemoteDataSource({required this.firestore});
  final FirebaseFirestore firestore;

  @override
  Future<List<PromoModel>> getActivePromos() async {
    final now = DateTime.now();

    final snapshot = await firestore
        .collection('promos')
        .where('isActive', isEqualTo: true)
        .where('startDate', isLessThanOrEqualTo: now)
        .where('endDate', isGreaterThanOrEqualTo: now)
        .get();

    return snapshot.docs
        .map((doc) => PromoModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<PromoModel> getPromoById(String id) async {
    final doc = await firestore.collection('promos').doc(id).get();

    if (!doc.exists) {
      throw ServerException();
    }

    return PromoModel.fromJson(doc.data()!);
  }
}

class ServerException implements Exception {}
