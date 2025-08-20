// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../interfaces/i_auth_service.dart';
import '../interfaces/i_subscription_service.dart';

/// Rotas principais do app
class AppRoutes {
  // Auth
  static const String login = '/login';
  static const String enhancedLogin = '/enhanced-login';
  static const String loginWeb = '/login-web';
  
  // Home
  static const String home = '/home';
  static const String desktop = '/desktop';
  static const String mobile = '/mobile';
  
  // Pet Management
  static const String animalPage = '/animal';
  static const String animalForm = '/animal/form';
  static const String consultaPage = '/consulta';
  static const String consultaForm = '/consulta/form';
  static const String despesaPage = '/despesa';
  static const String despesaForm = '/despesa/form';
  static const String medicamentoPage = '/medicamento';
  static const String medicamentoForm = '/medicamento/form';
  static const String vacinaPage = '/vacina';
  static const String vacinaForm = '/vacina/form';
  static const String lembreteePage = '/lembrete';
  static const String lembreteForm = '/lembrete/form';
  static const String pesoPage = '/peso';
  static const String pesoForm = '/peso/form';
  
  // Calculators
  static const String calculadoras = '/calculadoras';
  static const String conversao = '/calc/conversao';
  static const String idadeAnimal = '/calc/idade-animal';
  static const String fluidoterapia = '/calc/fluidoterapia';
  static const String gestacao = '/calc/gestacao';
  static const String dosagemAnestesico = '/calc/dosagem-anestesico';
  static const String condicaoCorporal = '/calc/condicao-corporal';
  static const String gestacaoParto = '/calc/gestacao-parto';
  static const String hidratacaoFluidoterapia = '/calc/hidratacao-fluidoterapia';
  static const String pesoIdealCondicaoCorporal = '/calc/peso-ideal-condicao-corporal';
  static const String necessidadeCalorias = '/calc/necessidade-calorias';
  static const String dietaCaseira = '/calc/dieta-caseira';
  static const String diabetesInsulina = '/calc/diabetes-insulina';
  static const String dosagemMedicamento = '/calc/dosagem-medicamento';
  
  // Breeds
  static const String racasSeletor = '/racas/seletor';
  static const String racasLista = '/racas/lista';
  static const String racasDetalhes = '/racas/detalhes';
  
  // Medications
  static const String listaMedicamento = '/medicamentos/lista';
  
  // Dashboard & Reports
  static const String dashboard = '/dashboard';
  
  // Settings & Config
  static const String options = '/options';
  static const String database = '/database';
  static const String atualizacoes = '/atualizacoes';
  static const String sobre = '/sobre';
  static const String more = '/more';
  
  // Subscription & Premium
  static const String premium = '/premium';
  static const String subscription = '/subscription';
  static const String promo = '/promo';
}

/// Gerenciador centralizado de rotas usando GetX
/// Substitui o uso misto de Navigator e Get por navegação consistente
class RouteManager {
  static RouteManager? _instance;
  static RouteManager get instance => _instance ??= RouteManager._();
  RouteManager._();

  /// Configurações de transição padrão
  static const Duration defaultTransitionDuration = Duration(milliseconds: 300);
  static const Transition defaultTransition = Transition.cupertino;

  /// Navegar para tela com verificação de autenticação
  void toWithAuth(
    String route, {
    dynamic arguments,
    bool requiresPremium = false,
    Transition? transition,
    Duration? duration,
  }) {
    if (_checkAuth(requiresPremium)) {
      Get.toNamed(
        route,
        arguments: arguments,
      );
    }
  }

  /// Navegar substituindo a tela atual
  void offWithAuth(
    String route, {
    dynamic arguments,
    bool requiresPremium = false,
    Transition? transition,
    Duration? duration,
  }) {
    if (_checkAuth(requiresPremium)) {
      Get.offNamed(
        route,
        arguments: arguments,
      );
    }
  }

  /// Navegar removendo todas as telas do stack
  void offAllWithAuth(
    String route, {
    dynamic arguments,
    bool requiresPremium = false,
    Transition? transition,
    Duration? duration,
  }) {
    if (_checkAuth(requiresPremium)) {
      Get.offAllNamed(
        route,
        arguments: arguments,
      );
    }
  }

  /// Navegação simples sem verificações
  void to(
    dynamic page, {
    dynamic arguments,
    Transition? transition,
    Duration? duration,
  }) {
    Get.to(
      page,
      arguments: arguments,
      transition: transition ?? defaultTransition,
      duration: duration ?? defaultTransitionDuration,
    );
  }

