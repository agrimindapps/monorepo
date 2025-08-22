import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailParams {
  final String email;
  final String password;

  SignInWithEmailParams({
    required this.email,
    required this.password,
  });
}

class SignInWithEmail implements UseCase<User, SignInWithEmailParams> {
  final AuthRepository repository;

  SignInWithEmail(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInWithEmailParams params) async {
    if (params.email.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Email é obrigatório'));
    }

    if (!_isValidEmail(params.email)) {
      return Left(ValidationFailure(message: 'Email inválido'));
    }

    if (params.password.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Senha é obrigatória'));
    }

    if (params.password.length < 6) {
      return Left(ValidationFailure(message: 'Senha deve ter pelo menos 6 caracteres'));
    }

    return await repository.signInWithEmail(params.email, params.password);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}

class SignUpWithEmailParams {
  final String email;
  final String password;
  final String? name;

  SignUpWithEmailParams({
    required this.email,
    required this.password,
    this.name,
  });
}

class SignUpWithEmail implements UseCase<User, SignUpWithEmailParams> {
  final AuthRepository repository;

  SignUpWithEmail(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpWithEmailParams params) async {
    if (params.email.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Email é obrigatório'));
    }

    if (!_isValidEmail(params.email)) {
      return Left(ValidationFailure(message: 'Email inválido'));
    }

    if (params.password.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Senha é obrigatória'));
    }

    if (params.password.length < 6) {
      return Left(ValidationFailure(message: 'Senha deve ter pelo menos 6 caracteres'));
    }

    if (params.name != null && params.name!.trim().length < 2) {
      return Left(ValidationFailure(message: 'Nome deve ter pelo menos 2 caracteres'));
    }

    return await repository.signUpWithEmail(params.email, params.password, params.name);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}

class SignInWithGoogle implements UseCase<User, NoParams> {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.signInWithGoogle();
  }
}

class SignInWithApple implements UseCase<User, NoParams> {
  final AuthRepository repository;

  SignInWithApple(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.signInWithApple();
  }
}

class SignInWithFacebook implements UseCase<User, NoParams> {
  final AuthRepository repository;

  SignInWithFacebook(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.signInWithFacebook();
  }
}

class SignOut implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SignOut(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.signOut();
  }
}

class GetCurrentUser implements UseCase<User?, NoParams> {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, User?>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}

class SendEmailVerification implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SendEmailVerification(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.sendEmailVerification();
  }
}

class SendPasswordResetEmail implements UseCase<void, String> {
  final AuthRepository repository;

  SendPasswordResetEmail(this.repository);

  @override
  Future<Either<Failure, void>> call(String email) async {
    if (email.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Email é obrigatório'));
    }

    if (!_isValidEmail(email)) {
      return Left(ValidationFailure(message: 'Email inválido'));
    }

    return await repository.sendPasswordResetEmail(email);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}

class UpdateProfileParams {
  final String? name;
  final String? photoUrl;

  UpdateProfileParams({
    this.name,
    this.photoUrl,
  });
}

class UpdateProfile implements UseCase<User, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    if (params.name != null && params.name!.trim().length < 2) {
      return Left(ValidationFailure(message: 'Nome deve ter pelo menos 2 caracteres'));
    }

    return await repository.updateProfile(params.name, params.photoUrl);
  }
}

class DeleteAccount implements UseCase<void, NoParams> {
  final AuthRepository repository;

  DeleteAccount(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.deleteAccount();
  }
}