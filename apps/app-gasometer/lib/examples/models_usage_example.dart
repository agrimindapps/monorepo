import 'package:hive/hive.dart';
import '../features/vehicles/data/models/vehicle_model.dart';
import '../features/fuel/data/models/fuel_supply_model.dart';
import '../features/odometer/data/models/odometer_model.dart';
import '../features/expenses/data/models/expense_model.dart';
import '../features/maintenance/data/models/maintenance_model.dart';
import '../core/data/models/category_model.dart';

/// Example of how to use the migrated Hive models
/// All models maintain the original properties and behavior
/// 
/// TypeIDs (sequential from 0):
/// - VehicleModel: 0
/// - FuelSupplyModel: 1  
/// - OdometerModel: 2
/// - ExpenseModel: 3
/// - MaintenanceModel: 4
/// - CategoryModel: 5
class ModelsUsageExample {
  
  static Future<void> demonstrateModelsUsage() async {
    // Open Hive boxes
    final vehiclesBox = await Hive.openBox<VehicleModel>('vehicles');
    final fuelSuppliesBox = await Hive.openBox<FuelSupplyModel>('fuel_supplies');
    final odometerBox = await Hive.openBox<OdometerModel>('odometer_readings');
    final expensesBox = await Hive.openBox<ExpenseModel>('expenses');
    final maintenanceBox = await Hive.openBox<MaintenanceModel>('maintenance');
    final categoriesBox = await Hive.openBox<CategoryModel>('categories');

    // 1. Create a vehicle
    final vehicle = VehicleModel(
      marca: 'Toyota',
      modelo: 'Corolla',
      ano: 2020,
      placa: 'ABC-1234',
      odometroInicial: 10000.0,
      combustivel: 1, // Flex
      cor: 'Prata',
      odometroAtual: 15000.0,
    );

    await vehiclesBox.add(vehicle);
    print('✅ Vehicle created: ${vehicle.marca} ${vehicle.modelo}');

    // 2. Create fuel supply record
    final fuelSupply = FuelSupplyModel(
      veiculoId: vehicle.id!,
      data: DateTime.now().millisecondsSinceEpoch,
      odometro: 15050.0,
      litros: 40.0,
      valorTotal: 280.0,
      precoPorLitro: 7.00,
      tanqueCheio: true,
      posto: 'Posto Shell',
      observacao: 'Abastecimento completo',
      tipoCombustivel: 1,
    );

    await fuelSuppliesBox.add(fuelSupply);
    print('✅ Fuel supply recorded: ${fuelSupply.litros}L for R\$${fuelSupply.valorTotal}');

    // Calculate consumption with previous odometer
    final consumption = fuelSupply.calcularConsumoCorreto(15000.0);
    print('📊 Consumption: ${consumption.toStringAsFixed(2)} km/L');

    // 3. Create odometer reading
    final odometerReading = OdometerModel(
      idVeiculo: vehicle.id!,
      data: DateTime.now().millisecondsSinceEpoch,
      odometro: 15050.0,
      descricao: 'Leitura após abastecimento',
      tipoRegistro: 'manual',
    );

    await odometerBox.add(odometerReading);
    print('✅ Odometer reading: ${odometerReading.odometro} km');

    // 4. Create expense
    final expense = ExpenseModel(
      veiculoId: vehicle.id!,
      tipo: 'Manutenção',
      descricao: 'Troca de óleo e filtros',
      valor: 150.0,
      data: DateTime.now().millisecondsSinceEpoch,
      odometro: 15050.0,
    );

    await expensesBox.add(expense);
    print('✅ Expense recorded: ${expense.descricao} - R\$${expense.valor}');

    // 5. Create maintenance record
    final maintenance = MaintenanceModel(
      veiculoId: vehicle.id!,
      tipo: 'Preventiva',
      descricao: 'Troca de óleo e filtros',
      valor: 150.0,
      data: DateTime.now().millisecondsSinceEpoch,
      odometro: 15050,
      concluida: true,
    );

    await maintenanceBox.add(maintenance);
    print('✅ Maintenance recorded: ${maintenance.descricao}');

    // 6. Create category
    final category = CategoryModel(
      categoria: 1,
      descricao: 'Combustível',
    );

    await categoriesBox.add(category);
    print('✅ Category created: ${category.descricao}');

    // 7. Demonstrate data queries
    print('\n📋 Data Summary:');
    print('- Vehicles: ${vehiclesBox.length}');
    print('- Fuel Supplies: ${fuelSuppliesBox.length}');
    print('- Odometer Readings: ${odometerBox.length}');
    print('- Expenses: ${expensesBox.length}');
    print('- Maintenance Records: ${maintenanceBox.length}');
    print('- Categories: ${categoriesBox.length}');

    // 8. Demonstrate business logic
    final allExpenses = expensesBox.values.toList();
    final totalExpenses = ExpenseModel.calcularTotalDespesas(allExpenses);
    print('\n💰 Total expenses: R\$${totalExpenses.toStringAsFixed(2)}');

    final allMaintenance = maintenanceBox.values.toList();
    final totalMaintenance = MaintenanceModel.calcularTotalManutencoes(allMaintenance);
    print('🔧 Total maintenance: R\$${totalMaintenance.toStringAsFixed(2)}');

    // 9. Demonstrate validation
    if (fuelSupply.validarCamposBasicos()) {
      print('✅ Fuel supply data is valid');
    }

    if (fuelSupply.validarConsistenciaFinanceira()) {
      print('✅ Financial consistency validated');
    }

    // Close boxes (optional, done automatically)
    // await vehiclesBox.close();
    // await fuelSuppliesBox.close();
    // await odometerBox.close();
    // await expensesBox.close();
    // await maintenanceBox.close();
    // await categoriesBox.close();

    print('\n🎉 All models working correctly!');
  }
}