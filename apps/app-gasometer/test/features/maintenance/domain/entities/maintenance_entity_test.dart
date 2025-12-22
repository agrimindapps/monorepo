import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer_drift/features/maintenance/domain/entities/maintenance_entity.dart';

void main() {
  group('MaintenanceEntity', () {
    final testMaintenance = MaintenanceEntity(
      id: 'test-id',
      vehicleId: 'vehicle-001',
      type: MaintenanceType.preventive,
      status: MaintenanceStatus.completed,
      title: 'Troca de óleo',
      description: 'Troca de óleo e filtros',
      cost: 250.0,
      serviceDate: DateTime(2024, 1, 15),
      odometer: 15000.0,
      workshopName: 'Auto Center ABC',
      workshopPhone: '(11) 98765-4321',
      workshopAddress: 'Rua Test, 123',
      nextServiceDate: DateTime(2024, 7, 15),
      nextServiceOdometer: 20000.0,
      photosPaths: ['/path/photo1.jpg'],
      invoicesPaths: ['/path/invoice.pdf'],
      parts: {'Óleo': '5W30', 'Filtro': 'ABC-123'},
      notes: 'Tudo OK',
      metadata: {'mechanic': 'João'},
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
      userId: 'user-001',
      moduleName: 'gasometer',
    );

    test('should create maintenance entity with all fields', () {
      expect(testMaintenance.id, 'test-id');
      expect(testMaintenance.vehicleId, 'vehicle-001');
      expect(testMaintenance.type, MaintenanceType.preventive);
      expect(testMaintenance.status, MaintenanceStatus.completed);
      expect(testMaintenance.title, 'Troca de óleo');
      expect(testMaintenance.cost, 250.0);
      expect(testMaintenance.odometer, 15000.0);
      expect(testMaintenance.workshopName, 'Auto Center ABC');
    });

    test('should identify status correctly', () {
      expect(testMaintenance.isCompleted, true);
      expect(testMaintenance.isPending, false);
      expect(testMaintenance.isInProgress, false);
      expect(testMaintenance.isCancelled, false);
    });

    test('should identify type correctly', () {
      expect(testMaintenance.isPreventive, true);
      expect(testMaintenance.isCorrective, false);
      expect(testMaintenance.isInspection, false);
      expect(testMaintenance.isEmergency, false);
    });

    test('should detect workshop info presence', () {
      expect(testMaintenance.hasWorkshopInfo, true);
      
      final withoutWorkshop = testMaintenance.copyWith(clearWorkshop: true);
      expect(withoutWorkshop.hasWorkshopInfo, false);
    });

    test('should detect next service info', () {
      expect(testMaintenance.hasNextService, true);
      
      final withoutNext = testMaintenance.copyWith(clearNextService: true);
      expect(withoutNext.hasNextService, false);
    });

    test('should detect photos presence', () {
      expect(testMaintenance.hasPhotos, true);
      
      final withoutPhotos = testMaintenance.copyWith(photosPaths: []);
      expect(withoutPhotos.hasPhotos, false);
    });

    test('should detect invoices presence', () {
      expect(testMaintenance.hasInvoices, true);
      
      final withoutInvoices = testMaintenance.copyWith(invoicesPaths: []);
      expect(withoutInvoices.hasInvoices, false);
    });

    test('should detect parts presence', () {
      expect(testMaintenance.hasParts, true);
      
      final withoutParts = testMaintenance.copyWith(parts: {});
      expect(withoutParts.hasParts, false);
    });

    test('should detect notes presence', () {
      expect(testMaintenance.hasNotes, true);
      
      final withoutNotes = testMaintenance.copyWith(notes: '');
      expect(withoutNotes.hasNotes, false);
    });

    test('should calculate days since service', () {
      final recent = testMaintenance.copyWith(
        serviceDate: DateTime.now().subtract(const Duration(days: 10)),
      );
      expect(recent.daysSinceService, 10);
    });

    test('should calculate kilometers from last service', () {
      final km = testMaintenance.kilometersFromLastService(18000.0);
      expect(km, 3000.0);
    });

    test('should detect if next service is due by odometer', () {
      // Remove date to test only odometer
      final maintenanceWithoutDate = testMaintenance.copyWith(clearNextService: true);
      final withOdometerOnly = maintenanceWithoutDate.copyWith(
        nextServiceOdometer: 20000.0,
      );
      
      final isDue = withOdometerOnly.isNextServiceDue(21000.0);
      expect(isDue, true);
      
      final notDue = withOdometerOnly.isNextServiceDue(19000.0);
      expect(notDue, false);
    });

    test('should detect if next service is due by date', () {
      final pastDate = testMaintenance.copyWith(
        nextServiceDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(pastDate.isNextServiceDue(0.0), true);
    });

    test('should calculate urgency level - overdue', () {
      final overdue = testMaintenance.copyWith(
        nextServiceDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(overdue.urgencyLevel, 'overdue');
      expect(overdue.urgencyDisplayName, 'Vencida');
    });

    test('should calculate urgency level - urgent', () {
      final urgent = testMaintenance.copyWith(
        nextServiceDate: DateTime.now().add(const Duration(days: 5)),
      );
      expect(urgent.urgencyLevel, 'urgent');
      expect(urgent.urgencyDisplayName, 'Urgente');
    });

    test('should calculate urgency level - soon', () {
      final soon = testMaintenance.copyWith(
        nextServiceDate: DateTime.now().add(const Duration(days: 20)),
      );
      expect(soon.urgencyLevel, 'soon');
      expect(soon.urgencyDisplayName, 'Em Breve');
    });

    test('should calculate urgency level - normal', () {
      final normal = testMaintenance.copyWith(
        nextServiceDate: DateTime.now().add(const Duration(days: 60)),
      );
      expect(normal.urgencyLevel, 'normal');
      expect(normal.urgencyDisplayName, 'Normal');
    });

    test('should format cost as Brazilian currency', () {
      expect(testMaintenance.formattedCost, 'R\$ 250,00');
    });

    test('should format odometer', () {
      expect(testMaintenance.formattedOdometer, '15000 km');
    });

    test('should copy with new values', () {
      final updated = testMaintenance.copyWith(
        title: 'Revisão completa',
        cost: 500.0,
      );

      expect(updated.title, 'Revisão completa');
      expect(updated.cost, 500.0);
      expect(updated.vehicleId, 'vehicle-001'); // unchanged
    });

    test('should mark as dirty', () {
      final dirty = testMaintenance.markAsDirty();
      
      expect(dirty.isDirty, true);
      expect(dirty.updatedAt!.isAfter(testMaintenance.updatedAt!), true);
    });

    test('should mark as synced', () {
      final synced = testMaintenance.markAsSynced();
      
      expect(synced.isDirty, false);
      expect(synced.lastSyncAt, isNotNull);
    });

    test('should mark as deleted', () {
      final deleted = testMaintenance.markAsDeleted();
      
      expect(deleted.isDeleted, true);
      expect(deleted.isDirty, true);
    });

    test('should increment version', () {
      final incremented = testMaintenance.incrementVersion();
      
      expect(incremented.version, testMaintenance.version + 1);
    });

    test('should use equality correctly', () {
      final maintenance1 = testMaintenance;
      final maintenance2 = testMaintenance.copyWith();
      final maintenance3 = testMaintenance.copyWith(title: 'Different');

      expect(maintenance1, equals(maintenance2));
      expect(maintenance1, isNot(equals(maintenance3)));
    });
  });

  group('MaintenanceType', () {
    test('should have correct display names', () {
      expect(MaintenanceType.preventive.displayName, 'Preventiva');
      expect(MaintenanceType.corrective.displayName, 'Corretiva');
      expect(MaintenanceType.inspection.displayName, 'Revisão');
      expect(MaintenanceType.emergency.displayName, 'Emergencial');
    });

    test('should identify recurring types', () {
      expect(MaintenanceType.preventive.isRecurring, true);
      expect(MaintenanceType.inspection.isRecurring, true);
      expect(MaintenanceType.corrective.isRecurring, false);
      expect(MaintenanceType.emergency.isRecurring, false);
    });

    test('should have icon names', () {
      expect(MaintenanceType.preventive.iconName, 'build_circle');
      expect(MaintenanceType.corrective.iconName, 'build');
      expect(MaintenanceType.inspection.iconName, 'fact_check');
      expect(MaintenanceType.emergency.iconName, 'warning');
    });

    test('should have color values', () {
      expect(MaintenanceType.preventive.colorValue, 0xFF4CAF50);
      expect(MaintenanceType.corrective.colorValue, 0xFFFF9800);
      expect(MaintenanceType.inspection.colorValue, 0xFF2196F3);
      expect(MaintenanceType.emergency.colorValue, 0xFFF44336);
    });
  });

  group('MaintenanceStatus', () {
    test('should have correct display names', () {
      expect(MaintenanceStatus.pending.displayName, 'Pendente');
      expect(MaintenanceStatus.inProgress.displayName, 'Em Andamento');
      expect(MaintenanceStatus.completed.displayName, 'Concluída');
      expect(MaintenanceStatus.cancelled.displayName, 'Cancelada');
    });

    test('should have color values', () {
      expect(MaintenanceStatus.pending.colorValue, 0xFFFF9800);
      expect(MaintenanceStatus.inProgress.colorValue, 0xFF2196F3);
      expect(MaintenanceStatus.completed.colorValue, 0xFF4CAF50);
      expect(MaintenanceStatus.cancelled.colorValue, 0xFF9E9E9E);
    });
  });
}
