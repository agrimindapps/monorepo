import 'package:flutter/foundation.dart' show mustCallSuper;

abstract class IFavoritosRepository {
  @mustCallSuper
  Future<void> addFavorito(dynamic favorito);
  @mustCallSuper
  Future<void> removeFavorito(dynamic favorito);
  @mustCallSuper
  List<dynamic> getAllFavoritos();
  @mustCallSuper
  bool isFavorito(dynamic item);
}