import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPremium = false;
  DateTime? _expirationDate;
  StreamSubscription<User?>? _authStream;
  
  PremiumProvider({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _initialize();
  }
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPremium => _isPremium;
  DateTime? get expirationDate => _expirationDate;
  bool get canPurchasePremium => !isAnonymousUser;
  
  bool get isAnonymousUser => _firebaseAuth.currentUser?.isAnonymous ?? false;
  
  String get subscriptionStatus {
    if (!_isPremium) return 'Gratuito';
    if (_expirationDate != null && _expirationDate!.isBefore(DateTime.now())) {
      return 'Expirado';
    }
    return 'Premium';
  }
  
  void _initialize() {
    // Escuta mudanças de autenticação
    _authStream = _firebaseAuth.authStateChanges().listen((user) {
      if (user != null && !user.isAnonymous) {
        _checkPremiumStatus();
      } else {
        _isPremium = false;
        _expirationDate = null;
        notifyListeners();
      }
    });
    
    // Verifica status inicial
    if (_firebaseAuth.currentUser != null && !_firebaseAuth.currentUser!.isAnonymous) {
      _checkPremiumStatus();
    }
  }
  
  Future<void> _checkPremiumStatus() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    
    try {
      final premiumDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subscriptions')
          .doc('premium')
          .get();
      
      if (premiumDoc.exists) {
        final data = premiumDoc.data();
        final expiresAt = (data?['expiresAt'] as Timestamp?)?.toDate();
        
        _isPremium = expiresAt != null && expiresAt.isAfter(DateTime.now());
        _expirationDate = expiresAt;
        
        // Também verifica licenças locais de desenvolvimento
        if (!_isPremium) {
          _isPremium = await _checkLocalLicense();
        }
      } else {
        // Verifica licenças locais de desenvolvimento
        _isPremium = await _checkLocalLicense();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao verificar status premium: $e');
      _isPremium = false;
      notifyListeners();
    }
  }
  
  Future<bool> _checkLocalLicense() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localLicense = prefs.getString('gasometer_local_license');
      
      if (localLicense != null) {
        final licenseData = DateTime.tryParse(localLicense);
        if (licenseData != null && licenseData.isAfter(DateTime.now())) {
          _expirationDate = licenseData;
          return true;
        } else {
          // Remove licença expirada
          await prefs.remove('gasometer_local_license');
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> purchaseProduct(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // TODO: Implementar RevenueCat quando disponível
      // Por enquanto simula uma compra bem-sucedida
      await Future.delayed(const Duration(seconds: 2));
      
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.isAnonymous) {
        final expirationDate = DateTime.now().add(const Duration(days: 365));
        
        // Salva no Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('subscriptions')
            .doc('premium')
            .set({
          'productId': productId,
          'purchasedAt': FieldValue.serverTimestamp(),
          'expiresAt': Timestamp.fromDate(expirationDate),
          'isActive': true,
          'platform': defaultTargetPlatform.name,
          'app': 'gasometer',
        });
        
        _isPremium = true;
        _expirationDate = expirationDate;
        
        // Log evento de compra
        await _logPurchaseEvent(productId);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro na compra: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> restorePurchases() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // TODO: Implementar RestorePurchases do RevenueCat
      await _checkPremiumStatus();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao restaurar compras: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> _logPurchaseEvent(String productId) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return;
      
      await _firestore.collection('purchase_events').add({
        'userId': user.uid,
        'productId': productId,
        'timestamp': FieldValue.serverTimestamp(),
        'app': 'gasometer',
        'platform': defaultTargetPlatform.name,
      });
    } catch (e) {
      debugPrint('Erro ao logar evento de compra: $e');
    }
  }
  
  // Método para desenvolvimento - gerar licença local
  Future<void> generateLocalLicense({int days = 30}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expirationDate = DateTime.now().add(Duration(days: days));
      
      await prefs.setString(
        'gasometer_local_license',
        expirationDate.toIso8601String(),
      );
      
      _isPremium = true;
      _expirationDate = expirationDate;
      notifyListeners();
      
      debugPrint('Licença local gerada. Expira em: ${expirationDate.toString()}');
    } catch (e) {
      debugPrint('Erro ao gerar licença local: $e');
    }
  }
  
  // Método para desenvolvimento - revogar licença local
  Future<void> revokeLocalLicense() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('gasometer_local_license');
      
      await _checkPremiumStatus(); // Recheck status
      
      debugPrint('Licença local revogada');
    } catch (e) {
      debugPrint('Erro ao revogar licença local: $e');
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Métodos para verificar funcionalidades específicas do GasOMeter
  bool canAddUnlimitedVehicles() => isPremium;
  bool canAccessAdvancedReports() => isPremium;
  bool canExportData() => isPremium;
  bool canUseCustomCategories() => isPremium;
  bool canAccessPremiumThemes() => isPremium;
  bool canBackupToCloud() => isPremium;
  bool canUseLocationHistory() => isPremium;
  bool canAccessAdvancedAnalytics() => isPremium;
  
  // Verifica se uma funcionalidade específica está disponível
  bool hasFeature(String featureId) {
    if (!isPremium) return false;
    
    // Lista de features premium do GasOMeter
    const premiumFeatures = [
      'unlimited_vehicles',
      'advanced_reports',
      'export_data',
      'custom_categories',
      'premium_themes',
      'cloud_backup',
      'location_history',
      'advanced_analytics',
      'cost_predictions',
      'maintenance_alerts',
      'fuel_price_alerts',
      'detailed_charts',
    ];
    
    return premiumFeatures.contains(featureId);
  }
  
  // Limites para usuários gratuitos
  int get maxVehicles => isPremium ? -1 : 2; // -1 = ilimitado
  int get maxFuelRecords => isPremium ? -1 : 50;
  int get maxMaintenanceRecords => isPremium ? -1 : 20;
  
  @override
  void dispose() {
    _authStream?.cancel();
    super.dispose();
  }
}