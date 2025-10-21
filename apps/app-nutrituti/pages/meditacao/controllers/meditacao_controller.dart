// Flutter imports:
// Package imports:
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// Project imports:
import '../constants/meditacao_constants.dart';
import '../models/meditacao_achievement_model.dart';
import '../models/meditacao_model.dart';
import '../models/meditacao_stats_model.dart';
import '../repository/meditacao_repository.dart';
import '../services/meditacao_logger_service.dart';

class MeditacaoController extends GetxController {
  final MeditacaoRepository _repository = MeditacaoRepository();
  final audioPlayer = AudioPlayer();

  // Estado observável
  final RxList<MeditacaoModel> sessoes = <MeditacaoModel>[].obs;
  final Rx<MeditacaoStatsModel> stats = MeditacaoStatsModel().obs;
  final RxList<MeditacaoAchievementModel> conquistas =
      <MeditacaoAchievementModel>[].obs;
  final RxBool isLoading = true.obs;

  // Configurações de timer
  final RxInt duracaoSelecionada = MeditacaoConstants.duracaoPadraoMinutos.obs; // minutos
  final RxInt tempoRestante = 0.obs;
  final RxBool emMeditacao = false.obs;
  final RxString tipoMeditacaoAtual = MeditacaoConstants.tipoPadrao.obs;
  final RxString humorSelecionado = ''.obs;

  // Configurações de notificação
  final RxBool notificacoesHabilitadas = false.obs;
  final Rx<TimeOfDay> horarioNotificacao =
      const TimeOfDay(hour: MeditacaoConstants.notificacaoHoraPadrao, minute: MeditacaoConstants.notificacaoMinutoPadrao).obs;

  // Plug-in de notificações
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  // Mapeamento dos tipos de meditação para arquivos de áudio
  final Map<String, String> tiposMeditacao = {
    'Respiração': 'stream-of-water-loop-2.mp3',
    'Corpo': 'vehicle-interior-in-motion-repeatable.mp3',
    'Gratidão': 'pink-noise-ocean-waves-on-grainy.mp3',
    'Sono': 'crush-and-shred.mp3',
  };

  @override
  void onInit() {
    super.onInit();

    // Inicializar timezone para notificações
    tz_data.initializeTimeZones();

    // Inicializar dados
    _carregarDados();
    _inicializarNotificacoes();

    // Configurar tempo restante inicial
    tempoRestante.value = duracaoSelecionada.value * 60;
  }

  @override
  void onClose() {
    // Liberar recursos
    audioPlayer.dispose();
    super.onClose();
  }

  // Carregar todos os dados do repositório
  Future<void> _carregarDados() async {
    isLoading.value = true;

    try {
      // Carregar sessões
      sessoes.value = await _repository.getSessoes();

      // Carregar estatísticas
      stats.value = await _repository.getEstatisticas();

      // Carregar conquistas
      conquistas.value = await _repository.getConquistas();
    } catch (e) {
      MeditacaoLoggerService.e('Erro ao carregar dados', 
        component: 'Controller', error: e);
    } finally {
      isLoading.value = false;
    }
  }

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

  // Alternar notificações (ligar/desligar)
  Future<void> alternarNotificacoes(bool valor) async {
    notificacoesHabilitadas.value = valor;
    await _repository.setNotificacoesHabilitadas(valor);

    if (valor) {
      agendarNotificacaoDiaria();
    } else {
      cancelarNotificacoes();
    }
  }

  // Definir horário de notificação
  Future<void> definirHorarioNotificacao(TimeOfDay horario) async {
    horarioNotificacao.value = horario;
    await _repository.setHorarioNotificacao(horario.hour, horario.minute);

    if (notificacoesHabilitadas.value) {
      agendarNotificacaoDiaria();
    }
  }

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

  // Alternar o timer de meditação (iniciar/pausar)
  void alternarTimer() {
    // Se estiver iniciando a meditação, verificar se o humor foi selecionado
    if (!emMeditacao.value) {
      if (humorSelecionado.isEmpty) {
        Get.snackbar(
          'Atenção',
          'Selecione seu humor antes de iniciar a meditação',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    emMeditacao.value = !emMeditacao.value;

    if (emMeditacao.value) {
      // Reiniciar tempo se já estiver zerado
      if (tempoRestante.value <= 0) {
        tempoRestante.value = duracaoSelecionada.value * 60;
      }

      // Iniciar timer
      Get.engine.addPostFrameCallback((_) => _iniciarTimer());
    }
  }

  // Iniciar o timer de meditação
  void _iniciarTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      // Verifica se ainda está em meditação (não foi pausado)
      if (emMeditacao.value) {
        if (tempoRestante.value > 0) {
          tempoRestante.value--;
          _iniciarTimer(); // Chamada recursiva para o próximo segundo
        } else {
          // Finalizar sessão
          emMeditacao.value = false;
          _finalizarSessao();
        }
      }
    });
  }

  // Finalizar sessão de meditação
  Future<void> _finalizarSessao() async {
    // Parar áudio
    await audioPlayer.stop();

    // Verificar se há um humor selecionado
    if (humorSelecionado.isEmpty) {
      Get.snackbar(
        'Atenção',
        'Selecione seu humor antes de finalizar a sessão',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Criar e salvar nova sessão
    final novaSessao = MeditacaoModel.create(
      duracao: duracaoSelecionada.value,
      tipo: tipoMeditacaoAtual.value,
      humor: humorSelecionado.value,
    );

    await _repository.salvarSessao(novaSessao);

    // Recarregar dados
    await _carregarDados();

    // Verificar novas conquistas
    final novasConquistas = await _repository.getNovasConquistas();

    if (novasConquistas.isNotEmpty) {
      // Mostrar diálogo de conquistas
      _mostrarDialogoConquistas(novasConquistas);
    } else {
      // Mostrar diálogo de conclusão
      _mostrarDialogoConclusao();
    }
  }

  // Selecionar duração da meditação
  void selecionarDuracao(int minutos) {
    duracaoSelecionada.value = minutos;
    tempoRestante.value = minutos * 60;
  }

  // Iniciar tipo de meditação com áudio correspondente
  Future<void> iniciarTipoMeditacao(String tipo) async {
    tipoMeditacaoAtual.value = tipo;

    // Obter o arquivo de áudio correto para o tipo
    final arquivoAudio = tiposMeditacao[tipo] ?? 'stream-of-water-loop-2.mp3';
    final caminhoAudio = 'assets/asrm/$arquivoAudio';

    // Parar áudio atual
    await audioPlayer.stop();

    // Reproduzir novo áudio
    await audioPlayer.play(AssetSource(caminhoAudio));
  }

  // Selecionar humor
  void selecionarHumor(String humor) {
    humorSelecionado.value = humor;
  }

  // Mostrar diálogo de conclusão
  void _mostrarDialogoConclusao() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Parabéns!'),
          ],
        ),
        content: Text(
          'Você completou ${duracaoSelecionada.value} minutos de meditação.\n'
          'Continue mantendo sua prática diária!',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Mostrar diálogo de conquistas
  void _mostrarDialogoConquistas(
      List<MeditacaoAchievementModel> novasConquistas) {
    Get.dialog(
      AlertDialog(
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
            onPressed: () => Get.back(),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  // Converter string de ícone para IconData
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

  // Obter dados agrupados por dia para o gráfico
  Map<DateTime, int> getDadosGrafico() {
    final Map<DateTime, int> dadosDiarios = {};

    for (final sessao in sessoes) {
      // Normalizar data (remover horas, minutos, segundos)
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
}
