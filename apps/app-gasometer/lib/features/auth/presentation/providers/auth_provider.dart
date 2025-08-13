import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/platform_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final AnalyticsService _analytics = AnalyticsService();
  final PlatformService _platformService = PlatformService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;
  bool _isPremium = false;
  StreamSubscription<User?>? _userSubscription;
  
  AuthProvider({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _initializeAuthState();
  }
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isPremium => _isPremium;
  bool get isAnonymous => _currentUser?.isAnonymous ?? false;
  
  void _initializeAuthState() {
    _userSubscription = _firebaseAuth.authStateChanges().listen(
      (user) async {
        _currentUser = user;
        
        // Se há usuário (incluindo anônimo), marca como inicializado
        if (user != null) {
          _isInitialized = true;
          
          // Se é usuário anônimo, apenas notifica
          if (user.isAnonymous) {
            debugPrint('🔐 Usuário anônimo já autenticado: ${user.uid}');
            _isPremium = false;
            notifyListeners();
            return;
          }
          
          // Sincroniza dados do usuário quando não é anônimo
          await _syncUserData();
          await _checkPremiumStatus();
          // Configurar usuário no analytics
          await _analytics.setUserId(user.uid);
          await _analytics.setUserProperties({
            'user_type': 'authenticated',
            'is_premium': _isPremium.toString(),
          });
        } else {
          // Se não há usuário e deve usar modo anônimo, inicializa anonimamente
          if (await shouldUseAnonymousMode()) {
            debugPrint('🔐 Iniciando modo anônimo automaticamente');
            await signInAnonymously();
            return;
          }
          _isInitialized = true;
          _isPremium = false;
        }
        
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isInitialized = true;
        notifyListeners();
      },
    );
  }
  
  Future<void> _syncUserData() async {
    if (_currentUser == null) return;
    
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      
      if (!userDoc.exists) {
        // Criar documento do usuário se não existe
        await _firestore.collection('users').doc(_currentUser!.uid).set({
          'email': _currentUser!.email,
          'displayName': _currentUser!.displayName,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'isAnonymous': false,
          'appVersion': 'gasometer_1.0.0',
        });
      } else {
        // Atualizar último login
        await _firestore.collection('users').doc(_currentUser!.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar dados do usuário: $e');
    }
  }
  
  Future<void> _checkPremiumStatus() async {
    if (_currentUser == null) return;
    
    try {
      final premiumDoc = await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('subscriptions')
          .doc('premium')
          .get();
      
      if (premiumDoc.exists) {
        final data = premiumDoc.data();
        final expiresAt = (data?['expiresAt'] as Timestamp?)?.toDate();
        _isPremium = expiresAt != null && expiresAt.isAfter(DateTime.now());
      } else {
        _isPremium = false;
      }
    } catch (e) {
      debugPrint('Erro ao verificar status premium: $e');
      _isPremium = false;
    }
  }
  
  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
  
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _currentUser = credential.user;
      
      // Log analytics
      await _analytics.logLogin('email');
      await _analytics.logUserAction('login_success', parameters: {
        'method': 'email',
      });
      
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro inesperado: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> register(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        await credential.user!.reload();
        _currentUser = _firebaseAuth.currentUser;
      }
      
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro inesperado: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> signInAnonymously() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      debugPrint('🔐 Iniciando login anônimo...');
      final credential = await _firebaseAuth.signInAnonymously();
      _currentUser = credential.user;
      debugPrint('🔐 Usuário anônimo criado: ${_currentUser?.uid}');
      _isLoading = false;
      
      // Salvar preferência de modo anônimo
      await _saveAnonymousPreference();
      
      // Log analytics para modo anônimo
      await _analytics.logAnonymousSignIn();
      await _analytics.setUserProperties({
        'user_type': 'anonymous',
        'is_premium': 'false',
      });
      
      debugPrint('🔐 Usuário logado anonimamente. isAuthenticated: $isAuthenticated');
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      debugPrint('🔐 Erro Firebase: ${e.code} - ${e.message}');
      _errorMessage = _getFirebaseErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('🔐 Erro inesperado: $e');
      _errorMessage = 'Erro inesperado: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Log analytics antes do logout
      await _analytics.logLogout();
      
      await _firebaseAuth.signOut();
      _currentUser = null;
      _isPremium = false;
      _isLoading = false;
      
      debugPrint('🔐 Usuário deslogado');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao fazer logout: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _saveAnonymousPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('use_anonymous_mode', true);
    } catch (e) {
      debugPrint('Erro ao salvar preferência anônima: $e');
    }
  }
  
  Future<bool> shouldUseAnonymousMode() async {
    try {
      // Se for mobile (Android/iOS), usar modo anônimo por padrão
      if (_platformService.shouldUseAnonymousByDefault) {
        final prefs = await SharedPreferences.getInstance();
        // Retorna true por padrão para mobile, ou a preferência salva se existir
        return prefs.getBool('use_anonymous_mode') ?? true;
      }
      
      // Para outras plataformas (web/desktop), só usar se explicitamente habilitado
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('use_anonymous_mode') ?? false;
    } catch (e) {
      // Em caso de erro, usar modo anônimo se for mobile
      return _platformService.shouldUseAnonymousByDefault;
    }
  }
  
  Future<void> initializeAnonymousIfNeeded() async {
    if (!isAuthenticated && await shouldUseAnonymousMode()) {
      await signInAnonymously();
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado. Verifique o email digitado.';
      case 'wrong-password':
        return 'Senha incorreta. Tente novamente.';
      case 'email-already-in-use':
        return 'Este email já está sendo usado por outra conta.';
      case 'weak-password':
        return 'A senha é muito fraca. Use pelo menos 6 caracteres.';
      case 'invalid-email':
        return 'Email inválido. Verifique o formato digitado.';
      case 'too-many-requests':
        return 'Muitas tentativas de login. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet.';
      default:
        return 'Erro de autenticação: $code';
    }
  }
}