import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../controller/favoritos_controller.dart';
import '../services/favoritos_data_service.dart';
import '../services/favoritos_search_service.dart';
import '../services/favoritos_ui_state_service.dart';
import '../services/favoritos_hive_repository.dart';

class FavoritosProviders {
  static List<SingleChildWidget> get providers => [
    ChangeNotifierProvider<FavoritosDataService>(
      create: (_) => FavoritosDataService(
        repository: FavoritosHiveRepository(),
      ),
    ),
    ChangeNotifierProvider<FavoritosUIStateService>(
      create: (_) => FavoritosUIStateService(),
    ),
    ChangeNotifierProvider<FavoritosSearchService>(
      create: (context) => FavoritosSearchService(
        dataService: context.read<FavoritosDataService>(),
      ),
    ),
    ChangeNotifierProvider<FavoritosController>(
      create: (context) => FavoritosController(
        dataService: context.read<FavoritosDataService>(),
        searchService: context.read<FavoritosSearchService>(),
        uiStateService: context.read<FavoritosUIStateService>(),
      ),
    ),
  ];
}