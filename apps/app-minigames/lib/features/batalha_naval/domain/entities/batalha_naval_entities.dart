enum CellState { empty, ship, hit, miss }

enum GamePhase { placing, playing, gameOver }

enum ShipOrientation { horizontal, vertical }

class Ship {
  final String name;
  final int size;
  final List<List<int>> positions;
  int hits;

  Ship({
    required this.name,
    required this.size,
    this.positions = const [],
    this.hits = 0,
  });

  bool get isSunk => hits >= size;

  Ship copyWith({
    String? name,
    int? size,
    List<List<int>>? positions,
    int? hits,
  }) {
    return Ship(
      name: name ?? this.name,
      size: size ?? this.size,
      positions: positions ?? this.positions,
      hits: hits ?? this.hits,
    );
  }
}

class ShipType {
  final String name;
  final int size;

  const ShipType(this.name, this.size);

  static const List<ShipType> defaultFleet = [
    ShipType('Porta-Aviões', 5),
    ShipType('Encouraçado', 4),
    ShipType('Cruzador', 3),
    ShipType('Submarino', 3),
    ShipType('Destroyer', 2),
  ];
}
