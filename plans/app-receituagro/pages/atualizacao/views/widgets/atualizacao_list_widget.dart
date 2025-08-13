// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/atualizacao_model.dart';

class AtualizacaoListWidget extends StatelessWidget {
  final List<AtualizacaoModel> atualizacoes;
  final bool isDark;

  const AtualizacaoListWidget({
    super.key,
    required this.atualizacoes,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (atualizacoes.isEmpty) {
      return _buildEmptyState();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF5F5F5),
      child: ListView.separated(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: atualizacoes.length,
        itemBuilder: (context, index) {
          final atualizacao = atualizacoes[index];
          final isLatest = index == 0;
          
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isLatest 
                    ? Colors.green.shade100 
                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isLatest 
                      ? Colors.green.shade400 
                      : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                  width: 1,
                ),
              ),
              child: Icon(
                isLatest ? Icons.new_releases : Icons.update,
                color: isLatest 
                    ? Colors.green.shade700 
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                size: 20,
              ),
            ),
            title: Row(
              children: [
                Text(
                  atualizacao.versao,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (isLatest) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ATUAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                atualizacao.notas.join('\n• ').replaceFirst(RegExp(r'^'), '• '),
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.3,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            visualDensity: VisualDensity.comfortable,
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            color: isDark ? Colors.white24 : Colors.black26,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF5F5F5),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhuma atualização disponível',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'O histórico de versões será exibido aqui',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.black45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
