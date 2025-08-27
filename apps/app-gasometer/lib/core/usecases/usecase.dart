import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../constants/ui_constants.dart';
import '../error/failures.dart';

/// Base class for all use cases
/// 
/// [Type] is the return type
/// [Params] is the input parameters type
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case for operations that don't require parameters
abstract class NoParamsUseCase<Type> {
  Future<Either<Failure, Type>> call();
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
  final String featureId;
  
  const CanUseFeatureParams({required this.featureId});
  
  @override
  List<Object> get props => [featureId];
}

/// Parâmetros para verificar limite de veículos
class CanAddVehicleParams extends UseCaseParams {
  final int currentCount;
  
  const CanAddVehicleParams({required this.currentCount});
  
  @override
  List<Object> get props => [currentCount];
}

/// Parâmetros para verificar limite de registros de combustível
class CanAddFuelRecordParams extends UseCaseParams {
  final int currentCount;
  
  const CanAddFuelRecordParams({required this.currentCount});
  
  @override
  List<Object> get props => [currentCount];
}

/// Parâmetros para verificar limite de registros de manutenção
class CanAddMaintenanceRecordParams extends UseCaseParams {
  final int currentCount;
  
  const CanAddMaintenanceRecordParams({required this.currentCount});
  
  @override
  List<Object> get props => [currentCount];
}

/// Parâmetros para compra de premium
class PurchasePremiumParams extends UseCaseParams {
  final String productId;
  
  const PurchasePremiumParams({required this.productId});
  
  @override
  List<Object> get props => [productId];
}

/// Parâmetros para gerar licença local
class GenerateLocalLicenseParams extends UseCaseParams {
  final int days;
  
  const GenerateLocalLicenseParams({this.days = AppDefaults.defaultLicenseDays});
  
  @override
  List<Object> get props => [days];
}