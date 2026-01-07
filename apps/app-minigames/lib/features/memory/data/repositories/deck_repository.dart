import 'package:app_minigames/features/memory/domain/entities/deck_configuration.dart';

class DeckRepository {
  static const List<DeckConfiguration> availableDecks = [
    // Classic deck is implicit (null config)
    
    // Example Deck 1 (Placeholder)
    DeckConfiguration(
      id: 'animals_deck',
      name: 'Animais',
      assetPath: 'assets/memory_decks/animals.png',
      rows: 4,
      columns: 5,
      spriteWidth: 200,
      spriteHeight: 200,
      totalSprites: 20,
    ),
    
    // Example Deck 2 (Placeholder)
    DeckConfiguration(
      id: 'fruits_deck',
      name: 'Frutas',
      assetPath: 'assets/memory_decks/fruits.png',
      rows: 4,
      columns: 4,
      spriteWidth: 150,
      spriteHeight: 150,
      totalSprites: 16,
    ),
  ];
  
  static DeckConfiguration? getDeckById(String id) {
    try {
      return availableDecks.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}
