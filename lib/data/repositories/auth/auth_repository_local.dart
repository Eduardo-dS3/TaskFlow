import '../../../utils/result.dart';
import 'auth_repository.dart';

/// Sessão do modo de demonstração: já começa autenticada e aceita qualquer
/// e-mail e senha.
class AuthRepositoryLocal extends AuthRepository {
  bool _authenticated = true;

  @override
  bool get isAuthenticated => _authenticated;

  @override
  Future<Result<bool>> needsSetup() async => const Result.ok(false);

  @override
  Future<Result<void>> setup({
    required String name,
    required String email,
    required String password,
  }) => login(identity: email, password: password);

  @override
  Future<Result<void>> login({
    required String identity,
    required String password,
  }) async {
    _authenticated = true;
    notifyListeners();
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> logout() async {
    _authenticated = false;
    notifyListeners();
    return const Result.ok(null);
  }
}
