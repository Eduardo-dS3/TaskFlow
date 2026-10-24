import 'package:flutter/foundation.dart';

import '../../../utils/result.dart';

/// Sessão do usuário.
///
/// Notifica os ouvintes (como o roteador) sempre que o usuário entra ou sai.
abstract class AuthRepository extends ChangeNotifier {
  bool get isAuthenticated;

  /// Indica se o servidor ainda não tem nenhuma conta cadastrada.
  Future<Result<bool>> needsSetup();

  /// Cria o primeiro administrador e já inicia a sessão com ele.
  Future<Result<void>> setup({
    required String name,
    required String email,
    required String password,
  });

  /// Entra com o e-mail ou o nome de usuário ([identity]) e a senha.
  Future<Result<void>> login({
    required String identity,
    required String password,
  });

  Future<Result<void>> logout();
}
