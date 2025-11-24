import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_validation_service.dart';

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
  final AuthValidationService validationService;

  SignInWithEmail(this.repository, this.validationService);

  @override
  Future<Either<Failure, User>> call(SignInWithEmailParams params) async {
    final validation = validationService.validateSignInCredentials(
      params.email,
      params.password,
    );

    return validation.fold(
      (failure) => Left(failure),
      (credentials) => repository.signInWithEmail(
        credentials.email,
        credentials.password,
      ),
    );
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
  final AuthValidationService validationService;

  SignUpWithEmail(this.repository, this.validationService);

  @override
  Future<Either<Failure, User>> call(SignUpWithEmailParams params) async {
    final validation = validationService.validateSignUpCredentials(
      params.email,
      params.password,
      params.name,
    );

    return validation.fold(
      (failure) => Left(failure),
      (credentials) => repository.signUpWithEmail(
        credentials.email,
        credentials.password,
        credentials.name,
      ),
    );
  }
}

class SignInWithGoogle implements UseCase<User, NoParams> {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return repository.signInWithGoogle();
  }
}

class SignInWithApple implements UseCase<User, NoParams> {
  final AuthRepository repository;

  SignInWithApple(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return repository.signInWithApple();
  }
}

class SignInWithFacebook implements UseCase<User, NoParams> {
  final AuthRepository repository;

  SignInWithFacebook(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return repository.signInWithFacebook();
  }
}

class SignInAnonymously implements UseCase<User, NoParams> {
  final AuthRepository repository;

  SignInAnonymously(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return repository.signInAnonymously();
  }
}

class SignOut implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SignOut(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return repository.signOut();
  }
}

class GetCurrentUser implements UseCase<User?, NoParams> {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, User?>> call(NoParams params) async {
    return repository.getCurrentUser();
  }
}

class SendEmailVerification implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SendEmailVerification(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return repository.sendEmailVerification();
  }
}

class SendPasswordResetEmail implements UseCase<void, String> {
  final AuthRepository repository;
  final AuthValidationService validationService;

  SendPasswordResetEmail(this.repository, this.validationService);

  @override
  Future<Either<Failure, void>> call(String email) async {
    final validation = validationService.validateEmail(email);

    return validation.fold(
      (failure) => Left(failure),
      (validEmail) => repository.sendPasswordResetEmail(validEmail),
    );
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
  final AuthValidationService validationService;

  UpdateProfile(this.repository, this.validationService);

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    if (params.name != null && params.name!.isNotEmpty) {
      final nameValidation = validationService.validateName(params.name!);
      if (nameValidation.isLeft()) {
        return nameValidation.fold(
          (failure) => Left(failure),
          (_) => throw UnimplementedError(),
        );
      }
    }

    return repository.updateProfile(params.name, params.photoUrl);
  }
}

class DeleteAccount implements UseCase<void, NoParams> {
  final AuthRepository repository;

  DeleteAccount(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return repository.deleteAccount();
  }
}
