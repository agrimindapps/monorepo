// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../theme/agrihurbi_theme.dart';

/// Sistema de loading contextual para o módulo AgriHurbi
/// 
/// Oferece diferentes tipos de loading com mensagens contextuais
/// e shimmer effects para melhor UX
class AgrihurbiLoading {
  /// Loading circular simples com mensagem contextual
  static Widget circular({
    required String message,
    Color? color,
    double size = 24.0,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AgrihurbiTheme.agriculturaPrimary,
              ),
            ),
          ),
          const SizedBox(height: AgrihurbiTheme.space3),
          Text(
            message,
            style: AgrihurbiTheme.bodyMedium.copyWith(
              color: AgrihurbiTheme.mutedTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Loading circular com progresso (0.0 a 1.0)
  static Widget circularWithProgress({
    required String message,
    required double progress,
    Color? color,
    double size = 32.0,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              backgroundColor: AgrihurbiTheme.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AgrihurbiTheme.agriculturaPrimary,
              ),
            ),
          ),
          const SizedBox(height: AgrihurbiTheme.space3),
          Text(
            message,
            style: AgrihurbiTheme.bodyMedium.copyWith(
              color: AgrihurbiTheme.mutedTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AgrihurbiTheme.space2),
          Text(
            '${(progress * 100).toInt()}%',
            style: AgrihurbiTheme.labelSmall.copyWith(
              color: AgrihurbiTheme.mutedTextColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Loading linear para operações step-by-step
  static Widget linear({
    required String message,
    double? progress,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AgrihurbiTheme.space4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: AgrihurbiTheme.bodyMedium.copyWith(
              color: AgrihurbiTheme.mutedTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AgrihurbiTheme.space3),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AgrihurbiTheme.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AgrihurbiTheme.agriculturaPrimary,
            ),
            borderRadius: AgrihurbiTheme.radiusSmall,
          ),
        ],
      ),
    );
  }

  /// Loading específico para salvamento
  static Widget saving() {
    return circular(
      message: 'Salvando dados...',
      color: AgrihurbiTheme.successColor,
    );
  }

  /// Loading específico para carregamento de dados
  static Widget loading({String? customMessage}) {
    return circular(
      message: customMessage ?? 'Carregando dados...',
      color: AgrihurbiTheme.agriculturaPrimary,
    );
  }

  /// Loading específico para sincronização
  static Widget syncing() {
    return circular(
      message: 'Sincronizando...',
      color: AgrihurbiTheme.infoColor,
    );
  }

  /// Loading específico para upload
  static Widget uploading({double? progress}) {
    if (progress != null) {
      return circularWithProgress(
        message: 'Enviando imagem...',
        progress: progress,
        color: AgrihurbiTheme.warningColor,
      );
    }
    return circular(
      message: 'Enviando imagem...',
      color: AgrihurbiTheme.warningColor,
    );
  }

  /// Loading específico para exclusão
  static Widget deleting() {
    return circular(
      message: 'Removendo...',
      color: AgrihurbiTheme.errorColor,
      size: 20,
    );
  }

  /// Loading específico para bovinos
  static Widget loadingBovinos() {
    return circular(
      message: 'Carregando rebanho...',
      color: AgrihurbiTheme.animalPrimary,
    );
  }

  /// Loading específico para equinos
  static Widget loadingEquinos() {
    return circular(
      message: 'Carregando cavalos...',
      color: AgrihurbiTheme.animalPrimary,
    );
  }

  /// Loading específico para medições
  static Widget loadingMedicoes() {
    return circular(
      message: 'Carregando medições...',
      color: AgrihurbiTheme.rainColor,
    );
  }

  /// Loading específico para pluviômetros
  static Widget loadingPluviometros() {
    return circular(
      message: 'Carregando pluviômetros...',
      color: AgrihurbiTheme.rainColor,
    );
  }

  /// Loading específico para cálculos
  static Widget calculating() {
    return circular(
      message: 'Calculando...',
      color: AgrihurbiTheme.calculatorPrimary,
    );
  }

  /// Loading específico para clima
  static Widget loadingWeather() {
    return circular(
      message: 'Carregando previsão...',
      color: AgrihurbiTheme.infoColor,
    );
  }

  /// Loading específico para commodities
  static Widget loadingCommodities() {
    return circular(
      message: 'Atualizando preços...',
      color: AgrihurbiTheme.warningColor,
    );
  }

  /// Loading específico para notícias
  static Widget loadingNews() {
    return circular(
      message: 'Carregando notícias...',
      color: AgrihurbiTheme.infoColor,
    );
  }
}

