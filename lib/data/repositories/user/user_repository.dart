import '../../../domain/models/member.dart';
import '../../../utils/result.dart';

/// Dados para cadastrar uma nova pessoa na equipe.
class NewMember {
  const NewMember({
    required this.name,
    required this.email,
    required this.role,
    required this.password,
    this.isAdmin = false,
    this.weeklyCapacity = 40,
  });

  final String name;
  final String email;
  final String role;
  final String password;
  final bool isAdmin;
  final double weeklyCapacity;
}

/// Fonte da verdade para a equipe e o perfil do usuário logado.
abstract class UserRepository {
  /// Usuário autenticado na sessão.
  Future<Result<Member>> getCurrentUser();

  /// Emite o usuário logado sempre que o perfil dele é alterado.
  Stream<Member> get currentUserChanges;

  /// Todas as pessoas da equipe, inclusive contas desativadas.
  Future<Result<List<Member>>> getMembers();

  /// Atualiza nome e cargo do próprio usuário.
  Future<Result<Member>> updateProfile({
    required String name,
    required String role,
  });

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Registra que o usuário está usando o app (indicador "online").
  Future<Result<void>> markPresence();

  /// Administração da equipe (apenas administradores).
  Future<Result<Member>> createMember(NewMember data);

  /// Atualiza nome, e-mail, cargo, permissões, status e capacidade.
  Future<Result<Member>> updateMember(Member member);

  Future<Result<void>> resetPassword(String memberId, String newPassword);
}
