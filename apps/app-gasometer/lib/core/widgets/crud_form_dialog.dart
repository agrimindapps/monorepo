import 'package:flutter/material.dart';

/// Enum que define os modos de operação do dialog CRUD
enum CrudDialogMode {
  /// Modo de criação - campos editáveis, botão de salvar
  create,

  /// Modo de visualização - campos readonly, botão de editar
  view,

  /// Modo de edição - campos editáveis, botões de salvar/cancelar
  edit,
}

/// Dialog reutilizável para operações CRUD com 3 modos:
/// - Create: Formulário limpo para criar novo registro
/// - View: Exibição readonly com botão de editar
/// - Edit: Formulário preenchido para edição
///
/// Exemplo de uso:
/// ```dart
/// CrudFormDialog(
///   mode: CrudDialogMode.view,
///   title: 'Abastecimento',
///   subtitle: 'Detalhes do registro',
///   headerIcon: Icons.local_gas_station,
///   content: FuelFormView(vehicleId: vehicleId, readOnly: mode == CrudDialogMode.view),
///   onModeChange: (newMode) => setState(() => mode = newMode),
///   onSave: () => handleSave(),
///   onDelete: () => handleDelete(),
/// )
/// ```
class CrudFormDialog extends StatelessWidget {
  const CrudFormDialog({
    super.key,
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.headerIcon,
    required this.content,
    this.onModeChange,
    this.onSave,
    this.onCancel,
    this.onDelete,
    this.isLoading = false,
    this.isSaving = false,
    this.canSave = true,
    this.showCloseButton = true,
    this.showDeleteButton = true,
    this.errorMessage,
    this.maxWidth = 500,
    this.maxHeight = 700,
  });

  /// Modo atual do dialog (create, view, edit)
  final CrudDialogMode mode;

  /// Título exibido no header
  final String title;

  /// Subtítulo exibido abaixo do título
  final String subtitle;

  /// Ícone do header
  final IconData headerIcon;

  /// Conteúdo do formulário
  final Widget content;

  /// Callback quando o modo muda (view -> edit)
  final void Function(CrudDialogMode)? onModeChange;

  /// Callback quando salva (create ou edit)
  final VoidCallback? onSave;

  /// Callback quando cancela
  final VoidCallback? onCancel;

  /// Callback quando exclui (apenas em view/edit)
  final VoidCallback? onDelete;

  /// Se está carregando dados
  final bool isLoading;

  /// Se está salvando
  final bool isSaving;

  /// Se pode salvar (validação do form)
  final bool canSave;

  /// Se mostra botão de fechar
  final bool showCloseButton;

  /// Se mostra botão de excluir (em view/edit)
  final bool showDeleteButton;

  /// Mensagem de erro opcional
  final String? errorMessage;

  /// Largura máxima do dialog
  final double maxWidth;

  /// Altura máxima do dialog
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            if (isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: content,
                ),
              ),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Ícone com badge de modo
              Stack(
                children: [
                  Icon(headerIcon, color: colorScheme.onSurface, size: 24),
                  if (mode == CrudDialogMode.view)
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.visibility,
                          size: 10,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTitleWithMode(),
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _buildSubtitleOrError(context),
                  ],
                ),
              ),
              // Botão de fechar
              if (showCloseButton)
                IconButton(
                  onPressed: onCancel ?? () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: colorScheme.onSurface, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTitleWithMode() {
    switch (mode) {
      case CrudDialogMode.create:
        return 'Novo $title';
      case CrudDialogMode.view:
        return title;
      case CrudDialogMode.edit:
        return 'Editar $title';
    }
  }

  Widget _buildSubtitleOrError(BuildContext context) {
    final theme = Theme.of(context);

    if (errorMessage != null) {
      return Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    return Text(
      subtitle,
      style: TextStyle(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        fontSize: 13,
      ),
    );
  }

  Widget _buildModeBadge(BuildContext context) {
    final theme = Theme.of(context);
    final (color, icon, label) = switch (mode) {
      CrudDialogMode.create => (
          Colors.green,
          Icons.add_circle_outline,
          'Novo'
        ),
      CrudDialogMode.view => (
          Colors.blue,
          Icons.visibility_outlined,
          'Visualizando'
        ),
      CrudDialogMode.edit => (Colors.orange, Icons.edit_outlined, 'Editando'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: switch (mode) {
        CrudDialogMode.create => _buildCreateButtons(context),
        CrudDialogMode.view => _buildViewButtons(context),
        CrudDialogMode.edit => _buildEditButtons(context),
      },
    );
  }

  /// Botões para modo CREATE: [Cancelar] [Salvar]
  Widget _buildCreateButtons(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSaving
                ? null
                : (onCancel ?? () => Navigator.of(context).pop()),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              side: BorderSide(color: theme.colorScheme.outline),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: (isSaving || !canSave) ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              disabledBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: isSaving
                ? SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : const Text(
                    'Salvar',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  /// Botões para modo VIEW: [Cancelar] [Editar]
  Widget _buildViewButtons(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Botão de cancelar/fechar (outline)
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              side: BorderSide(color: theme.colorScheme.outline),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Botão de editar (primário)
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onModeChange != null
                ? () => onModeChange!(CrudDialogMode.edit)
                : null,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Editar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  /// Botões para modo EDIT: [Cancelar] [Salvar Alterações]
  Widget _buildEditButtons(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Cancelar (volta para view se veio de view, ou fecha)
        Expanded(
          child: OutlinedButton(
            onPressed: isSaving
                ? null
                : () {
                    if (onModeChange != null) {
                      onModeChange!(CrudDialogMode.view);
                    } else {
                      (onCancel ?? () => Navigator.of(context).pop())();
                    }
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              side: BorderSide(color: theme.colorScheme.outline),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Salvar alterações
        Expanded(
          child: ElevatedButton(
            onPressed: (isSaving || !canSave) ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              disabledBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: isSaving
                ? SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : const Text(
                    'Salvar',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }
}

/// Helper para mostrar o CrudFormDialog
Future<T?> showCrudFormDialog<T>({
  required BuildContext context,
  required CrudDialogMode initialMode,
  required String title,
  required String subtitle,
  required IconData headerIcon,
  required Widget Function(CrudDialogMode mode) contentBuilder,
  void Function(CrudDialogMode)? onModeChange,
  VoidCallback? onSave,
  VoidCallback? onDelete,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => CrudFormDialog(
      mode: initialMode,
      title: title,
      subtitle: subtitle,
      headerIcon: headerIcon,
      content: contentBuilder(initialMode),
      onModeChange: onModeChange,
      onSave: onSave,
      onDelete: onDelete,
    ),
  );
}
