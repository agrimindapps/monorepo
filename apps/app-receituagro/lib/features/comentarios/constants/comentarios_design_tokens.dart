import 'package:core/core.dart';
import 'package:flutter/material.dart';

class ComentariosDesignTokens {
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF8F00);
  static const Color warningBackgroundColor = Color(0xFFFFF8E1);
  static const Color warningTextColor = Color(0xFFFF6F00);
  static const Color errorColor = Color(0xFFF44336);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color dialogBackgroundDark = Color(0xFF1E1E1E);
  static const Color dialogHeaderDark = Color(0xFF2D2D2D);
  static const Color dialogHeaderLight = Color(0xFFF8F9FA);
  static const IconData commentIcon = FontAwesomeIcons.commentDots;
  static const IconData addIcon = Icons.add;
  static const IconData editIcon = Icons.edit_outlined;
  static const IconData deleteIcon = Icons.delete_outline;
  static const IconData searchIcon = Icons.search;
  static const IconData clearIcon = Icons.clear;
  static const IconData saveIcon = Icons.check;
  static const IconData cancelIcon = Icons.close;
  static const IconData infoIcon = Icons.info_outline;
  static const IconData diamondIcon = Icons.diamond;
  static const double maxPageWidth = 1120.0;
  static const double maxDialogWidth = 400.0;
  static const double defaultBorderRadius = 12.0;
  static const double dialogBorderRadius = 20.0; // Moved from hardcoded value
  static const double cardElevation = 2.0;
  static const double fabBottomPadding = 60.0;
  static const double maxDialogHeight = 500.0; // Moved from hardcoded value
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(24.0);
  static const EdgeInsets pagePadding = EdgeInsets.all(8.0);
  static const EdgeInsets dialogPadding = EdgeInsets.all(24.0);
  static const Duration debounceDelay = Duration(milliseconds: 300);
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const int minCommentLength = 5;
  static const int maxCommentLength = 300; // Moved from hardcoded value
  static const int maxSearchLength = 100;
  static const int freeTierMaxComments = 9999999;
  static const int premiumMaxComments = 9999999;
  static const String loadingMessage = 'Carregando comentários...';
  static const String noPermissionTitle = 'Comentários não disponíveis';
  static const String noPermissionDescription = 
      'Este recurso está disponível apenas para assinantes do app.';
  static const String limitReachedTitle = 'Limite de comentários atingido';
  static const String emptyStateMessage = 'Nenhum comentário encontrado.';
  static const String emptySearchMessage = 'Nenhum comentário encontrado.';
  static const String unlockButtonText = 'Desbloquear Agora';
  static const String upgradeToPremiumText = 'Assinar Premium';
  static const String shortCommentError = 'O comentário deve ter pelo menos 5 caracteres';
  static const String saveErrorTitle = 'Erro';
  static const String saveErrorMessage = 'Erro ao salvar comentário';
  static const String deleteErrorMessage = 'Erro ao deletar comentário';
  static const String updateErrorMessage = 'Erro ao atualizar comentário';
  static const String commentSavedMessage = 'Comentário salvo com sucesso';
  static const String commentDeletedMessage = 'Comentário removido';
  static const String commentUpdatedMessage = 'Comentário atualizado';

  static BoxDecoration getCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(defaultBorderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration getWarningDecoration() {
    return BoxDecoration(
      color: warningBackgroundColor,
      borderRadius: BorderRadius.circular(defaultBorderRadius),
      border: Border.all(color: warningColor),
    );
  }

  static TextStyle getTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
    ) ?? const TextStyle(fontWeight: FontWeight.bold);
  }

  static TextStyle getBodyStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
  }

  static TextStyle getWarningTextStyle() {
    return const TextStyle(
      color: warningTextColor,
      fontWeight: FontWeight.bold,
    );
  }
}
