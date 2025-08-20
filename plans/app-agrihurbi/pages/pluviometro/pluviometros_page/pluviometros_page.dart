// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../controllers/pluviometros_controller.dart';
import '../../../models/pluviometros_models.dart';
import '../pluviometros_cadastro/index.dart';
import 'error_handling/error_handler.dart';
import 'validation/pluviometro_validator.dart';
import 'views/pluviometros_view.dart';

class PluviometrosPage extends StatefulWidget {
  const PluviometrosPage({super.key});

  @override
  State<PluviometrosPage> createState() => _PluviometrosPageState();
}

class _PluviometrosPageState extends State<PluviometrosPage> {
  List<Pluviometro> pluviometros = [];
  bool isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarPluviometros();
  }

  Future<void> _carregarPluviometros() async {
    setState(() => isLoading = true);
    try {
      final pluviometrosList = await PluviometrosController().getPluviometros();

      // Validar cada pluviômetro carregado
      for (final pluviometro in pluviometrosList) {
        final validation = PluviometroValidator.validate(pluviometro);
        if (!validation.isValid) {
          debugPrint(
              'Pluviômetro ${pluviometro.id} possui erros de validação: ${validation.summary}');
        }
      }

      setState(() {
        pluviometros = pluviometrosList;
        _errorMessage = null;
      });
    } catch (e, stackTrace) {
      final errorResponse =
          PluviometroErrorHandler.instance.handleError(e, stackTrace);
      setState(() => _errorMessage = errorResponse.userMessage);

      // Mostrar dialog se necessário
      if (errorResponse.shouldShowDialog && mounted) {
        _showErrorDialog(errorResponse);
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _handleMenuAction(String action, Pluviometro pluviometro) {
    switch (action) {
      case 'edit':
        pluviometroCadastro(context, pluviometro)
            .then((_) => _carregarPluviometros());
        break;
      case 'delete':
        _confirmDeletePluviometro(pluviometro);
        break;
    }
  }

  void _confirmDeletePluviometro(Pluviometro pluviometro) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content:
            Text('Deseja excluir o pluviômetro "${pluviometro.descricao}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              // PluviometrosController().deletePluviometro(pluviometro).then((_) {
              //   _carregarPluviometros();
              // });
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(Pluviometro pluviometro) {
    // Implementar navegação para detalhes
  }

  Future<void> _handleAddNew() async {
    final result = await pluviometroCadastro(context, null);
    if (result == true) {
      _carregarPluviometros();
    }
  }

  void _showErrorDialog(ErrorResponse errorResponse) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorResponse.userMessage),
            if (errorResponse.canRetry) ...[
              const SizedBox(height: 16),
              const Text('Deseja tentar novamente?'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          if (errorResponse.canRetry)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Future.delayed(
                  errorResponse.retryDelay ?? Duration.zero,
                  _carregarPluviometros,
                );
              },
              child: const Text('Tentar Novamente'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PluviometrosView(
      isLoading: isLoading,
      errorMessage: _errorMessage,
      pluviometros: pluviometros,
      onRefresh: _carregarPluviometros,
      onMenuAction: _handleMenuAction,
      onTap: _navigateToDetail,
      onAddNew: _handleAddNew,
    );
  }
}
