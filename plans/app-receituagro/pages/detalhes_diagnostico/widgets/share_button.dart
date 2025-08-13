// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

class ShareButtonWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final String Function(String) formatText;

  const ShareButtonWidget({
    super.key,
    required this.data,
    required this.formatText,
  });

  void _shareContent() {
    final shareText = _buildShareText(data);
    Share.share(shareText);
  }

  String _buildShareText(Map<String, dynamic> data) {
    return '''
Recomendação de Diagnóstico

Defensivo: ${data['nomeDefensivo']}
Praga (Nome Comum): ${data['nomePraga']}
Praga (Nome Científico): ${data['nomeCientifico']}
Cultura: ${data['cultura']}

Informações Gerais:
${_formatField('Ingrediente Ativo', data['ingredienteAtivo'])}
${_formatField('Toxicologia', data['toxico'])}
${_formatField('Classe Ambiental', data['classAmbiental'])}
${_formatField('Classe Agronômica', data['classeAgronomica'])}
${_formatField('Formulação', data['formulacao'])}
${_formatField('Modo de Ação', data['modoAcao'])}
${_formatField('Reg. MAPA', data['mapa'])}

Aplicação:
${_formatField('Dosagem', data['dosagem'])}
${_formatField('Vazão Terrestre', data['vazaoTerrestre'])}
${_formatField('Vazão Aérea', data['vazaoAerea'])}
${_formatField('Intervalo de Aplicação', data['intervaloAplicacao'])}
${_formatField('Intervalo de Segurança', data['intervaloSeguranca'])}

Modo de Aplicação: 
${formatText(data['tecnologia'] ?? '')}
''';
  }

  String _formatField(String label, String? value) {
    return '$label: ${value?.isNotEmpty == true ? value : 'Não há informações'}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade200),
      ),
      margin: const EdgeInsets.only(right: 8),
      child: IconButton(
        icon: Icon(
          Icons.share_rounded,
          color: Colors.purple.shade700,
          size: 20,
        ),
        onPressed: _shareContent,
        tooltip: 'Compartilhar',
        iconSize: 20,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
        splashRadius: 24,
      ),
    );
  }
}
