// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// Project imports:
import '../constants/meditacao_constants.dart';
import '../models/meditacao_achievement_model.dart';
import '../models/meditacao_model.dart';
import '../models/meditacao_stats_model.dart';
import 'meditacao_repository_provider.dart';

part 'meditacao_provider.g.dart';

// State class for meditation
class MeditacaoState {
  final List<MeditacaoModel> sessoes;
  final MeditacaoStatsModel stats;
  final List<MeditacaoAchievementModel> conquistas;
  final bool isLoading;
  final int duracaoSelecionada;
  final int tempoRestante;
  final bool emMeditacao;
  final String tipoMeditacaoAtual;
  final String humorSelecionado;
  final bool notificacoesHabilitadas;
  final TimeOfDay horarioNotificacao;

  MeditacaoState({
    this.sessoes = const [],
    MeditacaoStatsModel? stats,
    this.conquistas = const [],
    this.isLoading = true,
    this.duracaoSelecionada = MeditacaoConstants.duracaoPadraoMinutos,
    this.tempoRestante = 0,
    this.emMeditacao = false,
    this.tipoMeditacaoAtual = MeditacaoConstants.tipoPadrao,
    this.humorSelecionado = '',
    this.notificacoesHabilitadas = false,
    TimeOfDay? horarioNotificacao,
  })  : horarioNotificacao = horarioNotificacao ??
            const TimeOfDay(
              hour: MeditacaoConstants.notificacaoHoraPadrao,
              minute: MeditacaoConstants.notificacaoMinutoPadrao,
            ),
        stats = stats ?? MeditacaoStatsModel();

  MeditacaoState copyWith({
    List<MeditacaoModel>? sessoes,
    MeditacaoStatsModel? stats,
    List<MeditacaoAchievementModel>? conquistas,
    bool? isLoading,
    int? duracaoSelecionada,
    int? tempoRestante,
    bool? emMeditacao,
    String? tipoMeditacaoAtual,
    String? humorSelecionado,
    bool? notificacoesHabilitadas,
    TimeOfDay? horarioNotificacao,
  }) {
    return MeditacaoState(
      sessoes: sessoes ?? this.sessoes,
      stats: stats ?? this.stats,
      conquistas: conquistas ?? this.conquistas,
      isLoading: isLoading ?? this.isLoading,
      duracaoSelecionada: duracaoSelecionada ?? this.duracaoSelecionada,
      tempoRestante: tempoRestante ?? this.tempoRestante,
      emMeditacao: emMeditacao ?? this.emMeditacao,
      tipoMeditacaoAtual: tipoMeditacaoAtual ?? this.tipoMeditacaoAtual,
      humorSelecionado: humorSelecionado ?? this.humorSelecionado,
      notificacoesHabilitadas:
          notificacoesHabilitadas ?? this.notificacoesHabilitadas,
      horarioNotificacao: horarioNotificacao ?? this.horarioNotificacao,
    );
  }
}

