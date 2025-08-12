// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../racas_lista/views/racas_lista_page.dart';
import '../models/especie_seletor_model.dart';

class RacasSeletorController extends ChangeNotifier {
  List<EspecieSeletor> _especies = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<EspecieSeletor> get especies => List.unmodifiable(_especies);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  Map<String, int> get estatisticas => EspecieSeletorRepository.getEstatisticas();

  void inicializar() {
    _carregarEspecies();
  }

  void _carregarEspecies() {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Simular carregamento (em uma implementação real, seria uma chamada à API)
      Future.delayed(const Duration(milliseconds: 500), () {
        _especies = EspecieSeletorRepository.getTodas();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'Erro ao carregar espécies: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void recarregar() {
    _carregarEspecies();
  }

  void navigateToEspecieRacas(BuildContext context, EspecieSeletor especie) {
    if (!especie.hasRacas) {
      _showNoRacasMessage(context, especie.nome);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RacasListaPage(),
        settings: RouteSettings(
          arguments: {
            'especie': especie.nome,
            'imagePath': especie.imagem,
            'totalRacas': especie.totalRacas,
          },
        ),
      ),
    );
  }

  void _showNoRacasMessage(BuildContext context, String nomeEspecie) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nenhuma raça disponível para $nomeEspecie ainda'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void showEspecieInfo(BuildContext context, EspecieSeletor especie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(especie.icone, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(especie.nome),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(especie.descricao),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.pets, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  especie.racasText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          if (especie.hasRacas)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                navigateToEspecieRacas(context, especie);
              },
              child: const Text('Ver Raças'),
            ),
        ],
      ),
    );
  }

  List<EspecieSeletor> getEspeciesPopulares() {
    return EspecieSeletorRepository.getPopulares();
  }

  EspecieSeletor? getEspeciePorNome(String nome) {
    return EspecieSeletorRepository.getEspeciePorNome(nome);
  }
}
