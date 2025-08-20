// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../models/pluviometros_models.dart';
import '../services/id_generation_service.dart';
import '../services/performance_optimization_service.dart';
import '../services/pluviometro_business_service.dart';
import '../services/pluviometro_repository_service.dart';
import '../utils/type_conversion_utils.dart';

class PluviometroCadastroController {
  final formKey = GlobalKey<FormState>();
  String descricao = '';
  double quantidade = 0.0;
  late final TextEditingController quantidadeController;

  // Serviços injetados
  final PluviometroBusinessService _businessService;
  final IPluviometroRepository _repository;
  final IdGenerationService _idService;

  PluviometroCadastroController({
    PluviometroBusinessService? businessService,
    IPluviometroRepository? repository,
    IdGenerationService? idService,
  })  : _businessService = businessService ?? PluviometroBusinessService(),
        _repository = repository ?? PluviometroRepositoryService(),
        _idService = idService ??
            IdGenerationService(
              repository: repository ?? PluviometroRepositoryService(),
            ) {
    // Inicialização otimizada do controller
    quantidadeController = PerformanceOptimizationService.getOrCreateController(
      'quantidade_$hashCode',
      initialValue: '0.00',
    );
  }

  void init(Pluviometro? pluviometro) {
    if (pluviometro != null) {
      descricao = pluviometro.descricao;

      // Conversão lazy otimizada
      final cacheKey = 'quantidade_${pluviometro.id}';
      quantidade = PerformanceOptimizationService.lazyDoubleConversion(
        pluviometro.quantidade,
        cacheKey,
      );
    }

    // Formatação lazy otimizada
    final formattedValue = PerformanceOptimizationService.lazyFormatting(
      quantidade,
      'format_quantidade_$hashCode',
      () => TypeConversionUtils.doubleToString(quantidade),
    );

    quantidadeController.text = formattedValue;
  }

  Future<bool> submit(BuildContext context, Pluviometro? pluviometro) async {
    if (!formKey.currentState!.validate()) return false;

    formKey.currentState!.save();

    try {
      Pluviometro newPluviometro;

      if (pluviometro != null) {
        // Atualização
        newPluviometro = _businessService.updatePluviometro(
          original: pluviometro,
          descricao: descricao,
          quantidade: quantidade,
          latitude: pluviometro.latitude,
          longitude: pluviometro.longitude,
          fkGrupo: pluviometro.fkGrupo,
        );
      } else {
        // Criação
        final id = await _idService.generateSecureId();
        newPluviometro = await _businessService.createNewPluviometro(
          id: id,
          descricao: descricao,
          quantidade: quantidade,
        );
      }

      // Validação de negócio
      final validation = _businessService.validatePluviometro(newPluviometro);
      if (!validation.isValid) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(validation.errorMessage)),
          );
        }
        return false;
      }

      // Persistência
      if (pluviometro != null) {
        await _repository.updatePluviometro(newPluviometro);
      } else {
        await _repository.addPluviometro(newPluviometro);
      }

      return true;
    } catch (e) {
      // Verificar se o context ainda está montado antes de usar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar pluviômetro: $e')),
        );
      }
      return false;
    }
  }

  void dispose() {
    // Libera o controller otimizado
    PerformanceOptimizationService.releaseController('quantidade_$hashCode');

    // Limpeza automática de cache
    PerformanceOptimizationService.autoCleanupCache();
  }
}
