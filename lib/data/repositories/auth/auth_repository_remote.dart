import 'dart:async';

import 'package:pocketbase/pocketbase.dart';

import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import '../../services/api/api_exception.dart';
import 'auth_repository.dart';

/// Sessão autenticada no servidor do TaskFlow.
///
/// O token fica salvo no navegador, então a sessão continua após recarregar
/// a página até expirar ou o usuário sair.
class AuthRepositoryRemote extends AuthRepository {
  AuthRepositoryRemote({required ApiClient apiClient}) : _api = apiClient {
    _subscription = _api.authChanges.listen((_) => notifyListeners());
  }

  final ApiClient _api;
  late final StreamSubscription<AuthStoreEvent> _subscription;

  @override
  bool get isAuthenticated => _api.isAuthenticated;

  /// Valida a sessão salva. Token expirado ou conta desativada encerram a
  /// sessão; falhas de rede mantêm o usuário conectado.
  Future<void> restoreSession() async {
    if (!_api.isAuthenticated) return;
    final result = await _api.authRefresh();
    if (result case Error(error: ApiException(:final statusCode))) {
      if (statusCode >= 400 && statusCode < 500) _api.clearSession();
    }
  }

  @override
  Future<Result<bool>> needsSetup() async {
    final result = await _api.send('/api/taskflow/setup');
    return switch (result) {
      Ok(:final value) => Result.ok(value['needsSetup'] == true),
      Error(:final error) => Result.error(error),
    };
  }

  @override
  Future<Result<void>> setup({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _api.send(
      '/api/taskflow/setup',
      method: 'POST',
      body: {'name': name.trim(), 'email': email.trim(), 'password': password},
    );
    if (result case Error(:final error)) return Result.error(error);
    return login(email: email, password: password);
  }

  @override
  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    final result = await _api.authWithPassword(email.trim(), password);
    return switch (result) {
      Ok() => const Result.ok(null),
      Error(error: ApiException(statusCode: 400)) => Result.error(
        ApiException('E-mail ou senha incorretos.', statusCode: 400),
      ),
      Error(error: ApiException(statusCode: 403)) => Result.error(
        ApiException(
          'Esta conta está desativada. Fale com um administrador.',
          statusCode: 403,
        ),
      ),
      Error(:final error) => Result.error(error),
    };
  }

  @override
  Future<Result<void>> logout() async {
    _api.clearSession();
    return const Result.ok(null);
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
