import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// Dados do primeiro administrador, informados na configuração inicial.
typedef SetupData = ({String name, String email, String password});

/// Dados de acesso informados na tela de login.
typedef Credentials = ({String identity, String password});

/// Login e configuração inicial do servidor.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required this._authRepository}) {
    checkSetup = Command0(_checkSetup)..execute();
    login = Command1(_login);
    setup = Command1(_setup);
  }

  final AuthRepository _authRepository;

  /// Descobre se o servidor ainda não tem contas cadastradas.
  late final Command0<bool> checkSetup;
  late final Command1<void, Credentials> login;
  late final Command1<void, SetupData> setup;

  bool _needsSetup = false;

  /// Exibe o formulário de criação do primeiro administrador.
  bool get needsSetup => _needsSetup;

  Future<Result<bool>> _checkSetup() async {
    final result = await _authRepository.needsSetup();
    if (result case Ok(:final value)) {
      _needsSetup = value;
      notifyListeners();
    }
    return result;
  }

  Future<Result<void>> _login(Credentials credentials) => _authRepository.login(
    identity: credentials.identity,
    password: credentials.password,
  );

  Future<Result<void>> _setup(SetupData data) => _authRepository.setup(
    name: data.name,
    email: data.email,
    password: data.password,
  );
}
