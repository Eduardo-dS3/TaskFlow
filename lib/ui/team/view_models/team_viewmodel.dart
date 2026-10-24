import 'package:flutter/foundation.dart';

import '../../../data/repositories/user/user_repository.dart';
import '../../../domain/models/member.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// Nova senha definida por um administrador para outra pessoa.
typedef PasswordReset = ({Member member, String password});

/// Gestão da equipe (somente administradores).
class TeamViewModel extends ChangeNotifier {
  TeamViewModel({required this._userRepository, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    load = Command0(_load)..execute();
    createMember = Command1(_createMember);
    updateMember = Command1(_updateMember);
    resetPassword = Command1(_resetPassword);
    toggleActive = Command1(_toggleActive);
  }

  final UserRepository _userRepository;
  final DateTime Function() _clock;

  late final Command0<void> load;
  late final Command1<void, NewMember> createMember;
  late final Command1<void, Member> updateMember;
  late final Command1<void, PasswordReset> resetPassword;

  /// Desativa uma conta ativa ou reativa uma desativada.
  late final Command1<void, Member> toggleActive;

  DateTime get now => _clock();

  Member? _currentUser;
  Member? get currentUser => _currentUser;

  bool get isAdmin => _currentUser?.isAdmin ?? false;

  List<Member> _members = [];

  /// Pessoas ativas primeiro, depois em ordem alfabética.
  List<Member> get members => [..._members]
    ..sort((a, b) {
      if (a.active != b.active) return a.active ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

  int get activeCount => _members.where((m) => m.active).length;

  /// O administrador não altera o próprio acesso (evita se trancar fora).
  bool isSelf(Member member) => member.id == _currentUser?.id;

  Future<Result<void>> _load() async {
    final results = await (
      _userRepository.getCurrentUser(),
      _userRepository.getMembers(),
    ).wait;
    switch (results) {
      case (Ok(value: final user), Ok(value: final members)):
        _currentUser = user;
        _members = members;
        notifyListeners();
        return const Result.ok(null);
      case (Error(:final error), _) || (_, Error(:final error)):
        notifyListeners();
        return Result.error(error);
    }
  }

  /// Executa uma alteração e, se der certo, recarrega a equipe.
  Future<Result<void>> _mutate(Future<Result<Object?>> action) async {
    final result = await action;
    if (result case Error(:final error)) return Result.error(error);
    return _load();
  }

  Future<Result<void>> _createMember(NewMember data) =>
      _mutate(_userRepository.createMember(data));

  Future<Result<void>> _updateMember(Member member) =>
      _mutate(_userRepository.updateMember(member));

  Future<Result<void>> _resetPassword(PasswordReset data) =>
      _userRepository.resetPassword(data.member.id, data.password);

  Future<Result<void>> _toggleActive(Member member) => _mutate(
    _userRepository.updateMember(member.copyWith(active: !member.active)),
  );
}
