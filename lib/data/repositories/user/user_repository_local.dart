import 'dart:async';

import '../../../domain/models/member.dart';
import '../../../domain/models/team_rules.dart';
import '../../../utils/result.dart';
import '../../services/local/local_data_service.dart';
import 'user_repository.dart';

/// Implementação de [UserRepository] em memória (demonstração e testes).
///
/// Senhas não são verificadas: o modo de demonstração não tem login real.
class UserRepositoryLocal implements UserRepository {
  UserRepositoryLocal({required LocalDataService localDataService})
    : _service = localDataService;

  final LocalDataService _service;
  final _changes = StreamController<Member>.broadcast();

  @override
  Stream<Member> get currentUserChanges => _changes.stream;

  Member _save(Member member) {
    _service.upsertMember(member);
    if (member.id == _service.currentUser.id) _changes.add(member);
    return member;
  }

  @override
  Future<Result<Member>> getCurrentUser() async =>
      Result.ok(_service.currentUser);

  @override
  Future<Result<List<Member>>> getMembers() async =>
      Result.ok(_service.members);

  @override
  Future<Result<Member>> updateProfile({
    required String name,
    required String role,
  }) async {
    if (name.trim().isEmpty) {
      return Result.error(Exception('O nome é obrigatório'));
    }
    final user = _service.currentUser;
    return Result.ok(
      _save(user.copyWith(name: name.trim(), role: role.trim())),
    );
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async => const Result.ok(null);

  @override
  Future<Result<void>> markPresence() async {
    _service.upsertMember(
      _service.currentUser.copyWith(lastSeen: _service.now),
    );
    return const Result.ok(null);
  }

  @override
  Future<Result<Member>> createMember(NewMember data) async {
    final email = data.email.trim().toLowerCase();
    final username = data.username.trim().toLowerCase();
    final exists = _service.members.any(
      (m) =>
          m.email.toLowerCase() == email ||
          (username.isNotEmpty && m.username.toLowerCase() == username),
    );
    if (exists) {
      return Result.error(Exception('E-mail ou usuário já cadastrado'));
    }
    final member = Member(
      id: _service.newId('u'),
      name: data.name.trim(),
      role: data.role.trim(),
      email: data.email.trim(),
      username: data.username.trim(),
      isAdmin: data.isAdmin,
      weeklyCapacity: data.weeklyCapacity,
    );
    return Result.ok(_save(member));
  }

  @override
  Future<Result<Member>> updateMember(Member member) async {
    if (_service.findMember(member.id) == null) {
      return Result.error(Exception('Pessoa não encontrada'));
    }
    if (!keepsActiveAdmin(_service.members, member)) {
      return Result.error(Exception(lastAdminMessage));
    }
    return Result.ok(_save(member));
  }

  @override
  Future<Result<void>> resetPassword(
    String memberId,
    String newPassword,
  ) async => const Result.ok(null);
}