  /// Substituir tela atual sem verificações
  void off(
    dynamic page, {
    dynamic arguments,
    Transition? transition,
    Duration? duration,
  }) {
    Get.off(
      page,
      arguments: arguments,
      transition: transition ?? defaultTransition,
      duration: duration ?? defaultTransitionDuration,
    );
  }

  /// Limpar stack e navegar
  void offAll(
    dynamic page, {
    dynamic arguments,
    Transition? transition,
    Duration? duration,
  }) {
    Get.offAll(
      page,
      arguments: arguments,
      transition: transition ?? defaultTransition,
      duration: duration ?? defaultTransitionDuration,
    );
  }

  /// Voltar para tela anterior
  void back({dynamic result}) {
    if (Navigator.canPop(Get.context!)) {
      Get.back(result: result);
    }
  }

  /// Mostrar dialog
  Future<T?> showDialog<T>(
    Widget dialog, {
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    return Get.dialog<T>(
      dialog,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
    );
  }

  /// Mostrar bottom sheet
  Future<T?> showBottomSheet<T>(
    Widget bottomSheet, {
    bool isScrollControlled = false,
    bool enableDrag = true,
  }) {
    return Get.bottomSheet<T>(
      bottomSheet,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
    );
  }

  /// Mostrar snackbar
  void showSnackbar(
    String title,
    String message, {
    Color? backgroundColor,
    Color? colorText,
    Duration? duration,
    SnackPosition? snackPosition,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: colorText,
      duration: duration ?? const Duration(seconds: 3),
      snackPosition: snackPosition ?? SnackPosition.BOTTOM,
    );
  }

  /// Navegação para login quando não autenticado
  void toLogin() {
    Get.offAllNamed(AppRoutes.login);
  }

  /// Navegação para planos premium
  void toPremiumPlans() {
    Get.toNamed(AppRoutes.premium);
  }

  /// Verificar autenticação e premium
  bool _checkAuth(bool requiresPremium) {
    try {
      final authService = Get.find<IAuthService>();
      
      if (!authService.isLoggedIn) {
        showSnackbar(
          'Acesso Negado',
          'Você precisa estar logado para acessar esta funcionalidade',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        toLogin();
        return false;
      }
      
      if (requiresPremium) {
        final subscriptionService = Get.find<ISubscriptionService>();
        if (!subscriptionService.isPremium) {
          showSnackbar(
            'Premium Necessário',
            'Esta funcionalidade é exclusiva para usuários Premium',
            backgroundColor: Colors.amber,
            colorText: Colors.white,
          );
          toPremiumPlans();
          return false;
        }
      }
      
      return true;
    } catch (e) {
      showSnackbar(
        'Erro',
        'Erro ao verificar autenticação: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// Métodos de conveniência para rotas específicas
  
  void toAnimalPage() => Get.toNamed(AppRoutes.animalPage);
  void toAnimalForm({dynamic arguments}) => Get.toNamed(AppRoutes.animalForm, arguments: arguments);
  
  void toConsultaPage() => Get.toNamed(AppRoutes.consultaPage);
  void toConsultaForm({dynamic arguments}) => Get.toNamed(AppRoutes.consultaForm, arguments: arguments);
  
  void toDespesaPage() => Get.toNamed(AppRoutes.despesaPage);
  void toDespesaForm({dynamic arguments}) => Get.toNamed(AppRoutes.despesaForm, arguments: arguments);
  
  void toMedicamentoPage() => Get.toNamed(AppRoutes.medicamentoPage);
  void toMedicamentoForm({dynamic arguments}) => Get.toNamed(AppRoutes.medicamentoForm, arguments: arguments);
  
  void toVacinaPage() => Get.toNamed(AppRoutes.vacinaPage);
  void toVacinaForm({dynamic arguments}) => Get.toNamed(AppRoutes.vacinaForm, arguments: arguments);
  
  void toLembretePage() => Get.toNamed(AppRoutes.lembreteePage);
  void toLembreteForm({dynamic arguments}) => Get.toNamed(AppRoutes.lembreteForm, arguments: arguments);
  
  void toPesoPage() => Get.toNamed(AppRoutes.pesoPage);
  void toPesoForm({dynamic arguments}) => Get.toNamed(AppRoutes.pesoForm, arguments: arguments);
  
  void toCalculadoras() => Get.toNamed(AppRoutes.calculadoras);
  void toDashboard() => Get.toNamed(AppRoutes.dashboard);
  void toOptions() => Get.toNamed(AppRoutes.options);
  void toRacasSeletor() => Get.toNamed(AppRoutes.racasSeletor);
  void toListaMedicamento() => Get.toNamed(AppRoutes.listaMedicamento);
}
