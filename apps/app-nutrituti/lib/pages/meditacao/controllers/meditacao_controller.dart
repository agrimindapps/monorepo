// Flutter imports:
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// Project imports:
import '../constants/meditacao_constants.dart';
import '../models/meditacao_achievement_model.dart';
import '../models/meditacao_model.dart';
import '../models/meditacao_stats_model.dart';
import '../repository/meditacao_repository.dart';
import '../services/meditacao_logger_service.dart';

/// DEPRECATED: This GetX controller has been replaced by Riverpod providers
/// See: lib/pages/meditacao/providers/meditacao_provider.dart
@Deprecated('Use MeditacaoProvider (Riverpod) instead. Will be removed after migration.')
class MeditacaoController {
  final MeditacaoRepository _repository = MeditacaoRepository();
  final audioPlayer = AudioPlayer();

  // REMOVED: GetX reactive states - Use Riverpod providers instead
  // See: lib/pages/meditacao/providers/meditacao_provider.dart
  //
  // final RxList<MeditacaoModel> sessoes = <MeditacaoModel>[].obs;
  // final Rx<MeditacaoStatsModel> stats = MeditacaoStatsModel().obs;
  // final RxList<MeditacaoAchievementModel> conquistas = <MeditacaoAchievementModel>[].obs;
  // final RxBool isLoading = true.obs;
  // final RxInt duracaoSelecionada = MeditacaoConstants.duracaoPadraoMinutos.obs;
  // final RxInt tempoRestante = 0.obs;
  // final RxBool emMeditacao = false.obs;
  // final RxString tipoMeditacaoAtual = MeditacaoConstants.tipoPadrao.obs;
  // final RxString humorSelecionado = ''.obs;
  // STUB: Substituindo Rx do GetX por variáveis simples (FASE 0.7)
  // TODO FASE 1: Migrar para Riverpod StateNotifier
  final _RxValue<bool> notificacoesHabilitadas = _RxValue(false);
  final _RxValue<TimeOfDay> horarioNotificacao = _RxValue(const TimeOfDay(hour: 9, minute: 0));

  // Plug-in de notificações
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  // Mapeamento dos tipos de meditação para arquivos de áudio
  final Map<String, String> tiposMeditacao = {
    'Respiração': 'stream-of-water-loop-2.mp3',
    'Corpo': 'vehicle-interior-in-motion-repeatable.mp3',
    'Gratidão': 'pink-noise-ocean-waves-on-grainy.mp3',
    'Sono': 'crush-and-shred.mp3',
  };

  // REMOVED: GetX lifecycle methods
  // Use Riverpod provider lifecycle (ref.onDispose) instead
  //
  // @override
  // void onInit() { ... }
  //
  // @override
  // void onClose() { ... }

  // REMOVED: Use Riverpod provider methods instead
  // See: lib/pages/meditacao/providers/meditacao_provider.dart
  //
  // Future<void> _carregarDados() async { ... }

  // Inicializar notificações
  Future<void> _inicializarNotificacoes() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Configurações para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configurações para iOS
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin!.initialize(initializationSettings);

    // Carregar configurações de notificação
    notificacoesHabilitadas.value =
        await _repository.getNotificacoesHabilitadas();

    final horario = await _repository.getHorarioNotificacao();
    horarioNotificacao.value = TimeOfDay(
      hour: horario['hora']!,
      minute: horario['minuto']!,
    );

    // Agendar notificação se estiver habilitada
    if (notificacoesHabilitadas.value) {
      agendarNotificacaoDiaria();
    }
  }

  // REMOVED: Use Riverpod provider methods instead
  // See: lib/pages/meditacao/providers/meditacao_provider.dart
  //
  // Future<void> alternarNotificacoes(bool valor) async { ... }
  // Future<void> definirHorarioNotificacao(TimeOfDay horario) async { ... }

  // Agendar notificação diária
  Future<void> agendarNotificacaoDiaria() async {
    // Cancelar notificações existentes
    await cancelarNotificacoes();

    // Configurar detalhes da notificação
    const androidDetails = AndroidNotificationDetails(
      'meditation_channel',
      'Lembrete de Meditação',
      channelDescription: 'Lembretes diários para praticar meditação',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const detalhes = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    // Obter data e hora atual
    final agora = DateTime.now();

    // Criar data para a notificação usando TZDateTime
    tz.TZDateTime dataAgendada = tz.TZDateTime(
      tz.local,
      agora.year,
      agora.month,
      agora.day,
      horarioNotificacao.value.hour,
      horarioNotificacao.value.minute,
    );

    // Se a hora já passou hoje, agendar para amanhã
    if (dataAgendada.isBefore(tz.TZDateTime.now(tz.local))) {
      dataAgendada = dataAgendada.add(const Duration(days: 1));
    }

    // await flutterLocalNotificationsPlugin?.zonedSchedule(
    //   0,
    //   'Hora de Meditar',
    //   'Reserve alguns minutos para sua meditação diária.',
    //   dataAgendada,
    //   detalhes,
    //   androidAllowWhileIdle: true,
    //   uiLocalNotificationDateInterpretation:
    //       UILocalNotificationDateInterpretation.absoluteTime,
    //   matchDateTimeComponents: DateTimeComponents.time,
    //   androidScheduleMode: null,
    // );
  }

  // Cancelar todas as notificações
  Future<void> cancelarNotificacoes() async {
    await flutterLocalNotificationsPlugin?.cancelAll();
  }

  // REMOVED: All business logic migrated to Riverpod providers
  // See: lib/pages/meditacao/providers/meditacao_provider.dart
  //
  // void alternarTimer() { ... }
  // void _iniciarTimer() { ... }
  // Future<void> _finalizarSessao() async { ... }
  // void selecionarDuracao(int minutos) { ... }
  // Future<void> iniciarTipoMeditacao(String tipo) async { ... }
  // void selecionarHumor(String humor) { ... }
  // void _mostrarDialogoConclusao() { ... }
  // void _mostrarDialogoConquistas(...) { ... }

  // REMOVED: Utility methods migrated to Riverpod providers or services
  // See: lib/pages/meditacao/providers/meditacao_provider.dart
  //
  // IconData _getIconData(String icone) { ... }
  // Map<DateTime, int> getDadosGrafico() { ... }
}

// STUB: Helper class para substituir Rx do GetX (FASE 0.7)
// TODO FASE 1: Remover após migração completa para Riverpod
class _RxValue<T> {
  T _value;
  _RxValue(this._value);

  T get value => _value;
  set value(T newValue) => _value = newValue;
}
