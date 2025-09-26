import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/receituagro_navigation_service.dart';
import 'package:get_it/get_it.dart';
import '../../../core/repositories/fitossanitario_hive_repository.dart';
import '../../../core/repositories/pragas_hive_repository.dart';
import '../../../core/services/diagnostico_integration_service.dart';
import '../../detalhes_diagnostico/detalhe_diagnostico_page.dart';
import '../models/favorito_defensivo_model.dart';
import '../models/favorito_diagnostico_model.dart';
import '../models/favorito_praga_model.dart';

/// Serviço de navegação inteligente para favoritos
/// Usa dados reais dos repositórios para navegação correta
class FavoritosNavigationService {
  final FitossanitarioHiveRepository _fitossanitarioRepository;
  final PragasHiveRepository _pragasRepository;
  final DiagnosticoIntegrationService _integrationService;

  FavoritosNavigationService({
    required FitossanitarioHiveRepository fitossanitarioRepository,
    required PragasHiveRepository pragasRepository,
    required DiagnosticoIntegrationService integrationService,
  })  : _fitossanitarioRepository = fitossanitarioRepository,
        _pragasRepository = pragasRepository,
        _integrationService = integrationService;

  /// Navega para detalhes do defensivo com dados reais
  Future<void> navigateToDefensivoDetails(
    BuildContext context,
    FavoritoDefensivoModel defensivo,
  ) async {
    try {
      // Busca dados atualizados do defensivo
      final defensivoReal = _fitossanitarioRepository.getById(defensivo.idReg);
      
      if (defensivoReal != null) {
        final navigationService = GetIt.instance<ReceitaAgroNavigationService>();
        await navigationService.navigateToDetalheDefensivo(
          defensivoName: defensivoReal.nomeComum.isNotEmpty
              ? defensivoReal.nomeComum
              : defensivoReal.nomeTecnico,
          extraData: {'fabricante': defensivoReal.fabricante ?? 'Fabricante não informado'},
        );
      } else {
        _showNotFoundError(context, 'Defensivo não encontrado');
      }
    } catch (e) {
      _showNavigationError(context, 'Erro ao abrir detalhes do defensivo');
    }
  }

  /// Navega para detalhes da praga com dados reais
  Future<void> navigateToPragaDetails(
    BuildContext context,
    FavoritoPragaModel praga,
  ) async {
    try {
      // Busca dados atualizados da praga
      final pragaReal = _pragasRepository.getById(praga.idReg);
      
      if (pragaReal != null) {
        final navigationService = GetIt.instance<ReceitaAgroNavigationService>();
        await navigationService.navigateToDetalhePraga(
          pragaName: pragaReal.nomeComum,
          pragaId: pragaReal.idReg, // Use ID for better precision
          pragaScientificName: pragaReal.nomeCientifico.isNotEmpty
              ? pragaReal.nomeCientifico
              : 'Nome científico não disponível',
        );
      } else {
        _showNotFoundError(context, 'Praga não encontrada');
      }
    } catch (e) {
      _showNavigationError(context, 'Erro ao abrir detalhes da praga');
    }
  }

  /// Navega para detalhes do diagnóstico com dados relacionais completos
  Future<void> navigateToDiagnosticoDetails(
    BuildContext context,
    FavoritoDiagnosticoModel diagnostico,
  ) async {
    try {
      // Busca diagnóstico completo com dados relacionais
      final diagnosticoCompleto = await _integrationService.getDiagnosticoCompleto(diagnostico.idReg);
      
      if (diagnosticoCompleto != null) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalheDiagnosticoPage(
              diagnosticoId: diagnosticoCompleto.diagnostico.objectId,
              nomeDefensivo: diagnosticoCompleto.nomeDefensivo,
              nomePraga: diagnosticoCompleto.nomePraga,
              cultura: diagnosticoCompleto.nomeCultura,
            ),
          ),
        );
      } else {
        _showNotFoundError(context, 'Diagnóstico não encontrado');
      }
    } catch (e) {
      _showNavigationError(context, 'Erro ao abrir detalhes do diagnóstico');
    }
  }

  /// Navega para página de cultura específica
  Future<void> navigateToCulturaPage(
    BuildContext context,
    String culturaId,
    String culturaNome,
  ) async {
    try {
      // Aqui seria a navegação para a página específica da cultura
      // Por enquanto mostra um diálogo informativo
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Cultura: $culturaNome'),
          content: Text('Navegação para detalhes da cultura $culturaNome\n\nID: $culturaId'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showNavigationError(context, 'Erro ao abrir página da cultura');
    }
  }

  /// Navega para busca avançada com filtros pré-definidos
  Future<void> navigateToAdvancedSearch(
    BuildContext context, {
    String? culturaId,
    String? pragaId,
    String? defensivoId,
  }) async {
    try {
      // Aqui seria a navegação para busca avançada com filtros
      final filtros = <String, String>{};
      if (culturaId != null) filtros['cultura'] = culturaId;
      if (pragaId != null) filtros['praga'] = pragaId;
      if (defensivoId != null) filtros['defensivo'] = defensivoId;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Busca Avançada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Navegação para busca avançada com filtros:'),
              const SizedBox(height: 8),
              ...filtros.entries.map((entry) =>
                Text('• ${entry.key}: ${entry.value}')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showNavigationError(context, 'Erro ao abrir busca avançada');
    }
  }

  /// Verifica se um item ainda existe nos repositórios
  Future<bool> isItemStillValid(String tipo, String itemId) async {
    try {
      switch (tipo) {
        case 'defensivos':
          return _fitossanitarioRepository.getById(itemId) != null;
        case 'pragas':
          return _pragasRepository.getById(itemId) != null;
        case 'diagnosticos':
          final diagnostico = await _integrationService.getDiagnosticoCompleto(itemId);
          return diagnostico != null;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Obtém informações resumidas de um item para exibição
  Future<Map<String, String>?> getItemSummary(String tipo, String itemId) async {
    try {
      switch (tipo) {
        case 'defensivos':
          final item = _fitossanitarioRepository.getById(itemId);
          if (item != null) {
            return {
              'nome': item.nomeComum.isNotEmpty ? item.nomeComum : item.nomeTecnico,
              'subtitulo': item.ingredienteAtivo ?? 'Ingrediente não informado',
              'detalhes': '${item.fabricante} • ${item.classeAgronomica}',
            };
          }
          break;
        case 'pragas':
          final item = _pragasRepository.getById(itemId);
          if (item != null) {
            return {
              'nome': item.nomeComum,
              'subtitulo': item.nomeCientifico.isNotEmpty 
                  ? item.nomeCientifico 
                  : 'Nome científico não disponível',
              'detalhes': 'Praga agrícola',
            };
          }
          break;
        case 'diagnosticos':
          final item = await _integrationService.getDiagnosticoCompleto(itemId);
          if (item != null) {
            return {
              'nome': '${item.nomeDefensivo} para ${item.nomePraga}',
              'subtitulo': item.nomeCultura,
              'detalhes': 'Dosagem: ${item.dosagem}',
            };
          }
          break;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Mostra erro de item não encontrado
  void _showNotFoundError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'Atualizar Favoritos',
          onPressed: () {
            // Aqui poderia triggerar uma atualização dos favoritos
          },
        ),
      ),
    );
  }

  /// Mostra erro de navegação
  void _showNavigationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Limpa cache de navegação se necessário
  void clearNavigationCache() {
    // Implementar se houver cache específico de navegação
  }
}