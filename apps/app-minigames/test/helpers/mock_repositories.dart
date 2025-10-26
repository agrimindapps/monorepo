import 'package:mocktail/mocktail.dart';
import 'package:app_minigames/features/memory/domain/repositories/memory_repository.dart';
import 'package:app_minigames/features/memory/domain/usecases/generate_cards_usecase.dart';
import 'package:app_minigames/features/snake/domain/repositories/snake_repository.dart';

class MockMemoryRepository extends Mock implements MemoryRepository {}

class MockGenerateCardsUseCase extends Mock implements GenerateCardsUseCase {}

class MockSnakeRepository extends Mock implements SnakeRepository {}
