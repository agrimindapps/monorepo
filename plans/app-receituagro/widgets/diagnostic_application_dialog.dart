// Flutter imports:
import 'package:flutter/material.dart';

class DiagnosticApplicationDialog {
  static void show({
    required BuildContext context,
    required Map<dynamic, dynamic> data,
    List<DialogAction>? actions,
    bool showLimiteMaximo = false,
    bool isPremium = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width - 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 00),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data['nomeDefensivo'] ?? 'Informações de Aplicação',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagem da praga
                      if (data['nomeCientifico'] != null)
                        Container(
                          width: double.infinity,
                          height: 200,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildPragaImage(data['nomeCientifico']),
                          ),
                        ),
                      // Nome da praga
                      if (data['nomeComum'] != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              data['nomeComum'],
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      // Nome científico
                      if (data['nomeCientifico'] != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              data['nomeCientifico'],
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade600,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      if (data['ingredienteAtivo'] != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Ingrediente Ativo: ${data['ingredienteAtivo']}',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade700,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoItemWithDots(
                              'Dosagem',
                              data['dosagem'] ?? 'Não disponível',
                              isDark,
                              isPremium,
                              Icons.medication,
                            ),
                            _buildInfoItemWithDots(
                              'Aplicação Terrestre',
                              data['vazaoTerrestre'] ?? 'Não disponível',
                              isDark,
                              isPremium,
                              Icons.agriculture,
                            ),
                            _buildInfoItemWithDots(
                              'Aplicação Aérea',
                              data['vazaoAerea'] ?? 'Não disponível',
                              isDark,
                              isPremium,
                              Icons.flight,
                            ),
                            _buildInfoItemWithDots(
                              'Intervalo de Aplicação',
                              data['intervaloAplicacao'] ?? 'Não disponível',
                              isDark,
                              isPremium, // Agora também é premium
                              Icons.schedule,
                            ),
                            if (showLimiteMaximo)
                              _buildInfoItemWithDots(
                                'Limite Máximo de Aplicações',
                                data['limiteMaximoAplicacoes'] ??
                                    'Não disponível',
                                isDark,
                                true, // Este campo sempre é visível
                                Icons.warning,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Actions
              if (actions != null && actions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: actions
                        .map((action) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: actions.indexOf(action) == 0 ? 0 : 4,
                                  right: actions.indexOf(action) ==
                                          actions.length - 1
                                      ? 0
                                      : 4,
                                ),
                                child: action.isElevated
                                    ? ElevatedButton(
                                        onPressed: action.onPressed,
                                        child: Text(action.label),
                                      )
                                    : OutlinedButton(
                                        onPressed: action.onPressed,
                                        child: Text(action.label),
                                      ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói um item de informação com placeholder de dots para usuários não premium
  static Widget _buildInfoItemWithDots(
    String label,
    String value,
    bool isDark,
    bool isPremium,
    IconData icon,
  ) {
    // Placeholder específico baseado no tipo de informação
    String getPlaceholder() {
      if (label.toLowerCase().contains('dosagem')) return '••• mg/L';
      if (label.toLowerCase().contains('terrestre')) return '••• L/ha';
      if (label.toLowerCase().contains('aérea')) return '••• L/ha';
      if (label.toLowerCase().contains('intervalo')) return '••• dias';
      return '•••••';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white70 : Colors.grey.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Conteúdo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label sempre visível
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                // Valor ou placeholder com dots
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isPremium ? value : getPlaceholder(),
                        style: TextStyle(
                          color: isPremium
                              ? (isDark ? Colors.white : Colors.black)
                              : Colors.grey.shade400,
                          fontSize: 14,
                          fontWeight:
                              isPremium ? FontWeight.w600 : FontWeight.w300,
                        ),
                      ),
                    ),
                    // Badge premium discreto
                    if (!isPremium) ...[
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.diamond,
                            size: 12,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Premium',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.amber.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a imagem da praga baseada no nome científico
  static Widget _buildPragaImage(String? nomeCientifico) {
    if (nomeCientifico == null || nomeCientifico.isEmpty) {
      return const Icon(
        Icons.bug_report,
        size: 60,
        color: Colors.grey,
      );
    }

    final imagePath = 'assets/imagens/bigsize/$nomeCientifico.jpg';

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.bug_report,
          size: 60,
          color: Colors.grey,
        );
      },
    );
  }
}

class DialogAction {
  final String label;
  final VoidCallback onPressed;
  final bool isElevated;

  const DialogAction({
    required this.label,
    required this.onPressed,
    this.isElevated = false,
  });
}
