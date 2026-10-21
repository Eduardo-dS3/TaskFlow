import '../../../domain/models/member.dart';
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
      _service.upsertMember(_copy(user, name: name.trim(), role: role.trim())),
    );
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async => const Result.ok(null);

  @override
  Future<Result<void>> markPresence() async {
    _service.upsertMember(_copy(_service.currentUser, lastSeen: _service.now));
    return const Result.ok(null);
  }

  @override
  Future<Result<Member>> createMember(NewMember data) async {
    final exists = _service.members.any(
      (m) => m.email.toLowerCase() == data.email.trim().toLowerCase(),
    );
    if (exists) return Result.error(Exception('E-mail já cadastrado'));
    final member = Member(
      id: _service.newId('u'),
      name: data.name.trim(),
      role: data.role.trim(),
      email: data.email.trim(),
      isAdmin: data.isAdmin,
      weeklyCapacity: data.weeklyCapacity,
    );
    return Result.ok(_service.upsertMember(member));
  }

  @override
  Future<Result<Member>> updateMember(Member member) async {
    if (_service.findMember(member.id) == null) {
      return Result.error(Exception('Pessoa não encontrada'));
    }
    return Result.ok(_service.upsertMember(member));
  }

  @override
  Future<Result<void>> resetPassword(
    String memberId,
    String newPassword,
  ) async => const Result.ok(null);

  static Member _copy(
    Member member, {
    String? name,
    String? role,
    DateTime? lastSeen,
  }) => Member(
    id: member.id,
    name: name ?? member.name,
    role: role ?? member.role,
    email: member.email,
    isAdmin: member.isAdmin,
    active: member.active,
    weeklyCapacity: member.weeklyCapacity,
    lastSeen: lastSeen ?? member.lastSeen,
  );
}
