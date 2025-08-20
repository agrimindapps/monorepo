// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/atualizacoes_controller.dart';
import '../../models/atualizacao_model.dart';
import '../../utils/atualizacoes_constants.dart';
import '../../utils/atualizacoes_helpers.dart';

class AtualizacaoCardWidget extends StatelessWidget {
  final Atualizacao atualizacao;
  final AtualizacoesController controller;
  final bool showFullNotes;

  const AtualizacaoCardWidget({
    super.key,
    required this.atualizacao,
    required this.controller,
    this.showFullNotes = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AtualizacoesConstants.cardElevation,
      color: AtualizacoesHelpers.getCardBackgroundColor(),
      shape: RoundedRectangleBorder(
        borderRadius: AtualizacoesHelpers.getCardBorderRadius(),
      ),
      child: InkWell(
        onTap: () => controller.showVersionDetails(context, atualizacao),
        borderRadius: AtualizacoesHelpers.getCardBorderRadius(),
        child: Padding(
          padding: AtualizacoesHelpers.getCardPadding(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildNotes(context),
              if (atualizacao.categoria != null) ...[
                const SizedBox(height: 8),
                _buildCategory(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          AtualizacoesHelpers.getVersionIcon(atualizacao, controller.allAtualizacoes),
          color: AtualizacoesHelpers.getVersionColor(atualizacao, controller.allAtualizacoes),
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            atualizacao.versaoFormatada,
            style: AtualizacoesConstants.getVersionTextStyle(
              isLatest: controller.isLatestVersion(atualizacao.versao),
              isImportant: atualizacao.isImportante,
            ),
          ),
        ),
        AtualizacoesHelpers.buildVersionBadge(atualizacao, controller.allAtualizacoes),
      ],
    );
  }

  Widget _buildNotes(BuildContext context) {
    if (atualizacao.notas.isEmpty) {
      return Text(
        AtualizacoesConstants.noReleaseNotes,
        style: AtualizacoesConstants.releaseNoteStyle.copyWith(
          fontStyle: FontStyle.italic,
          color: Colors.grey[600],
        ),
      );
    }

    final notesToShow = showFullNotes 
        ? atualizacao.notas 
        : atualizacao.notas.take(AtualizacoesConstants.maxNotesPreview).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...notesToShow.map((nota) => _buildNoteItem(nota)),
        if (!showFullNotes && atualizacao.notas.length > AtualizacoesConstants.maxNotesPreview)
          _buildExpandButton(),
      ],
    );
  }

  Widget _buildNoteItem(String nota) {
    final releaseNote = AtualizacoesHelpers.parseReleaseNotes([nota]).first;
    return AtualizacoesHelpers.buildReleaseNote(releaseNote);
  }

  Widget _buildExpandButton() {
    final remainingCount = atualizacao.notas.length - AtualizacoesConstants.maxNotesPreview;
    
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextButton(
        onPressed: () {
          // Aqui poderia abrir um modal com todas as notas
          // Por enquanto, vamos usar o showVersionDetails
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          '... e mais $remainingCount ${remainingCount == 1 ? 'item' : 'itens'}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue[600],
          ),
        ),
      ),
    );
  }

  Widget _buildCategory() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Text(
        atualizacao.categoria!,
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
