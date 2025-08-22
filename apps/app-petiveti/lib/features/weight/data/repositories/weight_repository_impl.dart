import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/weight.dart';
import '../../domain/repositories/weight_repository.dart';
import '../datasources/weight_local_datasource.dart';
import '../models/weight_model.dart';

class WeightRepositoryImpl implements WeightRepository {
  final WeightLocalDataSource localDataSource;

  WeightRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Weight>>> getWeights() async {
    try {
      final weightModels = await localDataSource.getWeights();
      final weights = weightModels.map((model) => model.toEntity()).toList();
      return Right(weights);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar registros de peso: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Weight>>> getWeightsByAnimalId(String animalId) async {
    try {
      final weightModels = await localDataSource.getWeightsByAnimalId(animalId);
      final weights = weightModels.map((model) => model.toEntity()).toList();
      return Right(weights);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar registros de peso do animal: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Weight?>> getLatestWeightByAnimalId(String animalId) async {
    try {
      final weightModel = await localDataSource.getLatestWeightByAnimalId(animalId);
      if (weightModel == null) {
        return const Right(null);
      }
      return Right(weightModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar último peso: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Weight>> getWeightById(String id) async {
    try {
      final weightModel = await localDataSource.getWeightById(id);
      if (weightModel == null) {
        return Left(CacheFailure(message: 'Registro de peso não encontrado'));
      }
      return Right(weightModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar registro de peso: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> addWeight(Weight weight) async {
    try {
      final weightModel = WeightModel.fromEntity(weight);
      await localDataSource.cacheWeight(weightModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao adicionar registro de peso: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateWeight(Weight weight) async {
    try {
      final weightModel = WeightModel.fromEntity(weight);
      await localDataSource.updateWeight(weightModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao atualizar registro de peso: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> hardDeleteWeight(String id) async {
    try {
      await localDataSource.hardDeleteWeight(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao excluir permanentemente registro de peso: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Weight>>> searchWeights(
    String animalId, {
    double? minWeight,
    double? maxWeight,
    DateTime? startDate,
    DateTime? endDate,
    int? bodyConditionScore,
  }) async {
    try {
      // Get all weights for the animal first
      final weightModels = await localDataSource.getWeightsByAnimalId(animalId);
      
      // Apply filters
      var filteredModels = weightModels.where((model) {
        final weight = model.toEntity();
        
        if (minWeight != null && weight.weight < minWeight) return false;
        if (maxWeight != null && weight.weight > maxWeight) return false;
        if (startDate != null && weight.date.isBefore(startDate)) return false;
        if (endDate != null && weight.date.isAfter(endDate)) return false;
        if (bodyConditionScore != null && weight.bodyConditionScore != bodyConditionScore) return false;
        
        return true;
      }).toList();
      
      final weights = filteredModels.map((model) => model.toEntity()).toList();
      return Right(weights);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar registros de peso: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWeight(String id) async {
    try {
      await localDataSource.deleteWeight(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao excluir registro de peso: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Weight>>> getWeightHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final weightModels = await localDataSource.getWeightHistory(
        animalId,
        startDate,
        endDate,
      );
      final weights = weightModels.map((model) => model.toEntity()).toList();
      return Right(weights);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar histórico de peso: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, WeightStatistics>> getWeightStatistics(String animalId) async {
    try {
      final weightModels = await localDataSource.getWeightsByAnimalId(animalId);
      final weights = weightModels.map((model) => model.toEntity()).toList();
      
      if (weights.isEmpty) {
        return const Right(WeightStatistics(totalRecords: 0));
      }
      
      weights.sort((a, b) => a.date.compareTo(b.date));
      
      final currentWeight = weights.last.weight;
      final averageWeight = weights.map((w) => w.weight).reduce((a, b) => a + b) / weights.length;
      final minWeight = weights.map((w) => w.weight).reduce((a, b) => a < b ? a : b);
      final maxWeight = weights.map((w) => w.weight).reduce((a, b) => a > b ? a : b);
      final totalWeightChange = weights.length > 1 ? weights.last.weight - weights.first.weight : 0.0;
      
      // Calculate overall trend
      WeightTrend? overallTrend;
      if (weights.length >= 2) {
        final firstHalf = weights.take(weights.length ~/ 2).map((w) => w.weight).reduce((a, b) => a + b) / (weights.length ~/ 2);
        final secondHalf = weights.skip(weights.length ~/ 2).map((w) => w.weight).reduce((a, b) => a + b) / (weights.length - weights.length ~/ 2);
        
        if (secondHalf > firstHalf + 0.1) {
          overallTrend = WeightTrend.gaining;
        } else if (secondHalf < firstHalf - 0.1) {
          overallTrend = WeightTrend.losing;
        } else {
          overallTrend = WeightTrend.stable;
        }
      }
      
      // Calculate body condition distribution
      final bodyConditionDistribution = <BodyCondition, int>{};
      for (final weight in weights) {
        final condition = weight.bodyCondition;
        bodyConditionDistribution[condition] = (bodyConditionDistribution[condition] ?? 0) + 1;
      }
      
      final statistics = WeightStatistics(
        currentWeight: currentWeight,
        averageWeight: averageWeight,
        minWeight: minWeight,
        maxWeight: maxWeight,
        overallTrend: overallTrend,
        totalWeightChange: totalWeightChange,
        averageWeightChange: weights.length > 1 ? totalWeightChange / (weights.length - 1) : 0.0,
        totalRecords: weights.length,
        firstRecordDate: weights.first.date,
        lastRecordDate: weights.last.date,
        bodyConditionDistribution: bodyConditionDistribution,
      );
      
      return Right(statistics);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar estatísticas de peso: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, WeightTrendAnalysis>> analyzeWeightTrend(
    String animalId, {
    int periodInDays = 90,
  }) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: periodInDays));
      
      final weightModels = await localDataSource.getWeightHistory(animalId, startDate, now);
      final weights = weightModels.map((model) => model.toEntity()).toList();
      
      if (weights.length < 2) {
        return Right(WeightTrendAnalysis(
          trend: WeightTrend.stable,
          trendStrength: 0.0,
          dataPoints: weights.map((w) => WeightPoint(
            date: w.date,
            weight: w.weight,
            bodyConditionScore: w.bodyConditionScore,
          )).toList(),
        ));
      }
      
      weights.sort((a, b) => a.date.compareTo(b.date));
      
      // Calculate trend using simple linear regression
      final n = weights.length.toDouble();
      final sumX = weights.asMap().entries.map((e) => e.key.toDouble()).reduce((a, b) => a + b);
      final sumY = weights.map((w) => w.weight).reduce((a, b) => a + b);
      final sumXY = weights.asMap().entries.map((e) => e.key.toDouble() * e.value.weight).reduce((a, b) => a + b);
      final sumX2 = weights.asMap().entries.map((e) => (e.key.toDouble() * e.key.toDouble())).reduce((a, b) => a + b);
      
      final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
      
      final trend = slope > 0.01 ? WeightTrend.gaining : 
                   slope < -0.01 ? WeightTrend.losing : WeightTrend.stable;
      
      final trendStrength = (slope.abs() / weights.first.weight).clamp(0.0, 1.0);
      
      final dataPoints = weights.map((w) => WeightPoint(
        date: w.date,
        weight: w.weight,
        bodyConditionScore: w.bodyConditionScore,
      )).toList();
      
      // Simple projections
      final daysTo30 = 30.0;
      final daysTo90 = 90.0;
      final lastWeight = weights.last.weight;
      
      final projectedWeightIn30Days = lastWeight + (slope * daysTo30);
      final projectedWeightIn90Days = lastWeight + (slope * daysTo90);
      
      // Generate recommendations and alerts
      final recommendations = <String>[];
      final alerts = <String>[];
      
      if (trend == WeightTrend.gaining && trendStrength > 0.5) {
        recommendations.add('Considere ajustar a dieta para controlar o ganho de peso');
        if (trendStrength > 0.8) {
          alerts.add('Ganho de peso acelerado detectado');
        }
      } else if (trend == WeightTrend.losing && trendStrength > 0.5) {
        recommendations.add('Monitore a alimentação e considere consultar um veterinário');
        if (trendStrength > 0.8) {
          alerts.add('Perda de peso acelerada detectada');
        }
      }
      
      return Right(WeightTrendAnalysis(
        trend: trend,
        trendStrength: trendStrength,
        dataPoints: dataPoints,
        projectedWeightIn30Days: projectedWeightIn30Days,
        projectedWeightIn90Days: projectedWeightIn90Days,
        recommendations: recommendations,
        alerts: alerts,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao analisar tendência de peso: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Weight>>> getAbnormalWeightChanges(
    String animalId, {
    double thresholdPercentage = 10.0,
    int timeFrameDays = 30,
  }) async {
    try {
      final weightModels = await localDataSource.getWeightsByAnimalId(animalId);
      final weights = weightModels.map((model) => model.toEntity()).toList();
      
      if (weights.length < 2) return const Right([]);
      
      weights.sort((a, b) => a.date.compareTo(b.date));
      
      final abnormalChanges = <Weight>[];
      
      for (int i = 1; i < weights.length; i++) {
        final current = weights[i];
        final previous = weights[i - 1];
        
        final daysDifference = current.date.difference(previous.date).inDays;
        if (daysDifference > timeFrameDays) continue;
        
        final percentageChange = ((current.weight - previous.weight) / previous.weight * 100).abs();
        
        if (percentageChange >= thresholdPercentage) {
          abnormalChanges.add(current);
        }
      }
      
      return Right(abnormalChanges);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar mudanças anormais de peso: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> exportWeightData() async {
    try {
      final weightModels = await localDataSource.getWeights();
      final data = weightModels.map((model) => model.toJson()).toList();
      return Right(data);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao exportar dados de peso: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> importWeightData(List<Map<String, dynamic>> data) async {
    try {
      final weightModels = data.map((json) => WeightModel.fromJson(json)).toList();
      await localDataSource.cacheWeights(weightModels);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao importar dados de peso: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getWeightRecordsCount(String animalId) async {
    try {
      final count = await localDataSource.getWeightsCount(animalId);
      return Right(count);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao contar registros de peso: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, double?>> calculateAnimalBMI(String animalId) async {
    try {
      // BMI calculation for animals is not standard, return null for now
      // This could be implemented with specific formulas for dogs/cats if needed
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao calcular IMC animal: ${e.toString()}'));
    }
  }

  @override
  Stream<List<Weight>> watchWeights() {
    return localDataSource.watchWeights().map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Stream<List<Weight>> watchWeightsByAnimalId(String animalId) {
    return localDataSource.watchWeightsByAnimalId(animalId).map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }
}