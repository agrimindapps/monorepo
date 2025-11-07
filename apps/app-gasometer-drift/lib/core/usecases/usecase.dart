import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Equatable;
import 'package:dartz/dartz.dart';

import '../constants/ui_constants.dart';

/// Base class for all use cases
///
/// [Type] is the return type
/// [Params] is the input parameters type
abstract class UseCase<Type, Params> {
  Future<Either<core.Failure, Type>> call(Params params);
}

/// Use case for operations that don't require parameters
abstract class NoParamsUseCase<Type> {
  Future<Either<core.Failure, Type>> call();
}

/// Base class for use case parameters
abstract class UseCaseParams extends Equatable {
  const UseCaseParams();
}

/// Empty parameters for use cases that don't need params
class NoParams extends UseCaseParams {
  const NoParams();

  @override
  List<Object> get props => [];
}

/// Parâmetros para verificar features
class CanUseFeatureParams extends UseCaseParams {
  const CanUseFeatureParams({required this.featureId});
  final String featureId;

  @override
  List<Object> get props => [featureId];
}

/// Parâmetros para verificar limite de veículos
class CanAddVehicleParams extends UseCaseParams {
  const CanAddVehicleParams({required this.currentCount});
  final int currentCount;

  @override
  List<Object> get props => [currentCount];
}

/// Parâmetros para verificar limite de registros de combustível
class CanAddFuelRecordParams extends UseCaseParams {
  const CanAddFuelRecordParams({required this.currentCount});
  final int currentCount;

  @override
  List<Object> get props => [currentCount];
}

/// Parâmetros para verificar limite de registros de manutenção
class CanAddMaintenanceRecordParams extends UseCaseParams {
  const CanAddMaintenanceRecordParams({required this.currentCount});
  final int currentCount;

  @override
  List<Object> get props => [currentCount];
}

/// Parâmetros para compra de premium
class PurchasePremiumParams extends UseCaseParams {
  const PurchasePremiumParams({required this.productId});
  final String productId;

  @override
  List<Object> get props => [productId];
}

/// Parâmetros para gerar licença local
class GenerateLocalLicenseParams extends UseCaseParams {
  const GenerateLocalLicenseParams({
    this.days = AppDefaults.defaultLicenseDays,
  });
  final int days;

  @override
  List<Object> get props => [days];
}
