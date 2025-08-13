// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../../../core/themes/manager.dart';
import '../../../../intermediate.dart';
import '../../../router.dart';
import '../models/sobre_model.dart';
import '../models/sobre_state.dart';

class SobreController extends GetxController {
  final _unfocusNode = FocusNode();

  final Rx<SobreState> _state = const SobreState().obs;
  SobreState get state => _state.value;

  bool get hasAppData => state.sobreData.appName.isNotEmpty;
  bool get hasContatos => state.hasContatos;

  @override
  void onInit() {
    super.onInit();
    _initializeTheme();
    _loadAppData();
  }

  @override
  void onClose() {
    _unfocusNode.dispose();
    super.onClose();
  }

  void _initializeTheme() {
    _updateState(state.copyWith(isDark: ThemeManager().isDark.value));
    ThemeManager().isDark.listen((value) {
      _updateState(state.copyWith(isDark: value));
    });
  }

  void _updateState(SobreState newState) {
    _state.value = newState;
  }

  void _loadAppData() {
    _updateState(state.copyWith(isLoading: true));

    try {
      final globalEnv = GlobalEnvironment();
      final sobreData = SobreModel(
        appName: globalEnv.iAppName ?? 'Receituagro',
        appVersion: globalEnv.iAppVersion ?? '1.0.0',
        appEmailContato: globalEnv.iAppEmailContato ?? 'contato@agrimind.com.br',
      );

      final contatos = [
        const ContatoModel(
          titulo: 'E-mail',
          url: '',
          path: '',
          iconType: 'email',
        ),
        const ContatoModel(
          titulo: 'Facebook',
          url: 'm.facebook.com',
          path: 'agrimind.br',
          iconType: 'facebook',
        ),
        const ContatoModel(
          titulo: 'Instagram',
          url: 'www.instagram.com',
          path: 'agrimind.br',
          iconType: 'instagram',
        ),
      ];

      _updateState(state.copyWith(
        sobreData: sobreData,
        contatos: contatos,
        isLoading: false,
      ));
    } catch (e) {
      _updateState(state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar dados do app: ${e.toString()}',
      ));
    }
  }

  Future<void> abrirLinkExterno(String url, String path) async {
    try {
      final Uri toLaunch = Uri(scheme: 'https', host: url, path: path);

      if (await canLaunchUrl(toLaunch)) {
        await launchUrl(toLaunch);
      } else {
        _updateState(state.copyWith(
          error: 'Não foi possível abrir o link $url',
        ));
      }
    } catch (e) {
      _updateState(state.copyWith(
        error: 'Erro ao abrir link: ${e.toString()}',
      ));
    }
  }

  Future<void> abrirEmail() async {
    try {
      String appEmailContato = state.sobreData.appEmailContato;
      String appName = state.sobreData.appName;
      String appVersion = state.sobreData.appVersion;

      final Uri toLaunch = Uri.parse(
        'mailto:$appEmailContato?subject=$appName%20-%20$appVersion%20|%20Problemas%20/%20Melhorias%20/%20Duvidas&body=Descreva%20aqui%20sua%20mensagem\n\n',
      );

      if (await canLaunchUrl(toLaunch)) {
        await launchUrl(toLaunch);
      } else {
        _updateState(state.copyWith(
          error: 'Não foi possível abrir o email',
        ));
      }
    } catch (e) {
      _updateState(state.copyWith(
        error: 'Erro ao abrir email: ${e.toString()}',
      ));
    }
  }

  void navegarParaAtualizacoes() {
    Get.toNamed(AppRoutes.atualizacao);
  }

  void voltarPagina() {
    Get.back();
  }

  void limparErro() {
    _updateState(state.copyWith(error: ''));
  }

  String get versaoAtual {
    try {
      final globalEnv = GlobalEnvironment();
      final atualizacoes = globalEnv.atualizacoesText;
      if (atualizacoes.isNotEmpty) {
        return atualizacoes[0]['versao']?.toString() ?? state.sobreData.appVersion;
      }
      return state.sobreData.appVersion;
    } catch (e) {
      return state.sobreData.appVersion;
    }
  }
}
