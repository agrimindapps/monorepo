import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../auth/presentation/notifiers/notifiers.dart';
import '../../domain/services/account_service.dart';
import '../../domain/services/ui_feedback_service.dart';

/// Controller responsável pela lógica de negócio do perfil
class ProfileController {
  ProfileController(this._accountService, this._imageService);
  final AccountService _accountService;
  final LocalProfileImageService _imageService;

  /// Atualiza o nome do usuário
  Future<void> updateName(
    BuildContext context,
    WidgetRef ref,
    String name,
  ) async {
    try {
      UiFeedbackService.showImageProcessingDialog(
        context,
      ); // Reusing dialog for now

      final success = await _accountService.updateName(ref, name);

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Remove loading dialog

      if (success) {
        UiFeedbackService.showSuccessSnackBar(
          context,
          'Nome atualizado com sucesso!',
        );
      } else {
        UiFeedbackService.showErrorSnackBar(context, 'Erro ao atualizar nome');
      }
    } catch (e) {
      if (!context.mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      UiFeedbackService.showErrorSnackBar(
        context,
        'Erro inesperado ao atualizar nome',
      );
    }
  }

  /// Processa uma nova imagem selecionada para avatar
  Future<void> processNewAvatarImage(
    BuildContext context,
    WidgetRef ref,
    File imageFile,
  ) async {
    try {
      UiFeedbackService.showImageProcessingDialog(context);

      final validationResult = _imageService.validateImageFile(imageFile);
      if (validationResult.isLeft()) {
        Navigator.of(context).pop(); // Remove loading dialog
        UiFeedbackService.showErrorSnackBar(
          context,
          validationResult.fold((l) => l.message, (r) => ''),
        );
        return;
      }

      final result = await _imageService.processImageToBase64(imageFile);

      result.fold(
        (failure) {
          if (!context.mounted) return;
          Navigator.of(context).pop(); // Remove loading dialog
          UiFeedbackService.showErrorSnackBar(context, failure.message);
        },
        (base64String) async {
          final success = await _accountService.updateAvatar(ref, base64String);

          if (!context.mounted) return;
          Navigator.of(context).pop(); // Remove loading dialog

          if (success) {
            UiFeedbackService.showSuccessSnackBar(
              context,
              'Foto do perfil atualizada com sucesso!',
            );
          } else {
            final errorMsg = ref.read(authProvider).errorMessage;
            UiFeedbackService.showErrorSnackBar(
              context,
              errorMsg ?? 'Erro ao atualizar foto',
            );
          }
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Remove loading dialog
      }
      UiFeedbackService.showErrorSnackBar(
        context,
        'Erro inesperado ao processar imagem',
      );
    }
  }

  /// Remove a imagem atual do avatar
  Future<void> removeCurrentAvatar(BuildContext context, WidgetRef ref) async {
    try {
      final confirmed =
          await UiFeedbackService.showRemoveImageConfirmationDialog(context);
      if (!confirmed || !context.mounted) return;

      UiFeedbackService.showImageProcessingDialog(context);
      final success = await _accountService.removeAvatar(ref);

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Remove loading dialog

      if (success) {
        UiFeedbackService.showSuccessSnackBar(
          context,
          'Foto do perfil removida com sucesso!',
        );
      } else {
        final errorMsg = ref.read(authProvider).errorMessage;
        UiFeedbackService.showErrorSnackBar(
          context,
          errorMsg ?? 'Erro ao remover foto',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Remove loading dialog
      }
      UiFeedbackService.showErrorSnackBar(
        context,
        'Erro inesperado ao remover imagem',
      );
    }
  }

  /// Manipula a edição do avatar
  Future<void> handleEditAvatar(
    BuildContext context,
    bool hasAvatar,
    void Function(File) onImageSelected,
    VoidCallback? onRemoveImage,
  ) async {
    await HapticFeedback.lightImpact();

    if (!context.mounted) return;
    await ProfileImagePickerWidget.show(
      context: context,
      hasCurrentImage: hasAvatar,
      onImageSelected: onImageSelected,
      onRemoveImage: onRemoveImage,
    );
  }

  /// Realiza logout do usuário
  Future<void> performLogout(BuildContext context, WidgetRef ref) async {
    try {
      await _accountService.logout(ref);
      if (context.mounted) {
        UiFeedbackService.showSuccessSnackBar(
          context,
          'Logout realizado com sucesso',
        );
        // TODO: Navigate to home or login page
      }
    } catch (e) {
      if (context.mounted) {
        UiFeedbackService.showErrorSnackBar(
          context,
          'Erro ao sair: ${e.toString()}',
        );
      }
    }
  }
}
