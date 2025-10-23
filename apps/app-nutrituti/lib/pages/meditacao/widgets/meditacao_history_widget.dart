// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../constants/meditacao_constants.dart';
import '../providers/meditacao_provider.dart';

class MeditacaoHistoryWidget extends ConsumerWidget {
  const MeditacaoHistoryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessoes = ref.watch(
      meditacaoNotifierProvider.select((state) => state.sessoes),
    );

    if (sessoes.isEmpty) {
      return const _EmptyHistoryCard();
    }

    return _HistoryCard(sessoes: sessoes);
  }
}

class _EmptyHistoryCard extends StatelessWidget {
  const _EmptyHistoryCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: MeditacaoConstants.elevacaoPadrao,
      child: Padding(
        padding: EdgeInsets.all(MeditacaoConstants.paddingPadrao),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HistoryTitle(),
            SizedBox(height: MeditacaoConstants.paddingPadrao),
            _EmptyState(),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final List<dynamic> sessoes;

  const _HistoryCard({required this.sessoes});

  @override
  Widget build(BuildContext context) {
    final recentSessions = sessoes.take(MeditacaoConstants.maxHistoricoSessoes ~/ 5).toList();
    final hasMoreSessions = sessoes.length > recentSessions.length;

    return Card(
      elevation: MeditacaoConstants.elevacaoPadrao,
      child: Padding(
        padding: const EdgeInsets.all(MeditacaoConstants.paddingPadrao),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HistoryTitle(),
            const SizedBox(height: MeditacaoConstants.paddingPadrao),
            ...recentSessions.map((sessao) => _SessionListTile(sessao: sessao)),
            if (hasMoreSessions) const _ViewMoreButton(),
          ],
        ),
      ),
    );
  }
}

class _HistoryTitle extends StatelessWidget {
  const _HistoryTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Histórico de Sessões',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(MeditacaoConstants.paddingPadrao),
        child: Text(
          'Nenhuma sessão registrada ainda.',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

class _SessionListTile extends StatelessWidget {
  final dynamic sessao;

  // Use static formatters to avoid recreating them
  static final DateFormat _dateFormat = DateFormat.yMMMd();
  static final DateFormat _timeFormat = DateFormat.Hm();

  const _SessionListTile({required this.sessao});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.self_improvement, color: Colors.blue),
      title: Text(
        '${sessao.tipo} - ${sessao.duracao} min',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text('Humor: ${sessao.humor}'),
      trailing: _DateTimeInfo(
        dateText: _dateFormat.format(sessao.dataRegistro as DateTime),
        timeText: _timeFormat.format(sessao.dataRegistro as DateTime),
      ),
    );
  }
}

class _DateTimeInfo extends StatelessWidget {
  final String dateText;
  final String timeText;

  const _DateTimeInfo({
    required this.dateText,
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          dateText,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          timeText,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _ViewMoreButton extends StatelessWidget {
  const _ViewMoreButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: MeditacaoConstants.paddingPequeno),
      child: Center(
        child: TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Histórico Completo: Funcionalidade em desenvolvimento'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: const Text('Ver Histórico Completo'),
        ),
      ),
    );
  }
}
