import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../data/models/vehicle_model.dart';

class VehiclesProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  late Box<VehicleModel> _localBox;
  
  List<VehicleEntity> _vehicles = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot>? _firestoreSubscription;
  
  VehiclesProvider({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _initialize();
  }
  
  List<VehicleEntity> get vehicles => _vehicles;
  List<VehicleEntity> get activeVehicles => _vehicles.where((v) => v.isActive).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get hasVehicles => _vehicles.isNotEmpty;
  int get vehicleCount => _vehicles.length;
  int get activeVehicleCount => activeVehicles.length;
  
  Future<void> _initialize() async {
    try {
      // Inicializar Hive box para armazenamento local
      _localBox = await Hive.openBox<VehicleModel>('vehicles');
      
      // Carregar dados locais primeiro
      await _loadLocalVehicles();
      
      // Escutar mudanças de autenticação
      _authSubscription = _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao inicializar: ${e.toString()}';
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  Future<void> _loadLocalVehicles() async {
    try {
      final localVehicles = _localBox.values
          .map((model) => model.toEntity())
          .toList();
      
      _vehicles = localVehicles;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar veículos locais: $e');
    }
  }
  
  void _onAuthStateChanged(User? user) {
    if (user != null && !user.isAnonymous) {
      _startFirestoreSync(user.uid);
    } else {
      _stopFirestoreSync();
      // Para usuários anônimos, manter apenas dados locais
      if (user?.isAnonymous == true) {
        _loadLocalVehicles();
      } else {
        _clearData();
      }
    }
  }
  
  void _startFirestoreSync(String userId) {
    _firestoreSubscription?.cancel();
    
    _firestoreSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .snapshots()
        .listen(
          (snapshot) => _onFirestoreSnapshot(snapshot, userId),
          onError: (error) {
            _errorMessage = 'Erro de sincronização: ${error.toString()}';
            notifyListeners();
          },
        );
  }
  
  void _stopFirestoreSync() {
    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
  }
  
  Future<void> _onFirestoreSnapshot(QuerySnapshot snapshot, String userId) async {
    try {
      final firestoreVehicles = snapshot.docs
          .map((doc) => VehicleModel.fromFirestore(doc).toEntity())
          .toList();
      
      // Sincronizar com dados locais
      await _syncWithLocal(firestoreVehicles, userId);
      
      _vehicles = firestoreVehicles;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao processar snapshot do Firestore: $e');
    }
  }
  
  Future<void> _syncWithLocal(List<VehicleEntity> firestoreVehicles, String userId) async {
    try {
      // Limpar box local
      await _localBox.clear();
      
      // Salvar dados do Firestore localmente
      for (final vehicle in firestoreVehicles) {
        final model = VehicleModel.fromEntity(vehicle);
        await _localBox.put(vehicle.id, model);
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar localmente: $e');
    }
  }
  
  void _clearData() {
    _vehicles = [];
    _localBox.clear();
    notifyListeners();
  }
  
  Future<bool> addVehicle(VehicleEntity vehicle) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }
      
      final newVehicle = vehicle.copyWith(
        userId: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      if (user.isAnonymous) {
        // Salvar apenas localmente para usuários anônimos
        final model = VehicleModel.fromEntity(newVehicle);
        await _localBox.put(newVehicle.id, model);
        
        _vehicles.add(newVehicle);
      } else {
        // Salvar no Firestore para usuários autenticados
        final model = VehicleModel.fromEntity(newVehicle);
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('vehicles')
            .doc(newVehicle.id)
            .set(model.toFirestore());
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao adicionar veículo: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateVehicle(VehicleEntity vehicle) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }
      
      final updatedVehicle = vehicle.copyWith(
        updatedAt: DateTime.now(),
      );
      
      if (user.isAnonymous) {
        // Atualizar apenas localmente para usuários anônimos
        final model = VehicleModel.fromEntity(updatedVehicle);
        await _localBox.put(updatedVehicle.id, model);
        
        final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
        if (index != -1) {
          _vehicles[index] = updatedVehicle;
        }
      } else {
        // Atualizar no Firestore para usuários autenticados
        final model = VehicleModel.fromEntity(updatedVehicle);
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('vehicles')
            .doc(updatedVehicle.id)
            .update(model.toFirestore());
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar veículo: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteVehicle(String vehicleId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }
      
      if (user.isAnonymous) {
        // Remover apenas localmente para usuários anônimos
        await _localBox.delete(vehicleId);
        _vehicles.removeWhere((v) => v.id == vehicleId);
      } else {
        // Remover do Firestore para usuários autenticados
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('vehicles')
            .doc(vehicleId)
            .delete();
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao remover veículo: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  VehicleEntity? getVehicleById(String vehicleId) {
    try {
      return _vehicles.firstWhere((v) => v.id == vehicleId);
    } catch (e) {
      return null;
    }
  }
  
  List<VehicleEntity> getVehiclesByType(VehicleType type) {
    return _vehicles.where((v) => v.type == type && v.isActive).toList();
  }
  
  List<VehicleEntity> getVehiclesByFuelType(FuelType fuelType) {
    return _vehicles.where((v) => 
        v.supportedFuels.contains(fuelType) && v.isActive).toList();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _authSubscription?.cancel();
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}