# Plano de Atualização Automática de Odômetro

## ✅ Concluído

### 1. VehicleRepository
- ✅ Criado método `updateVehicleOdometer(vehicleId, newOdometer)`
- ✅ Lógica: só atualiza se novo odômetro > odômetro atual
- ✅ Marca registro como dirty para sync

### 2. FuelRepository
- ✅ Adicionada dependência `VehicleRepository`
- ✅ Chamada `updateVehicleOdometer` em `addFuelRecord`
- ✅ Chamada `updateVehicleOdometer` em `updateFuelRecord`
- ✅ Provider atualizado

### 3. ExpensesRepository  
- ✅ Adicionada dependência `VehicleRepository`
- ⏳ Chamada `updateVehicleOdometer` em `saveExpense` - PENDENTE
- ⏳ Chamada `updateVehicleOdometer` em `updateExpense` - PENDENTE
- ⏳ Provider atualizado - PENDENTE

## ⏳ Pendente

### 4. MaintenanceRepository
- ⏳ Adicionar dependência `VehicleRepository`
- ⏳ Importar `VehicleRepository`
- ⏳ Chamar `updateVehicleOdometer` em `addMaintenanceRecord`
- ⏳ Chamar `updateVehicleOdometer` em `updateMaintenanceRecord`
- ⏳ Atualizar provider

### 5. OdometerRepository
- ⏳ Adicionar dependência `VehicleRepository`
- ⏳ Importar `VehicleRepository`
- ⏳ Chamar `updateVehicleOdometer` em `addOdometerReading`
- ⏳ Chamar `updateVehicleOdometer` em `updateOdometerReading`
- ⏳ Atualizar provider

## Localizações

- **ExpensesRepository**: `/apps/app-gasometer/lib/features/expenses/data/repositories/expenses_repository_drift_impl.dart`
  - Métodos: `saveExpense` (linha ~69), `updateExpense` (precisa localizar)
  - Provider: `/apps/app-gasometer/lib/core/providers/dependency_providers.dart`

- **MaintenanceRepository**: `/apps/app-gasometer/lib/features/maintenance/data/repositories/maintenance_repository_drift_impl.dart`
  - Métodos: `addMaintenanceRecord`, `updateMaintenanceRecord`
  - Provider: `/apps/app-gasometer/lib/core/providers/dependency_providers.dart`

- **OdometerRepository**: `/apps/app-gasometer/lib/features/odometer/data/repositories/odometer_repository_drift_impl.dart`
  - Métodos: `addOdometerReading`, `updateOdometerReading`
  - Provider: `/apps/app-gasometer/lib/core/providers/dependency_providers.dart`

## Checklist de Atualização para Cada Repositório

1. **Imports**
   ```dart
   import '../../../vehicles/domain/repositories/vehicle_repository.dart';
   ```

2. **Construtor**
   ```dart
   final VehicleRepository _vehicleRepository;
   ```

3. **Após salvar/atualizar com sucesso**
   ```dart
   // Atualizar odômetro do veículo
   await _vehicleRepository.updateVehicleOdometer(
     vehicleId: int.parse(entity.vehicleId),
     newOdometer: entity.odometer,
   );
   ```

4. **Provider**
   ```dart
   final vehicleRepository = ref.watch(vehicleRepositoryProvider);
   // Adicionar ao construtor
   ```

## Nota sobre Odômetro em Expenses

⚠️ O `ExpenseEntity` tem campo `odometer` mas a tabela `ExpenseData` não! Precisa verificar se:
- Schema Drift precisa ser atualizado
- Ou se odometer não é usado em expenses
- Linha 46 do expenses_repository_drift_impl.dart: `odometer: 0.0, // Não temos este campo na tabela atual`
