// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../database/20_odometro_model.dart';
import '../../../../widgets/dialog_cadastro_widget.dart';
import '../bindings/odometro_cadastro_form_binding.dart';
import '../controller/odometro_cadastro_form_controller.dart';
import '../helpers/odometro_ui_helper.dart';
import '../models/odometro_constants.dart';
import '../views/odometro_cadastro_form_view.dart';

/// Função para abrir o dialog de cadastro/edição de odômetro
///
/// Agora usa binding adequado para gerenciar o lifecycle do controller
/// automaticamente, evitando vazamentos de memória e cleanup manual
Future<bool?> odometroCadastro(
  BuildContext context,
  OdometroCar? odometro,
) {
  debugPrint('🐛 [FUNCTION] odometroCadastro chamada - INÍCIO');
  debugPrint('🐛 [FUNCTION] Context: $context');
  debugPrint('🐛 [FUNCTION] Odômetro: $odometro');

  final formWidgetKey = GlobalKey<OdometroCadastroWrapperWidgetState>();
  debugPrint('🐛 [FUNCTION] FormWidgetKey criado: $formWidgetKey');

  // Inicializa o binding para garantir que o controller seja criado adequadamente
  debugPrint('🐛 [FUNCTION] Inicializando binding...');
  OdometroCadastroFormBinding().dependencies();
  debugPrint('🐛 [FUNCTION] Binding inicializado');

  return DialogCadastro.show(
    context: context,
    title: odometro == null ? 'Cadastrar Odômetro' : 'Editar Odômetro',
    formKey: formWidgetKey,
    maxHeight: OdometroConstants.dialogPreferredHeight,
    onSubmit: () {
      debugPrint('🐛 [DIALOG] onSubmit callback chamado!');
      debugPrint(
          '🐛 [DIALOG] formWidgetKey.currentState: ${formWidgetKey.currentState}');

      if (formWidgetKey.currentState != null) {
        final isLoading = formWidgetKey.currentState!.isLoading;
        debugPrint('🐛 [DIALOG] isLoading: $isLoading');

        if (!isLoading) {
          debugPrint(
              '🐛 [DIALOG] Chamando formWidgetKey.currentState!.submit()...');
          formWidgetKey.currentState!.submit();
        } else {
          debugPrint('🐛 [DIALOG] Não submetendo - já está loading');
        }
      } else {
        debugPrint('🐛 [DIALOG] ERRO: formWidgetKey.currentState é null!');
      }
    },
    disableSubmitWhen: () {
      final disabled = formWidgetKey.currentState?.isLoading ?? false;
      debugPrint('🐛 [DIALOG] disableSubmitWhen: $disabled');
      return disabled;
    },
    formWidget: (key) {
      debugPrint('🐛 [DIALOG] formWidget callback - key recebida: $key');
      debugPrint(
          '🐛 [DIALOG] formWidget callback - key == formWidgetKey: ${key == formWidgetKey}');
      return OdometroCadastroWrapperWidget(key: key, odometro: odometro);
    },
  );
}

/// Widget de cadastro de odômetro usando práticas modernas do GetX
///
/// Usa GetView para acessar automaticamente o controller, seguindo
/// as melhores práticas atuais do GetX sem gerenciamento manual
class OdometroCadastroWidget extends GetView<OdometroCadastroFormController> {
  final OdometroCar? odometro;

  const OdometroCadastroWidget({super.key, this.odometro});

  @override
  Widget build(BuildContext context) {
    return OdometroCadastroWrapperWidget(odometro: odometro);
  }
}

/// Wrapper widget para manter compatibilidade com DialogCadastro
///
/// Este widget mantém o estado necessário para a interface do DialogCadastro
/// enquanto usa GetView internamente para seguir práticas modernas
class OdometroCadastroWrapperWidget extends StatefulWidget {
  final OdometroCar? odometro;

  OdometroCadastroWrapperWidget({super.key, this.odometro}) {
    debugPrint(
        '🐛 [WRAPPER] Construtor chamado - key: $key, odometro: $odometro');
  }

  @override
  OdometroCadastroWrapperWidgetState createState() =>
      OdometroCadastroWrapperWidgetState();
}

/// State que agora apenas acessa o controller via Get.find
///
/// O controller é gerenciado automaticamente pelo binding, eliminando
/// a necessidade de cleanup manual e prevenindo vazamentos de memória
class OdometroCadastroWrapperWidgetState
    extends State<OdometroCadastroWrapperWidget> {
  late OdometroCadastroFormController _controller;

  @override
  void initState() {
    super.initState();
    debugPrint('🐛 [WIDGET] initState - INÍCIO');

    // Acessa o controller já registrado via binding
    debugPrint('🐛 [WIDGET] Procurando controller...');
    try {
      _controller = Get.find<OdometroCadastroFormController>();
      debugPrint('🐛 [WIDGET] Controller encontrado: ${_controller.hashCode}');
    } catch (e) {
      debugPrint('🐛 [WIDGET] ERRO ao encontrar controller: $e');
      rethrow;
    }

    // Configure UI callbacks to separate concerns
    _controller.onShowError = (title, message) {
      debugPrint('🐛 [WIDGET] onShowError chamado: $title - $message');
      OdometroUIHelper.showErrorDialog(title, message);
    };

    // Inicializa o formulário com os dados do odômetro
    debugPrint('🐛 [WIDGET] Agendando inicialização do formulário...');
    debugPrint('🐛 [WIDGET] Odômetro para edição: ${widget.odometro}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🐛 [WIDGET] PostFrameCallback executando initializeForm...');
      _controller.initializeForm(widget.odometro);
    });

    debugPrint('🐛 [WIDGET] initState - FIM');
  }

  /// Submete o formulário delegando para o controller
  ///
  /// O controller agora gerencia seu próprio estado de loading
  /// eliminando a necessidade de estado local no widget
  Future<void> submit({VoidCallback? onSuccess}) async {
    debugPrint('🐛 [WIDGET] submit() chamado - INÍCIO');
    debugPrint('🐛 [WIDGET] onSuccess fornecido: ${onSuccess != null}');
    debugPrint('🐛 [WIDGET] Widget mounted: $mounted');
    debugPrint(
        '🐛 [WIDGET] Controller isLoading: ${_controller.isLoading.value}');

    try {
      debugPrint('🐛 [WIDGET] Chamando _controller.submitForm...');
      final result = await _controller.submitForm(
        onSuccess: () {
          debugPrint('🐛 [WIDGET] onSuccess callback chamado!');
          onSuccess?.call();
          if (mounted) {
            debugPrint('🐛 [WIDGET] Fechando dialog com resultado true');
            Navigator.of(context).pop(true);
          } else {
            debugPrint(
                '🐛 [WIDGET] Widget não está mounted, não fechando dialog');
          }
        },
      );
      debugPrint('🐛 [WIDGET] Resultado do submitForm: $result');
    } catch (e, stackTrace) {
      debugPrint('🐛 [WIDGET] ERRO em submit: $e');
      debugPrint('🐛 [WIDGET] Stack trace: $stackTrace');
    }

    debugPrint('🐛 [WIDGET] submit() - FIM');
  }

  /// Obtém o estado de loading diretamente do controller
  bool get isLoading => _controller.isLoading.value;

  @override
  void dispose() {
    // Limpa o formulário ao fechar/cancelar o diálogo
    _controller.resetForm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const OdometroCadastroFormView();
  }
}
