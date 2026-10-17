import '../../../domain/models/member.dart';
import '../../../utils/result.dart';

abstract class UserRepository {
  /// Usuário autenticado na sessão.
  Future<Result<Member>> getCurrentUser();

  /// Pessoas que podem ser atribuídas a tarefas.
  Future<Result<List<Member>>> getMembers();
}
