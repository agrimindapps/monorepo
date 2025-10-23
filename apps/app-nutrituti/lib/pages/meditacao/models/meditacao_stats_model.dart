// Project imports:
import '../constants/meditacao_constants.dart';

class MeditacaoStatsModel {
  final int totalMinutos;
  final int totalSessoes;
  final int sequenciaAtual; // streak atual
  final int maiorSequencia; // maior streak registrado
  final Set<String> tiposUsados; // conjunto de tipos de meditação utilizados
  final DateTime? ultimaSessao; // data da última sessão

  MeditacaoStatsModel({
    this.totalMinutos = 0,
    this.totalSessoes = 0,
    this.sequenciaAtual = 0,
    this.maiorSequencia = 0,
    Set<String>? tiposUsados,
    this.ultimaSessao,
  }) : tiposUsados = tiposUsados ?? {};

  // Converter para Map para salvar no SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'totalMinutos': totalMinutos,
      'totalSessoes': totalSessoes,
      'sequenciaAtual': sequenciaAtual,
      'maiorSequencia': maiorSequencia,
      'tiposUsados': tiposUsados.toList(),
      'ultimaSessao': ultimaSessao?.toIso8601String(),
    };
  }

  // Construir a partir de um Map (do SharedPreferences)
  factory MeditacaoStatsModel.fromMap(Map<String, dynamic> map) {
    return MeditacaoStatsModel(
      totalMinutos: (map['totalMinutos'] as num?)?.toInt() ?? 0,
      totalSessoes: (map['totalSessoes'] as num?)?.toInt() ?? 0,
      sequenciaAtual: (map['sequenciaAtual'] as num?)?.toInt() ?? 0,
      maiorSequencia: (map['maiorSequencia'] as num?)?.toInt() ?? 0,
      tiposUsados: Set<String>.from(map['tiposUsados'] as Iterable? ?? []),
      ultimaSessao: map['ultimaSessao'] != null
          ? DateTime.parse(map['ultimaSessao'] as String)
          : null,
    );
  }

  // Adicionar uma nova sessão às estatísticas
  MeditacaoStatsModel adicionarSessao(String tipo, int duracao) {
    final agora = DateTime.now();
    final novaTiposUsados = Set<String>.from(tiposUsados)..add(tipo);

    // Verificar sequência (streak)
    int novaSequencia = sequenciaAtual;

    if (ultimaSessao != null) {
      final ontem = DateTime(agora.year, agora.month, agora.day - 1);
      final dataUltima =
          DateTime(ultimaSessao!.year, ultimaSessao!.month, ultimaSessao!.day);

      // Se a última sessão foi ontem, incrementa a sequência
      if (dataUltima.isAtSameMomentAs(ontem)) {
        novaSequencia++;
      }
      // Se a última sessão não foi ontem e nem hoje, reinicia a sequência
      else if (!dataUltima
          .isAtSameMomentAs(DateTime(agora.year, agora.month, agora.day))) {
        novaSequencia = MeditacaoConstants.conquistaPrimeiraSessao;
      }
    } else {
      // Primeira sessão
      novaSequencia = MeditacaoConstants.conquistaPrimeiraSessao;
    }

    return MeditacaoStatsModel(
      totalMinutos: totalMinutos + duracao,
      totalSessoes: totalSessoes + 1,
      sequenciaAtual: novaSequencia,
      maiorSequencia:
          novaSequencia > maiorSequencia ? novaSequencia : maiorSequencia,
      tiposUsados: novaTiposUsados,
      ultimaSessao: agora,
    );
  }
}
