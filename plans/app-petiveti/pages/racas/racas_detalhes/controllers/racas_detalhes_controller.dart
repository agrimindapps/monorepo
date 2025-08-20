// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/raca_detalhes_model.dart';
import '../views/racas_detalhes_page.dart';

class RacasDetalhesController extends ChangeNotifier {
  RacaDetalhes? _raca;
  bool _isFavorite = false;
  int _currentImageIndex = 0;

  RacaDetalhes? get raca => _raca;
  bool get isFavorite => _isFavorite;
  int get currentImageIndex => _currentImageIndex;

  void inicializarRaca(Object? arguments) {
    String? nomeRaca;
    
    if (arguments is String) {
      nomeRaca = arguments;
    } else if (arguments is Map<String, dynamic>) {
      nomeRaca = arguments['nome'] as String?;
    }

    if (nomeRaca != null) {
      _raca = RacaDetalhesRepository.getRacaOrDefault(nomeRaca);
      notifyListeners();
    }
  }

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
  }

  void updateImageIndex(int index) {
    if (_raca != null && index >= 0 && index < _raca!.galeria.length) {
      _currentImageIndex = index;
      notifyListeners();
    }
  }

  void navigateToRelatedBreed(BuildContext context, RacaRelacionada racaRelacionada) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const RacasDetalhesPage(),
        settings: RouteSettings(arguments: racaRelacionada.nome),
      ),
    );
  }

  void showImageGallery(BuildContext context) {
    if (_raca == null || _raca!.galeria.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ImageGalleryPage(
          images: _raca!.galeria,
          initialIndex: _currentImageIndex,
          heroTag: 'raca_image_${_raca!.nome}',
        ),
      ),
    );
  }

  void shareRaca(BuildContext context) {
    if (_raca == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartilhando informações sobre ${_raca!.nome}'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void showVeterinaryConsult(BuildContext context) {
    if (_raca == null) return;

    // Será implementado quando o modal estiver criado
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrindo consulta veterinária')),
    );
  }

  void shareVeterinaryInfo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Informações veterinárias compartilhadas'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// Widget auxiliar para galeria de imagens
class _ImageGalleryPage extends StatelessWidget {
  final List<String> images;
  final int initialIndex;
  final String heroTag;

  const _ImageGalleryPage({
    required this.images,
    required this.initialIndex,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Center(
            child: Hero(
              tag: index == initialIndex ? heroTag : 'gallery_$index',
              child: InteractiveViewer(
                child: Image.asset(
                  images[index],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

