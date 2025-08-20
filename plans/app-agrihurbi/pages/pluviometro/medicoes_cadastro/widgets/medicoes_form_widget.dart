// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/widgets/dialog_cadastro_widget.dart';
import '../../../../models/medicoes_models.dart';
import '../controllers/medicoes_cadastro_controller.dart';
import '../services/error_handling/error_handler_service.dart';
import 'datetime_section_widget.dart';
import 'observacoes_section_widget.dart';
import 'quantidade_section_widget.dart';

Future<bool?> medicoesCadastro(BuildContext context, Medicoes? medicao) {
  final formWidgetKey = GlobalKey<MedicoesFormWidgetState>();

  return DialogCadastro.show(
    context: context,
    title: 'Medição',
    maxHeight: _calculateDialogHeight(context),
    formKey: formWidgetKey,
    onSubmit: () {
      formWidgetKey.currentState?._submit();
    },
    formWidget: (formKey) => MedicoesFormWidget(
      key: formKey,
      medicao: medicao,
    ),
  );
}

/// Calcula altura dinâmica do dialog baseada no viewport
double _calculateDialogHeight(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  // Altura base para campos obrigatórios
  double baseHeight = 320; // Data/hora + quantidade + botões

  // Adiciona altura para observações
  baseHeight += 120; // Campo de observações com 3 linhas

  // Ajusta para orientação
  if (screenWidth > screenHeight) {
    // Landscape - usar mais altura disponível
    baseHeight = (screenHeight * 0.8).clamp(400, 600);
  } else {
    // Portrait - altura conservadora
    baseHeight = (screenHeight * 0.6).clamp(350, 550);
  }

  return baseHeight;
}

class MedicoesFormWidget extends StatefulWidget {
  final Medicoes? medicao;

  const MedicoesFormWidget({super.key, this.medicao});

  @override
  MedicoesFormWidgetState createState() => MedicoesFormWidgetState();
}

class MedicoesFormWidgetState extends State<MedicoesFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _controller = MedicoesCadastroController();
  final _errorHandler = ErrorHandlerService();

  late double _quantidade;
  late int _dtMedicao;
  String? _observacoes;

  @override
  void initState() {
    super.initState();
    _dtMedicao = DateTime.now().millisecondsSinceEpoch;
    _initializeValues();
  }

  void _initializeValues() {
    if (widget.medicao != null) {
      _quantidade = widget.medicao!.quantidade;
      _observacoes = widget.medicao!.observacoes;
    } else {
      _quantidade = 0;
      _observacoes = null;
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final result = await _controller.saveMedicao(
      createdAt: widget.medicao?.createdAt,
      quantidade: _quantidade,
      dtMedicao: _dtMedicao,
      id: widget.medicao?.id,
      fkPluviometro: widget.medicao?.fkPluviometro,
      observacoes: _observacoes,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.of(context).pop(true);
    } else {
      final userMessage = result.error != null
          ? _errorHandler.getUserFriendlyMessage(result.error!)
          : 'Erro desconhecido ao salvar medição';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DateTimeSectionWidget(
            dtMedicao: _dtMedicao,
            onDateTimeChanged: (value) => setState(() => _dtMedicao = value),
          ),
          QuantidadeSectionWidget(
            quantidade: _quantidade,
            onQuantidadeChanged: (value) => setState(() => _quantidade = value),
          ),
          ObservacoesSectionWidget(
            observacoes: _observacoes,
            onObservacoesChanged: (value) =>
                setState(() => _observacoes = value),
          ),
        ],
      ),
    );
  }
}
