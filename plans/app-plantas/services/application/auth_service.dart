// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/models/auth_models.dart';
import '../../../core/services/auth_navigation_service.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../models/user_model.dart';
import '../../pages/web/login_page.dart';

class AuthService extends GetxService {
  static AuthService get instance => Get.find<AuthService>();

  final FirebaseAuthService _firebaseAuth = FirebaseAuthService();
  final AuthNavigationService _navigationService = AuthNavigationService();
  final _currentUser = Rx<UserModel?>(null);
  final _isLoading = false.obs;

  UserModel? get currentUser => _currentUser.value;
  Rx<UserModel?> get currentUserStream => _currentUser;
  bool get isLoggedIn => _currentUser.value?.isLoggedIn ?? false;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _firebaseAuth.authStateChanges.listen((AuthUser? authUser) {
      if (authUser != null) {
        _currentUser.value = _convertAuthUserToUserModel(authUser);
      } else {
        _currentUser.value = null;
      }
    });
  }

  UserModel _convertAuthUserToUserModel(AuthUser authUser) {
    return UserModel(
      id: authUser.id,
      nome: authUser.displayName,
      email: authUser.email,
      criadoEm: authUser.createdAt,
      isPremium:
          false, // TODO: Implementar verificação de premium via Firestore
    );
  }

  Future<void> _loadUserFromStorage() async {
    try {
      _isLoading.value = true;

      // Verificar se há usuário logado no Firebase
      final currentAuthUser = _firebaseAuth.currentUser;
      if (currentAuthUser != null) {
        _currentUser.value = _convertAuthUserToUserModel(currentAuthUser);
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar usuário: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> login(String email, String senha) async {
    try {
      _isLoading.value = true;

      final result =
          await _firebaseAuth.signInWithEmailAndPassword(email, senha);

      if (result.success && result.user != null) {
        _currentUser.value = _convertAuthUserToUserModel(result.user!);

        Get.snackbar(
          'Sucesso',
          'Login realizado com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF20B2AA),
          colorText: Colors.white,
        );

        // Navegar para a home do app-plantas
        _navigationService.navigateToModuleHome(ModuleAuthConfig.plantas);

        return true;
      } else {
        Get.snackbar(
          'Erro',
          result.errorMessage ?? 'Erro ao fazer login',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro inesperado ao fazer login: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> register(String nome, String email, String senha) async {
    try {
      _isLoading.value = true;

      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
        displayName: nome,
      );

      if (result.success && result.user != null) {
        _currentUser.value = _convertAuthUserToUserModel(result.user!);

        Get.snackbar(
          'Sucesso',
          'Conta criada com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF20B2AA),
          colorText: Colors.white,
        );

        // Navegar para a home do app-plantas
        _navigationService.navigateToModuleHome(ModuleAuthConfig.plantas);

        return true;
      } else {
        Get.snackbar(
          'Erro',
          result.errorMessage ?? 'Erro ao criar conta',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro inesperado ao criar conta: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading.value = true;

      await _firebaseAuth.signOut();

      // O listener do authStateChanges já vai definir _currentUser como null

      Get.snackbar(
        'Logout',
        'Você foi desconectado com sucesso',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey[600],
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('❌ Erro ao fazer logout: $e');
      Get.snackbar(
        'Erro',
        'Erro ao fazer logout: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateUserPremiumStatus(bool isPremium) async {
    if (_currentUser.value != null) {
      _currentUser.value = _currentUser.value!.copyWith(isPremium: isPremium);
      // TODO: Implementar salvamento da informação de premium no Firestore
    }
  }

  void navegarParaLogin() {
    // Importar a página de login e navegar diretamente
    Get.to(() => const LoginPage());
  }

  Future<bool> mostrarDialogoLogout() async {
    return await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Confirmar Logout'),
            content: const Text('Tem certeza que deseja sair da sua conta?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sair'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