/// Widget de loading com placeholder para listas
class AgrihurbiPlaceholder {
  /// Placeholder simples para cards de lista
  static Widget listCard({
    double height = 80.0,
    bool showAvatar = false,
  }) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(
        horizontal: AgrihurbiTheme.space4,
        vertical: AgrihurbiTheme.space2,
      ),
      decoration: AgrihurbiTheme.cardDecoration.copyWith(
        color: AgrihurbiTheme.borderColor.withValues(alpha: 0.1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AgrihurbiTheme.space3),
        child: Row(
          children: [
            if (showAvatar) ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AgrihurbiTheme.borderColor.withValues(alpha: 0.3),
                  borderRadius: AgrihurbiTheme.radiusFull,
                ),
              ),
              const SizedBox(width: AgrihurbiTheme.space3),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AgrihurbiTheme.borderColor.withValues(alpha: 0.3),
                      borderRadius: AgrihurbiTheme.radiusSmall,
                    ),
                  ),
                  const SizedBox(height: AgrihurbiTheme.space2),
                  Container(
                    height: 10,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AgrihurbiTheme.borderColor.withValues(alpha: 0.2),
                      borderRadius: AgrihurbiTheme.radiusSmall,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AgrihurbiTheme.borderColor.withValues(alpha: 0.3),
                borderRadius: AgrihurbiTheme.radiusSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Placeholder para lista de bovinos/equinos
  static Widget animalList() {
    return Column(
      children: List.generate(
        5,
        (index) => listCard(
          height: 120,
          showAvatar: true,
        ),
      ),
    );
  }

  /// Placeholder para lista de medições
  static Widget medicoesList() {
    return Column(
      children: List.generate(
        8,
        (index) => listCard(height: 60),
      ),
    );
  }

  /// Placeholder para cards de estatísticas
  static Widget statisticsCards() {
    return Padding(
      padding: const EdgeInsets.all(AgrihurbiTheme.space4),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: 2,
        mainAxisSpacing: AgrihurbiTheme.space3,
        crossAxisSpacing: AgrihurbiTheme.space3,
        children: List.generate(4, (index) {
          return Container(
            decoration: BoxDecoration(
              color: AgrihurbiTheme.borderColor.withValues(alpha: 0.1),
              borderRadius: AgrihurbiTheme.radiusMedium,
            ),
          );
        }),
      ),
    );
  }

  /// Placeholder para gráficos
  static Widget chart({double height = 200}) {
    return Container(
      height: height,
      margin: const EdgeInsets.all(AgrihurbiTheme.space4),
      decoration: BoxDecoration(
        color: AgrihurbiTheme.borderColor.withValues(alpha: 0.1),
        borderRadius: AgrihurbiTheme.radiusMedium,
      ),
      child: Center(
        child: Icon(
          Icons.bar_chart,
          size: 48,
          color: AgrihurbiTheme.mutedTextColor,
        ),
      ),
    );
  }
}

/// Widget overlay de loading que cobre toda a tela
class AgrihurbiLoadingOverlay extends StatelessWidget {
  final String message;
  final bool isVisible;
  final Widget child;
  final Color? backgroundColor;

  const AgrihurbiLoadingOverlay({
    super.key,
    required this.message,
    required this.isVisible,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isVisible)
          Container(
            color: (backgroundColor ?? Colors.black).withValues(alpha: 0.5),
            child: AgrihurbiLoading.circular(message: message),
          ),
      ],
    );
  }
}

/// Estados de loading específicos para diferentes contextos
enum LoadingContext {
  saving,
  loading,
  syncing,
  uploading,
  deleting,
  calculating,
  bovinos,
  equinos,
  medicoes,
  pluviometros,
  weather,
  commodities,
  news,
}

/// Extension para facilitar o uso dos loadings
extension LoadingContextWidget on LoadingContext {
  Widget get widget {
    switch (this) {
      case LoadingContext.saving:
        return AgrihurbiLoading.saving();
      case LoadingContext.loading:
        return AgrihurbiLoading.loading();
      case LoadingContext.syncing:
        return AgrihurbiLoading.syncing();
      case LoadingContext.uploading:
        return AgrihurbiLoading.uploading();
      case LoadingContext.deleting:
        return AgrihurbiLoading.deleting();
      case LoadingContext.calculating:
        return AgrihurbiLoading.calculating();
      case LoadingContext.bovinos:
        return AgrihurbiLoading.loadingBovinos();
      case LoadingContext.equinos:
        return AgrihurbiLoading.loadingEquinos();
      case LoadingContext.medicoes:
        return AgrihurbiLoading.loadingMedicoes();
      case LoadingContext.pluviometros:
        return AgrihurbiLoading.loadingPluviometros();
      case LoadingContext.weather:
        return AgrihurbiLoading.loadingWeather();
      case LoadingContext.commodities:
        return AgrihurbiLoading.loadingCommodities();
      case LoadingContext.news:
        return AgrihurbiLoading.loadingNews();
    }
  }
}