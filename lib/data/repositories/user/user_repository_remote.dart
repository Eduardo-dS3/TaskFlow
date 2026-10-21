import 'package:pocketbase/pocketbase.dart';

import '../../../domain/models/member.dart';
import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import '../../services/api/mappers/member_mappers.dart';
import '../../services/api/mappers/record_utils.dart';
import 'user_repository.dart';

/// Implementação de [UserRepository] no servidor (coleção `users`).
class UserRepositoryRemote implements UserRepository {
  UserRepositoryRemote({required ApiClient apiClient}) : _api = apiClient;

  static const _users = ApiClient.usersCollection;

  final ApiClient _api;

  Future<Result<Member>> _member(Future<Result<RecordModel>> request) async {
    final result = await request;
    return switch (result) {
      Ok(:final value) => Result.ok(memberFromRecord(value)),
      Error(:final error) => Result.error(error),
    };
  }

  @override
  Future<Result<Member>> getCurrentUser() {
    if (!_api.isAuthenticated) {
      return Future.value(Result.error(Exception('Nenhum usuário conectado')));
    }
    return _member(_api.getOne(_users, _api.authId));
  }

  @override
  Future<Result<List<Member>>> getMembers() async {
    final result = await _api.list(_users, sort: 'name');
    return switch (result) {
      Ok(:final value) => Result.ok([
        for (final r in value) memberFromRecord(r),
      ]),
      Error(:final error) => Result.error(error),
    };
  }

  @override
  Future<Result<Member>> updateProfile({
    required String name,
    required String role,
  }) => _member(
    _api.update(_users, _api.authId, {
      'name': name.trim(),
      'role': role.trim(),
    }),
  );

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final email = _api.authRecord?.getStringValue('email') ?? '';
    final result = await _api.update(_users, _api.authId, {
      'oldPassword': currentPassword,
      'password': newPassword,
      'passwordConfirm': newPassword,
    });
    if (result case Error(:final error)) return Result.error(error);
    // Trocar a senha invalida o token atual: entra de novo com a senha nova.
    final login = await _api.authWithPassword(email, newPassword);
    return switch (login) {
      Ok() => const Result.ok(null),
      Error(:final error) => Result.error(error),
    };
  }

  @override
  Future<Result<void>> markPresence() async {
    if (!_api.isAuthenticated) return const Result.ok(null);
    final result = await _api.update(_users, _api.authId, {
      'lastSeen': formatDate(DateTime.now()),
    });
    return switch (result) {
      Ok() => const Result.ok(null),
      Error(:final error) => Result.error(error),
    };
  }

  @override
  Future<Result<Member>> createMember(NewMember data) => _member(
    _api.create(_users, {
      'name': data.name.trim(),
      'email': data.email.trim(),
      'role': data.role.trim(),
      'password': data.password,
      'passwordConfirm': data.password,
      'isAdmin': data.isAdmin,
      'weeklyCapacity': data.weeklyCapacity,
      'active': true,
      'verified': true,
      'emailVisibility': true,
    }),
  );

  @override
  Future<Result<Member>> updateMember(Member member) =>
      _member(_api.update(_users, member.id, memberToBody(member)));

  @override
  Future<Result<void>> resetPassword(
    String memberId,
    String newPassword,
  ) async {
    final result = await _api.update(_users, memberId, {
      'password': newPassword,
      'passwordConfirm': newPassword,
    });
    return switch (result) {
      Ok() => const Result.ok(null),
      Error(:final error) => Result.error(error),
    };
  }
}
