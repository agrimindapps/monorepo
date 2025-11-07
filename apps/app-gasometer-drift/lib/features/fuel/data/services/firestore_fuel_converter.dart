import 'package:core/core.dart';

import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../domain/entities/fuel_record_entity.dart';
import '../models/fuel_supply_model.dart';

/// Serviço responsável por converter documentos Firestore de combustível
///
/// Isola a lógica de conversão de dados Firestore para entidades,
/// seguindo o princípio Single Responsibility.
@lazySingleton
class FirestoreFuelConverter {
  FirestoreFuelConverter();

  /// Converte DocumentSnapshot em FuelRecordEntity
  FuelRecordEntity? documentToEntity(DocumentSnapshot doc) {
    try {
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;

      // Adiciona ID ao mapa
      final dataWithId = {...data, 'id': doc.id};
      final model = FuelSupplyModel.fromFirebaseMap(dataWithId);

      return _modelToEntity(model);
    } catch (e) {
      // Log erro mas não quebra o fluxo
      return null;
    }
  }

  /// Converte lista de DocumentSnapshots em lista de entidades
  List<FuelRecordEntity> documentsToEntities(List<QueryDocumentSnapshot> docs) {
    final entities = <FuelRecordEntity>[];

    for (final doc in docs) {
      try {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final dataWithId = {...data, 'id': doc.id};
        final model = FuelSupplyModel.fromFirebaseMap(dataWithId);
        entities.add(_modelToEntity(model));
      } catch (e) {
        continue;
      }
    }

    return entities;
  }

  /// Converte FuelSupplyModel em FuelRecordEntity
  FuelRecordEntity _modelToEntity(FuelSupplyModel model) {
    return FuelRecordEntity(
      id: model.id,
      vehicleId: model.vehicleId,
      userId: model.userId,
      fuelType: FuelType.values[model.fuelType],
      liters: model.liters,
      pricePerLiter: model.pricePerLiter,
      totalPrice: model.totalPrice,
      odometer: model.odometer,
      date: DateTime.fromMillisecondsSinceEpoch(model.date),
      gasStationName: model.gasStationName,
      notes: model.notes,
      fullTank: model.fullTank ?? true,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Converte FuelRecordEntity em FuelSupplyModel
  FuelSupplyModel entityToModel(FuelRecordEntity entity, String userId) {
    return FuelSupplyModel.create(
      id: entity.id,
      userId: userId,
      vehicleId: entity.vehicleId,
      fuelType: entity.fuelType.index,
      liters: entity.liters,
      pricePerLiter: entity.pricePerLiter,
      totalPrice: entity.totalPrice,
      odometer: entity.odometer,
      date: entity.date.millisecondsSinceEpoch,
      gasStationName: entity.gasStationName,
      notes: entity.notes,
      fullTank: entity.fullTank,
    );
  }

  /// Converte FuelRecordEntity em mapa Firebase
  Map<String, dynamic> entityToFirebaseMap(
    FuelRecordEntity entity,
    String userId,
  ) {
    final model = entityToModel(entity, userId);
    return model.toFirebaseMap();
  }

  /// Valida se documento contém dados válidos de combustível
  bool isValidFuelDocument(DocumentSnapshot doc) {
    if (!doc.exists) return false;

    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return false;

    // Valida campos obrigatórios
    return data.containsKey('vehicle_id') &&
        data.containsKey('fuel_type') &&
        data.containsKey('liters') &&
        data.containsKey('price_per_liter') &&
        data.containsKey('total_cost') &&
        data.containsKey('date');
  }

  /// Extrai ID do usuário de um documento
  String? extractUserId(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      return data?['user_id'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Extrai ID do veículo de um documento
  String? extractVehicleId(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      return data?['vehicle_id'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Converte múltiplos modelos em entidades
  List<FuelRecordEntity> modelsToEntities(List<FuelSupplyModel> models) {
    return models.map(_modelToEntity).toList();
  }

  /// Verifica se dois registros são duplicados
  bool areDuplicates(FuelRecordEntity a, FuelRecordEntity b) {
    // Considera duplicado se mesmos dados em intervalo de 1 minuto
    final dateDiff = a.date.difference(b.date).abs();

    return a.vehicleId == b.vehicleId &&
        a.liters == b.liters &&
        a.totalPrice == b.totalPrice &&
        a.odometer == b.odometer &&
        dateDiff.inMinutes < 1;
  }
}
