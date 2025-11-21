# 🧪 Padrões de Testes

Testes são obrigatórios para manter o "Gold Standard". Usamos `mocktail` pela simplicidade e performance.

## Ferramentas
*   **Framework**: `flutter_test`
*   **Mocking**: `mocktail` (Não use `mockito` com build_runner se possível, para agilidade).
*   **Helpers**: `faker` (opcional para dados aleatórios).

## Estrutura do Teste (AAA)
Todo teste deve seguir visualmente o padrão Arrange-Act-Assert.

```dart
test('should return Right(Plant) when repository succeeds', () async {
  // Arrange
  when(() => mockRepository.addPlant(any())).thenAnswer((_) async => Right(tPlant));
  
  // Act
  final result = await useCase(params);
  
  // Assert
  expect(result, Right(tPlant));
  verify(() => mockRepository.addPlant(any())).called(1);
});
```

## O Que Testar

### 1. Use Cases (Prioridade Alta)
*   **Sucesso**: O repositório retorna dados corretamente.
*   **Falha de Validação**: Parâmetros inválidos retornam `Left(ValidationFailure)`.
*   **Falha de Repositório**: Erros do repositório (Server/Cache) são propagados corretamente.

### 2. Repositories (Impl)
*   **Conversão**: Verifica se `Model` é convertido corretamente para `Entity`.
*   **Exceções**: Verifica se `try/catch` captura exceções do DataSource e retorna `Failure`.
*   **Offline-first**: Verifica se tenta LocalDataSource antes/depois do RemoteDataSource.

### 3. Notifiers (Riverpod)
*   **Estado Inicial**: Verifica o estado no `build()`.
*   **Fluxo de Sucesso**: `isLoading` -> `data`.
*   **Fluxo de Erro**: `isLoading` -> `error`.

## Setup Padrão (Mocktail)

```dart
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockPlantsRepository extends Mock implements PlantsRepository {}
class FakePlant extends Fake implements Plant {}

void main() {
  late AddPlantUseCase useCase;
  late MockPlantsRepository mockRepository;

  setUpAll(() {
    // Registrar fallbacks para tipos customizados
    registerFallbackValue(FakePlant());
    registerFallbackValue(const AddPlantParams(name: 'Test'));
  });

  setUp(() {
    mockRepository = MockPlantsRepository();
    useCase = AddPlantUseCase(mockRepository);
  });
  
  // ... tests
}
```
