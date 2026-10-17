import 'package:flutter/foundation.dart';

import '../../../data/repositories/user/user_repository.dart';
import '../../../domain/models/member.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// Estado da moldura do app (usuário logado, notificações, sincronização).
class ShellViewModel extends ChangeNotifier {
  ShellViewModel({required this._userRepository}) {
    load = Command0(_load)..execute();
  }

  final UserRepository _userRepository;

  late final Command0<void> load;

  Member? _user;
  Member? get user => _user;

  bool _hasNotifications = true;
  bool get hasNotifications => _hasNotifications;

  /// Indica se os dados locais estão sincronizados com o servidor.
  bool get synced => true;

  void markNotificationsAsRead() {
    _hasNotifications = false;
    notifyListeners();
  }

  Future<Result<void>> _load() async {
    final result = await _userRepository.getCurrentUser();
    switch (result) {
      case Ok():
        _user = result.value;
      case Error():
        debugPrint('Falha ao carregar usuário: ${result.error}');
    }
    notifyListeners();
    return result;
  }
}