@riverpod
class MeditacaoNotifier extends _$MeditacaoNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;
  Timer? _timer;

  // Mapeamento dos tipos de meditação para arquivos de áudio
  final Map<String, String> _tiposMeditacao = {
    'Respiração': 'stream-of-water-loop-2.mp3',
    'Corpo': 'vehicle-interior-in-motion-repeatable.mp3',
    'Gratidão': 'pink-noise-ocean-waves-on-grainy.mp3',
    'Sono': 'crush-and-shred.mp3',
  };

  @override
  MeditacaoState build() {
    // Initialize timezone
    tz_data.initializeTimeZones();

    // Initialize notifications
    _inicializarNotificacoes();

    // Load data
    _carregarDados();

    // Set initial remaining time
    final initialState = MeditacaoState();
    return initialState.copyWith(
      tempoRestante: MeditacaoConstants.duracaoPadraoMinutos * 60,
    );
  }

  // Load all data from repository
  Future<void> _carregarDados() async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(meditacaoRepositoryProvider);

      // Load sessions
      final sessoes = await repository.getSessoes();

      // Load statistics
      final stats = await repository.getEstatisticas();

      // Load achievements
      final conquistas = await repository.getConquistas();

      state = state.copyWith(
        sessoes: sessoes,
        stats: stats,
        conquistas: conquistas,
        isLoading: false,
      );
    } catch (e) {
      // Log error
      debugPrint('Erro ao carregar dados: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // Initialize notifications
  Future<void> _inicializarNotificacoes() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    await _flutterLocalNotificationsPlugin!.initialize(initializationSettings);

    // Load notification settings
    final repository = ref.read(meditacaoRepositoryProvider);
    final notificacoesHabilitadas =
        await repository.getNotificacoesHabilitadas();

    final horario = await repository.getHorarioNotificacao();
    final horarioNotificacao = TimeOfDay(
      hour: horario['hora']!,
      minute: horario['minuto']!,
    );

    state = state.copyWith(
      notificacoesHabilitadas: notificacoesHabilitadas,
      horarioNotificacao: horarioNotificacao,
    );

    // Schedule notification if enabled
    if (notificacoesHabilitadas) {
      agendarNotificacaoDiaria();
    }
  }

  // Toggle notifications (on/off)
  Future<void> alternarNotificacoes(bool valor) async {
    final repository = ref.read(meditacaoRepositoryProvider);
    await repository.setNotificacoesHabilitadas(valor);

    state = state.copyWith(notificacoesHabilitadas: valor);

    if (valor) {
      agendarNotificacaoDiaria();
    } else {
      cancelarNotificacoes();
    }
  }

  // Set notification time
  Future<void> definirHorarioNotificacao(TimeOfDay horario) async {
    final repository = ref.read(meditacaoRepositoryProvider);
    await repository.setHorarioNotificacao(horario.hour, horario.minute);

    state = state.copyWith(horarioNotificacao: horario);

    if (state.notificacoesHabilitadas) {
      agendarNotificacaoDiaria();
    }
  }

  // Schedule daily notification
  Future<void> agendarNotificacaoDiaria() async {
    // Cancel existing notifications
    await cancelarNotificacoes();

    // Notification details
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

    // ignore: unused_local_variable
    const detalhes = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    // Get current date and time
    final agora = DateTime.now();

    // Create scheduled date using TZDateTime
    tz.TZDateTime dataAgendada = tz.TZDateTime(
      tz.local,
      agora.year,
      agora.month,
      agora.day,
      state.horarioNotificacao.hour,
      state.horarioNotificacao.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (dataAgendada.isBefore(tz.TZDateTime.now(tz.local))) {
      dataAgendada = dataAgendada.add(const Duration(days: 1));
    }

    // Schedule notification (commented out as in original)
    // await _flutterLocalNotificationsPlugin?.zonedSchedule(...)
  }

  // Cancel all notifications
  Future<void> cancelarNotificacoes() async {
    await _flutterLocalNotificationsPlugin?.cancelAll();
  }

  // Toggle meditation timer (start/pause)
  void alternarTimer(BuildContext context) {
    // If starting meditation, check if mood was selected
    if (!state.emMeditacao) {
      if (state.humorSelecionado.isEmpty) {
        _mostrarMensagem(
          context,
          'Atenção',
          'Selecione seu humor antes de iniciar a meditação',
        );
        return;
      }
    }

    final novoEstado = !state.emMeditacao;

    if (novoEstado) {
      // Reset time if already zero
      if (state.tempoRestante <= 0) {
        state = state.copyWith(
          emMeditacao: novoEstado,
          tempoRestante: state.duracaoSelecionada * 60,
        );
      } else {
        state = state.copyWith(emMeditacao: novoEstado);
      }

      // Start timer
      _iniciarTimer(context);
    } else {
      // Pause timer
      _timer?.cancel();
      state = state.copyWith(emMeditacao: novoEstado);
    }
  }

  // Start meditation timer
  void _iniciarTimer(BuildContext context) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.emMeditacao) {
        if (state.tempoRestante > 0) {
          state = state.copyWith(tempoRestante: state.tempoRestante - 1);
        } else {
          // Finish session
          timer.cancel();
          state = state.copyWith(emMeditacao: false);
          _finalizarSessao(context);
        }
      } else {
        timer.cancel();
      }
    });
  }

  // Finish meditation session
  Future<void> _finalizarSessao(BuildContext context) async {
    // Stop audio
    await _audioPlayer.stop();

    // Check if mood was selected
    if (state.humorSelecionado.isEmpty) {
      _mostrarMensagem(
        context,
        'Atenção',
        'Selecione seu humor antes de finalizar a sessão',
      );
      return;
    }

    // Create and save new session
    final novaSessao = MeditacaoModel.create(
      duracao: state.duracaoSelecionada,
      tipo: state.tipoMeditacaoAtual,
      humor: state.humorSelecionado,
    );

    final repository = ref.read(meditacaoRepositoryProvider);
    await repository.salvarSessao(novaSessao);

    // Reload data
    await _carregarDados();

    // Check for new achievements
    final novasConquistas = await repository.getNovasConquistas();

    if (context.mounted) {
      if (novasConquistas.isNotEmpty) {
        // Show achievements dialog
        _mostrarDialogoConquistas(context, novasConquistas);
      } else {
        // Show completion dialog
        _mostrarDialogoConclusao(context);
      }
    }
  }

  // Select meditation duration
  void selecionarDuracao(int minutos) {
    state = state.copyWith(
      duracaoSelecionada: minutos,
      tempoRestante: minutos * 60,
    );
  }

  // Start meditation type with corresponding audio
  Future<void> iniciarTipoMeditacao(String tipo) async {
    state = state.copyWith(tipoMeditacaoAtual: tipo);

    // Get correct audio file for type
    final arquivoAudio = _tiposMeditacao[tipo] ?? 'stream-of-water-loop-2.mp3';
    final caminhoAudio = 'assets/asrm/$arquivoAudio';

    // Stop current audio
    await _audioPlayer.stop();

    // Play new audio
    await _audioPlayer.play(AssetSource(caminhoAudio));
  }

  // Select mood
  void selecionarHumor(String humor) {
    state = state.copyWith(humorSelecionado: humor);
  }

  // Show completion dialog
  void _mostrarDialogoConclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Parabéns!'),
          ],
        ),
        content: Text(
          'Você completou ${state.duracaoSelecionada} minutos de meditação.\n'
          'Continue mantendo sua prática diária!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show achievements dialog
  void _mostrarDialogoConquistas(
    BuildContext context,
    List<MeditacaoAchievementModel> novasConquistas,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber),
            SizedBox(width: 8),
            Text('Conquista Desbloqueada!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: novasConquistas
              .map((conquista) => ListTile(
                    leading: Icon(
                      _getIconData(conquista.icone),
                      color: Colors.amber,
                    ),
                    title: Text(conquista.titulo),
                    subtitle: Text(conquista.descricao),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  // Show message (replacement for GetX snackbar)
  void _mostrarMensagem(BuildContext context, String titulo, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$titulo: $mensagem'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Convert icon string to IconData
  IconData _getIconData(String icone) {
    switch (icone) {
      case 'self_improvement':
        return Icons.self_improvement;
      case 'date_range':
        return Icons.date_range;
      case 'hourglass_full':
        return Icons.hourglass_full;
      case 'explore':
        return Icons.explore;
      default:
        return Icons.emoji_events;
    }
  }

  // Get chart data grouped by day
  Map<DateTime, int> getDadosGrafico() {
    final Map<DateTime, int> dadosDiarios = {};

    for (final sessao in state.sessoes) {
      // Normalize date (remove hours, minutes, seconds)
      final data = DateTime(
        sessao.dataRegistro.year,
        sessao.dataRegistro.month,
        sessao.dataRegistro.day,
      );

      if (dadosDiarios.containsKey(data)) {
        dadosDiarios[data] = dadosDiarios[data]! + sessao.duracao;
      } else {
        dadosDiarios[data] = sessao.duracao;
      }
    }

    return dadosDiarios;
  }

  // Dispose resources
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
  }
}
