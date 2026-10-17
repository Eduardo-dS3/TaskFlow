import '../../../domain/models/member.dart';
import '../../../utils/result.dart';
import '../../services/local/local_data_service.dart';
import 'user_repository.dart';

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
}
