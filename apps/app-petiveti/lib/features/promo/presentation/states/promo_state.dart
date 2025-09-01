import 'package:equatable/equatable.dart';

import '../../domain/entities/promo_content.dart';

class PromoState extends Equatable {
  final bool isLoading;
  final bool isSubmittingPreRegistration;
  final bool preRegistrationSuccess;
  final bool showPreRegistrationDialog;
  final PromoContent? promoContent;
  final String? error;
  final String? preRegistrationError;
  final int currentScreenshotIndex;

  const PromoState({
    required this.isLoading,
    required this.isSubmittingPreRegistration,
    required this.preRegistrationSuccess,
    required this.showPreRegistrationDialog,
    this.promoContent,
    this.error,
    this.preRegistrationError,
    required this.currentScreenshotIndex,
  });

  const PromoState.initial()
      : this(
          isLoading: false,
          isSubmittingPreRegistration: false,
          preRegistrationSuccess: false,
          showPreRegistrationDialog: false,
          promoContent: null,
          error: null,
          preRegistrationError: null,
          currentScreenshotIndex: 0,
        );

  PromoState copyWith({
    bool? isLoading,
    bool? isSubmittingPreRegistration,
    bool? preRegistrationSuccess,
    bool? showPreRegistrationDialog,
    PromoContent? promoContent,
    String? error,
    String? preRegistrationError,
    int? currentScreenshotIndex,
  }) {
    return PromoState(
      isLoading: isLoading ?? this.isLoading,
      isSubmittingPreRegistration: isSubmittingPreRegistration ?? this.isSubmittingPreRegistration,
      preRegistrationSuccess: preRegistrationSuccess ?? this.preRegistrationSuccess,
      showPreRegistrationDialog: showPreRegistrationDialog ?? this.showPreRegistrationDialog,
      promoContent: promoContent ?? this.promoContent,
      error: error,
      preRegistrationError: preRegistrationError,
      currentScreenshotIndex: currentScreenshotIndex ?? this.currentScreenshotIndex,
    );
  }

  bool get hasError => error != null;
  bool get hasPreRegistrationError => preRegistrationError != null;
  bool get hasContent => promoContent != null;

  @override
  List<Object?> get props => [
        isLoading,
        isSubmittingPreRegistration,
        preRegistrationSuccess,
        showPreRegistrationDialog,
        promoContent,
        error,
        preRegistrationError,
        currentScreenshotIndex,
      ];
}